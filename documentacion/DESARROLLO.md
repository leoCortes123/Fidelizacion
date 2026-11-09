# Desarrollo local

## Requisitos

| Herramienta | Uso |
| --- | --- |
| Node.js 22+ y npm 10+ | Web y scripts del API |
| Docker | Supabase local y pruebas SQL |
| Supabase CLI | `npx supabase` (no requiere instalación global) |
| Android Studio + JDK 17 | App Android (cuando se cree el proyecto) |

## 1. API (primero)

```bash
cd fidelizacionApi

npm run db:start      # Supabase local
npm run db:reset      # migraciones + seed
npm run db:status     # URL y claves locales

npm test              # PostgreSQL efímero: 600 aserciones + 4 concurrencias
```

La URL local es `http://127.0.0.1:54321`. Copia la clave `anon` que muestra
`db:status` al `.env` de la web.

Comandos útiles:

```bash
npm run db:stop
npm run db:push       # aplicar migraciones al proyecto vinculado
npm run db:diff       # generar una migración a partir de cambios locales
```

### Administrador inicial

La lista de correos con rol automático no se versiona. Antes del primer registro:

```sql
insert into private.bootstrap_admins (email)
values ('correo-del-administrador@dominio.com')
on conflict (email) do nothing;
```

## 2. Web

```bash
cd fidelizacionWeb
cp .env.example .env
# Edita VITE_SUPABASE_URL y VITE_SUPABASE_ANON_KEY

npm ci
npm run dev           # http://127.0.0.1:5173
```

Pruebas:

```bash
npm run typecheck
npm test              # 149 unitarias
npm run test:build    # build + smoke del bundle
npm run test:e2e      # 34 flujos; Playwright usa el puerto 5199
npm run test:all      # typecheck + unitarias + E2E
```

Si el puerto 5199 está ocupado, usa `E2E_PORT=5200 npm run test:e2e`.

Si Playwright no tiene navegador:

```bash
npx playwright install chromium
```

## 3. App Android

El repositorio `fidelizacionApp` solo contiene el espacio y las convenciones. Para
empezar:

1. Abre Android Studio y crea un proyecto **Empty Activity (Jetpack Compose)** en
   `fidelizacionApp/`.
2. Usa el paquete `com.fidelizacion.app` (o el definitivo).
3. Configura `SUPABASE_URL` y `SUPABASE_ANON_KEY` en `local.properties` o variables
   de Gradle; no las versiones.
4. Sigue el plan de [`APP_ANDROID.md`](APP_ANDROID.md).

## Flujo recomendado

```text
API: migración + prueba SQL
        ↓
Web/App: adaptar contrato y tipos
        ↓
Pruebas de web/app
        ↓
Documentación (si cambió una decisión o un flujo)
        ↓
Commit en el repositorio correspondiente
```

## Problemas frecuentes

| Síntoma | Acción |
| --- | --- |
| `npm` no conecta al registry | `NODE_OPTIONS=--no-network-family-autoselection npm install` |
| Supabase local no arranca | Verifica Docker y que los puertos 54321–54324 estén libres |
| La web dice “Falta configurar Supabase” | Crea `.env` y reinicia Vite |
| Google devuelve `redirect_uri_mismatch` | Revisa la URI exacta en Google Cloud y Supabase |
| El QR abre `localhost` en otro teléfono | Define `VITE_PUBLIC_APP_URL` con el dominio público |
| Playwright no abre Chromium | `npx playwright install chromium` |
| `supabase db push` no reconoce el proyecto | `npx supabase link --project-ref <PROJECT_REF>` |
