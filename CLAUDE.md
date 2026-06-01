# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Educational REST API (DAI course, ORT) demonstrating incremental refactoring from a single-file server to a layered architecture. CRUD for `alumnos` and `cursos` against PostgreSQL. Written in Spanish.

This is a teaching project — the author is a professor and students are learning Node.js and database access. Code is intentionally verbose and self-explanatory, with comments added to aid comprehension. Do not remove comments or simplify pedagogical patterns.

## Commands

```bash
npm install              # install dependencies
npm run server           # run the layered version (V3) — the main one
npm run server-noob      # run V1 (everything in one file)
npm run server-noob-mejorada  # run V2 (Router + Pool)
```

All scripts use `node --watch` for auto-reload on save. No test runner or linter is configured.

## Setup

1. PostgreSQL must be running locally.
2. Run `documents/database/script-postgress.sql` to create tables (`cursos`, `alumnos`) and seed data.
3. Copy `.env-template` to `.env` and fill in your DB credentials and log path.
4. Note: `src/configs/db-config.js` currently uses hardcoded credentials, not `process.env`. The commented-out block at the bottom shows the dotenv-based version.

## Architecture (V3 — `npm run server`)

ESM modules throughout (`"type": "module"` in package.json). Express 5.

```
server.js → mounts controllers as routers
  controller (Express Router) → HTTP concerns only, delegates to service
    service → business logic (e.g. calcularEdad, validarCursoExiste), delegates to repository
      repository → raw SQL via pg Pool
```

- **Controllers** export an Express `Router`, mounted at `/api/alumnos` and `/api/cursos`.
- **Services** are instantiated once per controller. `AlumnosService` depends on `CursosService` for FK validation.
- **Repositories** each manage their own `Pool` (lazy-initialized via `getDBPool()`).
- **Entities** (`Alumno`, `Curso`) are plain classes used to construct objects from code (see `/api/alumnos/test-insert`).
- **LogHelper** is a singleton that logs errors to file and/or console based on `.env` settings.

## Database helpers (V4 — `db-pg.js` / `db-mssql.js`)

`DbPg` and `DbMssql` expose the same 4-method interface (`queryAll`, `queryOne`, `queryReturnId`, `queryRowCount`), abstracting away the pg/mssql driver differences. The `*-repository-new.js` files use these instead of raw Pool access. To switch DB engines, change the import in the repository from `db-pg.js` to `db-mssql.js`.

## Key conventions

- Status codes use `http-status-codes` constants (`StatusCodes.OK`, `StatusCodes.CREATED`, etc.), not raw numbers.
- SQL uses positional parameters (`$1, $2, ...` for pg; `@param1, @param2, ...` for mssql).
- Repositories return `null` on not-found / error (no exceptions). Services throw on business rule violations.
- The project contains 4 evolutionary versions of the same API — V1 and V2 files are kept intentionally for teaching purposes and should not be deleted or "cleaned up".
