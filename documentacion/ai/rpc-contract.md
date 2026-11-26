# Contrato RPC (resumen)

Fuente: `documentacion/ARQUITECTURA.md`, `documentacion/ESTADO_PROYECTO.md`. Actualizar este archivo cuando cambie una firma.

## Públicas (anon)
- `business_public_get(slug)` — ficha pública del negocio (incluye redes sociales: `instagram`, `facebook`, `tiktok`, `twitter`, `youtube`, `website`).

## Autenticación / perfil
- `handle_new_user` (trigger) — crea profile (con `account_type` `customer` | `admin`) y roles; bootstrap admin si está en `private.bootstrap_admins`.
- `profile_set_account_type(p_account_type)` — guarda el tipo de cuenta (`customer` | `admin`) en `profiles` tras OAuth/registro sin otorgar permisos globales legacy.
- `profile_avatar_set(p_avatar_url)` — guarda o limpia `profiles.avatar_url` dentro de `business-assets/avatars/<user_id>/` y devuelve `previous_avatar_url` y `previous_storage_path` (cuando cambió o se limpió) para borrarlo vía Storage API.
- `get_my_profile`, `profile_update` — incluyen `avatar_url`; `profile_update` exige edad ≥ 18 años en `America/Bogota` (`underage_birth_date`) y rango `>= 1900-01-01` (`invalid_birth_date`).
- `get_my_app_roles()` — combina `user_roles`, `business_memberships` y `profiles.account_type = 'admin'`.

## Negocios y membresías
- `business_register` (exige consentimientos vigentes de `terms_business` + `dpa` con `business_id is null`; error `LEGAL_CONSENT_REQUIRED`), `business_join`, `business_profile_get`, `business_profile_update` (acepta redes sociales `p_facebook`, `p_tiktok`, `p_twitter`, `p_youtube`), `business_logo_set` (devuelve `previous_logo_url` y `previous_storage_path` cuando no la referencia otro ítem del negocio), `business_memberships_list` (incluye `nickname`, `phone`, `updated_at`), `business_search_profiles` (solo admin del negocio, con rate limit; restringida a miembros propios o coincidencia exacta de correo para no miembros, máx. 1 fila sin `user_id`, `full_name` ni `avatar_url`), `business_dashboard_summary`, `business_recent_activity`.
- Invitaciones QR de miembros: `business_member_invite_create` (admin), `business_member_invite_preview` (anon/authenticated), `business_member_invite_accept` (authenticated; crea membresía o cambia rol si ya era cliente; no degrada admin ni encargado), `business_member_invite_revoke` (admin).

## Cumplimiento legal, consentimientos y derechos del titular (solo authenticated)
- `legal_current_versions()` — devuelve JSONB con las versiones vigentes (`terms_customer`, `terms_business`, `privacy_policy`, `dpa`, `cookies`), sincronizado con `LEGAL_VERSIONS`.
- `legal_consent_record(p_documents legal_document_type[], p_business_id uuid default null, p_source_route text default '/', p_user_agent text default null)` — registra consentimientos con versión forzada desde servidor (idempotente sobre activos; prioriza `user-agent` HTTP del servidor; exige membresía/rol admin si `p_business_id` no es nulo; `terms_customer` y `privacy_policy` siempre globales).
- `legal_consent_status()` — devuelve `has_pending`, `is_business_admin`, `required_documents`, `accepted_documents`, `pending_documents` y `current_versions` (clientes/encargados: `terms_customer` + `privacy_policy`; admin con negocio activo: además `terms_business` + `dpa`).
- `legal_consents_my_list()` — historial de consentimientos del usuario autenticado (con `business_name` e `is_current_version`).
- `legal_consent_revoke(p_document_type legal_document_type, p_business_id uuid default null, p_revoke_all boolean default true)` — revoca consentimientos activos de marketing (`marketing_whatsapp`, `marketing_email`, `marketing_push`): con `p_business_id` revoca solo ese negocio; con `p_business_id = null` y `p_revoke_all = true` (defecto) hace opt-out total del canal (global + negocios); con `p_revoke_all = false` revoca solo la fila global. Rechaza documentos obligatorios con `consent_revoke_requires_account_deletion`.
- `profile_export_my_data()` — exporta en JSONB (`schema_version: '1.0'`) los datos propios del titular autenticado (perfil, consentimientos, membresías con saldo, compras QR con ítems + directas, canjes y movimientos de puntos; rate limit 10/5 min; sin PII de terceros, `cost_cop` ni `token_hash`).
- `account_delete_my_account(p_confirm text)` — exige confirmación literal `'ELIMINAR'` (`invalid_delete_confirmation`) y bloquea si es último admin de un negocio activo (`ACCOUNT_LAST_ADMIN`, con bloqueo determinista `FOR UPDATE` coordinado con `business_membership_create`). Anonimiza irreversiblemente `profiles` (`Usuario eliminado`, `deleted+<uuid>@anonymized.invalid`, `deleted_at = now()`) conservando el ledger inmutable; transfiere `businesses.created_by` a un co-admin activo si existe; cancela canjes abiertos y elimina tokens sin consumir, invitaciones pendientes, membresías, `user_roles` y entradas del correo en `private.bootstrap_admins`; revoca consentimientos de marketing; limpia PII de auditoría (`actor_email` y `metadata.customer_nickname`/`customer_email`); registra constancia inmutable en `account_deletion_log`; anonimiza/bloquea `auth.*` (`banned_until = '2999-12-31 23:59:59+00'`, `deleted_at`, borra `identities`/`sessions`/`refresh_tokens`/`mfa_factors`/`one_time_tokens`/`flow_state`/`oauth_*`/`audit_log_entries`); devuelve `avatar_storage_paths` para limpieza vía Storage API. Todas las RPC de perfil/cuenta/negocio/consentimientos rechazan cuentas eliminadas (`account_deleted`) y las búsquedas de staff excluyen `deleted_at is not null`.

## Programa y carta
- `business_program_upsert`, `products_list` (staff ve activos/inactivos y `cost_cop`; cliente miembro ve solo activos con `cost_cop = null`), `product_upsert` (acepta `p_image_url` en `business-assets` y devuelve `previous_storage_path` si la imagen reemplazada ya no tiene referencias), `product_combo_set`, `loyalty_reward_upsert` (acepta `p_image_url` en `business-assets` y devuelve `previous_storage_path` si la imagen reemplazada ya no tiene referencias), `loyalty_rewards_list`, `loyalty_rewards_available`.

## Compras
- `purchase_qr_create`, `purchase_qr_create_with_items`, `purchase_qr_regenerate(p_business_id, p_purchase_id)` (rota `token_hash` solo si los puntos siguen `pending_claim` y vigentes antes de `expires_at`, conservando el `expires_at` original), `purchase_qr_preview`, `purchase_qr_claim`, `business_purchases_page` / `business_purchase_detail` (derivan estado efectivo `'expired'` cuando `expires_at <= now()`).

## Puntos y canje
- `customer_businesses_summary`, `customer_points_expiry_summary(p_business_id)` (devuelve al cliente autenticado la regla `points_expiry_days`, `fifo_enabled`, `balance`, `next_expiry_at`, `next_expiry_points`, `expiring_within_30_days_points` y hasta 5 `upcoming_lots` calculados con la misma lógica FIFO que `points_expire_due`), `staff_get_customer` (incluye `reward_type`, `reward_image_url`, `origin`, `request_status`, `approved_at` en `redemptions`), `reward_request_redemption`, `redemption_token_validate`, `redemption_approve`, `redemption_deliver`, `redemption_cancel`, `redemption_redeem_by_token`.

## Cliente
- `customer_redemptions_list`, `customer_purchases_list`.

## Economía
- `business_economic_profile_upsert`, `business_economic_summary`, `business_economic_snapshot`.

## Auditoría
- `business_audit_log_page` (paginada, filtros por operación/categoría/actor/fechas/texto).

## Encargado / escaneo
- `redemption_scan_deliver` (flujo `/scan/:token`).

> Nota: nombres exactos y parámetros en las migraciones `fidelizacionApi/supabase/migrations/`. Para detalle, grep en la carpeta de migraciones.