# Esquema (resumen)

Tablas clave (multiempresa, todo lleva `business_id`):

- `profiles` — nombre, correo, `nickname`, `account_type` (`customer` | `admin`), fechas.
- `user_roles` — rol global legacy (`customer`, `admin`, `registrar`).
- `businesses` — negocio, slug, logo, estado.
- `business_memberships` — usuario ↔ negocio con rol (`admin`/`encargado`/`cliente`).
- `business_programs` — reglas de acumulación/canje.
- `products` — carta (incluye combos y foto `image_url`).
- `rewards` — recompensas con límites.
- `purchases` + `purchase_items` — compras con snapshot de reglas.
- `points_ledger` + `point_lots` — libro inmutable y lotes con `expires_at`.
- `redemptions` + `redemption_tokens` — canjes y tokens SHA-256.
- `campaigns` — multiplicadores/bonos.
- `business_economic_profiles`, `business_economic_snapshots`.
- `audit_log` — operaciones por negocio con actor y categoría.
- `private.bootstrap_admins` — correos con rol admin automático.

Autorización: RLS por negocio + RPC `SECURITY DEFINER`. El cliente solo usa clave pública.