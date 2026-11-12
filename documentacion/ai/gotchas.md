# Gotchas del proyecto

- El repositorio raíz no contiene el código: `fidelizacionWeb/`, `fidelizacionApi/`, `fidelizacionApp/` son repos independientes. No anidar `.git`.
- La documentación y `documentacion/privado/` (credenciales) no se versionan en los subrepos; en el meta-repo se ignora `documentacion/privado/`.
- Los E2E usan backend Supabase en memoria (`fake-supabase.ts`), no Supabase real.
- El QR apunta siempre al dominio publicado (`VITE_PUBLIC_APP_URL`), aunque se genere en local.
- `is_staff()` equivale a `admin` desde la migración del 23/10/2026.
- Importes en COP como `integer` (sin centavos).
- Fechas se presentan en `America/Bogota` aunque la BD use `timestamptz`.
- No hacer `supabase db reset` contra producción.
- `supabase/.temp` y `.vercel/` son locales; no versionar.
- El correo del administrador inicial se inserta manualmente en `private.bootstrap_admins`.
- graphify-out: solo versionar `GRAPH_REPORT.md`; el resto es cache regenerable.
- En funciones PL/pgSQL con `RETURNS TABLE`, calificar siempre las columnas en consultas (ej. `lpa.balance`) para evitar colisiones de nombre con variables de retorno (`SQLSTATE 42702: column reference is ambiguous`).
- En `index.html`, no usar scripts inline para respetar la directiva CSP estricta `script-src 'self'` de `vercel.json`; ubicar scripts estáticos en `public/`.