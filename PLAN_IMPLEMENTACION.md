# Plan de completación — Fidelización por puntos multiempresa (v2)

**Fecha:** 25/10/2026  
**Estado:** FASES 0–7 COMPLETADAS (local, remoto y web desplegada) — alcance completo implementado y probado
**Sustituye a:** v1 (que declaraba “COMPLETADO” de forma incorrecta)  
**Objetivo:** llegar a un módulo demostrable de punta a punta y luego al alcance completo del prompt original.

> **Nuevo ciclo (25/10/2026):** rediseño funcional y visual **Loopoint** a partir de
> [`documentacion/cambiosPlataforma.md`](documentacion/cambiosPlataforma.md). El plan de
> ejecución, las migraciones propuestas y la matriz de trazabilidad están en
> [`documentacion/PLAN_CAMBIOS_PLATAFORMA.md`](documentacion/PLAN_CAMBIOS_PLATAFORMA.md).
> Este documento describe el estado del módulo multiempresa ya entregado; no se modifica
> el historial de fases 0–7.

### Estado de ejecución (25/10/2026) — Fase 0

- **Migración `20261024000900_completion_hardening.sql` aplicada** en local y en el proyecto
  remoto `fidelizacion01` (`gxfytcquyobhhbjipbea`). Paridad verificada con
  `supabase migration list`.
- **Pruebas SQL nuevas**: `tests/db/loyalty-phase0-tests.sql` (roles, afiliación,
  acumulación, QR, reemisión, entrega y aislamiento). Integradas en `scripts/test-db.sh`.
  `npm test` en verde, incluidas las pruebas existentes y la de concurrencia.
- **Web**: `get_my_app_roles`, `businesses_list` con rol, contexto de negocio con
  `selectedRole`, hooks de afiliación/búsqueda/redenciones/reemisión/compra.
  `tsc -b`, 31 unitarias y 6 e2e en verde.
- **Bugs reales corregidos**:
  1. RLS con recursión infinita en `business_memberships` y `businesses`.
  2. `loyalty_transaction_post` tenía el orden de argumentos incorrecto; **todo el libro
     de puntos fallaba** al ejecutarse.
  3. `redemption_cancel` escribía `cancelled_by`, columna que no existía.
  4. `redemption_token_validate` devolvía `account_id` como `customer_id`.
  5. `points_*` no validaba rol ni pertenencia, y aceptaba `created_by` del navegador.
  6. `RewardsPage` no creaba recompensas (`if (!editing) return`) y ocultaba las inactivas.
- **Verificación remota**: `business_public_get('tacos-don-pepe')` responde con el negocio
  de prueba; `get_my_app_roles` devuelve `["admin","customer"]` y `businesses_list`
  devuelve el negocio con `role=admin`, confirmando funciones, grants y RLS.

**Resultado:** Fase 0 cerrada. Se continuó con la Fase 1.

### Estado de ejecución (25/10/2026) — Fase 1

- **Web**: nuevas páginas `/admin/program` y `/admin/products`; `RewardsPage` completo
  (producto, importes, porcentaje, vigencia y límites); rutas, menú lateral y accesos
  rápidos del dashboard actualizados. El enlace roto a `/admin/program` ya funciona.
- **Validación**: Zod en programa, productos y recompensas; mensajes en español y
  comprobaciones cruzadas (descuento ≤ compra mínima, porcentaje 1–100, producto
  obligatorio en producto gratis, costo > precio como advertencia bloqueante).
- **Seguridad de datos**: activar/desactivar una recompensa ahora reenvía todos sus
  campos (antes el upsert parcial los borraba).
- **Pruebas**: 45 unitarias (14 nuevas: programa, carta y recompensas) y 7 e2e
  (nueva: configurar programa + crear producto + crear recompensa + recargar y
  verificar persistencia). `tsc -b`, `vitest` y `playwright` en verde; build correcto.
- **Pendiente entonces (resuelto en Fase 2)**: mostrar el QR al cliente, migrar “Mis
  canjes”, pantalla admin de solicitudes y confirmación de entrega.

### Estado de ejecución (25/10/2026) — Fase 2

- **Cliente**: al solicitar una recompensa se abre el diálogo de éxito con QR
  (`QRCodeCanvas`), referencia del canje y cuenta atrás. El token se guarda por pestaña en
  `sessionStorage` (`loyalty:token:<redemptionId>`) y nunca incluye datos personales.
- **“Mis canjes”** migrado a `loyalty_my_redemptions()`: negocio, recompensa, puntos,
  estado, fechas y acción “Ver QR”. Si el token se perdió o venció se puede reemitir
  mientras la solicitud siga `pending`.
- **Administración**: nueva pantalla `/admin/redemptions` con filtro por estado, cliente,
  recompensa, puntos, fechas y acciones aprobar / rechazar / confirmar entrega / cancelar
  con motivo. Gating por `selectedRole` y `can_approve_redemptions`.
- **Encargado**: validación de QR con aviso y bloqueo si el token venció; tras aprobar se
  confirma la entrega en el mismo diálogo o desde la lista “Aprobadas pendientes de
  entrega”. Guard de rol: un encargado sin permiso ve un aviso, no el formulario.
- **Hooks**: invalidación por prefijo de saldo, movimientos, solicitudes y lista del
  cliente tras solicitar/aprobar/entregar/cancelar/reemitir.
- **Pruebas**: 59 unitarias (14 nuevas de QR, “Mis canjes”, admin y encargado) y 10 e2e
  (flujo completo solicitud → QR → reemisión → aprobación → entrega → estado final;
  admin aprueba/entrega/cancela; encargado sin permiso). `tsc -b`, `vitest`, `playwright`
  y build en verde.
- **Decisión**: el token se consume al aprobar, así que el QR solo se muestra mientras la
  solicitud está `pending`; tras aprobar, el cliente ve “aprobado, pendiente de entrega”.

### Estado de ejecución (25/10/2026) — Fase 3

- **Roles y destino**: `defaultPathForRoles` distingue admin, encargado (`registrar`) y
  cliente. Tras iniciar sesión se consulta `businesses_list`: si hay negocios se abre
  `/business/select` (rol por negocio); si no, el portal del rol global.
- **Selector por negocio**: `BusinessProvider` guarda la elección por usuario en
  `localStorage` (`fidelizacion:selected-business:<userId>`), sin `setState` en render,
  y expone `selectedRole` / `canApproveRedemptions`. `BusinessSwitcher` está disponible
  en las cabeceras de administración y cliente.
- **Guards**: `RequireBusinessRole` protege `/admin/*` (solo admin del negocio) y
  `/encargado` (admin/encargado). `RequireAdmin` envía al encargado a `/encargado` en
  lugar de a “Acceso restringido”; el cliente sigue viendo `/unauthorized`.
- **Miembros**: diálogo “Añadir miembro” con búsqueda por nombre/correo
  (`business_search_profiles`), rol encargado/cliente y permiso de aprobación. Los
  perfiles que ya pertenecen al negocio no se pueden volver a añadir; el backend impide
  degradar al último administrador.
- **Afiliación**: página pública `/join/:slug` con ficha del negocio, estado del programa
  y CTA que conserva el destino por login. `business_join` crea la membresía `cliente`,
  recuerda el negocio y lleva al saldo. El dashboard incluye “Invitar clientes” con
  enlace copiable y QR.
- **Pruebas**: 77 unitarias (18 nuevas de contexto, guards, afiliación y miembros) y 13
  e2e (afiliación pública, invitación/añadir encargado y redirección de encargado).
  `tsc -b`, `vitest`, `playwright` y build en verde.

### Estado de ejecución (25/10/2026) — Fase 7

- **Pruebas SQL de aceptación**: nuevo `tests/db/loyalty-tests.sql` con los **20 casos**
  del prompt, integrado en `scripts/test-db.sh`. Cubre registro, roles, aislamiento,
  recompensas, acumulación, reverso, duplicados, saldo, reserva/liberación, QR
  vigente/vencido/reutilizado, doble aprobación, vencimiento FIFO, presupuesto, datos
  incompletos, límites, acceso a datos ajenos, campañas y snapshots.
- **Concurrencia de aprobaciones**: `test-db.sh` añade dos conexiones reales que
  aprueban el mismo canje; solo una gana y queda un único token consumido y un único
  débito.
- **Brechas cerradas**: `max_redemptions_per_period`, `redemption_period_days` y
  `total_redemption_limit` se guardaban pero no se aplicaban; ahora
  `reward_request_redemption` los valida. `loyalty_reward_upsert` exige coherencia
  entre tipo y descuento, rechaza descuento > compra mínima y periodos incompletos.
  Migraciones `20261025000600_phase7_reward_limits.sql` y
  `20261025000700_phase7_configurable_benefit.sql` aplicadas en local y remoto.
- **Pruebas web**: 99 unitarias (nueva de mensajes de límites) y 18 E2E. El puerto de
  Playwright pasa a **5199** para no reutilizar un `npm run dev` con otro backend.
  `tsc -b`, `vitest`, `playwright`, build y smoke en verde.
- **Documentación**: `ENTREGA_FINAL.md`, `ESTADO_PROYECTO.md`, `PRUEBAS.md`,
  `BASE_DE_DATOS.md` y `SEGURIDAD.md` actualizados al alcance real.
- **Despliegue**: `db push` aplicado (20/20 en paridad). Build de producción y
  despliegue en Vercel (`https://fidelizacion01.vercel.app`); verificado que el
  bundle apunta al proyecto Supabase correcto y que el fallback SPA responde.
- **Total**: 275 aserciones SQL, 2 pruebas de concurrencia, 99 unitarias y 18 E2E.

**Siguiente:** operación y despliegue final (dominio, OAuth, protección de Vercel, cron y Android).

### Estado de ejecución (25/10/2026) — Fase 6

- **Vencimiento por lote**: `loyalty_point_transactions.expires_at`, asignado por
  `loyalty_transaction_post` según `points_expiry_days` y con backfill de créditos
  históricos. `points_expire_due(business_id)` consume los lotes en FIFO, descuenta
  primero lo ya gastado, no deja saldo negativo, es idempotente (`expiry:<lote>`) y
  escribe `points.expired` en auditoría. `points_expire_all_due()` es solo para el
  rol de servicio/cron.
- **Campañas**: tabla `loyalty_campaigns` con multiplicador (1–10), bono fijo, compra
  mínima y vigencia. CRUD auditado (`loyalty_campaign_upsert/list/delete`) y aplicación
  automática en `points_accrue_from_purchase`: se elige la campaña vigente con mayor
  beneficio, el resultado se registra con `rule_version = v1+campaign:<id>` y la
  respuesta incluye `base_points`, `campaign_id` y multiplicador/bono.
- **Snapshots mensuales**: tabla `loyalty_budget_snapshots` con ventas, presupuesto de
  referencia/máximo, costo redimido/pendiente y puntos emitidos/canjeados.
  `loyalty_budget_snapshot_create` es reproducible (upsert por negocio y mes) y
  `loyalty_budget_snapshot_all` queda reservado al cron.
- **UI**: nueva pantalla `/admin/campaigns` (crear, editar, activar/desactivar y
  eliminar), tarjeta de snapshots en `/admin/economic` y botón “Ejecutar vencimiento
  ahora” en la configuración del programa.
- **Seguridad de funciones**: al revisar los privilegios se detectó que el EXECUTE
  implícito de PUBLIC seguía vigente en funciones creadas después de la Fase 0, incluida
  `loyalty_transaction_post` (SECURITY DEFINER sin comprobación de rol), lo que permitía
  a un cliente acreditarse puntos. La migración `20261025000500_security_hardening_function_grants.sql`
  revoca el privilegio heredado, elimina el overload obsoleto y blinda el posteo interno;
  verificado con prueba SQL de `permission denied`.
- **Automatización**: dos jobs de pg_cron cuando la extensión está disponible:
  vencimiento diario (05:00) y snapshot mensual (día 1, 06:00). Si pg_cron no está
  disponible, la migración continúa y deja las RPC para ejecución manual.
- **Pruebas**: 98 unitarias (5 nuevas de campañas) y 18 e2e (campaña + compra
  multiplicada y snapshot mensual). Pruebas SQL de FIFO por lote, idempotencia,
  auditoría de vencimiento, campañas por vigencia/mínimo/bono, permisos y snapshot
  reproducible. `tsc -b`, `vitest`, `playwright`, build y migración remota en verde.

### Estado de ejecución (25/10/2026) — Fase 5

- **Wizard `/admin/onboarding`** con cuatro pasos: datos del negocio (nombre, zona
  horaria y días de operación), carta y costos, datos económicos y propuesta/activación.
- **Datos del negocio editables**: nueva RPC `business_update` (solo admin) con
  validación de zona horaria IANA y días 1–7, y auditoría `business.updated`.
- **Paso 2**: lista la carta, permite guardar el costo inline de cada producto, crear
  productos nuevos y avisa de los que no tienen costo (no bloquean el avance).
- **Paso 3**: reutiliza el formulario económico de la Fase 4 (estado por dato y
  “desconocido”); se puede saltar sin bloquear.
- **Paso 4**: propuesta editable de puntos por recompensa calculada como
  `costo del producto / (tasa de presupuesto × COP por punto)`, redondeada a múltiplos
  de 5. Muestra supuestos explícitos y explica qué indicadores no se pueden calcular
  cuando faltan ventas diarias, días de operación, ganancia o margen. Al activar:
  crea las recompensas seleccionadas (omitiendo nombres ya existentes para que el
  reintento sea seguro) y configura/activa el programa.
- **Borrador**: se guarda automáticamente en `localStorage`
  (`fidelizacion:onboarding:<businessId>`), se recupera al volver y se puede reiniciar.
- **Dashboard**: botón “Completar configuración” cuando el programa está inactivo.
- **Pruebas**: 93 unitarias (5 nuevas del wizard) y 16 e2e (wizard completo y enlace
  desde el dashboard). Pruebas SQL para `business_update` (admin, zona horaria válida,
  días de operación y bloqueo a encargados). `tsc -b`, `vitest`, `playwright`, build y
  migración remota en verde.

### Estado de ejecución (25/10/2026) — Fase 4

- **Bug crítico corregido — pantalla Carta**: `products_list` devolvía
  `column reference "id" is ambiguous` porque las columnas de salida de
  `returns table (id, name, …)` son variables PL/pgSQL y la consulta no las
  calificaba. La RPC ahora usa el alias `p.` en todas las columnas. Migración
  `20261025000100_fix_products_list_ambiguous.sql` aplicada en local y remoto;
  prueba SQL de regresión añadida.
- **Registro de compras**: nueva pantalla `/admin/purchases/new` con búsqueda de
  cliente afiliado, importe e importe elegible (por defecto igual), vista previa
  `floor(elegible / cop_por_punto)`, clave de idempotencia por intento y aviso si
  el programa está inactivo. El resultado muestra puntos y saldo, y permite
  **reversar** la compra con motivo (nueva RPC `loyalty_purchase_revert`).
- **Acumulación idempotente**: `loyalty_purchase_events` gana
  `idempotency_key`; `points_accrue_from_purchase` devuelve `purchase_event_id`
  y detecta reintentos incluso con 0 puntos. `loyalty_purchase_register` escribe
  `purchase.registered` en la auditoría del negocio.
- **Panel económico**: nueva pantalla `/admin/economic` con ventas diarias,
  días/mes, ganancia diaria, margen, clientes/día y presupuesto máximo. Cada
  dato se marca como confirmado, estimado o desconocido; marcar desconocido
  limpia el valor (`business_economic_profile_upsert` usa semántica de
  formulario completo). Tarjetas de ventas mensuales, presupuesto de referencia,
  costo redimido/pendiente/reservado, restante y % comprometido, con alertas al
  80 % y 100 %.
- **Auditoría**: nueva pantalla `/admin/audit` paginada en servidor
  (`business_audit_log_page`) con filtro por operación y detalle de metadata.
- **Navegación**: nuevos accesos “Registrar compra”, “Económico” y “Auditoría”;
  la barra móvil pasa a seis accesos primarios.
- **Pruebas**: 88 unitarias (11 nuevas de compras, económico y auditoría) y 14
  e2e (nueva: registrar compra → auditar → calcular panel). Pruebas SQL ampliadas
  con carta, perfil económico, compras de 0 puntos, reverso y auditoría.
  `tsc -b`, `vitest`, `playwright` y build en verde; migraciones aplicadas en
  local y en remoto (`gxfytcquyobhhbjipbea`).

---

## 1. Resumen ejecutivo

La base de datos está desplegada y sólida; el cierre de pruebas, documentación y despliegue está completado.

| Área | Estado | Comentario |
|---|---|---|
| Esquema, RLS, RPC | 100 % | 20 migraciones, 14 tablas nuevas, ~49 RPC, hardening y cron aplicados en remoto |
| Reglas de puntos/QR | 100 % | Libro corregido, vencimiento FIFO, campañas y límites de canje |
| UI administrador | 100 % | Programa, carta, recompensas, campañas, solicitudes, miembros, compras, económico, auditoría y wizard |
| UI cliente | 100 % | Saldo, QR, historial, “Mis canjes” y afiliación por enlace |
| UI encargado | 100 % | Valida, aprueba, confirma entrega, controla QR vencido y tiene guard de rol |
| Pruebas | 100 % | 275 aserciones SQL + 2 concurrencias + 99 unitarias + 18 e2e |

**Esfuerzo restante:** ninguno para el alcance planificado; solo operación (dominio, OAuth, acceso público, cron y Android).  
**MVP demostrable:** completo (programa, canje con QR, roles, afiliación, acumulación, económico, auditoría, wizard y campañas/vencimientos).

### Alcance actual

- **Resuelto en Fases 1–6:** programa, carta, recompensas, campañas, QR, “Mis canjes”,
  solicitudes, entrega, roles por negocio, guards, alta de miembros, afiliación pública,
  registro de compras con acreditación/reverso, panel económico, auditoría, wizard de
  configuración inicial, vencimiento FIFO y snapshots mensuales.
- Falta la operación final: dominio, OAuth real, acceso público de la demo y Android (Fase 7 cerrada).
- `/admin/settings` es el módulo **legacy** de un solo negocio; ya aparece etiquetado
  como “Sistema anterior” en el menú, separado del nuevo programa multiempresa.
- El frontend **está desplegado** en Vercel; el último `db push` dejó 20/20 migraciones en paridad.

---

## 2. Estado actual verificado (código, no documentación)

### 2.1 Base de datos

Migraciones aplicadas en remoto (`fidelizacion01`, ref `gxfytcquyobhhbjipbea`): `0001` a `0009`, `20261025*` hasta `20261025000700_phase7_configurable_benefit.sql` (20 en total, paridad verificada).

Tablas nuevas (14):
`businesses`, `business_memberships`, `products`, `loyalty_programs`, `loyalty_rewards`,
`loyalty_point_accounts`, `loyalty_point_transactions`, `loyalty_redemptions`,
`loyalty_redemption_tokens`, `business_economic_profiles`, `loyalty_purchase_events`,
`business_audit_logs`, `loyalty_campaigns`, `loyalty_budget_snapshots`.

Funciones principales:
`business_register`, `business_update`, `business_current_membership`, `require_business_role`,
`business_membership_create/update/list`, `loyalty_program_configure/get`,
`product_upsert/list`, `loyalty_reward_upsert/list/available`,
`loyalty_account_ensure/balance/transactions`, `loyalty_transaction_post`,
`points_accrue_from_purchase`, `points_reverse_purchase`, `points_grant_bonus`,
`points_expire_due/all_due`, `loyalty_campaign_upsert/list/delete`,
`reward_request_redemption`, `redemption_token_validate`, `redemption_approve/deliver/cancel`,
`loyalty_redemptions_list`, `business_economic_profile_upsert/get`,
`business_dashboard_economic`, `business_audit_log_list/page`,
`loyalty_budget_snapshot_create/list/all`,
`loyalty_purchase_register/revert`, `businesses_list`.

### 2.2 Web

| Archivo | Estado |
|---|---|
| `features/loyalty/BusinessRegisterPage.tsx` | Registra negocio (nombre, slug, timezone). No crea programa por defecto |
| `features/loyalty/BusinessSelectPage.tsx` | Lista negocios con su rol y navega al portal correcto |
| `features/loyalty/BusinessJoinPage.tsx` | **Nuevo.** Ficha pública `/join/:slug` y afiliación |
| `features/loyalty/BusinessSwitcher.tsx` | **Nuevo.** Selector de negocio en las cabeceras |
| `features/admin/BusinessDashboardPage.tsx` | Enlaces a programa/carta/recompensas/miembros; estado real del programa. Métricas aún “—” |
| `features/admin/ProgramPage.tsx` | **Nuevo.** Configuración completa con Zod, equivalencias y activación explícita |
| `features/admin/ProductsPage.tsx` | **Nuevo.** Carta con búsqueda, costo opcional y activo/inactivo |
| `features/admin/RewardsPage.tsx` | Producto gratis, descuentos, vigencia y límites por cliente/periodo/total |
| `features/admin/MembersPage.tsx` | Lista, alterna permiso y **añade miembros por correo** |
| `features/customer/BusinessBalancePage.tsx` | Saldo, movimientos, recompensas, solicitud y diálogo QR con vencimiento |
| `features/customer/RedemptionsPage.tsx` | “Mis canjes” con `loyalty_my_redemptions`, QR guardado y reemisión |
| `features/loyalty/EncargadoPage.tsx` | Valida, aprueba, bloquea QR vencido y confirma entrega |
| `features/admin/RedemptionsPage.tsx` | **Nuevo.** Solicitudes con filtros y acciones por rol |
| `features/admin/PurchaseRegistrationPage.tsx` | **Nuevo.** Compra presencial, puntos, idempotencia y reverso |
| `features/admin/CampaignsPage.tsx` | **Nuevo.** CRUD de campañas con multiplicador, bono, mínimo y vigencia |
| `features/admin/EconomicPage.tsx` | **Nuevo.** Perfil económico, panel de presupuesto y snapshots mensuales |
| `features/admin/AuditPage.tsx` | **Nuevo.** Auditoría paginada con filtro y metadata |
| `features/admin/BusinessGate.tsx` | **Nuevo.** Selección de negocio compartida por las pantallas de Fase 4 |
| `features/loyalty/OnboardingWizardPage.tsx` | **Nuevo.** Wizard de 4 pasos con borrador, propuesta y activación |
| `features/admin/EconomicDataForm.tsx` | **Nuevo.** Formulario económico reutilizado por panel y wizard |
| `features/admin/SettingsPage.tsx` | Configuración legacy (`settings`, `rewards`, auditoría vieja) |
| `app/router.tsx` | Programa, carta, solicitudes, compras, económico, auditoría, onboarding, `/join/:slug` y guards por negocio |
| `components/layout/AdminShell.tsx` | Menú nuevo, selector de negocio y legacy separado |
| `components/layout/CustomerShell.tsx` | Menú: Inicio, Balance, Compras, Canjes |

### 2.3 Pruebas

- `npx tsc -b`: limpio.
- `npx vitest run`: 99/99.
- `npx playwright test`: 18 pruebas e2e del módulo nuevo (registro, recompensas, programa+carta+recompensas, saldo/solicitud, QR/encargado, flujo completo de QR, admin aprueba/entrega/cancela, afiliación `/join`, alta de encargado, compra+auditoría+económico, wizard 4 pasos, enlace desde dashboard, campaña+compra multiplicada, snapshot mensual, aislamiento y guards). Puerto por defecto 5199.
- `tests/db/run-tests.sql` + `loyalty-phase0-tests.sql` + `loyalty-tests.sql`: 275 aserciones del módulo nuevo, incluidos los 20 casos de aceptación, `products_list`, `business_update`, vencimiento FIFO, campañas, límites de canje y snapshots reproducibles.
- Concurrencia: dos reclamos del mismo QR legacy y dos aprobaciones simultáneas del mismo canje.

---

## 3. Brechas priorizadas

| ID | Brecha | Impacto | Prioridad |
|---|---|---|---|
| G1 | ~~`/admin/program` no existe; botón roto~~ → resuelto en Fase 1 | Se puede configurar el programa | ✅ |
| G2 | ~~No hay carta/productos en UI~~ → resuelto en Fase 1 | Recompensas vinculadas a productos | ✅ |
| G3 | ~~El token QR se descarta al solicitar la redención~~ → resuelto en Fase 2 | Flujo de canje completo | ✅ |
| G4 | ~~“Mis canjes” usa la tabla legacy~~ → resuelto en Fase 2 | Usa `loyalty_my_redemptions` | ✅ |
| G5 | ~~No hay pantalla admin de solicitudes~~ → resuelto en Fase 2 | `/admin/redemptions` | ✅ |
| G6 | ~~No hay confirmación de entrega en UI~~ → resuelto en Fase 2 | `redemption_deliver` desde encargado y admin | ✅ |
| G7 | ~~Roles de UI salen solo de `user_roles`~~ → resuelto en Fase 3 | Rol por negocio y guard | ✅ |
| G8 | ~~No hay afiliación de clientes al negocio~~ → resuelto en Fase 3 | `/join/:slug` + `business_join` | ✅ |
| G9 | ~~Ninguna UI llama a `points_accrue_from_purchase`~~ → resuelto en Fase 4 | Los puntos se acumulan con compras reales | ✅ |
| G10 | ~~`points_*` no valida rol ni pertenencia; `p_created_by` es del cliente~~ → resuelto en Fase 0 | Roles, pertenencia y `created_by` validados en el servidor | ✅ |
| G11 | ~~`require_business_role(text[])` existe solo en remoto~~ → resuelto en Fase 0 | Migración canónica aplicada | ✅ |
| G12 | ~~`loyalty_program_get` falla si no hay fila de programa~~ → resuelto en Fase 0 | La pantalla nace con valores sugeridos | ✅ |
| G13 | ~~`MembersPage` no crea encargados~~ → resuelto en Fase 3 | Búsqueda por correo y alta | ✅ |
| G14 | ~~Formulario de recompensas incompleto~~ → resuelto en Fase 1 | Cubre producto, descuentos, vigencia y límites | ✅ |
| G15 | ~~Sin wizard de 4 pasos~~ → resuelto en Fase 5 | Creación guiada del programa | ✅ |
| G16 | ~~Sin panel económico ni auditoría en UI~~ → resuelto en Fase 4 | Panel y auditoría en pantalla | ✅ |
| G17 | ~~Sin vencimiento automático por lote~~ → resuelto en Fase 6 | Los puntos vencen por lote con job diario | ✅ |
| G18 | ~~Sin campañas/promociones ni snapshots de presupuesto~~ → resuelto en Fase 6 | Campañas con vigencia y snapshots mensuales | ✅ |
| G19 | ~~Pruebas SQL incompletas~~ → resuelto en Fase 7 | 20 casos de aceptación + concurrencia | ✅ |
| G20 | ~~`SettingsPage` legacy compite con el módulo nuevo~~ → separado en Fase 1 | Etiquetado “Sistema anterior” | ✅ |

---

## 4. Decisiones de arquitectura para esta fase

**D1. `business_memberships` es la fuente de verdad de roles por negocio.**
No se elimina `user_roles` (legacy), pero la UI usa una función nueva `get_my_app_roles()`
que hace unión: admin de algún negocio → `admin`; encargado → `registrar`; resto → `customer`.
La autorización real sigue en el servidor por `business_id`.

**D2. `businesses_list` devuelve el rol y el permiso del usuario en cada negocio.**
Así el contexto sabe si mostrar acciones de admin/encargado sin confiar en el navegador.

**D3. El token QR se muestra una sola vez y se puede reemitir.**
La BD solo guarda el hash. Se muestra el QR al crear la solicitud, se conserva en
`sessionStorage` por pestaña y se añade `redemption_token_reissue` (solo dueño, solo
`pending`/`approved`, rotando el hash) para recuperarlo si se cierra la pestaña.

**D4. Afiliación por enlace/QR público del negocio.**
`business_public_get(slug)` + `business_join(slug)`: crea membresía `cliente` y cuenta de
puntos con saldo 0. Nunca permite autoadjudicarse admin/encargado. El admin comparte
`/join/:slug` desde su panel. La afiliación por código/invitación y el rate limit quedan
como endurecimiento posterior.

**D5. Acumulación con RPC dedicada y servidor como autoridad.**
Nueva `loyalty_purchase_register(business, customer, amount, eligible, idempotency_key)`:
valida rol admin/encargado, deriva `created_by` de `auth.uid()`, asegura cuenta, aplica
`points_accrue_from_purchase` y bonos. Prohíbe que el navegador envíe `p_created_by`.

**D6. Migraciones inmutables.**
Las `0001`–`0009` ya están aplicadas: no se editan. Todo cambio va en una migración nueva
(desde `...001000`). Antes de cada push: `npx supabase migration list` y verificación de
paridad local/remoto.

> **Excepción histórica:** en la sesión de despliegue previa se editaron migraciones ya
> aplicadas (`20251021000200`, `20261023000100` y las `20261024000200`–`000700`) para
> reemplazar `%rowtype` y reordenar parámetros. El remoto ya las tiene aplicadas y un
> fresh deploy usa los archivos actuales. No volver a modificarlas.

**D7. Convivencia temporal con el módulo legacy.**
`/admin/settings`, `/admin` (QR de compras) y `/admin/purchases` se conservan para el flujo
anterior, pero se etiquetan como “Sistema anterior”. La configuración nueva vive en
`/admin/program`. No se borran tablas ni datos legacy.

**D8. El programa se crea con valores por defecto al registrar el negocio.**
`business_register` inserta `loyalty_programs` (`is_active=false`) y un
`business_economic_profiles` vacío. Se hace backfill de los negocios existentes. Así
`loyalty_program_get` nunca falla y la UI muestra un estado “sin activar”.

**D9. Wizard con borrador local y activación explícita.**
Los pasos 1–3 guardan borrador en `localStorage`; el paso 4 muestra la propuesta y solo
activa el programa al confirmar. `loyalty_program_configure` gana `p_is_active`.

**D10. Pruebas sin depender de servicios externos.**
Unitarias con Vitest y dobles de `rpc`; e2e con `tests/e2e/fake-supabase.ts`. Las SQL se
ejecutan contra Postgres local (Docker) o un proyecto de staging, nunca contra producción.

---

## 5. Fases de desarrollo

> Cada tarea tiene criterio de aceptación. No se pasa de fase sin `tsc -b`, `vitest` y
> la verificación manual indicada.

### Fase 0 — Saneamiento, seguridad y paridad de migraciones (P0 · 0.5–1 día) — ✅ COMPLETADA

**Ejecutada el 25/10/2026.** Migración `20261024000900` aplicada en local y remoto.
Pruebas SQL de fase en `tests/db/loyalty-phase0-tests.sql`; `npm test`, `tsc -b`,
31 unitarias y 6 e2e en verde. Ver “Estado de ejecución” al inicio para el detalle.

**T0.1** Crear `supabase/migrations/20261024000900_completion_hardening.sql` con:
- `require_business_role(uuid, text[])` (overload canónico) + grants.
- `get_my_app_roles()` (unión legacy + membresías).
- `businesses_list()` con `role`, `can_approve_redemptions`.
- Backfill/creación de `loyalty_programs` y `business_economic_profiles` por negocio.
- `loyalty_program_get` tolerante a “sin configurar”.
- `loyalty_program_configure` con `p_is_active boolean default true`.
- `business_public_get(p_slug)` + `business_join(p_slug)` + grants + auditoría.
- `loyalty_my_redemptions()` para el cliente.
- `redemption_token_reissue(p_redemption_id)` con rotación de hash y límite de intentos.
- `business_search_profiles(p_query)` (solo admin, límite 20).
- `loyalty_purchase_register(...)` (wrapper seguro de acumulación).
- Endurecer `points_accrue_from_purchase`, `points_reverse_purchase`,
  `points_grant_bonus`: `require_business_role`, cuenta del negocio, `created_by = auth.uid()`.
- Endurecer `loyalty_rewards_available`: si no es admin, forzar `p_customer_id = auth.uid()`.
- Restringir `business_membership_create` a roles `encargado`/`cliente` (evitar que un
  encargado con permiso se autoeleve a admin); crear admins solo desde el negocio creador
  o por soporte controlado.

**T0.2** Actualizar types, `queryKeys` y hooks para lo anterior.
**T0.3** Aplicar al remoto y verificar:
```sql
select proname, pg_get_function_identity_arguments(oid)
from pg_proc where proname in ('require_business_role','get_my_app_roles','business_join');
select business_id, role from public.business_memberships where user_id = auth.uid();
```
**T0.4** Prueba de humo: registrar negocio nuevo → `loyalty_program_get` responde sin error →
`businesses_list` trae `role=admin`.

**Aceptación:** un usuario nuevo que registra negocio entra a `/admin`; no hay errores
`function ... does not exist`; ningún RPC de puntos acepta `created_by` del navegador.

Estimación: **0.5–1 día**. Bloquea todo lo demás.

---

### Fase 1 — Núcleo de configuración (P0 · 1.5 días) — ✅ COMPLETADA

**Ejecutada el 25/10/2026.** Páginas `/admin/program` y `/admin/products`, recompensas
completas, rutas y menú. Ver “Estado de ejecución — Fase 1” al inicio para el detalle.

**T1.1** `src/features/admin/ProgramPage.tsx` → `/admin/program`
- Formulario: COP por punto, puntos por COP, vencimiento (días), tasa de presupuesto,
  bonos (primera compra, recurrencia, referidos), expiración QR, activo/inactivo.
- Estado “sin configurar” con valores sugeridos (1 punto/$1.000, 100 pts=$1.000,
  365 días, 1 %, QR 24 h).
- Validación con Zod y mensajes claros; guardar con `useConfigureLoyaltyProgram`.
- Mostrar equivalencia: “1 punto = $X; 100 puntos = $Y”.

**T1.2** `src/features/admin/ProductsPage.tsx` → `/admin/products`
- Tabla: nombre, precio, costo, activo; buscador; alta/edición en diálogo.
- Costo opcional con aviso “estimado, no contable”.
- Invalidar `products(businessId, true)` y `false`.

**T1.3** Completar `RewardsPage`
- Selector de producto para `free_product`.
- Campos: importe mínimo, descuento máximo, porcentaje, vigencia, límites por cliente/
  periodo/total.
- Validaciones: porcentaje 1–100; descuento ≤ mínimo; producto obligatorio si es gratis.

**T1.4** Router, `AdminShell` y enlaces del dashboard
- Añadir Programa, Productos y corregir `/admin/program`.
- Enlaces rápidos del dashboard con datos reales o “—” explícito.

**Aceptación:** crear programa + 2 productos + 3 recompensas (producto gratis, descuento
fijo, porcentaje), recargar y ver todo persistido; sin 404.

Estimación: **1.5 días**.

---

### Fase 2 — Redención completa con QR (P0 · 1 día) — ✅ COMPLETADA

**Ejecutada el 25/10/2026.** QR visible, “Mis canjes” nuevo, `/admin/redemptions` y entrega
confirmable. Ver “Estado de ejecución — Fase 2” al inicio.

**T2.1** `BusinessBalancePage`: al confirmar, abrir diálogo de éxito con
`QRCodeCanvas` (token), código, vencimiento y cuenta atrás. Guardar token en
`sessionStorage` (`loyalty:token:<redemptionId>`). No mostrar datos personales en el QR.

**T2.2** `customer/RedemptionsPage`: migrar a `loyalty_my_redemptions()`.
- Estado, fecha, puntos, botón “Ver QR” para `pending`/`approved`.
- Botón “Reemitir QR” si el token local no existe.
- Estados vacío/error/carga.

**T2.3** `src/features/admin/RedemptionsPage.tsx` → `/admin/redemptions`
- Filtros por estado; tabla con cliente, recompensa, puntos, fecha.
- Acciones: aprobar, rechazar, confirmar entrega, cancelar (con motivo).
- Visibilidad según `selectedBusiness.role` y `can_approve_redemptions`.
- Confirmaciones y mensajes de error de negocio (`forbidden`, `token_expired`, etc.).

**T2.4** `EncargadoPage`: añadir “Confirmar entrega” tras aprobar; cuenta atrás y aviso de
QR vencido; guard de rol.

**Aceptación (e2e real con 2 cuentas):** cliente solicita → ve QR → encargado escanea →
aprueba → confirma entrega → saldo consumido → cliente ve estado `delivered` → auditoría
registra los 3 pasos.

Estimación: **1 día**.

---

### Fase 3 — Roles, acceso y afiliación (P0 · 1 día) — ✅ COMPLETADA

**Ejecutada el 25/10/2026.** Roles por negocio, guards, alta de miembros y `/join/:slug`.
Ver “Estado de ejecución — Fase 3” al inicio.


**T3.1** `AuthProvider` usa `get_my_app_roles()`; `defaultPathForRoles`:
admin → `/admin`, encargado (`registrar`) → `/encargado`, cliente → `/customer`.
Post-login: si tiene negocios, `/business/select`; si no, `/customer`.

**T3.2** `BusinessContext`: persistir negocio seleccionado en `localStorage` por usuario;
eliminar `setState` durante render; exponer `role` y `canApprove` del negocio actual.
Selector de negocio visible en AdminShell/CustomerShell.

**T3.3** Guards: `RequireBusinessRole` para `/admin/*` (admin del negocio) y `/encargado`
(admin/encargado). El servidor sigue siendo la autoridad.

**T3.4** `MembersPage`: diálogo “Añadir miembro” con búsqueda por correo/nombre
(`business_search_profiles`), rol encargado/cliente y permiso de aprobación. No permitir
degradar al último admin.

**T3.5** `BusinessJoinPage` → `/join/:slug`: ficha pública del negocio + “Unirme”
(redirige a login con `next`), llama `business_join`, navega a `/customer/balance`.
En admin: tarjeta “Invitar clientes” con enlace copiable y QR.

**Aceptación:** admin nuevo ve `/admin`; encargado solo `/encargado`; cliente se afilia por
enlace y ve su saldo; cliente no entra a `/admin`; admin no puede quitarse el último rol admin.

Estimación: **1 día**.

---

### Fase 4 — Acumulación y panel económico (P1 · 1.5 días) — ✅ COMPLETADA

**T4.1** `src/features/admin/PurchaseRegistrationPage.tsx` → `/admin/purchases/new`
- Buscar cliente del negocio, importe, importe elegible (por defecto igual), vista previa
  `floor(elegible / cop_por_punto)`, clave de idempotencia.
- RPC `loyalty_purchase_register`; mostrar puntos y saldo resultante; invalidar cuenta,
  movimientos y compras.
- Aviso si el programa no está activo.
- **Resuelto:** `loyalty_purchase_events` ahora tiene `idempotency_key` y
  `loyalty_purchase_register` devuelve `purchase_event_id`. El reverso se hace con
  `loyalty_purchase_revert(p_business_id, p_event_id, p_reason)`, que exige admin,
  es idempotente y deja rastro en auditoría. `points_reverse_purchase` sigue
  disponible para compras legacy con `purchase_id`.

**T4.2** `src/features/admin/EconomicPage.tsx` → `/admin/economic`
- Perfil: ventas diarias, días/mes, ganancia diaria, margen, clientes/día, presupuesto máximo.
- Estado por dato: confirmado / estimado / desconocido.
- Tarjetas: ventas mensuales, presupuesto de referencia, costo redimido, pendiente,
  reservado, restante, % comprometido.
- Alertas a 80 % y 100 %; nota “estimación comercial, no costo contable”.
- Hook `useUpsertEconomicProfile` implementado en esta fase.

**T4.3** `src/features/admin/AuditPage.tsx` → `/admin/audit`
- Tabla paginada, filtro por operación, detalle de metadata.

**Aceptación:** registrar compra acredita puntos visibles en cliente; panel económico
cuadra con las fórmulas del prompt; auditoría muestra la compra y la redención.

Estimación: **1.5 días**.

---

### Fase 5 — Wizard de configuración inicial (P1 · 1.5 días) — ✅ COMPLETADA

**T5.1** `src/features/loyalty/OnboardingWizardPage.tsx` → `/admin/onboarding`
- Paso 1: datos del negocio (nombre, zona horaria, días de operación).
- Paso 2: carta (elegir productos existentes o crear; pedir costo si falta).
- Paso 3: datos económicos con estado por campo; permitir “desconocido”.
- Paso 4: propuesta calculada (puntos por $, presupuesto, recompensas sugeridas), editable,
  con supuestos explícitos y “Activar programa”.
- Borrador en `localStorage`; reanudar; no bloquear por datos opcionales.

**T5.2** Enlace “Completar configuración” en dashboard cuando `is_active=false`.

**Aceptación:** negocio nuevo completa los 4 pasos y queda operativo; se explica qué
indicadores no se pueden calcular.

Estimación: **1.5 días**.

---

### Fase 6 — Vencimientos, campañas y snapshots (P2 · 1.5–2 días) — ✅ COMPLETADA

**T6.1** Lotes de puntos: añadir `expires_at` a movimientos (migración nueva) y
`points_expire_due(business_id)` que debita lotes vencidos del más antiguo al más nuevo,
sin saldo negativo, idempotente, con auditoría. Programar con `pg_cron`/scheduled function.

**T6.2** Campañas: tabla `loyalty_campaigns`, RPC CRUD y pantalla simple (multiplicador/
bono, vigencia, activa). Aplicar en acumulación con `rule_version`.

**T6.3** Snapshots mensuales de presupuesto (`loyalty_budget_snapshots`) y job mensual.

**Aceptación:** puntos vencen por lote; campaña activa multiplica solo dentro de su vigencia;
snapshot mensual reproducible.

Estimación: **1.5–2 días**.

---

### Fase 7 — Pruebas, documentación y despliegue (P1/P2 · 1.5 días) — ✅ COMPLETADA

**T7.1** SQL: `tests/db/loyalty-tests.sql` con los 20 casos del prompt (registro, roles,
aislamiento, recompensas, acumulación, reverso, duplicados, saldo, reserva/liberación, QR
vigente/vencido/reutilizado, concurrencia, vencimiento, presupuesto, datos incompletos,
límites de descuento, acceso a datos ajenos). Integrar en `scripts/test-db.sh`.

**T7.2** Unitarias: programa, productos, recompensas, QR, roles, wizard, económico.
**T7.3** E2E: extender `fake-supabase.ts` y `loyalty.spec.ts` con afiliación, QR mostrado,
entrega y aislamiento.
**T7.4** Documentación: `BASE_DE_DATOS.md`, `SEGURIDAD.md`, `PRUEBAS.md`,
`ESTADO_PROYECTO.md`, `README.md`, `ENTREGA_FINAL.md` (marcar alcance real).
**T7.5** Despliegue: `db push` de migraciones nuevas, build y despliegue del frontend;
verificación manual con las cuentas de prueba.

**Aceptación:** `npm run test:all` verde, pruebas SQL verdes, checklist manual completo.

Estimación: **1.5 días**.

---

## 6. Orden, dependencias y calendario

```
F0 ─┬─> F1 ──> F2 ──> F3 ──> F4 ──> F5 ──> F7
    └─────────> F3 (roles/afiliación)
F6 (puede ir en paralelo después de F4)
```

| Semana | Entregable |
|---|---|
| 1 | F0 + F1 + F2 → configuración y canje funcionando |
| 2 | F3 + F4 + F5 → roles, afiliación, acumulación, wizard |
| 3 | F6 + F7 → vencimientos/campañas, pruebas, despliegue |

**Hito MVP (demo):** fin de F2. **Hito alcance completo:** fin de F7.

---

## 7. Matriz de pruebas mínima

### Unitarias / componentes
- Programa: valores por defecto, validación, guardar y activar.
- Productos: alta, edición, costo opcional, activo/inactivo.
- Recompensas: producto obligatorio, descuento ≤ mínimo, porcentaje 1–100, límites.
- QR: token visible una vez, reemisión, expiración, sin PII.
- Roles: admin/encargado/cliente; menús y guards.
- Wizard: pasos, borrador, datos desconocidos, activación.

### E2E (Playwright + fake Supabase)
1. Registro de negocio + programa + productos.
2. Afiliación de cliente por enlace.
3. Acumulación por compra y saldo.
4. Solicitud → QR visible → validación → aprobación → entrega → consumo.
5. QR vencido/reutilizado rechazado.
6. Aislamiento entre negocios.
7. Cliente no accede a admin; encargado sin permiso no aprueba.

### SQL (20 casos del prompt)
Los 20 casos de la sección 15 del prompt original, con datos deterministas y sin servicios
externos. Bloqueante para declarar terminado.

---

## 8. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Deriva local/remoto de migraciones | Migración 0009 única, `migration list` antes/después, nunca editar aplicadas |
| No hay Docker para pruebas SQL | Instalar Docker o usar proyecto de staging con `psql`; no ejecutar tests contra producción |
| Token QR perdido al cerrar pestaña | `sessionStorage` + `redemption_token_reissue` |
| Rol global `admin` muestra menús de negocios donde es cliente | Gating por rol del negocio seleccionado; servidor manda |
| Afiliación por slug abusable | Rate limit y código de invitación en fase posterior |
| Duplicidad con módulo legacy | Etiquetar legacy; no borrar; migrar pantallas de a una |
| Recompensas con costo nulo distorsionan presupuesto | Marcar como estimado y excluir de costo contable |

---

## 9. Verificación y comandos

### API
```bash
cd /home/leonardo/Fidelizacion/fidelizacionApi
npx supabase migration list          # paridad local/remoto
npx supabase db push                 # aplicar 0009+
npm test                             # pruebas SQL (requiere Docker/Postgres)
```

### Web
```bash
cd /home/leonardo/Fidelizacion/fidelizacionWeb
npm run typecheck
npm run test
npm run test:e2e
npm run build
```

### Checklist manual de aceptación
1. Registrar negocio nuevo → entra a `/admin` sin tocar `user_roles`.
2. Configurar programa en `/admin/program` → recargar y ver valores.
3. Crear 2 productos y 3 recompensas.
4. Compartir `/join/:slug`; un cliente se afilia y ve saldo 0.
5. Registrar compra → saldo y movimiento visibles para el cliente.
6. Cliente solicita recompensa → ve QR con vencimiento.
7. Encargado escanea, aprueba y confirma entrega → saldo consumido.
8. Cliente ve la redención en “Mis canjes” con estado `delivered`.
9. Panel económico cuadra; auditoría lista las operaciones.
10. Un negocio B no ve datos del negocio A.

---

## 10. Prompt de arranque para la sesión nueva

Copiar tal cual:

> Trabaja en `/home/leonardo/Fidelizacion`. Lee `PLAN_IMPLEMENTACION.md`,
> `ENTREGA_FINAL.md`, `documentacion/ESTADO_PROYECTO.md` y
> `documentacion/PLAN_CAMBIOS_PLATAFORMA.md`. El módulo multiempresa está completo
> (fases 0–7) y el rediseño Loopoint llegó hasta F6 (canje escaneado): 28
> migraciones, 124 unitarias, 30 E2E, 465 aserciones SQL y web en Vercel. Antes de
> tocar código ejecuta `npm test` en `fidelizacionApi` y `npm run test:all` en
> `fidelizacionWeb`. Reglas: no edites migraciones ya aplicadas (crea una nueva),
> no pongas secretos en el repo, no declares nada terminado sin `tsc -b`, `vitest`,
> Playwright, pruebas SQL y verificación del despliegue, y mantén el servidor como
> autoridad de `business_id` y permisos. Los pendientes son F7 (portal cliente
> multi-negocio), F8 (auditoría legible), F9 (cierre) y los operativos: dominio,
> Google OAuth, acceso público de la demo, cron y proyecto Android.

---

## 11. Checklist de progreso

### Fase 0 — ✅
- [x] Migración 0009 creada y revisada
- [x] `require_business_role(text[])` canónico
- [x] `get_my_app_roles()` y `businesses_list` con rol
- [x] Programa/perfil económico por defecto + backfill
- [x] `business_join` / `business_public_get`
- [x] `loyalty_my_redemptions` y `redemption_token_reissue`
- [x] `business_search_profiles`
- [x] Endurecer `points_*` (rol, pertenencia, `created_by`)
- [x] Corrección de RLS recursiva y orden de `loyalty_transaction_post`
- [x] Pruebas SQL de Fase 0
- [x] Push verificado en remoto

### Fase 1 — ✅
- [x] `/admin/program`
- [x] `/admin/products`
- [x] Recompensas completas
- [x] Rutas y menú

### Fase 2 — ✅
- [x] QR visible al cliente
- [x] “Mis canjes” con tabla nueva
- [x] `/admin/redemptions`
- [x] Confirmar entrega en encargado

### Fase 3 — ✅
- [x] Roles desde membresías
- [x] Negocio persistido + selector
- [x] Guards admin/encargado
- [x] Añadir miembros por correo
- [x] `/join/:slug`

### Fase 4 — ✅
- [x] Registrar compra → puntos
- [x] Panel económico
- [x] Auditoría

### Fase 5 — ✅
- [x] Wizard 4 pasos
- [x] Activación explícita

### Fase 6 — ✅
- [x] Vencimiento por lote
- [x] Campañas
- [x] Snapshots

### Fase 7 — ✅
- [x] 20 pruebas SQL (`tests/db/loyalty-tests.sql`) y concurrencia de aprobación
- [x] Unitarias y e2e nuevas (99 unitarias + 18 e2e)
- [x] Documentación actualizada (`BASE_DE_DATOS`, `SEGURIDAD`, `PRUEBAS`, `ESTADO_PROYECTO`, README y `ENTREGA_FINAL`)
- [x] Migración de límites aplicada en remoto y frontend desplegado en Vercel
- [ ] Verificación manual con cuentas reales y dominio definitivo (operación)
