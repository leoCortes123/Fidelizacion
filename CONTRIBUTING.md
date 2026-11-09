# Contribución

## Flujo
1. Rama por cambio: `feat/...`, `fix/...`, `test:`, `docs:`.
2. Commits convencionales.
3. Antes de PR: `npm run typecheck`, pruebas y build (web); `npm test` (api).
4. Si cambia un contrato RPC, actualizar `documentacion/ai/rpc-contract.md` y web/api en el mismo ciclo.
5. Documentación se actualiza en `documentacion/` cuando cambie una decisión o flujo.

## Checklist PR
- [ ] Tipos limpios
- [ ] Pruebas relevantes añadidas/actualizadas
- [ ] Build + smoke OK (web)
- [ ] Migraciones aditivas y probadas (api)
- [ ] Context packs actualizados si cambió contrato
- [ ] Sin secretos versionados