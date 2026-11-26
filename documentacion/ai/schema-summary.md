# Esquema (resumen)

Tablas clave (multiempresa, todo lleva `business_id`):

- `profiles` — nombre, correo, `nickname`, `phone`, `birth_date` (18+), `avatar_url`, `account_type` (`customer` | `admin`), `deleted_at` (marca de anonimización irreversible; RLS + triggers `BEFORE INSERT` rechazan cuentas eliminadas), fechas.
- `user_roles` — rol global legacy (`customer`, `admin`, `registrar`).
- `businesses` — negocio, slug, logo, contacto y redes (`instagram`, `facebook`, `tiktok`, `twitter`, `youtube`, `website`), estado.
- `business_memberships` — usuario ↔ negocio con rol (`admin`/`encargado`/`cliente`).
- `business_member_invites` — invitaciones QR de un solo uso (hash SHA-256, rol destino, expiración).
- `business_programs` — reglas de acumulación/canje.
- `products` — carta (incluye combos y foto `image_url`).
- `rewards` / `loyalty_rewards` — recompensas con límites y foto `image_url`.
- `purchases` + `purchase_items` — compras con snapshot de reglas.
- `points_ledger` + `point_lots` — libro inmutable y lotes con `expires_at`.
- `redemptions` + `redemption_tokens` — canjes y tokens SHA-256.
- `campaigns` — multiplicadores/bonos.
- `business_economic_profiles`, `business_economic_snapshots`.
- `audit_log` — operaciones por negocio con actor y categoría.
- `user_legal_consents` — registro auditable e inmutable (trigger `user_legal_consents_immutable`) de consentimientos legales y marketing (`legal_document_type`: `terms_customer`, `terms_business`, `privacy_policy`, `dpa`, `marketing_whatsapp`, `marketing_email`, `marketing_push`), versión `YYYY-MM-DD`, `accepted_at`, `revoked_at`, `source_route`, `user_agent`; RLS solo `SELECT` propio (cuentas activas), escritura exclusiva vía RPC, FKs `ON DELETE RESTRICT`.
- `account_deletion_log` — constancia inmutable sin PII (trigger `account_deletion_log_immutable`) de cuentas suprimidas (`user_id` unique FK `ON DELETE RESTRICT`, `deleted_at`, `reason`, conteos agregados); RLS activado sin acceso para `anon` ni `authenticated`.
- `private.bootstrap_admins` — correos con rol admin automático.

Autorización: RLS por negocio + RPC `SECURITY DEFINER`. El cliente solo usa clave pública.