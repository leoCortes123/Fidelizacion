---
name: fidelizacion-web
description: Tareas en la web React+Vite (tipos, unit, E2E, build). Usar cuando se modifique UI, rutas, componentes o hooks.
---
# Fidelización Web

- Dev: `cd fidelizacionWeb && npm run dev`
- Tipos: `npm run typecheck`
- Unit: `npm test`; un archivo: `npx vitest run tests/unit/<file>.test.tsx`
- E2E: `npm run test:e2e` (puerto 5199); un spec: `npx playwright test tests/e2e/<file>.spec.ts`
- Build+smoke: `npm run test:build`
- Todo: `npm run test:all`
- Lint/format: `npm run lint`, `npm run format`

Convenciones: guards por rol/negocio, RPC para escrituras, fechas America/Bogota, COP integer.