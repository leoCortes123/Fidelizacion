# Rutas web (resumen)

## Públicas
- `/` — landing con acceso a registro de cliente, registro de negocio e inicio de sesión.
- `/login`, `/auth/callback`, `/join/:slug`, `/claim/:token`, `/scan/:token`.

## Cliente (rol customer)
- `/customer` — selector arcade de negocios afiliados (puntos, categoría, descripción, 3 recompensas con barra de progreso y acceso a `MÁS RECOMPENSAS`).
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

Guards: `RequireAuth` + `RequireBusinessRole` (por negocio y rol). Selector de negocio persistido por usuario (`BusinessProvider`).