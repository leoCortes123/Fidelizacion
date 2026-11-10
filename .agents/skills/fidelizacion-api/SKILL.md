---
name: fidelizacion-api
description: Tareas de base de datos Supabase (migraciones, RPC, RLS, tests SQL). Usar cuando se modifique esquema o lógica en PostgreSQL.
---
# Fidelización API

- Pruebas: `cd fidelizacionApi && npm test`
- Supabase local: `npm run db:start`, `npm run db:reset`, `npm run db:status`
- Remoto: `npm run db:push`, `npm run db:diff`
- Migraciones aditivas en `supabase/migrations/`.
- Toda escritura sensible en RPC `SECURITY DEFINER` + RLS.
- Grants: anon solo `business_public_get` y `purchase_qr_preview`.
- Importes COP integer; fechas timestamptz.