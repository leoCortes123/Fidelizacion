---
name: fidelizacion-testing
description: Ejecutar y depurar pruebas (unit, E2E, SQL) de forma focalizada. Usar cuando se pida correr tests o diagnosticar fallos.
---
# Testing focalizado

Web:
- Un unit: `npx vitest run tests/unit/<file>.test.tsx`
- Por nombre: `npx vitest run -t "<nombre>"`
- Un E2E: `npx playwright test tests/e2e/<file>.spec.ts`
- Puerto ocupado: `E2E_PORT=5200 npm run test:e2e`

API:
- Suite completa: `npm test`
- Un archivo SQL: comentar los demás en `tests/db/run-tests.sql` o ejecutar con psql.

Siempre correr el mínimo necesario antes de la suite completa.