# Rutas web (resumen)

## Públicas
- `/`, `/login`, `/auth/callback`, `/join/:slug`, `/claim/:token`, `/scan/:token`.

## Cliente (rol customer)
- `/customer` — inicio por negocio (saldo, recompensas, movimientos).
- `/customer/purchases`, `/customer/redemptions`, `/customer/profile`.
- `/customer/businesses` — selector de negocios.

## Administrador (rol admin)
- `/admin/inicio` — dashboard.
- `/admin/programa`, `/admin/carta`, `/admin/recompensas`, `/admin/campanas`.
- `/admin/solicitudes`, `/admin/clientes`, `/admin/clientes/:id`.
- `/admin/compras`, `/admin/compras/:id`, `/admin/compras/registrar`.
- `/admin/economico`, `/admin/auditoria`, `/admin/miembros`, `/admin/config`.
- `/admin/onboarding`.

## Encargado
- `/encargado`, `/encargado/venta`, `/encargado/escanear`.

Guards: `RequireAuth` + `RequireBusinessRole` (por negocio y rol). Selector de negocio persistido por usuario (`BusinessProvider`).