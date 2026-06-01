# Server Noob — Análisis de la versión inicial

> **Archivo**: `src/server-noob.js`
> **Cómo ejecutarlo**: `npm run server-noob`

Esta es la primera versión de nuestra API. **Funciona**, pero tiene varios problemas de diseño que la hacen difícil de mantener y escalar. Vamos a analizarla para entender *qué* está mal y *por qué*, así en las próximas versiones la mejoramos paso a paso.

---

## 📦 ¿Qué hace este archivo?

Es un servidor Express que expone un CRUD completo de **alumnos** (5 endpoints) y un par de endpoints de **cursos** (2 endpoints), todo en un solo archivo de ~215 líneas.

### Endpoints que tiene

| Método | Ruta | Qué hace |
|--------|------|----------|
| GET | `/api/alumnos/` | Trae todos los alumnos |
| GET | `/api/alumnos/:id` | Trae un alumno por ID |
| POST | `/api/alumnos/` | Crea un alumno nuevo |
| PUT | `/api/alumnos/:id` | Modifica un alumno existente |
| DELETE | `/api/alumnos/:id` | Borra un alumno por ID |
| GET | `/api/cursos/` | Trae todos los cursos |
| GET | `/api/cursos/:id` | Trae un curso por ID |

---

## 🔍 Análisis del código

### Lo que está bien (y hay que reconocerlo)

Antes de criticar, veamos qué cosas sí están bien hechas:

1. **Usa `async/await` con `try/catch/finally`** — el patrón básico de manejo de errores asíncronos está correcto.

2. **Usa queries parametrizadas (`$1`, `$2`, etc.)** — esto previene inyección SQL. Si un alumno manda `'; DROP TABLE alumnos; --` como nombre, la query no se rompe porque `pg` lo escapa automáticamente. **Nunca armen queries concatenando strings** (`"SELECT * FROM alumnos WHERE id=" + id`), eso es una vulnerabilidad grave.

3. **Usa `http-status-codes`** — en vez de poner números mágicos como `200`, `201`, `404`, usa constantes legibles como `StatusCodes.OK`, `StatusCodes.CREATED`, `StatusCodes.NOT_FOUND`. Cualquier persona que lea el código entiende la intención sin tener que googlear "¿qué era el status 201?".

4. **Usa `RETURNING id` en el INSERT** — PostgreSQL permite devolver columnas del registro recién insertado. Así obtenemos el `id` auto-generado sin hacer un `SELECT` adicional.

5. **Separa la config de la base de datos en otro archivo** (`configs/db-config.js`) — al menos la conexión no está hardcodeada directamente en cada endpoint.

---

## 🚨 Problemas de esta versión

### Problema 1: Todo en un solo archivo — no escala

Hoy tenemos 7 endpoints y el archivo tiene ~215 líneas. Pensá qué pasa en una aplicación real:

- Agregar CRUD de `cursos` completo (POST, PUT, DELETE) → +100 líneas más
- Agregar endpoints para `grupos_pdp` → +150 líneas más
- Agregar endpoints para `alumnos_grupos_pdp` → +150 líneas más
- Agregar filtros, paginación, búsqueda → cada endpoint crece

Rápidamente tenés un archivo de **1000+ líneas** donde:
- Encontrar un endpoint específico es buscar una aguja en un pajar
- Si dos personas tocan el mismo archivo en Git, hay conflictos de merge constantes
- Es imposible saber de un vistazo "¿qué endpoints tiene la API de cursos?"

> 🤔 **Pregunta para pensar**: si un compañero te dice "el endpoint de crear alumno tiene un bug", ¿cuánto tardás en encontrarlo en un archivo de 1000 líneas vs. en un archivo `alumnos-router.js` de 130 líneas?

---

### Problema 2: Usa `Client` en vez de `Pool` — abre y cierra conexión en cada request

Este es el problema más importante de performance. Mirá lo que pasa en **cada** request:

```js
app.get('/api/alumnos/', async (req, res) => {
    const client = new Client(config);      // 1. Crea un cliente nuevo
    try {
        await client.connect();             // 2. Abre conexión a PostgreSQL
        const resultPg = await client.query(sql);
        res.status(StatusCodes.OK).json(resultPg.rows);
    } catch (error) {
        // ...
    } finally {
        await client.end();                 // 3. Cierra la conexión
    }
})
```

Cada vez que alguien llama a `/api/alumnos/`, el servidor:
1. **Crea** una conexión nueva a PostgreSQL
2. Ejecuta la query
3. **Destruye** la conexión

#### ¿Por qué es un problema?

Conectarse a PostgreSQL es **costoso** — implica:
- Abrir un socket TCP
- Hacer handshake de autenticación
- Negociar protocolo y encoding
- PostgreSQL crea un proceso nuevo en el servidor

Todo eso toma entre **20 y 100 milisegundos** por conexión. Si tu API recibe 100 requests por segundo, estás creando y destruyendo 100 conexiones por segundo. PostgreSQL tiene un límite de conexiones simultáneas (por defecto 100), así que bajo carga tu API **se cae**.

#### ¿Qué es mejor? → Pool

Un **Pool** (pileta de conexiones) crea un conjunto de conexiones al arrancar y las **reutiliza**:

```
CON CLIENT (lo que tenemos):
Request 1 → [crear conexión] → query → [cerrar conexión]
Request 2 → [crear conexión] → query → [cerrar conexión]
Request 3 → [crear conexión] → query → [cerrar conexión]
                  ↑ lento                     ↑ desperdicio

CON POOL (lo que queremos):
Arranque  → [crear 10 conexiones]
Request 1 → [tomar conexión del pool] → query → [devolver al pool]
Request 2 → [tomar conexión del pool] → query → [devolver al pool]
Request 3 → [tomar conexión del pool] → query → [devolver al pool]
                  ↑ instantáneo                     ↑ se reutiliza
```

| | Client | Pool |
|---|---|---|
| Conexiones | 1 nueva por request | Fijas, reutilizables |
| Velocidad | Lento (20-100ms overhead) | Rápido (sin overhead) |
| Bajo carga | Se cae | Funciona |
| `finally` | Necesitás `client.end()` | No hace falta cerrar nada |
| Código | Más largo (connect/end) | Más corto |
| Cuándo usar | Scripts que corren una vez | APIs y servidores |

> 💡 **Regla simple**: si tu programa se queda corriendo (como un servidor Express), usá **Pool**. Si tu programa corre una vez y termina (como un script de migración), usá **Client**.

---

### Problema 3: El `finally` puede fallar silenciosamente

```js
} finally {
    await client.end();    // ← ¿qué pasa si esto tira un error?
}
```

Si `client.connect()` falló (por ejemplo, PostgreSQL está apagado), el `client` nunca se conectó. Llamar a `client.end()` sobre un cliente no conectado puede tirar una excepción que **no se catchea** (el `catch` solo atrapa errores del `try`, no del `finally`).

Esto genera un error como:

```
Error: Called end on a client that was never connected
```

...que aparece en la consola y puede confundir al alumno.

---

### Problema 4: El PUT — ID en la URL y validación contra el body

En REST, la URL identifica **qué recurso** estás modificando. Por eso todos los endpoints que trabajan con un recurso específico llevan el ID en la URL:

```
GET    /api/alumnos/:id    ← "traeme el alumno 5"
DELETE /api/alumnos/:id    ← "borrá el alumno 5"
PUT    /api/alumnos/:id    ← "modificá el alumno 5"
```

Fijate cómo lo implementamos:

```js
app.put('/api/alumnos/:id', async (req, res) => {
    let id = parseInt(req.params.id);   // ID de la URL (fuente de verdad)
    let entity = req.body;

    // Si el body también trae un id, verificamos que coincida
    if (entity.id && parseInt(entity.id) !== id) {
        return res.status(StatusCodes.BAD_REQUEST)
            .send(`El id de la URL (${id}) no coincide con el id del body (${entity.id}).`);
    }
    // ...
    const values = [ id, /* ... */ ];   // Usamos el id de la URL, no del body
```

#### ¿Por qué validar URL contra body?

Imaginá este request:

```
PUT /api/alumnos/5
body: { "id": 99, "nombre": "Juan" }
```

¿Qué debería pasar? ¿Modificar el alumno 5 o el 99? Si no validamos, dependemos de cuál de los dos usemos en la query — eso genera bugs silenciosos. Con la validación, devolvemos un **400 Bad Request** claro que le dice al cliente "mandaste datos contradictorios".

> 💡 **La regla**: el ID de la URL es la **fuente de verdad**. El body puede incluirlo (por comodidad) pero si lo hace, tiene que coincidir. Si no lo incluye, no pasa nada — usamos el de la URL.

---

### Problema 5: No se valida nada del body

En el POST y PUT, si el alumno manda un body vacío `{}`, el código **no se queja**:

```js
const values = [
    entity?.nombre           ?? '',     // nombre vacío
    entity?.apellido         ?? '',     // apellido vacío
    entity?.id_curso         ?? 0,      // curso 0 (¿existe?)
    entity?.fecha_nacimiento ?? null,
    entity?.hace_deportes    ?? 0
];
```

El `??` (nullish coalescing) pone valores por defecto y la query se ejecuta. Resultado: se crea un alumno sin nombre, sin apellido, en un curso que no existe. La base de datos acepta cualquier cosa.

> ⚠️ **Esto no es un error de sintaxis** — el código funciona. Pero a nivel de negocio, ¿tiene sentido crear un alumno sin nombre? Más adelante vamos a ver cómo validar estos datos.

---

### Problema 6: Credenciales hardcodeadas en la config

El archivo `configs/db-config.js` tiene los datos de conexión escritos directamente en el código:

```js
const DBConfig = {
    host        : "localhost",
    database    : "DAI",
    user        : "postgres",
    password    : "root",
    port        : 5432
}
```

Esto está bien para empezar y para probar localmente, pero si subís esto a GitHub, cualquiera puede ver tu usuario y contraseña. En la versión con capas vamos a usar **variables de entorno** (archivo `.env`) para sacar las credenciales del código fuente.

---

### Problema 7: El puerto está hardcodeado

```js
const port = 3000;
```

Si necesitás correr la API en otro puerto (porque el 3000 ya está ocupado, o porque estás en producción), tenés que modificar el código. Más adelante vamos a leer el puerto desde una variable de entorno:

```js
const port = process.env.PORT || 3000;
```

---

### Problema 8: Código repetido en cada endpoint

Mirá cuántas veces se repite el mismo patrón:

```js
const client = new Client(config);
try {
    await client.connect();
    // ... la query cambia, pero todo lo demás es igual
} catch (error) {
    console.log(error);
    res.status(StatusCodes.INTERNAL_SERVER_ERROR).send(`Error: ` + error.message);
} finally {
    await client.end();
}
```

Ese bloque se repite **7 veces** en este archivo. Si mañana queremos cambiar cómo logeamos los errores (por ejemplo, guardarlos en un archivo en vez de `console.log`), hay que modificarlo en **7 lugares**. Eso viola el principio **DRY** (Don't Repeat Yourself).

---

## 📊 Resumen visual

```
server-noob.js (215 líneas, 1 solo archivo)
├── imports y config
├── middlewares (cors, json)
├── 5 endpoints de alumnos     ← todo mezclado
├── 2 endpoints de cursos      ← en el mismo archivo
├── SQL inline en cada endpoint
├── conexión Client en cada endpoint (lento)
└── app.listen
```

---

## 🚀 ¿Hacia dónde vamos?

En las próximas versiones vamos a resolver estos problemas **uno a la vez**:

| Versión | Qué mejoramos | Problema que resuelve |
|---------|---------------|----------------------|
| **server-noob-01** | Separar endpoints en archivos con `Router` + usar `Pool` | Problemas 1, 2, 3 y 8 — escalabilidad y performance |
| **server** (capas) | Arquitectura controller → service → repository, dotenv | Problemas 5, 6 y 7 — separación de responsabilidades |

> 💡 **La idea clave**: no es que `server-noob.js` esté "mal" — es que no está preparado para crecer. Funciona perfecto para 7 endpoints. Pero cuando una aplicación crece, necesitás organización. Y es más fácil organizar **desde el principio** que refactorizar después.

---

## 🔗 Siguiente documento

Ahora que sabemos qué problemas tiene esta versión, vamos a resolverlos paso a paso: [Server Noob Mejorada — Router + Pool](server-noob-mejorada-explicacion.md).
