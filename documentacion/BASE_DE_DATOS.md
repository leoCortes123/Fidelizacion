# Base de datos, RPC y RLS

> **Repositorio:** `fidelizacionApi`. Las rutas `supabase/…`, `tests/db/…` y
> `scripts/test-db.sh` son relativas a ese repositorio.

## Migraciones

| Migración | Contenido |
| --- | --- |
| `20251021000100_schema.sql` | Esquema legacy: perfiles, roles, compras, recompensas, libro y auditoría |
| `20251021000200_functions.sql` | RPC legacy, reclamo atómico, rate limiting y canje administrativo |
| `20251021000300_policies.sql` | RLS y grants del esquema legacy |
| `20261023000100_admin_flow.sql` | Admin inicial, canje/anulación y panel |
| `20261024000100_business_isolation_schema.sql` | **Multiempresa:** negocios, membresías, productos, programa, recompensas, cuentas, transacciones, redenciones, tokens, económico, eventos y auditoría |
| `20261024000200_business_isolation_functions.sql` | Registro de negocio, membresías, programa |
| `20261024000300_products_rewards_functions.sql` | Carta y recompensas |
| `20261024000400_points_transactions.sql` | Libro de puntos, acumulación, reverso y bonos |
| `20261024000500_redemptions_tokens.sql` | Solicitud, QR, aprobación, entrega y cancelación |
| `20261024000600_economic_audit.sql` | Perfil económico, panel y auditoría |
| `20261024000700_business_isolation_policies.sql` | RLS y grants del módulo nuevo |
| `20261024000800_missing_functions.sql` | `businesses_list`, `loyalty_program_get` |
| `20261024000900_completion_hardening.sql` | Roles por negocio, afiliación, reemisión, búsqueda de perfiles y hardening |
| `20261025000100_fix_products_list_ambiguous.sql` | Corrección de `products_list` |
| `20261025000200_phase4_purchases_economic_audit.sql` | Compras auditadas, reverso y perfil económico |
| `20261025000300_phase5_onboarding.sql` | `business_update` (nombre, zona horaria y días) |
| `20261025000400_phase6_expiry_campaigns_snapshots.sql` | Vencimiento FIFO, campañas, snapshots y jobs |
| `20261025000500_security_hardening_function_grants.sql` | Revocación de `PUBLIC` y blindaje del posteo interno |
| `20261025000600_phase7_reward_limits.sql` | Límites por periodo/total, coherencia de descuentos y validaciones |
| `20261025000700_phase7_configurable_benefit.sql` | Conserva el importe del beneficio configurable |
| `20261025000800_purchase_qr_flow.sql` | Venta con QR por negocio y reclamo del cliente |
| `20261025000900_purchase_qr_grants.sql` | Grants del flujo de venta con QR |
| `20261025001000_loopoint_identity_business_profile.sql` | Nickname, perfil de negocio, logo, frecuencia y búsqueda |
| `20261025001100_business_assets_storage.sql` | Bucket `business-assets` y `business_logo_set` |
| `20261025001200_catalog_combos_purchase_items.sql` | Combos, líneas snapshot, detalle y métricas de compra |
| `20261025001300_dashboard_summary.sql` | `business_dashboard_summary` y actividad reciente |
| `20261025001400_customers_without_manual_redeem.sql` | Clientes, compras manuales y sin canje manual |
| `20261025001500_redemption_scan_flow.sql` | **Canje escaneado:** `/scan/:token`, `origin`, contexto y entrega por token |
| `20261025001600_customer_multi_business.sql` | **Portal multi-negocio:** `customer_businesses_summary`, canjes con slug/logo e índices |
| `20261026000100_audit_log_readable.sql` | **Auditoría legible:** `business_audit_log_page` con actor, filtros y texto libre |
| `20261026000200_backfill_grants_indexes.sql` | **Cierre F9:** backfill de nicknames/frecuencia, barrido de grants, comentarios e índice `products_business_kind_idx` |

Todas (**31**) están aplicadas en local y en remoto (`gxfytcquyobhhbjipbea`).

Semilla: `supabase/seed.sql` (configuración y catálogo legacy, sin usuarios).

## Tipos del módulo multiempresa

| Tipo | Valores |
| --- | --- |
| `business_role` | `admin`, `encargado`, `cliente` |
| `loyalty_reward_type` | `free_product`, `fixed_discount`, `percentage_discount`, `configurable_benefit` |
| `redemption_request_status` | `pending`, `approved`, `delivered`, `cancelled`, `expired` |
| `point_movement_type` | `purchase_credit`, `redemption_debit`, `redemption_refund`, `expiry_debit`, `admin_adjustment` |
| `app_role` | `customer`, `admin`, `registrar` (legacy) |

## Tablas del módulo multiempresa

| Tabla | Clave y reglas |
| --- | --- |
| `businesses` | `slug` único, zona horaria IANA, días de operación 1–7, `is_active` |
| `business_memberships` | `(business_id, user_id)` único; rol; `can_approve_redemptions` solo para encargados |
| `products` | Carta por negocio; precio > 0; costo opcional ≥ 0 |
| `loyalty_programs` | Una fila por negocio; COP por punto, puntos por COP, vencimiento, tasa de presupuesto, vigencia del QR y `is_active` |
| `loyalty_rewards` | Tipo, producto, puntos, mínimo de compra, descuento, vigencia y límites |
| `loyalty_point_accounts` | `(business_id, customer_id)` único; saldo proyectado |
| `loyalty_point_transactions` | Libro inmutable por trigger; `expires_at` por lote; clave idempotente única |
| `loyalty_redemptions` | Estado, puntos, código, clave idempotente por cuenta, responsables y fechas |
| `loyalty_redemption_tokens` | SHA-256 del token, vencimiento y consumo; nunca el token en claro |
| `business_economic_profiles` | Ventas, días, ganancia, margen, clientes/día, presupuesto y `data_status` |
| `loyalty_purchase_events` | Evento de compra con elegibilidad, puntos y clave idempotente |
| `business_audit_logs` | Operaciones del negocio con actor y metadata (sin secretos) |
| `loyalty_campaigns` | Multiplicador 1–10, bono, compra mínima y vigencia |
| `loyalty_budget_snapshots` | Un registro por negocio y mes; reproducible |

### Reglas de negocio relevantes

- **Puntos:** `floor(importe_elegible / cop_por_point_unit)`, con tope de 1.000.000.
- **Vencimiento:** cada crédito guarda `expires_at`; `points_expire_due` consume los
  lotes vencidos del más antiguo al más nuevo (FIFO), descuenta lo ya gastado, no
  deja saldo negativo y es idempotente (`expiry:<lote>`).
- **Campañas:** se aplica la campaña activa y vigente con mayor beneficio; la
  acumulación registra `rule_version = v1+campaign:<id>` y devuelve puntos base.
- **Recompensas:** el tipo de descuento debe ser coherente con sus importes; el
  descuento no puede superar la compra mínima.
- **Límites de canje:** por cliente (histórico), por periodo móvil y total del
  negocio. Los canjes cancelados no consumen límite.
- **Reserva:** al solicitar se debita; al cancelar/rechazar se devuelve; al entregar
  no se vuelve a debitar. El token se consume al aprobar.
- **Presupuesto:** ventas mensuales = ventas diarias × días de operación; referencia
  = ventas × `budget_rate`; el máximo configurado manda en el panel.

## Funciones principales (RPC)

### Negocio, miembros y programa

`business_register`, `business_update`, `businesses_list`, `business_public_get`,
`business_join`, `business_current_membership`, `require_business_role`,
`business_membership_create/update/list`, `business_search_profiles`,
`get_my_app_roles`, `loyalty_program_configure/get`.

### Carta y recompensas

`product_upsert/list`, `loyalty_reward_upsert/list/available`.

### Puntos

`loyalty_account_ensure/balance/transactions`, `loyalty_transaction_post` (interno),
`points_accrue_from_purchase`, `points_reverse_purchase`, `points_grant_bonus`,
`points_expire_due`, `points_expire_all_due` (solo `service_role`).

### Compras y auditoría

Flujo vigente de venta con QR: `purchase_qr_create`, `purchase_qr_preview`,
`purchase_qr_claim`, `business_purchases_list`, `purchase_qr_cancel`.

`loyalty_purchase_register` y `loyalty_purchase_revert` siguen disponibles para
ajustes administrativos, pero la web ya no asigna puntos manualmente desde caja.
También: `business_economic_profile_upsert/get`, `business_dashboard_economic`,
`business_audit_log_list/page`.

`business_audit_log_page(p_business_id, p_operation, p_limit, p_offset, p_actor,
p_from, p_to, p_search)` devuelve las operaciones del negocio paginadas y con
`actor_name` (join con `profiles`), `total_count` y orden descendente. Acepta:

- `p_operation`: una operación exacta o varias separadas por coma; los prefijos
  (`purchase.`, `redemption.`, `campaign.`, `business.`, `loyalty_program.`,
  `economic_profile.`, `product.`, `membership.`, `reward.`, `points.`,
  `budget.`) filtran por categoría completa.
- `p_actor`: nombre o correo del actor (coincidencia parcial, sin comodines).
- `p_from` / `p_to`: rango de fechas; `p_to` es exclusivo y un rango inválido
  devuelve `invalid_date_range`.
- `p_search`: texto libre sobre operación, entidad, actor y metadata.

Los comodines `%` y `_` se escapan, así que se buscan como texto literal. La
función exige sesión (`not_authenticated`) y rol `admin`/`encargado` del negocio
(`forbidden`); los índices `business_audit_logs_operation_idx` y
`business_audit_logs_actor_idx` apoyan los filtros.

La tabla legada `audit_log` (ajustes globales de plataforma) sigue disponible
como `admin_get_audit_log`; la web la muestra en la pestaña «Avanzado» con las
mismas etiquetas legibles.

`purchases.business_id` vincula cada venta con su negocio. Las compras antiguas
del flujo global quedan con `business_id` nulo.

### Canjes con QR

`reward_request_redemption`, `redemption_token_validate`,
`redemption_token_reissue`, `redemption_approve`, `redemption_deliver`,
`redemption_cancel`, `loyalty_redemptions_list`, `loyalty_my_redemptions`.

El flujo escaneado añade:

- `redemption_token_context(p_token)` → negocio, recompensa, nickname, estado,
  vencimiento y `can_redeem`. Resuelve el negocio desde el token; no acepta
  `business_id` y exige membresía `admin`/`encargado` con permiso.
- `redemption_redeem_by_token(p_token)` → aprueba y entrega en una transacción,
  consume el token y audita `redemption.scanned` + `redemption.delivered`.
- `loyalty_redemptions_list(..., p_origin)` → añade `origin` (`manual`/`qr_scan`)
  y `customer_nickname`, con filtro opcional por origen.

`loyalty_redemptions.origin` nace en `manual`; la entrega escaneada lo cambia a
`qr_scan`. Los tokens vencidos, consumidos o de otro negocio se rechazan sin
revelar datos.

### Portal del cliente multi-negocio

`customer_businesses_summary()` devuelve una fila por membresía del usuario
autenticado: negocio, slug, logo, rol dentro del negocio, programa activo, saldo,
recompensas asequibles, solicitudes en curso, última compra y frecuencia. No acepta
`business_id`; el servidor deriva todo de `business_memberships` y calcula saldo y
frecuencia por negocio, sin mezclarlos.

`loyalty_my_redemptions` incluye `business_slug` y `business_logo_url` para que la
lista global de canjes identifique el negocio. Los índices
`loyalty_redemptions_customer_status_idx` y
`loyalty_point_accounts_customer_business_idx` apoyan esas consultas.

### Campañas y presupuesto

`loyalty_campaign_upsert/list/delete`, `loyalty_budget_snapshot_create/list/all`
(el masivo, solo `service_role`).

## Matriz RLS (módulo multiempresa)

| Tabla | Cliente | Encargado | Admin |
| --- | --- | --- | --- |
| `businesses` | Miembro | Miembro | Miembro |
| `business_memberships` | Propia | Miembros | Miembros |
| `products`, `loyalty_programs`, `loyalty_rewards` | Miembro | Miembro | Miembro |
| `loyalty_point_accounts`, `loyalty_point_transactions` | Propios | Miembros | Miembros |
| `loyalty_redemptions` | Propias | Miembros | Miembros |
| `loyalty_redemption_tokens` | — | Miembros (con permiso para canjear) | Miembros |
| `business_economic_profiles`, `business_audit_logs` | Miembro | Miembro | Miembro |
| `loyalty_purchase_events`, `loyalty_campaigns`, `loyalty_budget_snapshots` | Miembro | Miembro | Miembro |

No hay políticas de escritura para clientes: las mutaciones pasan por RPC
`SECURITY DEFINER` que validan membresía y rol. La migración de hardening revocó el
`EXECUTE` heredado de `PUBLIC` y el posteo interno solo lo usan funciones internas.

La migración de cierre (`20261026000200`) repite el barrido de forma idempotente:
revoca `EXECUTE` a `PUBLIC` y `anon` en todo el esquema público, vuelve a conceder
solo las RPC explícitas a `authenticated` y a `service_role`, y falla si encuentra
alguna función `SECURITY DEFINER` ejecutable por `PUBLIC`. `anon` queda limitado a
`business_public_get(text)`, `purchase_qr_preview(text)` y `business_member_invite_preview(text)`. También rellena nicknames
y criterios de frecuencia que hubieran quedado `NULL`, sin pisar valores existentes.

## Concurrencia e idempotencia

- **Dos reclamos del mismo QR legacy:** `FOR UPDATE` + único de crédito; solo uno gana.
- **Dos aprobaciones del mismo canje:** `FOR UPDATE` sobre la redención; la segunda
  ve `redemption_not_pending` (probado con dos conexiones reales).
- **Dos escaneos del mismo QR:** `redemption_redeem_by_token` bloquea token y
  redención con `FOR UPDATE`; el segundo intento ve `redemption_already_delivered`
  o `token_already_consumed`.
- **Reintento de solicitud:** `(account_id, idempotency_key)` único; devuelve la
  misma redención sin reservar de nuevo.
- **Reintento de compra:** clave única en el evento y en el movimiento; también
  detecta compras de 0 puntos.
- **Reverso repetido:** clave `purchase-event:<id>:reverse`; devuelve `duplicate`.
- **Vencimiento repetido:** clave `expiry:<lote>`; el segundo intento no descuenta.

## Programación

Cuando `pg_cron` está disponible, la migración de Fase 6 crea:

- vencimiento diario a las 05:00;
- snapshot mensual el día 1 a las 06:00.

Ambos llaman funciones que exigen `service_role`. Si `pg_cron` no existe, las RPC
quedan para ejecución manual y la migración no falla.

## Esquema legacy

El flujo de un solo negocio (`program_settings`, `purchases`, `points_ledger`,
`rewards`, `redemptions`, `audit_log`, `config_history`) sigue activo para
compatibilidad y está etiquetado como **“Sistema anterior”** en la web. El módulo
multiempresa no lo modifica. La tabla `points_ledger` conserva su inmutabilidad y su
trigger diferido de saldo no negativo.
