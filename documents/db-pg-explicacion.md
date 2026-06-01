# DbPg — Clase helper para encapsular el acceso a PostgreSQL

> **Archivos**: `src/repositories/db-pg.js` + `db-mssql.js` + `cursos-repository-new.js` + `alumnos-repository-new.js`
> **Cómo verlo funcionar**: `npm run server` (los services ya importan los `*-repository-new.js`)
> **Prerequisito**: haber leído el análisis de [server-capas-explicacion](server-capas-explicacion.md)

---

## 🧩 ¿Cuál es el problema?

Mirá `cursos-repository.js` y `alumnos-repository.js` uno al lado del otro. ¿Qué ves?

```js
// cursos-repository.js                             // alumnos-repository.js
import pkg from 'pg'                                import pkg from 'pg'
import config from './../configs/db-config.js';     import config from './../configs/db-config.js';
import LogHelper from './../helpers/log-helper.js'  import LogHelper from './../helpers/log-helper.js'
const { Pool } = pkg;                               const { Pool } = pkg;
```

Los imports son **idénticos**. Ahora mirá los métodos:

```js
// cursos-repository.js                             // alumnos-repository.js
getAllAsync = async () => {                         getAllAsync = async () => {
    let returnArray = null;                             let returnArray = null;
    try {                                               try {
        const sql = `SELECT * FROM cursos`;                 const sql = `SELECT * FROM alumnos`;
        const resultPg = await this                         const resultPg = await this
            .getDBPool().query(sql);                            .getDBPool().query(sql);
        returnArray = resultPg.rows;                        returnArray = resultPg.rows;
    } catch (error) {                                   } catch (error) {
        LogHelper.logError(error);                          LogHelper.logError(error);
    }                                                   }
    return returnArray;                                 return returnArray;
}                                                   }
```

Lo único que cambia es **el SQL**. Todo lo demás — el `try/catch`, el `LogHelper.logError`, el `getDBPool()`, el `.rows` — es **boilerplate** que se repite textualmente. Y encima cada repository tiene su propia copia del método `getDBPool()` y su propio `this.DBPool`.

Si mañana tenés 10 entidades (profesores, materias, horarios, aulas...), vas a tener **10 repositories con el mismo boilerplate copiado**.

---

## 💡 La solución: una clase `DbPg`

La idea es simple: **extraer todo lo que se repite** en una clase aparte que se encargue de:

- Crear y administrar el Pool (una sola vez)
- Ejecutar queries con `try/catch`
- Loguear errores con `LogHelper`
- Extraer los datos del resultado de `pg` (`.rows`, `.rows[0]`, `.rowCount`)

El repository se queda solo con lo que le importa: **el SQL y los valores**.

```
ANTES                                    DESPUÉS
┌─────────────────────────┐              ┌─────────────────────────┐
│  CursosRepository       │              │  CursosRepository       │
│  ├─ import pkg from pg  │              │  ├─ import DbPg         │
│  ├─ import config       │              │  └─ métodos con SQL     │
│  ├─ import LogHelper    │              │     (sin try/catch,     │
│  ├─ getDBPool()         │              │      sin Pool,          │
│  └─ métodos con:        │              │      sin LogHelper)     │
│     ├─ try/catch        │              └─────────┬───────────────┘
│     ├─ getDBPool()      │                        │ usa
│     ├─ LogHelper        │              ┌─────────▼───────────────┐
│     └─ resultPg.rows    │              │  DbPg                   │
└─────────────────────────┘              │  ├─ Pool (lazy)         │
                                         │  ├─ try/catch           │
┌─────────────────────────┐              │  ├─ LogHelper           │
│  AlumnosRepository      │              │  └─ queryAll()          │
│  ├─ (todo repetido)     │              │     queryOne()          │
│  ...                    │              │     queryReturnId()     │
└─────────────────────────┘              │     queryRowCount()     │
                                         └─────────────────────────┘
```

---

## 🔍 Los 4 métodos de DbPg

Cada método encapsula un **patrón de uso distinto** que encontramos en los repositories:

| Método | ¿Qué devuelve? | ¿Cuándo se usa? | Ejemplo |
|--------|----------------|-----------------|---------|
| `queryAll(sql, values?)` | `rows` (array) o `null` | SELECT que devuelve una lista | `SELECT * FROM cursos` |
| `queryOne(sql, values?)` | `rows[0]` (objeto) o `null` | SELECT que devuelve un registro | `SELECT * FROM cursos WHERE id=$1` |
| `queryReturnId(sql, values?)` | `rows[0].id` (número) o `0` | INSERT con `RETURNING id` | `INSERT INTO cursos (...) RETURNING id` |
| `queryRowCount(sql, values?)` | `rowCount` (número) o `0` | UPDATE / DELETE | `DELETE FROM cursos WHERE id=$1` |

Los cuatro hacen lo mismo internamente:
1. Obtienen el Pool (lazy)
2. Ejecutan la query con `try/catch`
3. Si falla, loguean el error con `LogHelper`
4. Extraen el dato relevante del resultado de `pg`

---

## 📋 Comparación: antes y después

### Antes (`cursos-repository.js`) — 96 líneas

```js
import pkg from 'pg'
import config from './../configs/db-config.js';
import LogHelper from './../helpers/log-helper.js'

const { Pool } = pkg;

export default class CursosRepository {
    constructor() {
        console.log('Estoy en: CursosRepository.constructor()');
        this.DBPool = null;
    }

    getDBPool = () => {
        if (this.DBPool == null) {
            this.DBPool = new Pool(config);
        }
        return this.DBPool;
    }

    getAllAsync = async () => {
        console.log(`CursosRepository.getAllAsync()`);
        let returnArray = null;
        try {
            const sql = `SELECT * FROM cursos`;
            const resultPg = await this.getDBPool().query(sql);
            returnArray = resultPg.rows;
        } catch (error) {
            LogHelper.logError(error);
        }
        return returnArray;
    }

    // ... y así con cada método, repitiendo try/catch/LogHelper/getDBPool
}
```

### Después (`cursos-repository-new.js`) — 33 líneas

```js
import Db from './db-pg.js';

export default class CursosRepository {
    constructor() {
        console.log('Estoy en: CursosRepository.constructor()');
        this.db = new Db();
    }

    getAllAsync = async () => {
        console.log(`CursosRepository.getAllAsync()`);
        const sql = `SELECT * FROM cursos`;
        return await this.db.queryAll(sql);
    }

    getByIdAsync = async (id) => {
        console.log(`CursosRepository.getByIdAsync(${id})`);
        const sql = `SELECT * FROM cursos WHERE id=$1`;
        return await this.db.queryOne(sql, [id]);
    }

    createAsync = async (entity) => {
        console.log(`CursosRepository.createAsync(${JSON.stringify(entity)})`);
        const sql = `INSERT INTO cursos (nombre) VALUES ($1) RETURNING id`;
        return await this.db.queryReturnId(sql, [entity?.nombre ?? '']);
    }

    updateAsync = async (entity) => {
        console.log(`CursosRepository.updateAsync(${JSON.stringify(entity)})`);
        const sql = `UPDATE cursos SET nombre = $2 WHERE id = $1`;
        return await this.db.queryRowCount(sql, [entity.id, entity?.nombre ?? '']);
    }

    deleteByIdAsync = async (id) => {
        console.log(`CursosRepository.deleteByIdAsync(${id})`);
        const sql = `DELETE FROM cursos WHERE id=$1`;
        return await this.db.queryRowCount(sql, [id]);
    }
}
```

Fijate lo que **desapareció**:
- ❌ `import pkg from 'pg'` + `const { Pool } = pkg;`
- ❌ `import config` + `import LogHelper`
- ❌ `this.DBPool = null` + `getDBPool()`
- ❌ Todo el `try { ... } catch (error) { LogHelper.logError(error); }`
- ❌ El acceso a `.rows`, `.rows[0]`, `.rows[0].id`, `.rowCount`

Cada método se reduce a: **SQL + valores + llamar al método correcto de `Db`**.

---

## 🔑 El truco del `import Db`

Fijate cómo importamos en el repository:

```js
import Db from './db-pg.js';       // ← hoy: PostgreSQL
// import Db from './db-mssql.js'; // ← mañana: SQL Server
```

El nombre del import es **`Db`**, no `DbPg` ni `DbMssql`. ¿Por qué? Porque el repository usa `this.db = new Db()` y después llama `this.db.queryAll(...)`, `this.db.queryOne(...)`, etc. Si el import siempre se llama `Db`, para cambiar de motor solo cambiás **una línea** (el path del import) y el resto del archivo queda intacto.

```js
// Hoy con PostgreSQL                    // Mañana con SQL Server
import Db from './db-pg.js';              import Db from './db-mssql.js';

this.db = new Db();                       this.db = new Db();          // ← igual
this.db.queryAll(sql);                    this.db.queryAll(sql);       // ← igual
this.db.queryOne(sql, [id]);              this.db.queryOne(sql, [id]); // ← igual
```

> 💡 **Esto se llama "programar contra una interfaz"**: el repository no sabe (ni le importa) si por dentro hay un Pool de `pg` o una conexión de `mssql`. Solo sabe que tiene un objeto `db` con 4 métodos. Mientras el objeto respete esos métodos, todo funciona.

---

## 🔄 ¿Y si mañana cambio de base de datos?

Esa es la gracia. Hoy tenemos `db-pg.js` (PostgreSQL con `pg`) y `db-mssql.js` (SQL Server con `mssql`), las dos con **los mismos 4 métodos**:

```
                    ┌─────────────────┐
                    │   Repository    │
                    │ import Db from  │
                    │  './db-???.js'  │
                    └────────┬────────┘
                             │ usa
              ┌──────────────┼──────────────┐
              ▼              ▼              ▼
         ┌─────────┐   ┌──────────┐   ┌──────────────┐
         │  DbPg   │   │ DbMssql  │   │ DbSupabase   │
         │  (pg)   │   │ (mssql)  │   │ (supabase-js)│
         └─────────┘   └──────────┘   └──────────────┘
  queryAll()  ✓      queryAll()  ✓      queryAll()  ✓
  queryOne()  ✓      queryOne()  ✓      queryOne()  ✓
  queryReturnId() ✓  queryReturnId() ✓  queryReturnId() ✓
  queryRowCount() ✓  queryRowCount() ✓  queryRowCount() ✓
```

El repository no cambia — sigue mandando SQL y recibiendo resultados. Solo cambiás el import.

### Diferencias internas entre `DbPg` y `DbMssql`

| Aspecto | `DbPg` (pg) | `DbMssql` (mssql) |
|---------|-------------|-------------------|
| **Pool** | `new Pool(config)` — síncrono | `sql.connect(config)` — asíncrono (usa `await`) |
| **Ejecutar query** | `pool.query(sql, values)` — values es un array posicional | `request.input('param1', value)` + `request.query(sql)` — params nombrados |
| **Filas del resultado** | `result.rows` | `result.recordset` |
| **Filas afectadas** | `result.rowCount` | `result.rowsAffected[0]` |
| **Placeholders en SQL** | `$1, $2, $3` | `@param1, @param2, @param3` |

Fijate que la **interfaz externa** (los 4 métodos) es idéntica, pero la **implementación interna** es completamente distinta. Eso es exactamente lo que queremos: cada clase `Db` traduce entre "lo que el repository espera" y "lo que la librería necesita".

> ⚠️ **Ojo con los placeholders del SQL**: si cambiás de `DbPg` a `DbMssql`, las queries del repository también tienen que cambiar de `$1, $2` a `@param1, @param2`. Esto es una limitación — cada motor de base de datos tiene su propia sintaxis. Pero al menos la lógica de conexión, pools, try/catch y logueo **no se toca**.

---

## 🧠 ¿Por qué no hicimos esto desde el principio?

Porque necesitábamos ver el problema primero. Si hubiéramos arrancado con `DbPg` en la versión 1, nadie habría entendido **qué resuelve**. Ahora que vieron el boilerplate repetido en dos repositories, la motivación es obvia.

Esto es un patrón general en desarrollo de software: **primero hacelo funcionar, después refactorizá cuando el patrón se repite**. La regla clásica es la "regla de tres": si copiaste algo dos veces (tres copias en total), es hora de extraer.

---

## 📊 Resumen de todo el recorrido

Si mirás las 4 versiones del proyecto en perspectiva, cada una resolvió un problema específico:

| Versión | Problema | Solución | Archivos |
|---------|----------|----------|----------|
| **V1** server-noob | Todo en un solo archivo, Client lento | *Funciona, pero no escala* | 1 |
| **V2** server-noob-mejorada | Organización + performance | Router + Pool | 3 |
| **V3** server (capas) | Responsabilidades mezcladas | Controller → Service → Repository | 8+ |
| **V4** db-pg / db-mssql | Boilerplate repetido en repositories | Clase `Db` intercambiable | *-repository-new.js* |

```
V1 (todo junto)  →  V2 (separar)  →  V3 (capas)  →  V4 (intercambiar)
"funciona"           "organizado"      "mantenible"    "flexible"
```

Cada paso fue motivado por un **problema concreto** que encontramos en la versión anterior. No refactorizamos "porque sí" — refactorizamos porque el código lo necesitaba para seguir creciendo.
