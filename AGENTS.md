# Fidelización (Loopoint) — Workspace

Sistema de fidelización multiempresa: cada negocio configura programa, carta y recompensas. Web (React+Vite) + API (Supabase) + app Android (futuro). Autorización real en PostgreSQL (RLS + RPC).

## Estructura
- `fidelizacionWeb/` — portal cliente + panel admin (repo propio).
- `fidelizacionApi/` — Supabase: migraciones, RPC, RLS, seed, tests SQL (repo propio).
- `fidelizacionApp/` — espacio reservado Android (repo propio).
- `documentacion/` — arquitectura, pruebas, operación, negocio. **Versionada aquí.**
- `documentacion/ai/` — context packs compactos para agentes (lazy load).

## Comandos rápidos
Ver `documentacion/ai/testing-commands.md`. Resumen:
- API: `cd fidelizacionApi && npm test`
- Web tipos: `cd fidelizacionWeb && npm run typecheck`
- Web unit: `cd fidelizacionWeb && npm test`
- Web E2E: `cd fidelizacionWeb && npm run test:e2e` (puerto 5199)
- Web todo: `cd fidelizacionWeb && npm run test:all`

## Convenciones
- Migraciones aditivas en `fidelizacionApi/supabase/migrations/`.
- Toda escritura sensible pasa por RPC `SECURITY DEFINER`.
- Importes en pesos COP como `integer`.
- Fechas en `timestamptz`, presentación en `America/Bogota`.
- Commits convencionales (`feat:`, `fix:`, `test:`, `docs:`).

## Carga de contexto (lazy)
NO cargues todos los docs. Lee solo lo necesario:
- Arquitectura general: `documentacion/ARQUITECTURA.md`
- Contrato RPC/tablas: `documentacion/ai/rpc-contract.md`, `schema-summary.md`
- Rutas web: `documentacion/ai/routes-web.md`
- Gotchas: `documentacion/ai/gotchas.md`
- Estado actual: `documentacion/ESTADO_PROYECTO.md`

## Agentes específicos
- Web: `fidelizacionWeb/AGENTS.md`
- API: `fidelizacionApi/AGENTS.md`

## Subagentes disponibles
- `reviewer` — revisión read-only de cambios.
- `tester` — ejecuta pruebas focalizadas, no edita.
- `db-auditor` — revisa SQL/migraciones/grants, read-only.

Usar solo estos subagentes para mantenimiento; evitar redes amplias.
Existe `graphify-out/graph.json`. Para cambios focalizados, consulta primero `graphify query "<concepto>"` antes de leer código. Regenerar con `graphify .` tras cambios grandes.