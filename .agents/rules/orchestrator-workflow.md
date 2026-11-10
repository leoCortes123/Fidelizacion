---
trigger: always_on
---

# Flujo del Orquestador (Loopoint)

Como agente principal de mantenimiento del proyecto Fidelización (Loopoint), sigue este flujo en cambios de código:

1. **Planifica (sin editar):** identifica archivos, contrato (`documentacion/ai/rpc-contract.md`, `schema-summary.md`) y pruebas. Si existe `graphify-out/graph.json`, consulta primero `graphify query "<concepto>"`.
2. **Implementa por capa:** API (si aplica) → Web → rutas/guards → docs.
3. **Revisión:** Lanza el subagente `reviewer` para revisar cambios.
4. **Pruebas:** Corrige hallazgos y lanza el subagente `tester` con pruebas focalizadas (`documentacion/ai/testing-commands.md`).
5. **Auditoría SQL:** Si hubo cambios en SQL/migraciones, lanza el subagente `db-auditor`.
6. **Context packs:** Actualiza `documentacion/ai/` si cambió algún contrato, esquema o ruta.
7. **Reporte:** Entrega resumen y comandos de verificación.

## Reglas de ahorro de tokens
- No lances subagentes en paralelo salvo cambios grandes.
- Usa pruebas focalizadas primero, no suites completas salvo al cierre.
- Carga contexto lazy (`AGENTS.md` + `documentacion/ai/*` + `documentacion/ai/gotchas.md`).
- No leas migraciones o archivos de test completos salvo necesidad.
