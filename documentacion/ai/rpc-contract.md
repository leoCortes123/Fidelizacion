# Contrato RPC (resumen)

Fuente: `documentacion/ARQUITECTURA.md`, `documentacion/ESTADO_PROYECTO.md`. Actualizar este archivo cuando cambie una firma.

## Públicas (anon)
- `business_public_get(slug)` — ficha pública del negocio (incluye redes sociales: `instagram`, `facebook`, `tiktok`, `twitter`, `youtube`, `website`).

## Autenticación / perfil
- `handle_new_user` (trigger) — crea profile (con `account_type` `customer` | `admin`) y roles; bootstrap admin si está en `private.bootstrap_admins`.
- `profile_set_account_type(p_account_type)` — guarda el tipo de cuenta (`customer` | `admin`) en `profiles` tras OAuth/registro sin otorgar permisos globales legacy.
- `profile_avatar_set(p_avatar_url)` — guarda o limpia `profiles.avatar_url` dentro de `business-assets/avatars/<user_id>/`.
- `get_my_profile`, `profile_update` — incluyen `avatar_url`.
- `get_my_app_roles()` — combina `user_roles`, `business_memberships` y `profiles.account_type = 'admin'`.

## Negocios y membresías
- `business_create`, `business_join`, `business_profile_get`, `business_profile_update` (acepta redes sociales `p_facebook`, `p_tiktok`, `p_twitter`, `p_youtube`), `business_memberships_list` (incluye `nickname`, `phone`, `updated_at`), `business_dashboard_summary`, `business_recent_activity`.
- Invitaciones QR de miembros: `business_member_invite_create` (admin), `business_member_invite_preview` (anon/authenticated), `business_member_invite_accept` (authenticated; crea membresía o cambia rol si ya era cliente; no degrada admin ni encargado), `business_member_invite_revoke` (admin).

## Programa y carta
- `business_program_upsert`, `products_list` (staff ve activos/inactivos y `cost_cop`; cliente miembro ve solo activos con `cost_cop = null`), `product_upsert` (acepta `p_image_url` en `business-assets`), `product_combo_set`, `loyalty_reward_upsert` (acepta `p_image_url` en `business-assets`), `loyalty_rewards_list`, `loyalty_rewards_available`.

## Compras
- `purchase_qr_create`, `purchase_qr_create_with_items`, `purchase_qr_regenerate(p_business_id, p_purchase_id)` (rota `token_hash` solo si los puntos siguen `pending_claim` y vigentes antes de `expires_at`, conservando el `expires_at` original), `purchase_qr_preview`, `purchase_qr_claim`, `business_purchases_page` / `business_purchase_detail` (derivan estado efectivo `'expired'` cuando `expires_at <= now()`).

## Puntos y canje
- `customer_businesses_summary`, `staff_get_customer` (incluye `reward_type`, `reward_image_url`, `origin`, `request_status`, `approved_at` en `redemptions`), `reward_request_redemption`, `redemption_token_validate`, `redemption_approve`, `redemption_deliver`, `redemption_cancel`, `redemption_redeem_by_token`.

## Cliente
- `customer_redemptions_list`, `customer_purchases_list`.

## Economía
- `business_economic_profile_upsert`, `business_economic_summary`, `business_economic_snapshot`.

## Auditoría
- `business_audit_log_page` (paginada, filtros por operación/categoría/actor/fechas/texto).

## Encargado / escaneo
- `redemption_scan_deliver` (flujo `/scan/:token`).

> Nota: nombres exactos y parámetros en las migraciones `fidelizacionApi/supabase/migrations/`. Para detalle, grep en la carpeta de migraciones.