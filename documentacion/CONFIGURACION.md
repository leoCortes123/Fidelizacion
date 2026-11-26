# Configuración

> Los valores reales de este entorno están en
> [`privado/CREDENCIALES.local.md`](privado/CREDENCIALES.local.md), que no se
> versiona. Esta guía usa marcadores (`<PROJECT_REF>`, `<DOMINIO>`, `<CORREO_ADMIN>`).

## Repositorios implicados

| Componente | Repositorio | Configuración |
| --- | --- | --- |
| API / Supabase | `fidelizacionApi` | `supabase/config.toml`, migraciones y seed |
| Web | `fidelizacionWeb` | `.env` con las variables `VITE_*` |
| App | `fidelizacionApp` | `local.properties` o variables de Gradle (pendiente) |

## Estado actual

| Elemento | Estado |
| --- | --- |
| Proyecto Supabase | `<PROJECT_NAME>` (`<PROJECT_REF>`, región `<REGION>`) |
| Migraciones + seed | Aplicadas |
| Google OAuth | Provider habilitado en Supabase; redirect URI confirmada en Google Cloud |
| Registro con correo/contraseña | Habilitado con confirmación obligatoria (`enable_confirmations = true`) y recuperación de contraseña (`/restablecer-clave`) |
| Dominio público | Pendiente de definir en Vercel |
| Administrador inicial | Se configura por SQL en cada entorno; no se versiona |

## Requisitos

- Node.js 22+ y npm 10+
- Docker (para Supabase local y las pruebas de base de datos)
- Supabase CLI (`npx supabase`)
- Un proyecto de Google Cloud con OAuth 2.0

## Variables de entorno de la web

Archivo: `fidelizacionWeb/.env` (ignorado por Git, permisos `600`).

```dotenv
VITE_SUPABASE_URL=https://<PROJECT_REF>.supabase.co
VITE_SUPABASE_ANON_KEY=<CLAVE_PUBLICA>
VITE_BRAND_NAME=Fideliapp
VITE_BRAND_TAGLINE=Puntos por tus compras
VITE_PUBLIC_APP_URL=
VITE_PUBLIC_SITE_URL=https://fideliapp.pages.dev
VITE_LEGAL_SITE_URL=https://fideliapp.pages.dev
```

- `VITE_SUPABASE_URL` es la URL base, **sin** `/rest/v1/` ni barra final.
- `VITE_SUPABASE_ANON_KEY` es la clave pública (`publishable` o `anon`). Es la única
  clave que puede llegar al navegador.
- `VITE_PUBLIC_APP_URL` construye la URL de los QR. **Debe** ser el dominio público.
  Mientras esté vacío se usa `window.location.origin` (útil en local).
- `VITE_PUBLIC_SITE_URL` es la URL del sitio comercial estático (Cloudflare Pages).
- `VITE_LEGAL_SITE_URL` es la URL base para las páginas legales (`/privacidad`,
  `/terminos`, `/terminos-negocios`, `/dpa`, `/cookies`, `/eliminar-cuenta`,
  `/contacto`). Por defecto apunta a `https://fideliapp.pages.dev`.
- `VITE_BRAND_NAME` y `VITE_BRAND_TAGLINE` son provisionales.
- Vite incorpora estas variables en el build: hay que reconstruir si cambian.

> Nunca agregues la clave secreta (`service_role` / `sb_secret_…`) a la web ni a la
> app. Solo se usa en el panel de Supabase o en scripts administrativos.

## Secretos del API

No se versionan. Preferencias:

1. `npx supabase login` guarda el token de acceso fuera del repositorio.
2. La contraseña de la base y el token personal solo se usan para
   `supabase link` / `db push` y se revocan al terminar.
3. `supabase/.temp` (estado de vinculación) está en `.gitignore`.
4. El secreto de Google OAuth vive solo en el panel de Supabase.

`.env.example` en `fidelizacionApi` documenta las variables manuales
(`SUPABASE_PROJECT_REF`, `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_PASSWORD`) con valores
vacíos.

## Supabase local

```bash
cd fidelizacionApi
npm run db:start
npm run db:reset      # migraciones + seed
npm run db:status     # URL y claves locales
```

La URL local es `http://127.0.0.1:54321`. Copia la clave `anon` al `.env` de la web.

## Supabase alojado

```bash
cd fidelizacionApi
npx supabase login
npx supabase link --project-ref <PROJECT_REF>
npx supabase db push
```

La semilla (`supabase/seed.sql`) crea la configuración y cinco recompensas:

```bash
npx supabase db push --include-seed
# o pegar supabase/seed.sql en el SQL Editor
```

No ejecutes `supabase db reset` contra producción: borra datos.

## Google OAuth

### 1. Google Cloud

1. APIs & Services → Credentials → **Create credentials → OAuth client ID**.
2. Tipo **Web application**.
3. **Authorized JavaScript origins:** `https://<DOMINIO_WEB>`
4. **Authorized redirect URI:**
   `https://<PROJECT_REF>.supabase.co/auth/v1/callback`
5. OAuth consent screen: tipo External, scopes `openid`, `email`, `profile`, estado
   **In production**.

### 2. Supabase

Authentication → Providers → Google:

- Habilitado.
- Client ID y Client Secret de Google Cloud (secreto solo del lado servidor).

Authentication → URL Configuration:

- **Site URL:** `https://<DOMINIO_WEB>` (mientras tanto,
  `http://127.0.0.1:5173`).
- **Redirect URLs:**
  - `http://127.0.0.1:5173/**`
  - `http://localhost:5173/**`
  - `https://<DOMINIO_WEB>/**`
  - `https://<DOMINIO_WEB>/auth/callback`

La web redirige a `/auth/callback?next=…`; Supabase añade el código OAuth.

### 3. Verificar

1. Abrir `/login`.
2. Pulsar **Continuar con Google**.
3. Completar el consentimiento.
4. Confirmar que se crea `auth.users`, `profiles` y `user_roles` (`customer`).

## Registro con correo y contraseña

En `fidelizacionApi/supabase/config.toml` (`[auth.email]`) y en el panel de Supabase (**Authentication → Providers → Email**):

- Email habilitado.
- **Confirm email activado** (`enable_confirmations = true`): al registrarse, la web muestra la pantalla **"Revisa tu correo"** con opción de reenvío (`supabase.auth.resend`).
- **Recuperación de contraseña:** desde `/login` ("¿Olvidaste tu contraseña?") se envía el enlace hacia `/restablecer-clave`, donde el usuario define su nueva contraseña (`supabase.auth.updateUser`).
- **Redirect URLs en producción:** incluir `https://fideli-app.vercel.app/**`, `https://fideli-app.vercel.app/auth/callback` y `https://fideli-app.vercel.app/restablecer-clave`, con `site_url = "https://fideli-app.vercel.app"`.
- **SMTP propio (producción):** configurar un proveedor SMTP transaccional (Resend, Postmark, SES, etc.) en **Project Settings → Auth → SMTP Settings** con registros **SPF, DKIM y DMARC** en el dominio remitente para evitar spam y límites del SMTP por defecto de Supabase.
- **Plantillas en español:** versionadas en `fidelizacionApi/supabase/templates/` (`confirm.html` y `recovery.html`); copiar su contenido en **Authentication → Email Templates** del proyecto remoto.
- **Pruebas locales:** `supabase start` levanta Inbucket en `http://127.0.0.1:54324` para inspeccionar los correos de confirmación y recuperación sin salir a internet.

La pantalla `/login` permite alternar entre **Iniciar sesión** y **Registro**, además de recuperar el acceso. El alta guarda el nombre en `raw_user_meta_data.full_name` y el trigger crea el perfil.

## Administrador inicial

La lista de correos con rol automático **no se versiona**. En cada entorno, antes
del primer registro del administrador:

```sql
insert into private.bootstrap_admins (email)
values ('<CORREO_ADMIN>')
on conflict (email) do nothing;
```

El trigger `handle_new_user` concede `admin` a ese correo. Si la cuenta ya existía:

```sql
insert into public.user_roles (user_id, role)
select id, 'admin'
from auth.users
where email = '<CORREO_ADMIN>'
on conflict (user_id, role) do nothing;
```

Comprobar:

```sql
select p.email, r.role
from public.profiles p
join public.user_roles r on r.user_id = p.id
where p.email = '<CORREO_ADMIN>';
```

Para retirar el rol:

```sql
delete from public.user_roles
where user_id = (select id from auth.users where email = '<CORREO_ADMIN>')
  and role = 'admin';
```

La aplicación no crea ni modifica usuarios desde la interfaz.

## Ejecutar la web

```bash
cd fidelizacionWeb
npm ci
npm run dev
```

Abrir `http://127.0.0.1:5173`.

## Solución de problemas

| Síntoma | Causa probable | Acción |
| --- | --- | --- |
| Aviso “Falta configurar Supabase” | `.env` ausente o vacío | Crear `.env` y reiniciar Vite |
| `Invalid API key` | Clave incorrecta o URL con `/rest/v1/` | Copiar la URL base y la clave pública correctas |
| Google devuelve `redirect_uri_mismatch` | URI no autorizada | Añadir la URI exacta en Google Cloud |
| El login vuelve a `/` | Redirect URL no permitida en Supabase | Añadir el dominio en Auth → URL Configuration |
| El registro por correo pide confirmación | Comportamiento esperado (`enable_confirmations = true`) | Abrir el enlace en el correo (en local, revisar Inbucket en `http://127.0.0.1:54324`) o usar el botón de reenvío |
| El QR abre `localhost` en otro teléfono | `VITE_PUBLIC_APP_URL` vacío | Definir el dominio público y reconstruir |
| `permission denied for table …` | Se intentó escribir sin RPC | Usar la operación de la interfaz; es el comportamiento esperado |
| `redemption_requires_admin` | Se llamó al canje antiguo del cliente | Aplicar el canje desde `/admin/customers/:id` |
| npm no conecta al registry | Resolución de red IPv6 del entorno | `NODE_OPTIONS=--no-network-family-autoselection npm install` |
| Docker no arranca para pruebas | Docker detenido | Iniciar Docker y reintentar `npm test` en `fidelizacionApi` |
