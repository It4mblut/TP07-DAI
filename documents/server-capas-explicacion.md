# Server con Capas — Arquitectura Controller → Service → Repository

> **Archivos**: `src/server.js` + `src/controllers/` + `src/services/` + `src/repositories/`
> **Cómo ejecutarlo**: `npm run server`
> **Prerequisito**: haber leído los análisis de `server-noob` y `server-noob-mejorada`

En `server-noob-mejorada` resolvimos la organización (Router) y la performance (Pool). Pero los endpoints todavía mezclan **tres cosas distintas** en el mismo lugar: manejar el request HTTP, aplicar reglas de negocio, y hacer queries a la base de datos. Esta versión separa esas responsabilidades en **tres capas**.

---

## 🧩 ¿Qué son las capas y para qué sirven?

Imaginá un local de comidas rápidas (tipo McDonald's):

```
CLIENTE (Postman / navegador)
    │
    ▼
🖥️ CAJERO (Controller)                    → Recibe el pedido, lo pasa a la cocina, entrega la bandeja
    │
    ▼
👨‍🍳 COCINA (Service)                       → Sigue la receta, aplica las reglas, arma el pedido
    │
    ▼
📦 RESPONSABLE DEL DEPÓSITO (Repository)   → Sabe dónde están los ingredientes, los busca, los entrega
```

- El **cajero** no cocina — solo recibe el pedido del cliente, se lo pasa a la cocina, y cuando está listo lo entrega en la bandeja con el ticket. No sabe de recetas ni de ingredientes.
- La **cocina** no atiende al público ni va al depósito a buscar cosas — sigue las recetas y aplica las reglas. "Un Big Mac es: dos medallones, salsa especial, lechuga, queso, pepinos, cebolla, pan con sésamo". Si no hay pan integral, no se puede armar el combo Veggie. Si el pedido es un combo, hay que agregar papas y bebida. La cocina le **pide** al responsable del depósito lo que necesita.
- El **responsable del depósito** conoce exactamente dónde está cada cosa, cómo sacarla, cómo guardarla y cómo organizarla. No sabe de recetas ni de clientes — solo sabe buscar y entregar ingredientes cuando se los piden.

Si mañana cambiás de proveedor de ingredientes (de PostgreSQL a Supabase, por ejemplo), solo cambiás al responsable del depósito. La cocina y el cajero ni se enteran.

> 💡 **¿Por qué McDonald's y no un restaurante?** Porque en el fast food **todo está estandarizado**: pedidos fijos, recetas predecibles, ingredientes uniformes. Eso se parece más a una API: requests estandarizados, lógica predecible, datos uniformes.

---

## 📁 Estructura de archivos

```
src/
├── server.js                      ← Arranque: configura Express y conecta los controllers
├── controllers/
│   ├── alumnos-controller.js      ← Cajero: recibe HTTP requests, responde con status codes
│   └── cursos-controller.js
├── services/
│   ├── alumnos-service.js         ← Cocina: lógica de negocio (validaciones, cálculos)
│   └── cursos-service.js
├── repositories/
│   ├── alumnos-repository.js      ← Responsable del depósito: queries SQL contra PostgreSQL
│   └── cursos-repository.js
├── configs/
│   └── db-config.js               ← Configuración de conexión a la base de datos
└── helpers/
    └── log-helper.js              ← Utilidad para loguear errores (archivo + consola)
```

---

## 🔄 ¿Cómo fluye un request?

Supongamos que llega un `GET /api/alumnos/5`:

```
Postman
  │  GET /api/alumnos/5
  ▼
server.js                  →  app.use("/api/alumnos", AlumnosController)
  │
  ▼
alumnos-controller.js      →  router.get('/:id', ...)
  │                             Extrae id = 5 del req.params
  │                             Llama a currentService.getByIdAsync(5)
  ▼
alumnos-service.js         →  getByIdAsync(5)
  │                             Llama al repository para buscar el alumno
  │                             Le calcula la edad a partir de fecha_nacimiento
  │                             Devuelve el alumno con el campo "edad" agregado
  ▼
alumnos-repository.js      →  getByIdAsync(5)
  │                             Ejecuta: SELECT * FROM alumnos WHERE id=$1
  │                             Devuelve el row o null
  ▼
PostgreSQL
```

Fijate que **cada capa solo habla con la de abajo**. El controller no sabe de SQL, el repository no sabe de HTTP, y el service no sabe de ninguno de los dos.

---

## 📂 ¿Qué hace cada carpeta?

Antes de ver cada capa, un resumen rápido de **qué contiene cada carpeta** y por qué existe:

| Carpeta | Qué contiene | ¿Por qué existe? |
|---------|-------------|-------------------|
| `controllers/` | Routers de Express que reciben requests y responden con status codes | Separar la lógica HTTP del resto — si cambiás de Express a Fastify, solo tocás acá |
| `services/` | Clases con lógica de negocio: validaciones, cálculos, reglas | Centralizar las reglas para que no se repitan en cada endpoint |
| `repositories/` | Clases que ejecutan SQL contra la base de datos | Aislar el acceso a datos — si cambiás de PostgreSQL a SQL Server, solo tocás acá |
| `entities/` | Clases que representan las tablas (`Alumno`, `Curso`) | Crear objetos con estructura definida desde código, no depender siempre de `req.body` |
| `configs/` | Configuración de conexión a la base de datos | Centralizar en un lugar las credenciales y parámetros |
| `helpers/` | Utilidades transversales (LogHelper) | Funcionalidad compartida que no pertenece a ninguna capa específica |
| `router/` | Routers de la versión anterior (server-noob-mejorada) | Referencia histórica — en la versión con capas usamos `controllers/` |

> 💡 **Cada carpeta tiene una sola razón de existir.** Si mañana cambiás algo, sabés exactamente dónde buscarlo. Esa es la idea: que el código se encuentre donde lo esperás.

---

## 📋 ¿Qué hace cada capa? (en detalle)

### Controller — el cajero

El controller es un `Router` de Express. Su trabajo es:
1. **Leer** los datos del request (`req.params`, `req.body`)
2. **Llamar** al service correspondiente
3. **Responder** con el status code y el JSON adecuado
4. **Catchear** errores y devolver un status de error

```js
// alumnos-controller.js
router.get('/:id', async (req, res) => {
    try {
        let id = req.params.id;                                    // 1. Leo
        const returnEntity = await currentService.getByIdAsync(id); // 2. Llamo
        if (returnEntity != null){
            res.status(StatusCodes.OK).json(returnEntity);         // 3. Respondo 200
        } else {
            res.status(StatusCodes.NOT_FOUND).send(`No se encontro...`);
        }
    } catch (error) {
        console.log(error);
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).send(`Error: ${error.message}`); // 4. Catcheo
    }
});
```

> 💡 **El controller es el único que conoce `req`, `res`, y los status codes HTTP.** Ninguna otra capa debería importar Express ni devolver status codes.

---

### Service — la cocina

El service es una **clase** que contiene la lógica de negocio. Es el lugar donde ponemos las reglas, validaciones, cálculos y transformaciones que no son ni "leer el request" ni "hacer una query".

Siguiendo con la analogía del McDonald's: la cocina no solo sigue recetas — también **llama a otros servicios** cuando lo necesita. Si el pedido es para delivery, la cocina arma la comida y le avisa al **servicio de delivery** que lo retire y lo lleve. La cocina no sale a repartir — solo le dice "llevá esto a tal dirección". Lo mismo pasa en el código: después de crear un alumno, el service podría llamar a un `EmailService` para mandar un mail de bienvenida, o a un `NotificacionService` para avisarle al profesor. El service **orquesta**: hace su trabajo y coordina con otros servicios.

```
AlumnosService (la cocina)
    ├── AlumnosRepository        → "Dame los ingredientes" (buscar/guardar datos)
    ├── CursosService            → "¿Existe este curso?" (consultar a otro servicio)
    └── EmailService             → "Mandá el mail de bienvenida" (servicio de delivery)
```

En esta versión, `AlumnosService` hace dos cosas concretas que antes no existían:

#### 1. Calcular la edad del alumno

La base de datos guarda `fecha_nacimiento`, pero la **edad** es un dato que cambia con el tiempo — no tiene sentido guardarlo. El service lo calcula al vuelo:

```js
// alumnos-service.js
function calcularEdad(fechaNacimiento) {
    if (!fechaNacimiento) return null;
    const hoy = new Date();
    const nacimiento = new Date(fechaNacimiento);
    let edad = hoy.getFullYear() - nacimiento.getFullYear();
    const mesDiff = hoy.getMonth() - nacimiento.getMonth();
    if (mesDiff < 0 || (mesDiff === 0 && hoy.getDate() < nacimiento.getDate())) {
        edad--;
    }
    return edad;
}

getAllAsync = async () => {
    const returnArray = await this.AlumnosRepository.getAllAsync();
    if (returnArray == null) return null;
    return returnArray.map(alumno => agregarEdad(alumno));   // ← agrega "edad" a cada alumno
}
```

Ahora cuando hacés `GET /api/alumnos/1`, la respuesta incluye:

```json
{
    "id": 1,
    "nombre": "Liam",
    "apellido": "Cohen",
    "fecha_nacimiento": "2008-04-05",
    "edad": 18,
    "..."
}
```

> 🤔 **¿Por qué no calcular la edad en la base de datos?** Podrías hacer `EXTRACT(YEAR FROM AGE(fecha_nacimiento))` en SQL, pero eso mezcla lógica de negocio con la query. Si mañana la regla cambia (por ejemplo, "la edad se calcula al 1 de marzo de cada año" para temas académicos), preferís cambiar una función en JavaScript y no tocar el SQL.

#### 2. Validar que el curso existe antes de crear/actualizar un alumno

Cuando alguien manda un POST para crear un alumno con `id_curso: 999`, ¿qué pasa si el curso 999 no existe? Sin validación, PostgreSQL tira un error críptico de foreign key. Con validación en el service, devolvemos un mensaje claro:

```js
// alumnos-service.js
createAsync = async (entity) => {
    await this.validarCursoExiste(entity.id_curso);         // ← valida antes de insertar
    const rowsAffected = await this.AlumnosRepository.createAsync(entity);
    return rowsAffected;
}

validarCursoExiste = async (idCurso) => {
    if (!idCurso) return;
    const curso = await this.CursosService.getByIdAsync(idCurso);
    if (curso == null) {
        throw new Error(`El curso con id ${idCurso} no existe.`);
    }
}
```

Fijate algo clave: **`AlumnosService` usa `CursosService`** para verificar si el curso existe. No va directo al repository de cursos — respeta las capas. Esto es un **service llamando a otro service**.

```
AlumnosController
    └── AlumnosService
            ├── AlumnosRepository    (para guardar el alumno)
            └── CursosService        (para verificar que el curso existe)
                    └── CursosRepository
```

> ⚠️ **Trampa**: si mandás un POST con `{ "id_curso": 999 }` y el curso no existe, ahora recibís un **400 Bad Request** con el mensaje `"Error: El curso con id 999 no existe."` en vez de un error 500 con un stack trace de PostgreSQL. Eso es mejor para el cliente y más seguro (no exponés detalles internos de la base de datos).

#### ¿Qué pasaría si NO tuviéramos un service?

Imaginemos que no existe la capa de service y todo se hace en el controller:

**Escenario 1: "Calculá la edad del alumno"**

Sin service, ponés la función `calcularEdad()` en el controller de alumnos. Funciona. Pero mañana necesitás la edad del alumno también en un **reporte PDF** que genera otro módulo. ¿Copiás la función? Ahora tenés la misma lógica en dos lugares. Si cambia la regla (por ejemplo, "la edad se calcula al 1 de marzo"), hay que cambiarla en los dos.

Con service, `AlumnosService.getByIdAsync()` ya devuelve el alumno con la edad calculada. Cualquier parte del sistema que necesite un alumno con su edad llama al service — **un solo lugar**.

**Escenario 2: "No dejes crear un alumno en un curso que no existe"**

Sin service, ponés la validación en el endpoint POST del controller. Pero el PUT también necesita esa validación. Y el día que agregues un endpoint de **importar alumnos desde CSV**, también. La validación se copia y se copia.

Con service, `AlumnosService.validarCursoExiste()` se llama desde `createAsync` y `updateAsync` automáticamente. Cualquier forma de crear o modificar un alumno pasa por el service — **la regla se valida siempre**.

**Escenario 3: "Mandá un email cuando se cree un alumno"**

Sin service, ¿dónde ponés el envío del email? ¿En el controller? Entonces el controller sabe de HTTP, de emails, y probablemente de la base de datos. Hace todo y no hace nada bien.

Con service:

```js
createAsync = async (entity) => {
    await this.validarCursoExiste(entity.id_curso);
    const newId = await this.AlumnosRepository.createAsync(entity);
    await this.EmailService.enviarBienvenida(entity);    // ← fácil de agregar
    return newId;
}
```

El controller no se entera. El repository tampoco.

> 💡 **Regla práctica**: si la lógica se necesita en más de un endpoint, va en el service. Si la dejás en el controller, la vas a copiar.

---

### Repository — el responsable del depósito

El repository es una **clase** que ejecuta las queries SQL. Es el único que conoce la base de datos — si mañana cambiás de PostgreSQL a MySQL o Supabase, solo tocás esta capa.

```js
// alumnos-repository.js
getAllAsync = async () => {
    let returnArray = null;
    try {
        const sql = `SELECT * FROM alumnos`;
        const resultPg = await this.getDBPool().query(sql);
        returnArray = resultPg.rows;
    } catch (error) {
        LogHelper.logError(error);
    }
    return returnArray;
}
```

Cosas a notar:

- **Pool lazy**: el Pool se crea recién cuando se necesita (`getDBPool()`), no en el constructor. Esto evita intentar conectar a la base cuando todavía no se cargó la configuración.
- **LogHelper**: en vez de `console.log(error)` suelto, usa un helper que puede loguear a archivo y/o consola según la configuración del `.env`.
- **Errores silenciados**: si la query falla, el repository loguea el error y devuelve `null` o `0`. El controller interpreta eso como "no se encontró" o "error interno". Esto es una simplificación didáctica — en un proyecto real, dejarías que el error suba al controller para poder distinguir "no encontrado" de "la base se cayó".

---

## 🔧 Otros cambios respecto a la versión anterior

### Variables de entorno con dotenv

`server.js` ahora importa `dotenv/config` al arrancar, y `db-config.js` exporta la configuración que lee del archivo `.env`:

```js
// server.js
import 'dotenv/config'      // carga las variables del .env en process.env

// db-config.js
const DBConfigBest = {
    host     : process.env.DB_HOST       ?? '',
    database : process.env.DB_DATABASE   ?? '',
    user     : process.env.DB_USER       ?? '',
    password : process.env.DB_PASSWORD   ?? '',
    port     : process.env.DB_PORT       ?? 5432
}
export default DBConfigBest;
```

Esto resuelve dos problemas de las versiones anteriores:
- **Las credenciales no están en el código fuente** — están en `.env` (que se agrega a `.gitignore`).
- **El puerto es configurable**: `const port = process.env.PORT || 3000;`

> 💡 **El archivo `.env-template`** tiene las variables sin valores reales. Cada alumno copia ese archivo como `.env` y completa con sus datos locales.

### LogHelper — registro de errores centralizado

En vez de `console.log(error)` disperso por todo el código, los repositories usan `LogHelper.logError(error)`, que según la configuración del `.env` puede:
- Mostrar el error en consola
- Guardarlo en un archivo de log con fecha

### try/catch en los controllers

Las versiones anteriores no tenían `try/catch` en el controller. Si el service tiraba un error inesperado, el servidor crasheaba. Ahora cada endpoint está envuelto en `try/catch`:

```js
router.post('', async (req, res) => {
    try {
        // ... lógica normal ...
    } catch (error) {
        console.log(error);
        res.status(StatusCodes.BAD_REQUEST).send(`Error: ${error.message}`);
    }
});
```

Esto es importante ahora que el service puede tirar errores de validación (como "el curso no existe").

---

## 📊 Comparación con las versiones anteriores

| Aspecto | server-noob | server-noob-mejorada | server (capas) |
|---|---|---|---|
| **Archivos** | 1 | 3 | 8+ |
| **Conexión DB** | Client por request | Pool compartido | Pool lazy en repository |
| **Organización** | Todo junto | Separado por recurso | Separado por capa y recurso |
| **Lógica de negocio** | No hay | No hay | Edad calculada, curso validado |
| **Manejo de errores** | try/catch con finally | try/catch sin finally | try/catch en controller + LogHelper en repository |
| **Credenciales** | Hardcodeadas | Hardcodeadas | Variables de entorno (.env) |
| **Puerto** | Hardcodeado | Hardcodeado | Desde .env |

---

## 🧠 ¿Por qué no dejamos todo en el controller?

En un proyecto chico como este, separar en capas puede parecer **excesivo** — son más archivos y más código para lo mismo. Pero pensá qué pasa cuando crece:

**Sin capas** (todo en el controller):
- ¿Dónde pongo la validación de que el curso existe? → En el endpoint de POST
- ¿Y en el PUT también? → Copio la misma validación
- ¿Y si mañana agrego un endpoint de importar alumnos desde CSV? → Copio de nuevo
- Resultado: la misma regla repetida en 3 lugares. Si cambia, hay que cambiarla en los 3.

**Con capas** (lógica en el service):
- La validación está en `AlumnosService.validarCursoExiste()`
- POST, PUT y cualquier endpoint futuro llaman al mismo service
- Si la regla cambia, se cambia en **un solo lugar**

> 💡 **Regla práctica**: si una regla de negocio se necesita en más de un endpoint, tiene que estar en el service. Si la dejás en el controller, la vas a terminar copiando.

---

## 📊 Resumen visual

```
server-noob-mejorada                     server (capas)
┌──────────────────────┐                 ┌──────────────────────┐
│  server-noob-mej.js  │                 │  server.js           │
│  └─ app.use(routers) │                 │  └─ app.use(controllers)
└──────────────────────┘                 └──────────────────────┘
         │                                        │
    ┌────┴────┐                              ┌────┴────┐
    ▼         ▼                              ▼         ▼
┌────────┐ ┌────────┐                  ┌──────────┐ ┌──────────┐
│alumnos │ │cursos  │                  │ alumnos  │ │ cursos   │
│router  │ │router  │                  │controller│ │controller│
│        │ │        │                  └────┬─────┘ └────┬─────┘
│ SQL +  │ │ SQL +  │                       │            │
│ Pool + │ │ Pool + │                  ┌────▼─────┐ ┌────▼─────┐
│ status │ │ status │                  │ alumnos  │ │ cursos   │
│ codes  │ │ codes  │                  │ service  │ │ service  │
│ TODO   │ │ TODO   │                  │ (edad,   │ │          │
│ junto  │ │ junto  │                  │ validar  │ │          │
└────────┘ └────────┘                  │  curso)  │ │          │
                                       └────┬─────┘ └────┬─────┘
                                            │            │
                                       ┌────▼──────┐┌───▼───────┐
                                       │ alumnos   ││ cursos    │
                                       │ repository││ repository│
                                       │ (SQL+Pool)││ (SQL+Pool)│
                                       └───────────┘└───────────┘
```

En la versión con routers, cada archivo mezcla **tres responsabilidades** (HTTP + lógica + SQL). En la versión con capas, cada archivo tiene **una sola responsabilidad**. Si mañana cambiás la base de datos, solo tocás los repositories. Si cambiás una regla de negocio, solo tocás el service. Si cambiás la URL de un endpoint, solo tocás el controller.

---

## 🔁 Cada capa se puede intercambiar

Esta es una de las ventajas más importantes de separar en capas: **podés reemplazar una capa entera sin tocar las demás**.

### ¿Cambiar de base de datos?

Hoy los repositories usan PostgreSQL con la librería `pg`. Si mañana querés usar SQL Server, Supabase, o incluso un archivo JSON, solo cambiás los repositories. El controller y el service ni se enteran:

```
                    HOY                                 MAÑANA
Controller ──► Service ──► Repository (pg)     Controller ──► Service ──► Repository (mssql)
                                                    ↑ igual        ↑ igual        ↑ cambia solo esto
```

De hecho, ya tenemos preparadas las clases `db-pg.js` y `db-mssql.js` que permiten hacer ese cambio con **una sola línea** (ver documento [db-pg-explicacion.md](db-pg-explicacion.md)).

### ¿Cambiar de framework web?

Si mañana querés reemplazar Express por Fastify o Koa, solo cambiás los controllers. Los services y repositories no importan Express — no saben que existe.

### ¿Agregar una app móvil que use la misma lógica?

El service ya tiene `calcularEdad()` y `validarCursoExiste()`. Una app móvil (o un script de migración, o un job nocturno) puede usar el mismo service sin pasar por Express.

> 🤔 **Pensalo así**: las capas son como enchufes. Mientras el enchufe (la interfaz) sea el mismo, podés cambiar lo que hay atrás. El controller es el enchufe que el service necesita. El repository es el enchufe que el service usa. Mientras cada capa respete los métodos que la otra espera (`getAllAsync`, `getByIdAsync`, `createAsync`...), todo funciona.

---

## 📦 Carpeta `entities/` — crear objetos desde código

En el POST normal, los datos del alumno vienen del body del request:

```js
// Controller — los datos vienen del cliente
let entity = req.body;    // ← un objeto genérico, sin estructura definida
const newId = await currentService.createAsync(entity);
```

Funciona, pero `req.body` es un objeto genérico — no tiene estructura, no tiene autocompletado, no sabés qué campos tiene hasta que mirás la documentación. ¿Y si querés crear un alumno **desde código** (por ejemplo en un test, un script, o un endpoint de demostración)?

Para eso existe la carpeta `entities/` con la clase `Alumno`:

```js
import Alumno from './../entities/alumno.js'

// Crear un alumno con campos definidos — sabés exactamente qué lleva
const nuevoAlumno = new Alumno('Willy', 'Wonka', 1, '2005-07-15', true);

const newId = await currentService.createAsync(nuevoAlumno);
```

Podés ver esto funcionando en el endpoint `GET /api/alumnos/test-insert`.

> 💡 **La clase `Alumno` y `req.body` producen lo mismo**: un objeto con las propiedades `nombre`, `apellido`, `id_curso`, `fecha_nacimiento` y `hace_deportes`. La diferencia es que con la clase tenés **estructura y claridad** — sabés qué campos tiene, el IDE te los autocompleta, y si mañana querés agregar validación en el constructor podés hacerlo en un solo lugar.

---

## 🔗 ¿Qué sigue?

Ahora que tenemos la arquitectura en capas, el siguiente paso es reducir el **código repetido dentro de los repositories**. Los dos repositories (`alumnos-repository.js` y `cursos-repository.js`) repiten el mismo boilerplate: imports, Pool, try/catch, LogHelper, `.rows`...

Eso lo resolvemos en el siguiente documento: [DbPg — Clase helper de acceso a datos](db-pg-explicacion.md).
