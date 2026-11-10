---
name: fidelizacion-deploy
description: Despliegue web (Vercel) y API (Supabase). Usar cuando se prepare una release.
---
# Despliegue

Web (Vercel):
- `npm run build && npm run test:build`
- Smoke en `/`, `/login`, 404.
- Variables: VITE_SUPABASE_URL, VITE_SUPABASE_ANON_KEY, VITE_PUBLIC_APP_URL.

API (Supabase):
- `npm run db:push` (migraciones pendientes).
- Verificar paridad local/remoto (31 migraciones).
- No `db reset` en producción.