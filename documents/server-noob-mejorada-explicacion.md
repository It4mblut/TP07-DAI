# Server Noob Mejorada — ¿Qué cambiamos y por qué?

> **Archivos**: `src/server-noob-mejorada.js` + `src/router/alumnos-router-noob.js` + `src/router/cursos-router-noob.js`
> **Cómo ejecutarlo**: `npm run server-noob-mejorada`
> **Prerequisito**: haber leído el análisis de `server-noob` (`server-noob-explicacion.md`)

Esta versión resuelve **3 problemas grandes** que encontramos en `server-noob.js`, sin cambiar los endpoints ni lo que hace la API. La funcionalidad es exactamente la misma — lo que cambia es **cómo está organizado el código por dentro**.

---

## 🔄 Resumen de cambios

| | server-noob | server-noob-mejorada |
|---|---|---|
| **Archivos** | 1 archivo de ~215 líneas | 3 archivos (26 + 137 + 42 líneas) |
| **Conexión a la DB** | `Client` — abre y cierra en cada request | `Pool` — reutiliza conexiones |
| **Organización** | Todo en un solo lugar | Separado por recurso (alumnos, cursos) |
| **`finally` block** | Necesario (y puede fallar) | No hace falta — el Pool se encarga |
| **Archivo principal** | ~215 líneas de lógica | ~26 líneas: solo setup y arranque |

---

## 🧩 Mejora 1: Separar en archivos con `Router`

### El problema que resolvemos

En `server-noob.js` teníamos **todo** en un solo archivo: la configuración de Express, los 5 endpoints de alumnos, los 2 de cursos, y el `app.listen`. Si mañana agregamos más entidades, ese archivo crece sin parar.

### ¿Cómo lo resolvimos?

Express tiene un mecanismo llamado **`Router`** que permite definir endpoints en archivos separados y después "enchufarlos" al servidor principal.

**Antes** (server-noob.js — todo junto):
```js
const app = express();

// ... 5 endpoints de alumnos directos en app ...
app.get('/api/alumnos/',    async (req, res) => { /* ... */ });
app.get('/api/alumnos/:id', async (req, res) => { /* ... */ });
app.post('/api/alumnos/',   async (req, res) => { /* ... */ });
// ... etc

// ... 2 endpoints de cursos directos en app ...
app.get('/api/cursos/',     async (req, res) => { /* ... */ });
app.get('/api/cursos/:id',  async (req, res) => { /* ... */ });

app.listen(port);
```

**Después** (server-noob-mejorada.js — solo configura y delega):
```js
import AlumnosRouter from "./router/alumnos-router-noob.js"
import CursosRouter  from "./router/cursos-router-noob.js"

const app = express();

app.use("/api/alumnos", AlumnosRouter);   // "todo lo de alumnos, manejalo vos"
app.use("/api/cursos",  CursosRouter);    // "todo lo de cursos, manejalo vos"

app.listen(port);
```

Y cada router define sus propios endpoints:

```js
// alumnos-router-noob.js
import { Router } from 'express';

const router = Router();

router.get('',     async (req, res) => { /* ... */ });   // ← sin "/api/alumnos"
router.get('/:id', async (req, res) => { /* ... */ });
router.post('',    async (req, res) => { /* ... */ });
// ...

export default router;
```

### ¿Qué ganamos?

- **El archivo principal queda limpio**: 26 líneas que dejan claro qué rutas maneja la API.
- **Cada archivo tiene una sola responsabilidad**: `alumnos-router-noob.js` solo sabe de alumnos, `cursos-router-noob.js` solo sabe de cursos.
- **Encontrás las cosas rápido**: si hay un bug en cursos, vas a `cursos-router-noob.js` y listo — no tenés que scrollear 200 líneas.
- **Menos conflictos en Git**: si un compañero toca alumnos y vos tocás cursos, cada uno modifica un archivo distinto.

> 💡 **Fijate que las rutas en el router no incluyen `/api/alumnos`**. Eso ya lo definimos en `server-noob-mejorada.js` con `app.use("/api/alumnos", AlumnosRouter)`. El router solo define la parte que viene **después**: `''` (raíz), `'/:id'`, etc. Express concatena ambas partes automáticamente.

---

## ⚡ Mejora 2: `Pool` en vez de `Client`

### El problema que resolvemos

En `server-noob.js`, **cada request** abría una conexión nueva a PostgreSQL y la cerraba al terminar. Eso es lento (20-100ms extra por request) y no escala.

### ¿Cómo lo resolvimos?

Cambiamos `Client` por `Pool`. El pool se crea **una sola vez** cuando arranca el archivo y se reutiliza en todos los endpoints:

**Antes** (server-noob.js — Client por request):
```js
import pkg from 'pg';
const { Client } = pkg;

app.get('/api/alumnos/', async (req, res) => {
    const client = new Client(config);    // creo conexión
    try {
        await client.connect();           // abro conexión
        const result = await client.query(sql);
        res.json(result.rows);
    } catch (error) {
        // ...
    } finally {
        await client.end();               // cierro conexión
    }
});
```

**Después** (alumnos-router-noob.js — Pool compartido):
```js
import pkg from 'pg';
const { Pool } = pkg;

const pool = new Pool(config);   // se crea UNA vez al arrancar

router.get('', async (req, res) => {
    try {
        const result = await pool.query(sql);   // usa una conexión del pool
        res.json(result.rows);
    } catch (error) {
        // ...
    }
    // no hay finally — el pool reutiliza la conexión solo
});
```

### ¿Qué ganamos?

- **Performance**: no hay overhead de conectar/desconectar en cada request.
- **Estabilidad bajo carga**: el pool limita las conexiones simultáneas (por defecto 10), así que no agotamos las 100 conexiones de PostgreSQL.
- **Menos código**: no necesitamos `connect()`, ni `end()`, ni `finally`. El pool se encarga de todo internamente.

---

## 🧹 Mejora 3: Se eliminó el `finally` problemático

### El problema que resolvemos

En `server-noob.js`, el bloque `finally` hacía `await client.end()` para cerrar la conexión. Pero si `client.connect()` había fallado (por ejemplo, PostgreSQL estaba apagado), llamar a `end()` sobre un cliente nunca conectado tiraba un error adicional que confundía:

```
Error: Called end on a client that was never connected
```

### ¿Cómo lo resolvimos?

Con `Pool`, directamente **no hay `finally`**. No tenemos que abrir ni cerrar conexiones manualmente — el pool las administra solo. Problema resuelto de raíz.

**Antes**:
```js
try {
    await client.connect();
    // ...
} catch (error) {
    // ...
} finally {
    await client.end();    // ← podía fallar si connect() falló
}
```

**Después**:
```js
try {
    const result = await pool.query(sql);   // el pool hace todo
    // ...
} catch (error) {
    // ...
}
// sin finally — nada que cerrar
```

> 💡 **Menos código = menos bugs.** Cada línea que escribís es una línea que puede fallar. Si podés resolver algo con menos código, generalmente es mejor.

---

## 📁 Estructura de archivos resultante

```
src/
├── server-noob.js                  ← versión vieja (todo junto, Client)
├── server-noob-mejorada.js         ← versión nueva (solo setup, 26 líneas)
├── router/
│   ├── alumnos-router-noob.js      ← endpoints de alumnos (Pool)
│   └── cursos-router-noob.js       ← endpoints de cursos (Pool)
└── configs/
    └── db-config.js                ← configuración de conexión (compartida)
```

---

## ⚠️ ¿Qué falta todavía?

Esta versión mejora la **organización** y la **performance**, pero todavía tiene cosas por resolver:

| Pendiente | Por qué importa |
|-----------|-----------------|
| No se valida el body | Se pueden crear alumnos sin nombre ni apellido |
| Credenciales hardcodeadas | `db-config.js` tiene user y password en el código |
| Puerto hardcodeado | No se puede cambiar sin tocar el fuente |
| SQL mezclado con la lógica del endpoint | Si mañana cambiamos de base de datos, hay que reescribir todos los routers |

Estos problemas los vamos a resolver en las versiones siguientes, cuando separemos en **capas** (controller → service → repository) y usemos **variables de entorno** (`.env`).

---

## 🧠 Para que te quede claro

```
server-noob.js                         server-noob-mejorada.js
┌─────────────────────────┐            ┌──────────────────────┐
│  imports                │            │  imports             │
│  middlewares            │            │  middlewares         │
│  GET /api/alumnos       │            │  app.use(alumnos)  ──────► alumnos-router-noob.js
│  GET /api/alumnos/:id   │            │  app.use(cursos)   ──────► cursos-router-noob.js
│  POST /api/alumnos      │            │  app.listen          │
│  PUT /api/alumnos/:id   │            └──────────────────────┘
│  DELETE /api/alumnos/:id│                    26 líneas
│  GET /api/cursos        │
│  GET /api/cursos/:id    │
│  app.listen             │
└─────────────────────────┘
       215 líneas
```

Las tres mejoras se resumen en: **separar** (Router), **reutilizar** (Pool), y **simplificar** (sin finally). La API funciona exactamente igual desde afuera — lo que cambió es que ahora el código está preparado para crecer.

---

## 🔗 Siguiente documento

Resolvimos la organización y la performance. Pero los endpoints todavía mezclan lógica HTTP, reglas de negocio y SQL en el mismo lugar. Eso lo separamos en capas: [Server con Capas — Controller, Service, Repository](server-capas-explicacion.md).
