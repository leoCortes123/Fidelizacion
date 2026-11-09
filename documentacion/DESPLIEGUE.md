# Despliegue

> Valores reales del entorno actual: [`privado/CREDENCIALES.local.md`](privado/CREDENCIALES.local.md).
> Esta guía usa marcadores para que pueda publicarse sin datos operativos.

## Orden de despliegue

1. **API** (`fidelizacionApi`): proyecto Supabase, migraciones y Auth.
2. **Web** (`fidelizacionWeb`): Vercel/Netlify/Cloudflare Pages.
3. **App** (`fidelizacionApp`): Play Store (fase posterior).

## 1. Preparar Supabase

```bash
cd fidelizacionApi
npx supabase login
npx supabase link --project-ref <PROJECT_REF>
npx supabase db push
```

Verificar:

```sql
select count(*) from public.rewards;          -- catálogo legacy
select * from public.program_settings;        -- configuración legacy
select count(*) from public.businesses;       -- negocios del módulo nuevo
select count(*) from public.loyalty_rewards;  -- recompensas nuevas
select version, name from supabase_migrations.schema_migrations order by version;
select relname, relrowsecurity
from pg_class
where relnamespace = 'public'::regnamespace and relkind = 'r'
order by relname;
```

Comprobar la paridad de migraciones antes y después:

```bash
npx supabase migration list --linked
```

El despliegue actual tiene **28/28** migraciones en local y remoto. La última
(`20261025001500_redemption_scan_flow.sql`) añade el canje escaneado por QR.

Si el proyecto ya existía antes del 23/10/2026, vuelve a ejecutar `db push` para
incluir `20261023000100_admin_flow.sql`.

> Las migraciones son aditivas. No ejecutes `supabase db reset` contra producción.

## 2. Auth y Google

Seguir [`CONFIGURACION.md`](CONFIGURACION.md). En producción:

- Google Authorized redirect URI:
  `https://<PROJECT_REF>.supabase.co/auth/v1/callback`
- Supabase Site URL: `https://<DOMINIO_WEB>`
- Supabase Redirect URLs:
  - `https://<DOMINIO_WEB>/**`
  - `https://<DOMINIO_WEB>/auth/callback`

## 3. Primer administrador

La lista de correos con rol automático no se versiona. Antes del primer registro:

```sql
insert into private.bootstrap_admins (email)
values ('<CORREO_ADMIN>')
on conflict (email) do nothing;
```

Después del primer login, comprobar:

```sql
select p.email, r.role
from public.profiles p
join public.user_roles r on r.user_id = p.id
where p.email = '<CORREO_ADMIN>';
```

## 4. Variables de build de la web

```bash
cd fidelizacionWeb
VITE_SUPABASE_URL="https://<PROJECT_REF>.supabase.co" \
VITE_SUPABASE_ANON_KEY="<CLAVE_PUBLICA>" \
VITE_PUBLIC_APP_URL="https://<DOMINIO_WEB>" \
VITE_BRAND_NAME="Mi Negocio" \
VITE_BRAND_TAGLINE="Puntos por tus compras" \
npm run build
```

Subir `dist/` a Vercel, Netlify, Cloudflare Pages o un servidor estático. En Vercel,
las variables se configuran en Project Settings → Environment Variables.

## 5. Vercel

1. Importar `leoCortes123/fidelizacionWeb` en Vercel.
2. Framework preset: **Vite**.
3. Build command: `npm run build`; output: `dist`.
4. Configurar las variables del paso 4 (Production y Preview).
5. Mantener `vercel.json` (fallback SPA) y `public/_headers`.
6. Desplegar y copiar la URL final.
7. Actualizar `VITE_PUBLIC_APP_URL` con esa URL y volver a desplegar.
8. Actualizar Site URL y Redirect URLs en Supabase, y el JavaScript origin en Google
   Cloud.

> **Estado actual:** el proyecto `fidelizacion01` está desplegado en
> `https://fidelizacion01.vercel.app` con **Deployment Protection**
> (`vercel_authentication`) activa. Para una demo pública, desactívala en
> Project Settings → Deployment Protection. Con la protección activa, `vercel curl`
> genera un token de bypass; un navegador sin sesión de Vercel no verá la app.

Mientras el dominio sea provisional, los QR impresos apuntarán a él. Si más adelante
cambia el dominio, conserva una redirección desde el anterior.

### Reglas del hosting

- Fallback SPA para `/claim/*`, `/auth/callback`, `/customer/*` y `/admin/*`.
- HTTPS obligatorio.
- No cachear `index.html`; los assets con hash sí pueden cachearse.
- Cabeceras recomendadas (ver `vercel.json` y `public/_headers`):
  - CSP con `connect-src` al proyecto Supabase,
  - `X-Content-Type-Options: nosniff`,
  - `Referrer-Policy: strict-origin-when-cross-origin`,
  - `Permissions-Policy` sin cámara/micrófono en la web (la app usará cámara).

Ejemplo de CSP:

```text
default-src 'self';
connect-src 'self' https://<PROJECT_REF>.supabase.co;
img-src 'self' data: https:;
style-src 'self' 'unsafe-inline';
font-src 'self' data:;
script-src 'self';
frame-ancestors 'none';
base-uri 'self';
form-action 'self';
```

Vite sirve el JS como módulo desde el propio origen; no hace falta `unsafe-inline`
para scripts. Tailwind inyecta estilos en un archivo, pero algunos componentes usan
estilos inline, por eso `style-src` incluye `'unsafe-inline'`.

> `fidelizacionWeb/vercel.json` contiene una CSP con el dominio real del proyecto
> actual. Si se crea un proyecto Supabase nuevo, actualiza `connect-src`.

## 6. Verificación posterior

### Módulo multiempresa (v2)

- [ ] Registrar un negocio y entrar a `/admin` sin tocar `user_roles`.
- [ ] Configurar programa y activarlo; recargar y ver los valores.
- [ ] Crear carta y recompensas (producto, descuento, vigencia y límites).
- [ ] Compartir `/join/:slug`; un cliente se afilia y ve saldo 0.
- [ ] Registrar una compra y ver el saldo/movimiento en el cliente.
- [ ] Solicitar una recompensa y ver el QR con cuenta atrás.
- [ ] Escanear/validar con el encargado, aprobar y confirmar entrega.
- [ ] Abrir el QR de canje con la cámara: `/scan/<token>`, confirmar y volver a
      registrar compra; la solicitud queda con origen “QR escaneado”.
- [ ] Ver el canje `delivered` en “Mis canjes”.
- [ ] Reemitir un QR perdido y comprobar que el anterior ya no vale.
- [ ] Crear una campaña y verificar la multiplicación dentro de su vigencia.
- [ ] Crear un snapshot mensual y comprobar que repetirlo actualiza la misma fila.
- [ ] Verificar que un negocio B no ve datos del negocio A.
- [ ] Comprobar que un encargado sin permiso no puede aprobar.
- [ ] Revisar `/admin/audit` y el panel económico.

### Flujo legacy (sistema anterior)

- [ ] El botón de Google abre el consentimiento.
- [ ] El registro con correo entra sin verificación.
- [ ] Un administrador genera un QR de compra y el cliente lo abre en otro
      dispositivo.
- [ ] El cliente reclama una sola vez y ve los puntos.
- [ ] Anular el canje devuelve los puntos.
- [ ] Un cliente no entra a `/admin` (redirige a `/unauthorized`).
- [ ] El QR impreso usa el dominio público, no `localhost`.

## 7. Vencimiento, campañas y snapshots

La migración de Fase 6 crea, cuando `pg_cron` está disponible:

- vencimiento diario de puntos a las 05:00;
- snapshot mensual de presupuesto el día 1 a las 06:00.

Las funciones masivas (`points_expire_all_due`, `loyalty_budget_snapshot_all`) solo
se pueden ejecutar con `service_role`; no están disponibles para `authenticated`.
Comprobar en remoto:

```sql
select jobid, schedule, command from cron.job;
```

Si `pg_cron` no está habilitado, programa un job externo que invoque esas RPC con la
clave de servicio, o ejecuta los procesos manualmente desde el SQL Editor.

## 8. Rollback

- **Web:** volver al deployment anterior. Los QR siguen válidos mientras no cambie
  el dominio ni la base.
- **API:** las migraciones son aditivas. Para revertir datos usa backups de
  Supabase; no borres tablas con información de clientes.
- **App:** volver a la versión anterior en Play Console.
- Si se revoca un administrador por error, vuelve a insertar el rol con el SQL del
  primer administrador.

## 9. Operación

- Revisar `audit_log` periódicamente.
- Mantener al menos dos administradores activos.
- Configurar alertas de errores del hosting.
- Rotar credenciales de Google y de Supabase si se comprometen.
- No ejecutar `supabase db reset` en producción.
- Probar los cambios en un proyecto de staging antes de aplicarlos.
- Revisar que ningún `.env`, token o keystore haya entrado a los repositorios.
