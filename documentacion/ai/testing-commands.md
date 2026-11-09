# Comandos de prueba (focalizados)

## API (`fidelizacionApi`)
- Suite completa: `npm test` (PostgreSQL 16 efímero en Docker).
- Un archivo SQL específico: editar `tests/db/run-tests.sql` para comentar los demás, o ejecutar con psql contra el contenedor de pruebas. Preferir la suite completa solo al final.
- Migraciones: `npm run db:reset` (local), `npm run db:push` (remoto), `npm run db:diff`.
- Estado: `npm run db:status`.

## Web (`fidelizacionWeb`)
- Tipos: `npm run typecheck` (`tsc -b`).
- Unitarias (todas): `npm test` (Vitest).
- Un archivo: `npx vitest run tests/unit/<archivo>.test.tsx`.
- Un test por nombre: `npx vitest run -t "<nombre>"`.
- Build + smoke: `npm run test:build`.
- E2E (todas): `npm run test:e2e` (puerto 5199).
- Un spec E2E: `npx playwright test tests/e2e/<archivo>.spec.ts`.
- Todo: `npm run test:all`.

## Gotchas de ejecución
- Si el puerto 5199 está ocupado: `E2E_PORT=5200 npm run test:e2e`.
- Playwright sin navegador: `npx playwright install chromium`.
- npm con problemas de red: `NODE_OPTIONS=--no-network-family-autoselection npm install`.
- Supabase local no arranca: verificar Docker y puertos 54321–54324.
- Web sin `.env`: crear desde `.env.example` y reiniciar Vite.