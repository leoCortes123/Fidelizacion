# Rutas web (resumen)

## Públicas
- `/` — landing con acceso a registro de cliente, registro de negocio e inicio de sesión.
- `/login`, `/auth/callback`, `/join/:slug`, `/claim/:token`, `/scan/:token`.

## Cliente (rol customer)
- `/customer` — selector de negocios y resumen de puntos totales.
- `/customer/business/:businessId` — inicio por negocio (saldo, recompensas con barra de progreso, movimientos y compras).
- `/customer/purchases`, `/customer/redemptions`, `/customer/perfil` (y `/perfil`).

## Administrador (rol admin)
- `/admin/dashboard` — inicio operativo del negocio (métricas, QR de venta rápida, actividad e invitación).
- `/admin/products` — carta de productos y combos (acceso directo en menú lateral).
- `/admin/rewards` — recompensas del programa (acceso directo en menú lateral).
- `/admin/members` — equipo y permisos de encargados (acceso directo en menú lateral).
- `/admin/perfil` — perfil del administrador con pestañas: `Negocio` (incluye datos del administrador y del negocio), `Programa` y `Económico`.
- `/admin/onboarding` — asistente de onboarding para configurar nuevo negocio.
- `/admin/redemptions`, `/admin/customers`, `/admin/customers/:id`.
- `/admin/purchases`, `/admin/purchases/new`.
- `/admin/campaigns`, `/admin/audit`.
- Redirecciones de compatibilidad: `/admin/config`, `/admin/business`, `/admin/program`, `/admin/economic`, `/admin/settings`.

## Encargado
- `/encargado`, `/encargado/venta`, `/encargado/escanear`.

Guards: `RequireAuth` + `RequireBusinessRole` (por negocio y rol). Selector de negocio persistido por usuario (`BusinessProvider`).