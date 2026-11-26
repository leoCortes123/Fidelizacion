# Rutas web (resumen)

## Entrada y públicas (app en Vercel)
- `/` — `RootRedirect`: si hay sesión redirige al portal del rol (`resolvePostLoginPath`); si no hay sesión redirige a `/login` (conservando `?install=1`). Garantiza que la PWA instalada nunca abra en la página comercial.
- `/login` (admite `?install=1` para mostrar aviso de instalación PWA y enlaza "Volver al inicio" al sitio comercial `VITE_PUBLIC_SITE_URL`, por defecto `https://fideliapp.pages.dev`, además de pantalla "Revisa tu correo" con reenvío y recuperación de contraseña), `/auth/callback`, `/restablecer-clave` (actualización de contraseña vía enlace de recuperación), `/join/:slug`, `/claim/:token`, `/scan/:token`, `/aceptar-terminos` (pantalla de consentimiento legal pendiente protegida por `RequireAuth`, fuera de `ConsentGate`).

## Sitio comercial separado (`fidelizacionWebPage`, Cloudflare Pages `https://fideliapp.pages.dev`)
- Comerciales: `/` (Inicio), `/como-funciona`, `/funciones`, `/precios`, `/preguntas`.
- Legales y PQR: `/privacidad`, `/terminos`, `/terminos-negocios`, `/dpa`, `/cookies`, `/eliminar-cuenta`, `/contacto`.
- Sin sesión ni Supabase; botones de acceso enlazan a `https://fideli-app.vercel.app/login` y "Descargar app" a `/login?install=1`. Cloudflare Pages sirve `/index.html` con HTTP 200 en todas las rutas SPA (sin `404.html`).

## Cliente (rol customer)
- `/customer` — tarjeta pixel art retro 32x32 de negocios afiliados con navegación por flechas (monedas del cliente en el negocio, progreso, información del negocio y botón `Recompensas y carta`).
- `/customer/business/:businessId` — detalle del negocio (cabecera replicada + pestañas `RECOMPENSAS`, `CARTA` y `MOVIMIENTOS`, con modales de detalle).
- `/customer/purchases`, `/customer/redemptions`, `/customer/perfil` (y `/perfil`).

## Administrador (rol admin)
- `/admin/dashboard` — inicio operativo del negocio (métricas, QR de venta rápida, actividad e invitación).
- `/admin/products` — carta de productos y combos (acceso directo en menú lateral).
- `/admin/rewards` — recompensas del programa (acceso directo en menú lateral).
- `/admin/members` — equipo y permisos de encargados (acceso directo en menú lateral).
- `/admin/perfil` — perfil del administrador con pestañas: `Negocio` (incluye datos del administrador y del negocio), `Programa` y `Económico`.
- `/admin/onboarding` — asistente de onboarding de 3 pasos (`Datos del negocio`, `Datos económicos`, `Programa y activación`) y alta directa de nuevo negocio (`?new=1`).
- `/business/select` — selector de negocio (redirige a `/admin/onboarding?new=1` al registrar negocio).
- `/business/register` — redirige directamente a `/admin/onboarding?new=1`.
- `/admin/redemptions`, `/admin/customers`, `/admin/customers/:id`.
- `/admin/purchases`, `/admin/purchases/new`.
- `/admin/campaigns`, `/admin/audit`.
- Redirecciones de compatibilidad: `/admin/config`, `/admin/business`, `/admin/program`, `/admin/economic`, `/admin/settings`.

## Encargado
- `/encargado` — dashboard operativo del encargado (solicitudes pendientes, accesos directos y FAB a registrar venta).
- `/encargado/venta` — registrar venta con QR y detalle de ventas recientes.
- `/encargado/solicitudes` — solicitudes de recompensa (pestaña de solicitudes pendientes para aprobación directa y pestaña de clientes ordenados por puntos acumulados).

Guards: `RequireAuth` + `ConsentGate` (verifica `legal_consent_status()` y redirige a `/aceptar-terminos?next=...` si `has_pending` es true) + `RequireBusinessRole` (por negocio y rol). Selector de negocio persistido por usuario (`BusinessProvider`).