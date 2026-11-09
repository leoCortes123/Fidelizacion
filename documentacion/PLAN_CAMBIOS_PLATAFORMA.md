# Plan de ejecución — Rediseño Loopoint

**Fecha:** 25/10/2026  
**Fuente funcional:** [`cambiosPlataforma.md`](cambiosPlataforma.md)  
**Estado:** completado. Fases 0–9 cerradas el 27/10/2026, con migraciones en paridad
local/remota, suites en verde y web desplegada en producción.  
**Alcance:** web (`fidelizacionWeb`) + API/Supabase (`fidelizacionApi`). La app Android
(`fidelizacionApp`) queda fuera de este ciclo; se adaptará después con el mismo contrato RPC.

### Estado de ejecución (27/10/2026)

- **F0 — completada.** Ramas `feat/loopoint-redesign` creadas en web y API; logo copiado a
  `public/loopoint-coin.png`; `.env.example` versionado (se corrigió el `.gitignore`);
  dependencias de dropdown, tooltip y popover instaladas; baseline verificado.
- **F1 — completada en su núcleo.** Marca Loopoint, paleta de negocio, modo oscuro
  persistente, shells con menú fijo y contenido con scroll propio, cabecera auto-oculta,
  menú de usuario con cierre de sesión, FAB móvil, tooltips en Programa/Compras, borradores
  persistentes en Programa, Compras, Ajustes, Productos y Recompensas, reemplazo de “puntos”
  por “loopoints”, `/` redirigido por rol y hub interino `/admin/config`.
- **Verificación:** `tsc -b` limpio; **108 unitarias** y **20 E2E** en verde; build correcto.
- **Pendiente inmediato:** ninguno de F1. Los tooltips de Negocio/Recompensas se
  incorporaron en F2/F3 y las pestañas definitivas de Configuración llegaron en F3. La
  pantalla de Balance se eliminó en F7: `/customer/balance` redirige a `/customer` y el
  menú del cliente queda en Inicio, Compras y Canjes.
- **Campañas:** intactas, según la decisión del 25/10/2026.

- **F2 — completada.** Migraciones
  `20261025001000_loopoint_identity_business_profile.sql` y
  `20261025001100_business_assets_storage.sql` aplicadas en local y remoto (`fidelizacion01`).
  Incluye:
  - **Nickname** único (sin distinguir mayúsculas), autogenerado desde el nombre (con
    sufijos ante duplicados y fallback aleatorio), formato 3–24 y lista de reservados.
    `profile_update` permite **2 cambios explícitos**; el primero sobre un perfil heredado
    es gratuito y el autogenerado no cuenta. `profile_nickname_ensure` se llama al abrir el
    perfil o el menú de usuario. `get_my_profile` añade alias, cambios restantes y número
    de negocios.
  - **Perfil del negocio**: descripción, dirección/barrio/ciudad, WhatsApp, teléfono,
    Instagram y web con normalización y validación en servidor. `business_profile_get`
    (cualquier miembro) y `business_profile_update` (solo admin, auditado).
    `business_public_get` expone solo los campos públicos y la ficha `/join/:slug` muestra
    logo, descripción, ubicación y contacto.
  - **Logo**: bucket público `business-assets` (2 MB, JPEG/PNG/WebP) con políticas de
    escritura por `business/<id>/`; el navegador comprime a 1200 px y
    `business_logo_set` valida que la URL pertenece al negocio. Storage local habilitado en
    `supabase/config.toml`.
  - **Cliente frecuente configurable**: compras mínimas, ventana, gasto mínimo, días
    activo y días de recuperación (validados y auditados). Helpers
    `private.customer_frequency` y RPC `business_customer_frequency`; badges
    “Frecuente activo”, “Frecuente” y “En recuperación” en la lista y el detalle de
    clientes, que ahora son **por negocio** (`staff_list_customers`/`staff_get_customer`
    aceptan `p_business_id` de forma aditiva).
  - **Web**: `/perfil` con alias y disponibilidad en vivo; “Mi perfil” en el menú de
    usuario; tarjeta **Negocio** en Configuración con formulario y subida de logo;
    tarjeta **Cliente frecuente** en Programa con explicación dinámica.
- **Verificación F2:** pruebas SQL nuevas en `tests/db/loopoint-tests.sql` (integradas en
  `scripts/test-db.sh`) y `npm test` en verde; **118 unitarias** y **24 E2E** en verde;
  `tsc -b`, build y smoke correctos. Paridad de migraciones local/remota verificada.

- **F3 — completada.** `/admin/config` es ahora la única pantalla de configuración, con
  pestañas **Negocio, Programa, Carta, Recompensas, Económico, Equipo y Avanzado**
  (Radix Tabs, desplazamiento horizontal en móvil, estado en `?tab=`). Reutiliza las
  pantallas ya probadas en lugar de duplicarlas, así los formularios, borradores y
  validaciones existentes siguen siendo la única fuente de verdad. Las rutas antiguas
  (`/admin/program`, `/admin/products`, `/admin/rewards`, `/admin/economic`,
  `/admin/members`, `/admin/settings`, `/admin/business`) redirigen a la pestaña
  equivalente, y `/admin/onboarding` abre el asistente dentro de Configuración
  (`?onboarding=1`). Se eliminó el hub interino de tarjetas.
- **Verificación F3:** **26 E2E** (nuevas: pestañas + redirección + borrador entre
  pestañas; configuración a 360 px sin scroll horizontal) y build correcto. La suite
  unitaria se mantiene en 118.

- **F4 — completada.** Migraciones
  `20261025001200_catalog_combos_purchase_items.sql` (M3) y
  `20261025001300_dashboard_summary.sql` (M6) aplicadas en local y remoto.
  - **Carta con combos**: `products.kind` (`simple`/`combo`), `product_combo_items`
    (un solo nivel, sin auto-referencia ni productos de otro negocio) y
    `product_combo_set`. `products_list` devuelve tipo y componentes; el editor de
    Carta permite crear/editar combos con cantidades.
  - **Compras con ítems**: `purchase_items` guarda nombre y precio congelados
    (`snapshot`) y el desglose del combo. `purchase_qr_create_with_items` valida
    pertenencia, cantidades 1–99, duplicados y que la suma coincida con el importe;
    `purchase_qr_create` sigue funcionando como wrapper con `[]`.
  - **Detalle**: `business_purchases_page` (ítems + nickname),
    `business_purchase_detail`, `my_purchases_page` y `my_purchase_detail`. La
    vista previa pública incluye las líneas. El historial del cliente muestra el
    negocio, los ítems y el detalle, con filtro por negocio activo.
  - **Inicio real**: `business_dashboard_summary` (loopoints en circulación,
    emitidos y canjeados, solicitudes, clientes frecuentes/activos, ventas y compras
    de hoy/mes, QR pendientes, presupuesto y última actividad) y
    `business_recent_activity`. La pantalla muestra 8 tarjetas compactas, actividad
    reciente y el QR de invitación plegado.
  - **PurchaseComposer**: pestañas “Valor manual” / “Elegir de la carta”, buscador,
    steppers de cantidad, total calculado, borrador y resultado con líneas; al pasar
    a manual se descartan los productos elegidos.
- **Verificación F4:** pruebas SQL nuevas en `tests/db/loopoint-f4-tests.sql`
  (combos, sumas, aislamiento, snapshots, detalle, métricas y grants); **119
  unitarias** y **28 E2E** en verde; `tsc -b`, build y `npm test` correctos.
- **Nota de orden:** M6 se aplicó como `20261025001300` para mantener el orden
  cronológico; las migraciones M4 y M5 usarán timestamps posteriores.

- **F5 — completada.** Migración `20261025001400_customers_without_manual_redeem.sql`
  aplicada en local y remoto.
  - **Detalle de cliente sin canje manual**: se eliminó la tarjeta, el diálogo y los
    hooks de “Canjear recompensa”. Los canjes se consultan en modo lectura y enlazan a
    Solicitudes; las compras muestran ítems y abren el detalle.
  - **Compras del cliente**: `staff_get_customer` con negocio devuelve compras QR con
    contador de ítems, compras manuales del libro (`source = manual`) y canjes del
    negocio mapeados a estados legibles. Nickname, frecuencia y última compra ya
    estaban en el detalle desde F2.
  - **Lista de clientes**: filtro “Solo frecuentes” (`p_only_frequent`, aditivo),
    nickname, badge y última compra. La búsqueda ya incluye el alias.
  - **Compras**: contador de ítems, detalle reutilizable en admin y cliente, y estado
    de cancelación conservado para pendientes/expiradas.
- **Verificación F5:** 29 E2E (nueva: detalle sin canje manual, compra con combos
  clicable y filtro de frecuentes) y pruebas SQL de filtro, compras manuales y
  aislamiento; `npm test`, `tsc -b` y build en verde.

- **F6 — completada.** Migración `20261025001500_redemption_scan_flow.sql` aplicada en
  local y remoto.
  - **QR con URL**: el QR de canje codifica `${PUBLIC_APP_URL}/scan/<token>` y el
    diálogo conserva el código manual y el enlace como respaldo copiable.
  - **Pantalla `/scan/:token`**: requiere sesión, resuelve negocio y permisos desde el
    token (nunca desde el navegador), muestra recompensa, loopoints, nickname, cuenta
    atrás y estados inválido/vencido/usado/aprobado/sin permiso.
  - **Entrega atómica**: `redemption_redeem_by_token` aprueba y entrega en una sola
    transacción, consume el token y audita `redemption.scanned` +
    `redemption.delivered`. Al confirmar ofrece “Registrar compra” y “Ver solicitudes”.
  - **Origen**: `loyalty_redemptions.origin` (`manual` / `qr_scan`) y nuevo parámetro
    aditivo `p_origin` en `loyalty_redemptions_list`; el listado muestra nickname,
    origen, filtro por origen y “Registrar compra” tras la entrega.
  - **Encargado**: formulario de venta en `/encargado/venta` como destino de la
    redirección, más acceso directo desde su portal.
  - **Límites**: 60 consultas de contexto/min y 20 entregas/min por usuario; tokens
    inválidos, vencidos o reutilizados se rechazan sin filtrar datos.
- **Verificación F6:** 30 E2E (nueva: escaneo, entrega y vuelta a registrar compra),
  **124 unitarias**, 32 aserciones SQL nuevas (token, permisos, vencido, reutilizado,
  origen y aislamiento), concurrencia de dos escaneos simultáneos y `tsc -b`, build,
  smoke, `npm test` y paridad 28/28.

- **F7 — completada.** Migración `20261025001600_customer_multi_business.sql` aplicada
  en local y remoto (`fidelizacion01`), paridad **29/29**.
  - **Resumen multi-negocio**: `customer_businesses_summary()` devuelve una fila por
    membresía del usuario autenticado con nombre, slug, logo, rol del negocio, programa
    activo, saldo, recompensas listas, solicitudes en curso, última compra y frecuencia.
    El cliente nunca envía `business_id`: el servidor deriva cada fila de
    `business_memberships` y no mezcla saldos ni frecuencia entre negocios.
  - **Canjes globales**: `loyalty_my_redemptions` añade `business_slug` y
    `business_logo_url` para identificar el negocio en la lista y el detalle. Se añaden
    índices de apoyo por cliente/negocio y estado.
  - **`/customer`**: nueva pantalla de negocios con tarjeta por negocio (logo, loopoints,
    badge verde “lista” si hay recompensas asequibles, badge de frecuente, programa
    inactivo y última compra), totales consolidados y estado vacío con campo para pegar
    el enlace o código de invitación (`/join/:slug`).
  - **`/customer/business/:businessId`**: conserva el contenido anterior de saldo,
    recompensas, movimientos y compras, con lista horizontal de negocios en la cabecera
    y sincronización con `BusinessContext`; si el negocio no pertenece al cliente muestra
    un estado seguro.
  - **Sin Balance**: `/customer/balance` redirige a `/customer` y el menú del cliente
    queda en Inicio, Compras y Canjes. Los enlaces de afiliación, reclamo y canje apuntan
    al negocio concreto.
  - **Compras y canjes globales**: filtro por negocio y detalle reutilizable; el canje
    muestra negocio, estado, puntos, QR/reemisión y fechas. El perfil sigue disponible
    en `/customer/perfil`.
- **Verificación F7:** **126 unitarias** (nuevas de tarjetas multi-negocio, invitación y
  filtro/detalle de canjes) y **32 E2E** (nuevas: tres negocios con saldos separados,
  redirección de Balance, compras y canjes globales con filtro y detalle). Pruebas SQL
  nuevas en `tests/db/loopoint-f7-tests.sql` (26 aserciones: saldos por negocio,
  recompensas listas, frecuencia aislada, permisos y canjes con slug/logo). Total:
  **491 aserciones SQL + 4 pruebas de concurrencia**. `tsc -b`, `vitest`, `playwright`,
  build, smoke y `npm test` en verde.

---

## 0. Verificación previa de repositorios

Se ejecutó `git fetch --all --prune` y `git status -sb` en los tres repositorios:

| Repositorio | Rama | Estado local | Remoto | Stash | Pendiente de push |
| --- | --- | --- | --- | --- | --- |
| `fidelizacionApi` | `main` | limpio | `origin/main` = `1299c89` | vacío | **No** |
| `fidelizacionWeb` | `main` | limpio | `origin/main` = `dfecdea` | vacío | **No** |
| `fidelizacionApp` | `main` | limpio | `origin/main` = `0e7b6a3` | vacío | **No** |

**Conclusión:** no hay commits, archivos modificados ni stashes pendientes de subir. Se puede
empezar el rediseño sin riesgo de perder trabajo local.

Hallazgos que conviene corregir en la fase 0:

1. `fidelizacionWeb/.env.example` **existe pero está ignorado** por la regla final
   `.env*` del `.gitignore`; por eso no está versionado. Los repos de API y App sí lo
   incluyen. Es el único “faltante” real de los repos.
2. `documentacion/`, `PLAN_IMPLEMENTACION.md`, `ENTREGA_FINAL.md` y el logo viven en la
   raíz del workspace, **fuera de Git** por decisión documentada en
   [`REPOSITORIOS.md`](REPOSITORIOS.md). Este plan, por tanto, tampoco se versionará
   automáticamente.
3. `graphify-out/` está desactualizado respecto a los últimos cambios de QR; no se usa
   como fuente de verdad para este plan. La fuente es el código y las migraciones.

### Baseline que debe quedar verde antes de tocar código

```bash
# API
cd fidelizacionApi
npx supabase migration list     # 28/28 local y remoto
npm test                        # 275 aserciones + concurrencia

# Web
cd ../fidelizacionWeb
npm run test:all                # typecheck + 99 unitarias + 18 E2E (puerto 5199)
npm run build
```

---

## 1. Objetivo y principios

Convertir la plataforma actual (módulo de fidelización funcional pero con estética y
navegación de escritorio) en **Loopoint**, un producto mobile-first para usarse desde el
navegador de un teléfono, con dos experiencias claramente separadas:

- **Negocio:** panel de administración con menú fijo, datos condensados y operación rápida
  de caja (QR de compra, solicitudes, clientes, compras).
- **Cliente:** acceso a varios negocios, saldo de **loopoints** por negocio, recompensas y
  canjes.

Principios que se mantienen del proyecto actual:

1. **El servidor es la autoridad.** Toda escritura sensible sigue en RPC
   `SECURITY DEFINER`; el navegador nunca decide `business_id`, roles ni puntos.
2. **Migraciones inmutables.** No se editan las 22 migraciones aplicadas; todo cambio va en
   migraciones nuevas desde `20261025001000_*`.
3. **Compatibilidad aditiva.** Las RPC existentes se conservan o se envuelven; los cambios
   de contrato se despliegan API + web en el mismo ciclo.
4. **Sin secretos en el repositorio.** Fotos y archivos van a Supabase Storage, no al código.
5. **Mobile-first real.** Diseñar a 360 px, luego 390/430/768/1280. Sin scroll horizontal,
   objetivos táctiles ≥ 44 px, navegación inferior con safe-area.

---

## 2. Decisiones de diseño

Las decisiones marcadas como aprobadas el 25/10/2026 ya están cerradas. Las que tienen
valores por defecto son configurables por el admin desde la interfaz.

| # | Tema | Propuesta |
| --- | --- | --- |
| D1 | Nombre y moneda | App **Loopoint**; moneda **loopoint** (plural **loopoints**). En código/BD se mantiene `points`; solo cambia el texto visible. |
| D2 | Paleta cliente | Se conserva la actual (fondo crema, primario rojo, acentos ámbar). |
| D3 | Paleta negocio | **Aprobada:** turquesa/cian profundo + azul noche + acento dorado, alineada con el logo. Se aplica solo al portal de negocio. Tokens concretos en §3.4. |
| D4 | Modo oscuro | Variables CSS para ambos portales; preferencia guardada por usuario en `localStorage`, con detección inicial de `prefers-color-scheme`. |
| D5 | Menú de usuario | Avatar + desplegable: “Mi perfil”, “Modo oscuro/claro”, “Cerrar sesión”. Sin botón suelto de cerrar sesión. |
| D6 | Cliente frecuente | **Configurable por el admin.** Valores por defecto: **3 compras en 90 días** y **gasto mínimo $0**; “frecuente activo” si compró en los últimos **30 días**; “en recuperación” si fue frecuente y no compra desde **60 días**. Rangos validados en servidor. |
| D7 | NickName | 3–24 caracteres, minúsculas/números/punto/guion/guion bajo, único sin distinguir mayúsculas. Si el cliente no lo define: `nombreapellido`, luego `nombreapellido2`, `3`… hasta 99 y después sufijo aleatorio. **Solo se permiten 2 cambios explícitos** después del valor inicial; el tercero se rechaza en el servidor. |
| D8 | Campañas | **Sin cambios en este ciclo.** Se conserva la pantalla y la lógica actual de campañas dinámicas. No se añaden plantillas estáticas ni se modifica la acumulación. |
| D9 | Configuración | Una sola pantalla `/admin/config` con pestañas: Negocio, Programa, Carta, Recompensas, Económico, Equipo, Avanzado. Las rutas antiguas redirigen a la pestaña equivalente. |
| D10 | Pantalla principal | Se elimina la landing comercial. `/` redirige al portal del rol autenticado; sin sesión va a `/login`. |
| D11 | Fotos | Supabase Storage, bucket público de lectura `business-assets`, escritura autenticada por negocio, límite 2 MB y formatos JPEG/PNG/WebP. Se guarda la URL pública en `businesses.logo_url`. |
| D12 | Detalle de compra | Se guardan líneas snapshot de la compra (`purchase_items`) para que el detalle no cambie si luego se edita la carta. |
| D13 | Combos | Un combo es un producto con precio propio y una lista de componentes (solo un nivel, sin ciclos). El precio del combo es el que se cobra. |
| D14 | QR de canje | El QR contiene una URL `${PUBLIC_APP_URL}/scan/<token>`, no solo el token. Al escanear, el negocio autenticado ve la confirmación y al aceptar se registra la entrega y se redirige a “Registrar compra”. |
| D15 | Compatibilidad de RPC | Cambios de columnas de retorno → RPC nueva con nombre explícito (`*_v2` o descriptivo) y wrapper antiguo si aplica. Cambios de parámetros → parámetros nuevos con default o función nueva. |

---

## 3. Arquitectura objetivo

### 3.1 Shell y navegación

```
Escritorio (≥ 768 px)
┌──────────────┬────────────────────────────────────────────┐
│ Menú fijo    │ Barra superior (se oculta al bajar)        │
│ 100dvh       ├────────────────────────────────────────────┤
│ scroll propio│ Contenido con scroll propio                 │
│              │ max-width, padding inferior seguro          │
└──────────────┴────────────────────────────────────────────┘

Móvil (< 768 px)
┌────────────────────────────────────────────┐
│ Barra superior compacta (auto-oculta)      │
├────────────────────────────────────────────┤
│ Contenido scroll                           │
│                                            │
│                                  [FAB +]   │
├────────────────────────────────────────────┤
│ Navegación inferior fija (3–4 + Más)       │
└────────────────────────────────────────────┘
```

Detalles técnicos:

- Layout con `h-dvh overflow-hidden`; el `<main>` es el contenedor con
  `overflow-y-auto` y `ref` para el hook de scroll.
- Hook `useHideOnScroll(containerRef)` con `passive: true`, umbral 8 px, sin ocultar cerca
  del top; transición `transform: translateY(-100%)`.
- Barra inferior fija con `pb-[env(safe-area-inset-bottom)]`; contenido con
  `pb-[calc(5rem+env(safe-area-inset-bottom))]`.
- FAB del negocio en `bottom: calc(4.5rem + env(safe-area-inset-bottom))`, oculto en
  `/admin/purchases/new`, con `aria-label="Registrar compra"`.
- El menú lateral no comparte scroll con el contenido: `aside` fijo/`sticky` y
  `overflow-y-auto` propio.
- En móvil el menú completo se resuelve con barra inferior + hoja “Más”; no se usa un
  drawer que tape el formulario.

### 3.2 Rutas objetivo

| Ruta actual | Ruta nueva | Comportamiento |
| --- | --- | --- |
| `/` (Landing) | `/` | Redirección por sesión/rol; sin landing |
| `/admin/dashboard` | `/admin/inicio` | Inicio del negocio; `/admin/dashboard` redirige |
| `/admin/program` | `/admin/config?tab=programa` | Redirección compatible |
| `/admin/products` | `/admin/config?tab=carta` | Redirección compatible |
| `/admin/rewards` | `/admin/config?tab=recompensas` | Redirección compatible |
| `/admin/economic` | `/admin/config?tab=economico` | Redirección compatible |
| `/admin/members` | `/admin/config?tab=equipo` | Redirección compatible |
| `/admin/onboarding` | `/admin/config?onboarding=1` | Modo guiado dentro de Configuración |
| `/admin/settings` | `/admin/config?tab=avanzado` | Sistema anterior, oculto del menú |
| `/admin/campaigns` | `/admin/campanas` | Se mantiene como pantalla propia |
| `/admin/redemptions` | `/admin/solicitudes` | Se mantiene como pantalla propia |
| `/admin/audit` | `/admin/auditoria` | Se mantiene como pantalla propia |
| `/admin/customers` | `/admin/clientes` | Se mantiene |
| `/admin/purchases` | `/admin/compras` | Se mantiene; `/:id` para detalle |
| — | `/scan/:token` | Confirmación de canje escaneado |
| `/customer` | `/customer` | Lista de negocios del cliente |
| `/customer/balance` | `/customer` | Se elimina la pantalla de balance |
| — | `/customer/business/:businessId` | Inicio del negocio elegido |
| `/customer/purchases` | `/customer/compras` | Lista + detalle |
| `/customer/redemptions` | `/customer/canjes` | Lista + detalle |
| — | `/customer/perfil` | NickName (máximo 2 cambios) y nombre |

> Las rutas nuevas en español pueden conservar alias en inglés durante la transición para
> no romper enlaces compartidos ni pruebas. El plan asume rutas en español como canónicas.

### 3.3 Menús

**Negocio (orden del documento):**

1. Inicio
2. Configuración
3. Campañas (sin cambios funcionales en este ciclo)
4. Solicitudes
5. Auditoría
6. Clientes
7. Compras

Móvil: Inicio, Configuración, Solicitudes, Compras + “Más” (Campañas, Auditoría, Clientes,
Mi perfil). FAB de registrar compra siempre visible salvo en la propia pantalla de compra.

**Cliente:**

1. Inicio (lista de negocios)
2. Compras
3. Canjes

Sin “Balance”. El detalle del negocio se abre desde Inicio. En la cabecera del detalle se
muestra la lista horizontal de negocios en lugar del saludo.

### 3.4 Sistema visual

- Variables CSS existentes (`--background`, `--primary`, etc.) se mantienen para cliente.
- Nuevo ámbito `[data-portal='admin']` con la paleta aprobada turquesa/azul/dorado:

```css
[data-portal='admin'] {
  --background: 195 40% 97%;
  --foreground: 200 35% 12%;
  --card: 0 0% 100%;
  --primary: 187 85% 30%;
  --primary-foreground: 0 0% 100%;
  --secondary: 190 55% 90%;
  --secondary-foreground: 195 60% 18%;
  --muted: 195 25% 93%;
  --muted-foreground: 200 12% 40%;
  --accent: 43 95% 55%;
  --accent-foreground: 200 40% 15%;
  --border: 195 25% 85%;
  --input: 195 25% 85%;
  --ring: 187 85% 30%;
}

.dark[data-portal='admin'] {
  --background: 200 35% 9%;
  --foreground: 190 20% 94%;
  --card: 200 30% 12%;
  --primary: 187 75% 45%;
  --primary-foreground: 200 40% 10%;
  --secondary: 195 30% 18%;
  --secondary-foreground: 190 20% 94%;
  --muted: 200 25% 16%;
  --muted-foreground: 195 12% 66%;
  --accent: 43 90% 55%;
  --accent-foreground: 200 40% 12%;
  --border: 195 20% 22%;
  --input: 195 20% 22%;
  --ring: 187 75% 45%;
}
```

- Nuevo bloque `.dark` con equivalentes para la paleta cliente (se conserva la actual en
  claro y se añade su versión oscura).
- Tipografía actual (Inter + Bricolage Grotesque); en móvil se reducen drásticamente los
  títulos (`text-xl`/`text-2xl`, no `text-7xl` en cabeceras de configuración).
- Componentes nuevos:
  - `ThemeProvider` / `useTheme`.
  - `UserMenu`.
  - `AppHeader` con auto-hide.
  - `MobileNav` / `MoreSheet`.
  - `Fab`.
  - `HelpHint` / `FieldHint` (tooltip en escritorio, popover al toque en móvil).
  - `DraftBadge` (“Borrador guardado”, descartar).
  - `StatCard` compacta para Inicio.
  - `PurchaseComposer` (valor manual vs. carta).
  - `PurchaseDetail`.
  - `BusinessCard` (cliente, con loopoints y estado de recompensas).
  - `EmptyState`, `ErrorState` ya existentes se reutilizan.
- Marca: `Brand` usa `/loopoint-coin.png`; se actualiza `index.html` (título, descripción,
  favicon, `theme-color`) y `VITE_BRAND_NAME=Loopoint`.

---

## 4. Modelo de datos y migraciones

Todas las migraciones son aditivas. Orden propuesto (se puede agrupar alguna si el equipo
prefiere menos archivos, pero no se mezclan responsabilidades):

| # | Archivo | Contenido |
| --- | --- | --- |
| M1 | `20261025001000_loopoint_identity_business_profile.sql` | NickName (con límite de 2 cambios), perfil de negocio completo, criterios de cliente frecuente, helpers y RPC de perfil. |
| M2 | `20261025001100_business_assets_storage.sql` | Bucket `business-assets`, políticas de Storage, RPC `business_logo_set`. |
| M3 | `20261025001200_catalog_combos_purchase_items.sql` | Combos, líneas de compra, QR con ítems, detalle de compra, listas con detalle. |
| M4 | `20261025001300_customer_multi_business.sql` | Resumen multi-negocio del cliente, compras/canjes globales, mejoras de clientes para staff. |
| M5 | `20261025001400_redemption_scan_flow.sql` | Contexto de token sin `business_id`, aprobación/entrega por token, auditoría de escaneo. |
| M6 | `20261025001500_dashboard_summary.sql` | Métricas reales del Inicio del negocio y actividad reciente. |
| M7 | `20261025001600_backfill_grants_indexes.sql` | Backfill de nicknames, defaults, índices, grants/revokes y comentarios. |

**Total actual:** 22 migraciones existentes + **6 nuevas (M1–M6) = 28**. La migración M7 de cierre queda pendiente si el equipo la necesita.

### M1 — Identidad y perfil de negocio

**`profiles`**

- `nickname text` (nullable, único con `lower(btrim(nickname))` donde no sea null).
- `nickname_changes smallint not null default 0` con check `between 0 and 2`.
- Constraint de formato: `^[a-z0-9._-]{3,24}$` y lista de reservados
  (`admin`, `loopoint`, `soporte`, `sistema`).
- `private.handle_new_user` extendido para generar nickname si viene vacío.
- Funciones:
  - `profile_update(p_full_name, p_nickname)` → jsonb. Cada cambio explícito de nickname
    incrementa `nickname_changes`; al tercero lanza `nickname_change_limit`. El valor
    inicial y el autogenerado no cuentan como cambio.
  - `profile_nickname_available(p_nickname)` → boolean.
  - `profile_nickname_ensure()` → text (genera y persiste si falta; se llama al cargar el
    perfil del cliente).
- `get_my_profile` extendido con `nickname`, `nickname_changes`, `nickname_changes_left` y
  `business_count`.

**`businesses`**

- `description text`, `address text`, `neighborhood text`, `city text`,
  `phone_whatsapp text`, `phone text`, `instagram text`, `website text`,
  `logo_url text`.
- `business_update` actual conserva su firma y delega en
  `business_profile_update` (nueva firma completa). El `slug` **no** se edita desde la
  interfaz para no romper QR ni enlaces.
- `business_public_get` devuelve solo campos públicos: nombre, slug, logo, descripción,
  dirección/barrio/ciudad, WhatsApp, redes, programa activo. Nunca datos internos.

**`loyalty_programs`** — criterios configurables por el admin

| Campo | Default | Rango permitido |
| --- | --- | --- |
| `frequent_min_purchases` | 3 | 1–100 |
| `frequent_period_days` | 90 | 7–3650 |
| `frequent_min_spend_cop` | 0 | 0–50.000.000 |
| `frequent_active_days` | 30 | 1–365 |
| `recovery_inactive_days` | 60 | 7–3650, mayor que `frequent_active_days` |

- Helper `private.customer_is_frequent(p_business_id, p_customer_id)` y
  `private.customer_is_frequent_active(...)`.
- RPC `loyalty_program_frequent_update(...)`; `loyalty_program_get` devuelve los campos.
- La UI muestra el ejemplo: “Serás frecuente con 3 compras en los últimos 90 días y un
  gasto mínimo de $0”. Si el admin cambia los valores, se recalculan los badges al leer.

### M2 — Fotos de negocio

- Bucket `business-assets` (público de lectura).
- Políticas: escritura solo a `admin` del negocio, ruta obligatoria
  `business/<business_id>/...`; tamaño máximo 2 MB; MIME `image/jpeg`, `image/png`,
  `image/webp`.
- RPC `business_logo_set(p_business_id, p_object_path)` valida prefijo, guarda
  `logo_url` pública y audita `business.logo_updated`.
- La web comprime la imagen antes de subir (canvas, máx. 1200 px lado mayor).

### M3 — Carta, combos y detalle de compra

**Productos**

- `products.kind text not null default 'simple'` con check `('simple','combo')`.
- `product_combo_items`:
  - `combo_id uuid` → `products(id)` on delete cascade.
  - `component_product_id uuid` → `products(id)` on delete restrict.
  - `quantity integer` > 0.
  - PK `(combo_id, component_product_id)`.
  - Trigger/validación: no auto-referencia, componentes del mismo negocio, solo un nivel.
- `products_list` devuelve `kind` y `combo_items` (jsonb) para la carta.
- `product_combo_set(p_business_id, p_product_id, p_items jsonb)` reemplaza componentes.

**Compras**

- `purchase_items`:
  - `id`, `purchase_id` (cascade), `product_id` (set null), `name_snapshot`,
    `unit_price_cop`, `quantity`, `line_total_cop`, `is_combo`, `combo_detail jsonb`.
  - Índice por `purchase_id`.
- `purchase_qr_create_with_items(p_business_id, p_amount_cop, p_items jsonb)`:
  - Mantiene `purchase_qr_create(uuid, integer)` como wrapper que llama con `[]`.
  - Valida que `sum(line_total) = p_amount_cop` cuando hay ítems; cada producto pertenece
    al negocio; cantidades 1–99; importe máximo actual.
  - Guarda snapshots y devuelve `items`.
- `purchase_qr_preview` incluye los ítems (sin datos del cliente).
- `business_purchase_detail(p_business_id, p_purchase_id)` y
  `my_purchase_detail(p_purchase_id)`: compra, cliente, registrador, ítems, puntos,
  estado, fechas y desglose de combo.
- `business_purchases_list` se mantiene; nueva `business_purchases_page` añade
  `items_count` y `customer_nickname`.
- `my_purchases_page(p_business_id default null, ...)` para el cliente, con nombre/logo del
  negocio, `items_count` y `total_count`.

### M4 — Cliente multi-negocio

- `customer_businesses_summary()`:
  - `business_id`, `name`, `slug`, `logo_url`, `role`, `loyalty_active`,
    `balance`, `ready_rewards`, `pending_redemptions`, `last_purchase_at`,
    `is_frequent`, `is_frequent_active`.
  - Solo membresías del usuario autenticado; sin datos de otros negocios.
- `loyalty_my_redemptions` extendido con `business_slug`, `business_logo_url` y
  `business_nickname` (o RPC nueva si se prefiere no recrear).
- `staff_list_customers` se conserva; nueva `business_customers_page` con:
  `nickname`, `is_frequent`, `is_frequent_active`, `last_purchase_at`, `items` de la
  última compra (opcional).
- `staff_get_customer` (jsonb) se extiende sin cambiar firma: nickname, frecuente,
  última compra y detalle de compras con ítems.

> **Campañas:** no se añade ninguna migración ni cambio de lógica en este ciclo. La
> pantalla actual y las campañas dinámicas existentes se conservan tal cual.

### M5 — Canje por QR escaneado

- `redemption_token_context(p_token)`:
  - Solo autenticados.
  - Resuelve negocio desde el token (no requiere `business_id` en la URL).
  - Verifica membresía `admin`/`encargado` y permiso de aprobación.
  - Devuelve negocio, recompensa, puntos, estado, vencimiento, nickname del cliente y
    `can_approve`.
- `redemption_redeem_by_token(p_token)`:
  - Valida y bloquea el token, aprueba y confirma entrega en una sola operación
    transaccional, consume el token, debita puntos y audita
    `redemption.scanned` + `redemption.approved` + `redemption.delivered`.
  - Devuelve `business_id`, `redemption_id`, `reward_name`, `points_spent`, `balance`.
- Se mantiene el flujo manual existente (`redemption_approve`, `redemption_deliver`).
- Rate limit por usuario/token para evitar fuerza bruta.

### M6 — Métricas del Inicio

- `business_dashboard_summary(p_business_id)` devuelve:
  - `points_outstanding`, `points_issued_total`, `points_redeemed_total`
  - `pending_redemptions`, `frequent_customers`, `active_customers`
  - `sales_today_cop`, `sales_month_cop`, `purchases_today`, `purchases_month`
  - `pending_qr_count`, `budget_committed_percent`, `last_activity_at`
- `business_recent_activity(p_business_id, p_limit)` con compras/canjes recientes
  normalizados para la lista del Inicio.
- Índices de apoyo: `loyalty_purchase_events(business_id, created_at)`,
  `loyalty_redemptions(business_id, status, created_at)`,
  `purchases(business_id, claimed_at)`, `business_memberships(business_id, role)`.

### M7 — Cierre

- Backfill de nicknames para perfiles existentes.
- Backfill de criterios de frecuencia con los defaults.
- `grant execute` de todas las RPC nuevas a `authenticated`; `revoke` de `public`/`anon`
  donde corresponda.
- `revoke execute` de funciones internas nuevas.
- Comentarios de columnas y tablas.
- Verificación de que ninguna función `SECURITY DEFINER` quede ejecutable por `PUBLIC`.

---

## 5. Contratos RPC (resumen)

| RPC | Cambio | Uso |
| --- | --- | --- |
| `profile_update` | nueva | Guardar nombre y nickname (máx. 2 cambios). |
| `profile_nickname_available` | nueva | Validar nick en vivo. |
| `profile_nickname_ensure` | nueva | Autogenerar nick si falta. |
| `business_profile_update` | nueva; `business_update` wrapper | Datos completos del negocio. |
| `business_logo_set` | nueva | Guardar URL del logo subido. |
| `loyalty_program_frequent_update` | nueva | Criterios de cliente frecuente. |
| `product_combo_set` | nueva | Componentes del combo. |
| `purchase_qr_create_with_items` | nueva; `purchase_qr_create` wrapper | QR de compra con líneas. |
| `business_purchase_detail` | nueva | Detalle para admin/encargado. |
| `my_purchase_detail` | nueva | Detalle para cliente. |
| `my_purchases_page` | nueva | Historial del cliente por negocio/global. |
| `customer_businesses_summary` | nueva | Inicio multi-negocio del cliente. |
| `business_customers_page` | nueva | Clientes con nick, frecuencia y última compra. |
| `staff_get_customer` | misma firma, más campos JSON | Detalle de cliente con compras. |
| `redemption_token_context` | nueva | Resolver token escaneado. |
| `redemption_redeem_by_token` | nueva | Aprobar + entregar desde el QR. |
| `business_dashboard_summary` | nueva | Métricas del Inicio. |
| `business_recent_activity` | nueva | Actividad reciente. |

---

## 6. Fases de ejecución

> Cada fase termina con `tsc -b`, unitarias, E2E, pruebas SQL y build. No se pasa a la
> siguiente sin aceptación. Las estimaciones son para una persona; API y web pueden
> paralelizarse parcialmente.

### Fase 0 — Preparación y baseline (0.5 día) — ✅ COMPLETADA

**Tareas**

1. Ejecutar el baseline del punto 0 y anotar resultados.
2. Crear ramas `feat/loopoint-redesign` en web y API (y `feat/loopoint-plan` si se desea
   versionar documentación).
3. Corregir `.gitignore` de la web para que `.env.example` se versione:
   quitar la línea final `.env*` o añadir `!.env.example` después.
4. Copiar `loopointCoinNoBG.png` a `fidelizacionWeb/public/loopoint-coin.png`.
5. Añadir dependencias: `@radix-ui/react-dropdown-menu`, `@radix-ui/react-tooltip`,
   `@radix-ui/react-popover` (si se usa popover móvil).
6. Actualizar `.env.example` de la web: `VITE_BRAND_NAME=Loopoint`,
   `VITE_BRAND_TAGLINE=Loopoints por tus compras`.

**Aceptación:** baseline verde; `.env.example` versionado; asset disponible; sin cambios
funcionales todavía.

**Estimación:** 0.5 día.

---

### Fase 1 — Marca, tema, shells y navegación (3 días) — ✅ COMPLETADA

**Objetivo:** resolver todo lo transversal del documento antes de rediseñar pantallas.

**Tareas**

1. **Marca Loopoint**
   - `Brand` con `<img src="/loopoint-coin.png">`, tamaños compacto/normal, `alt`.
   - `index.html`: título `Loopoint`, descripción, favicon PNG, `theme-color` según tema.
   - `lib/config.ts`: defaults `Loopoint` / `Loopoints por tus compras`.
   - Sustituir textos visibles “puntos” por “loopoint/loopoints” con un helper
     `lib/copy.ts` (`loopoint`, `loopoints`, `formatLoopoints`). No renombrar tablas,
     columnas ni RPC.
2. **Temas y paletas**
   - `ThemeProvider` en `App.tsx`; clases `dark` y `data-portal="admin|customer"`.
   - Variables CSS nuevas para admin y dark; QR siempre sobre fondo blanco.
   - `UserMenu` con “Modo oscuro/claro”, “Mi perfil”, “Cerrar sesión”.
   - Persistencia `loopoint:theme` y `loopoint:portal`.
3. **Layout fijo**
   - `AdminShell` y `CustomerShell` con sidebar fijo (desktop) + contenido scroll propio.
   - `useHideOnScroll` en la barra superior de ambos shells.
   - Barra inferior móvil: Admin 4 + “Más”; Cliente 3. Corregir el `grid-cols-3` actual
     que renderiza 4 ítems.
   - Safe areas y `h-dvh`.
4. **Eliminar deuda visual**
   - Quitar botón “Ver portal del cliente” del `AdminShell`.
   - Quitar botones sueltos de cerrar sesión.
   - `/` deja de renderizar la landing; redirección por sesión/rol.
5. **Tooltips**
   - `HelpHint` con `Tooltip` en desktop y `Popover`/diálogo al toque en móvil.
   - `Field` acepta `hint` + `help`; se aplica primero en Programa, Negocio, Recompensas
     y Compras.
6. **Persistencia de formularios**
   - Hook `useFormDraft<T>({ key, storage, version, ttlDays })`.
   - `localStorage` para configuración; `sessionStorage` para importes de compra.
   - Restaurar al montar, guardar con debounce, limpiar al guardar con éxito, botón
     “Descartar borrador” y chip “Borrador guardado”.
   - Revisar `useEffect` que resetean formularios desde queries (por ejemplo
     `SettingsPage`) y condicionarlos a formulario limpio.
   - Aplicar a: Negocio, Programa, Carta/Combo, Recompensas, Compra y Wizard. Las campañas
     actuales no se tocan en este ciclo.
7. **Menús y rutas**
   - Reordenar `AdminShell`; ocultar pantallas individuales que pasan a Configuración.
   - Añadir alias/redirecciones de rutas.
   - Actualizar `defaultPathForRoles` y `businessHomePath` al nuevo portal.
8. **FAB**
   - Componente `Fab` visible solo en móvil del portal de negocio; enlace a
     `/admin/purchases/new` (o `/registrar-compra` para encargado).

**Archivos principales**

- `src/app/App.tsx`, `src/app/router.tsx`, `src/index.css`, `tailwind.config.ts`, `index.html`
- `src/components/layout/AdminShell.tsx`, `CustomerShell.tsx`, `RequireAuth.tsx`
- `src/components/layout/UserMenu.tsx`, `AppHeader.tsx`, `MobileNav.tsx`, `Fab.tsx`
- `src/components/shared/Brand.tsx`, `HelpHint.tsx`, `Field.tsx`, `DraftBadge.tsx`
- `src/components/theme/ThemeProvider.tsx`
- `src/lib/copy.ts`, `src/lib/useFormDraft.ts`, `src/lib/config.ts`
- `src/features/auth/LandingPage.tsx` (eliminar o dejar solo redirección)

**Aceptación**

- En 360×640: sin scroll horizontal; menú fijo; barra superior se oculta al bajar y
  reaparece al subir; FAB visible y no tapa la barra inferior.
- El tema oscuro persiste al recargar y no rompe QR ni tablas.
- Desaparecen el botón de cerrar sesión suelto y “Ver portal del cliente”.
- Un formulario a medio llenar sobrevive a cambiar de pestaña/ventana y a recargar.
- `vitest` y Playwright actualizados; build verde.

**Estimación:** 3 días.

---

### Fase 2 — Identidad, negocio y cliente frecuente (2 días) — ✅ COMPLETADA

**Objetivo:** aterrizar M1 y M2 con UI, antes de construir Configuración encima.

**Tareas**

1. Migraciones M1 y M2 + pruebas SQL.
2. `customer/ProfilePage`: nombre, `@nickname`, disponibilidad en vivo y contador
   “Cambios disponibles: 2 de 2”. Al agotar los 2 cambios, el campo se bloquea y el
   servidor rechaza cualquier intento (`nickname_change_limit`).
3. Autogeneración de nickname al iniciar sesión si no existe; mostrar en el menú de
   usuario y en listas.
4. `BusinessProfileForm`: nombre, descripción, dirección, barrio, ciudad, WhatsApp,
   teléfono, Instagram, web, logo. Validación con Zod; tooltips.
5. Upload de logo a Storage con compresión previa, preview, eliminar/reemplazar.
6. Criterios de cliente frecuente en Programa:
   - compras mínimas, ventana en días, gasto mínimo;
   - días para “activo” y días para “recuperación”;
   - explicación con ejemplo y tooltip.
7. Badges “Frecuente” / “Frecuente activo” en clientes y en el detalle.

**Aceptación SQL:** nickname duplicado rechazado; autogeneración consecutiva; dos cambios
permitidos y tercero rechazado; negocio A no puede editar logo de B; criterios validan
rangos; `customer_is_frequent` respeta ventana/gasto; RLS de Storage.

**Estimación:** 2 días.

---

### Fase 3 — Configuración unificada mobile-first (3 días) — ✅ COMPLETADA

**Objetivo:** una sola pantalla para toda la configuración, cómoda desde el teléfono.

**Tareas**

1. Nueva ruta `/admin/config` con `Tabs` (Radix ya instalado):
   - **Negocio:** formulario de Fase 2 + logo.
   - **Programa:** `ProgramForm` + criterios de frecuente + vencimiento + QR.
   - **Carta:** contenido de `ProductsPage` + combos (Fase 4).
   - **Recompensas:** contenido de `RewardsPage`.
   - **Económico:** contenido de `EconomicPage`.
   - **Equipo:** contenido de `MembersPage`.
   - **Avanzado:** configuración legacy, historial y notas del “sistema anterior”.
2. Extraer secciones de las páginas actuales a componentes reutilizables
   (`ProgramSection`, `ProductsSection`, `RewardsSection`, etc.) para que la ruta antigua
   solo redirija y el wizard las reutilice.
3. Wizard/onboarding como modo guiado de Configuración:
   - `?onboarding=1` muestra stepper compacto (Negocio → Carta → Económico → Propuesta).
   - El borrador existente se integra con `useFormDraft`; el mensaje grande de “borrador”
     se convierte en un chip discreto.
4. Diseño móvil:
   - Títulos `text-xl`/`text-2xl`; sin cabeceras gigantes.
   - Formularios a una columna, secciones colapsables, barra de guardado sticky.
   - Inputs con `inputMode`, autocompletado y ayudas.
   - Tablas de miembros/recompensas → tarjetas en móvil.
5. Redirecciones de `/admin/program`, `/admin/products`, `/admin/rewards`,
   `/admin/economic`, `/admin/members`, `/admin/onboarding`, `/admin/settings`.
6. Quitar del menú las entradas individuales; dejar solo Configuración.

**Aceptación**

- Se puede configurar negocio, programa, carta, recompensas, económico y equipo sin salir
  de `/admin/config`.
- A 360 px no hay scroll horizontal; guardar y recargar conserva datos; el borrador se
  recupera; el mensaje de borrador no ocupa media pantalla.
- Las rutas antiguas siguen funcionando por redirección.
- Pruebas de tabs, guardado y draft.

**Estimación:** 3 días.

---

### Fase 4 — Inicio del negocio, QR con carta/combos y detalle (3 días) — ✅ COMPLETADA

**Objetivo:** resolver B2/B3/B4 y sentar la base de compras con ítems.

**Tareas**

1. Migración M3 (combos + purchase items + QR con ítems) y M6 (métricas).
2. **Inicio (`/admin/inicio`)**
   - `StatCard` compactas (2 columnas móvil / 4 escritorio):
     loopoints emitidos y en circulación, solicitudes pendientes, clientes frecuentes,
     ventas de hoy/mes, presupuesto comprometido.
   - Sin tarjetas gigantes ni placeholders “—”.
   - Actividad reciente breve.
3. **PurchaseComposer**
   - Pestañas “Valor manual” y “Elegir de la carta”.
   - Selector de productos/combos con buscador, steppers de cantidad, total calculado.
   - Al aceptar: llena el importe y guarda los ítems seleccionados; si se edita el importe
     manualmente, se advierte y se descartan los ítems (o se recalcula, según D13).
   - Botón “Generar QR” y diálogo de resultado con QR, copiar enlace, descargar, imprimir.
   - Estados: programa inactivo, importe inválido, sin carta.
4. **QR de invitación**
   - Sección colapsable (“Mostrar QR de invitación”) con enlace copiable y QR, sin ocupar
     el espacio principal.
5. **Carta/combos**
   - En Configuración → Carta: tipo simple/combo, editor de componentes y cantidades,
     precio del combo, validaciones.
6. **Detalle de compra**
   - Ruta `/admin/compras/:id` o diálogo reutilizable; muestra líneas, combos, total,
     puntos, cliente, registrador, estado y fechas.
   - Lista de compras con `items_count`.
7. **Cliente**
   - `my_purchases_page` y `my_purchase_detail`; lista/detalle con negocio y líneas.

**Aceptación**

- Elegir 2 combos + 3 productos calcula el total y genera QR; el detalle muestra las
  líneas y el desglose de combos.
- Una compra manual sin ítems sigue funcionando y muestra “Sin detalle de productos”.
- Métricas del Inicio cuadran con las tablas; ningún “—”.
- Pruebas SQL de suma de ítems, producto de otro negocio, combo circular y aislamiento.

**Estimación:** 3 días.

---

### Fase 5 — Clientes y compras sin redención manual (2 días) — ✅ COMPLETADA

**Objetivo:** B15/B16 y C4.

**Tareas**

1. `CustomerDetailPage`:
   - Eliminar la tarjeta y el diálogo “Canjear recompensa” y sus hooks.
   - Añadir nickname, badge de frecuente, última compra.
   - Compras clicables → detalle con ítems.
   - Canjes en modo lectura.
2. `CustomersPage`:
   - Columnas/tarjetas con nickname, frecuencia y última compra.
   - Filtro “Solo frecuentes” y búsqueda por nickname.
3. `PurchasesPage`:
   - Detalle por compra; filtros por estado/fecha; contador de ítems.
   - Mantener cancelación de pendientes/expiradas con motivo.
4. `customer/PurchasesPage`:
   - Filtro por negocio, nombre/logo del negocio, detalle con ítems.

**Aceptación**

- No queda ninguna opción de redimir desde el detalle del cliente.
- Se ve el detalle de la compra desde clientes y desde compras, en admin y cliente.
- Pruebas de regresión de permisos: un negocio B no ve compras de A.

**Estimación:** 2 días.

---

### Fase 6 — Solicitudes y canje por QR escaneado (2 días) — ✅ COMPLETADA

**Objetivo:** B13.

> Las campañas no se modifican en este ciclo. Se conserva la pantalla actual y la lógica
> de campañas dinámicas existente.

**Tareas**

1. Migración M5.
2. Cambiar el valor del QR de canje a URL `/scan/<token>`; mostrar también el código
   manual como respaldo.
3. Nueva pantalla `/scan/:token`:
   - Requiere sesión; si no hay, va a login con `next`.
   - Resuelve negocio desde el token y valida rol/permiso.
   - Muestra recompensa, loopoints, cliente (nickname), vencimiento y cuenta atrás.
   - Botón “Confirmar entrega” → `redemption_redeem_by_token` → confirmación → redirección
     a registrar compra (`/admin/purchases/new` o sección de venta del encargado).
   - Estados: token inválido/vencido/usado, sin permiso, ya aprobado.
4. `Solicitudes`:
   - Origen de la solicitud: manual vs. QR escaneado.
   - Filtros y acciones actuales; evitar doble aprobación.
   - Tras aprobar un QR, ofrecer “Registrar compra”.
5. Encargado:
   - Incluir el formulario de venta/QR en su portal para que la redirección tenga destino.
   - Mantener validación manual de token como alternativa.
6. Rate limit y auditoría de escaneos.

**Aceptación**

- Cliente solicita → QR → el negocio escanea con la cámara → confirma → se descuentan
  loopoints → se registra entrega → vuelve a registrar compra.
- Token vencido/reutilizado/cliente equivocado rechazado.
- La solicitud aparece en el listado con su origen.
- E2E con dos cuentas (cliente y encargado/admin).

**Estimación:** 2 días.

---

### Fase 7 — Portal del cliente multi-negocio (2.5 días) — ✅ COMPLETADA

**Objetivo:** C1/C2/C3/C5.

**Tareas**

1. Migración M4.
2. `/customer` → `CustomerBusinessesPage`:
   - Tarjetas de negocios inscritos con logo, saldo de loopoints por negocio y badge verde
     si hay recompensas por reclamar.
   - Badge de frecuente, última actividad y acceso al detalle.
   - Estado vacío con invitación a afiliarse por enlace/QR.
3. `/customer/business/:businessId` → `CustomerBusinessHomePage`:
   - Reutiliza el contenido actual de saldo + recompensas + movimientos + compras.
   - En la cabecera, lista horizontal de negocios (en lugar del saludo).
   - Se sincroniza con `BusinessContext` para que los hooks existentes funcionen.
4. Eliminar `/customer/balance` y la entrada “Balance” del menú; redirección a `/customer`.
5. `/customer/compras`:
   - Lista global con filtro por negocio y detalle con ítems.
6. `/customer/canjes`:
   - Lista global de canjes con negocio, estado, puntos y QR/reemisión; detalle.
7. Perfil:
   - `/customer/perfil` con nickname (2 cambios), nombre y cambios restantes.
8. `CustomerShell`: 3 ítems, sin Balance; cabecera con selector de negocio.

**Aceptación**

- Un cliente con 3 negocios ve 3 tarjetas con saldos distintos y verdes donde corresponde.
- Al entrar a uno ve el mismo contenido que el antiguo “customer principal”, con la lista
  de negocios arriba.
- No existe pantalla ni entrada de Balance.
- Compras y canjes incluyen el negocio y su detalle.
- Pruebas de aislamiento: el resumen no mezcla negocios ni expone otros.

**Estimación:** 2.5 días.

---

### Fase 8 — Auditoría legible (1 día) — ✅ COMPLETADA

**Objetivo:** B14.

**Tareas**

1. Catálogo `auditLabels.ts` con etiqueta, descripción, icono y severidad para todas las
   operaciones existentes (`purchase.qr_created`, `redemption.approved`,
   `loyalty_program.configured`, `campaign.*`, `membership.*`, etc.).
2. Reescribir la tabla:
   - “Qué pasó” en español, entidad legible, actor (nombre/email), fecha.
   - Filtros por operación, actor, rango de fechas y texto.
   - Detalle con campos formateados (importes, puntos, nombres), no JSON crudo por defecto;
     “Ver JSON” como opción avanzada.
3. Vista móvil en tarjetas; iconos y colores por tipo.
4. Paginación y estados vacíos claros.
5. Opcional API: `business_audit_log_page` con `actor_name`; si no, resolver en cliente con
   el email.

**Aceptación**

- Un admin sin conocimiento técnico entiende qué ocurrió en cada fila.
- Se puede filtrar por “compras”, “canjes”, “campañas”, “configuración” y por fecha.
- No hay `purchase.qr_created` ni IDs truncados como texto principal.

**Estimación:** 1 día.

**Implementado**

- `src/features/admin/auditLabels.ts`: catálogo `AUDIT_LABELS` con las 31 operaciones
  que la base inserta en `business_audit_logs` (etiqueta, descripción, icono,
  severidad y categoría) y `LEGACY_AUDIT_LABELS` para las de la tabla legada
  `audit_log` de la pestaña «Avanzado». `auditSubject` resume cada fila y
  `describeAudit` formatea los campos y los cambios antes/después sin JSON crudo.
- `src/features/admin/AuditPage.tsx`: tabla en escritorio (qué pasó, entidad,
  actor, fecha y detalle) y tarjetas en móvil, con filtros por operación/categoría,
  actor, rango de fechas y texto libre, chips de filtros activos, paginación en el
  servidor y estado vacío con «Limpiar filtros». El detalle es un diálogo con
  campos formateados y «Ver JSON» como opción avanzada.
- Migración `20261026000100_audit_log_readable.sql`: `business_audit_log_page` con
  `actor_name`, filtros por operación (o varias separadas por coma), actor, rango
  de fechas y texto libre; escapa `%` y `_`, rechaza rangos inválidos y exige rol
  `admin`/`encargado` del negocio. Índices por operación y actor.
- Pruebas: `tests/db/loopoint-f8-tests.sql` (22 aserciones SQL) y
  `tests/unit/auditLabels.test.ts` (13 pruebas) más los flujos E2E de escritorio
  y móvil.
- La pestaña «Avanzado» (auditoría legada de plataforma) dejó de mostrar
  operaciones crudas e IDs truncados.

---

### Fase 9 — Pruebas, documentación y despliegue (2.5 días) — ✅ COMPLETADA

**Tareas**

1. Completar pruebas SQL, unitarias y E2E (ver sección 8).
2. Pruebas de viewport móvil y escritorio; revisar accesibilidad básica.
3. Actualizar documentación:
   - `BASE_DE_DATOS.md`, `SEGURIDAD.md`, `PRUEBAS.md`, `ESTADO_PROYECTO.md`,
     `ARQUITECTURA.md`, `README.md`, `ENTREGA_FINAL.md`.
   - Nuevo `PLAN_CAMBIOS_PLATAFORMA.md` (este archivo) y enlace desde
     `PLAN_IMPLEMENTACION.md`.
4. Migraciones: `db reset` local, `npm test`, `migration list`, `db push` remoto.
5. Build de producción + smoke; desplegar en Vercel; verificar `/scan/:token`,
   `/join/:slug`, `/admin/config` y el bundle apuntando al Supabase correcto.
6. Configurar variables: `VITE_BRAND_NAME=Loopoint`, `VITE_BRAND_TAGLINE`,
   `VITE_PUBLIC_APP_URL` con el dominio definitivo.
7. Verificación manual con cuentas reales (checklist de la sección 10).

**Aceptación:** todo verde, migraciones en paridad, web desplegada y smoke correcto.

**Estimación:** 2.5 días.

**Implementado (27/10/2026)**

- Migración `20261026000200_backfill_grants_indexes.sql` (M7): backfill de
  nicknames y criterios de frecuencia, barrido idempotente de `GRANT`/`REVOKE`
  (ninguna función `SECURITY DEFINER` ejecutable por `PUBLIC`; `anon` solo conserva
  `business_public_get` y `purchase_qr_preview`), comentarios de tablas/columnas e
  índice `products_business_kind_idx`.
- `tests/db/loopoint-f9-tests.sql` con **85 aserciones**: duplicados de nickname sin
  distinguir caja, RLS de perfiles, auditoría del logo, reemplazo de componentes de
  combos, snapshots de precio, aislamiento de compras, paginación/filtros, tokens
  consumidos, dashboard vacío, matriz de grants, idempotencia del backfill y regresión
  de campañas.
- `tests/db/loopoint-f8-tests.sql` endurecido: el orden de auditoría se comprueba con
  timestamps explícitos para no depender del orden de dos altas en el mismo segundo.
- `tests/unit/Brand.test.tsx`: marca, copy singular/plural y enlaces del logo.
- Verificación: `db reset` local, **31/31 migraciones** en paridad y `db push` remoto;
  API con **600 aserciones SQL** + 4 pruebas de concurrencia; web con **149 unitarias**,
  **34 E2E**, `tsc -b`, build y smoke correctos.
- Desplegado en producción (`https://fidelizacion01.vercel.app`); smoke 200 en
  `/login`, `/admin/inicio`, `/admin/config`, `/customer`, `/join/:slug` y
  `/scan/:token`; el bundle apunta a `gxfytcquyobhhbjipbea.supabase.co`.
- Documentación cerrada: `BASE_DE_DATOS`, `SEGURIDAD`, `PRUEBAS`, `ESTADO_PROYECTO`,
  `ARQUITECTURA`, `DESARROLLO`, `DESPLIEGUE`, `README`, `INFORME_FINAL`,
  `ENTREGA_FINAL` y este plan.

---

## 7. Trazabilidad requisito → fase

| ID | Requisito de `cambiosPlataforma.md` | Fase | Evidencia de aceptación |
| --- | --- | --- | --- |
| R01 | Nombre Loopoint y logo | F1 | `Brand`, `index.html`, favicon, título |
| R02 | Diseño responsive para teléfono | F1–F8 | Pruebas 360/390/768/1280, sin scroll horizontal |
| R03 | Menú y contenido separados; menú fijo no scrolleable | F1 | Shell con sidebar fijo + `main` scroll propio |
| R04 | Barra superior auto-oculta al bajar y aparece al subir | F1 | `useHideOnScroll` + prueba E2E |
| R05 | Quitar cerrar sesión; menú con cerrar sesión y modo oscuro | F1 | `UserMenu` + tema persistente |
| R06 | Tooltips en formularios/campos | F1 (+F2/F3) | `HelpHint` aplicado a formularios |
| R07 | Parámetros de cliente frecuente en configuración | F2/F3 | Campos en Programa + helper SQL |
| R08 | No perder formularios al cambiar de pestaña | F1 | `useFormDraft` + prueba de recarga |
| R09 | Dos paletas: cliente (conservar) y admin (cambiar) | F1 | Variables por `data-portal` |
| R10 | Eliminar “Ver portal de cliente” | F1 | Sin botón en `AdminShell` |
| R11 | FAB móvil a registrar compra | F1/F4 | `Fab` visible en móvil |
| R12 | Reemplazar “puntos” por “loopoints” | F1 | `lib/copy.ts` + revisión de textos |
| R13 | NickName único opcional con autogeneración y máximo 2 cambios | F2 | Migración + perfil + pruebas SQL |
| R14 | Eliminar página principal y redirigir | F1 | `/` redirige por sesión |
| R15 | Inicio: métricas condensadas + QR por valor o carta/combos + QR invitación | F4 | `PurchaseComposer`, `StatCard`, sección colapsable |
| R16 | Configuración como 2.ª opción, completa por pestañas, móvil, sin mensaje de borrador gigante | F3 | `/admin/config` + redirecciones + diseño móvil |
| R17 | Datos de negocio completos + foto en servidor | F2/F3 | Formulario + Storage |
| R18 | Pestaña de recompensas | F3 | Tab Recompensas |
| R20 | Dos formas de redención + escaneo + confirmación + volver a registrar compra | F6 | `/scan/:token` + flujo E2E |
| R21 | Auditoría más clara | F8 | Etiquetas, filtros y detalle legible |
| R22 | Clientes: quitar redimir + detalle de compra | F5 | `CustomerDetailPage` sin redención |
| R23 | Compras: detalle con productos de la carta | F4/F5 | `purchase_items` + detalle |
| R24 | Eliminar pantalla de balance del cliente | F7 | Sin ruta ni menú Balance |
| R25 | Inicio cliente: lista de negocios con loopoints y verde si hay recompensas | F7 | `customer_businesses_summary` + tarjetas |
| R26 | Al elegir negocio, pantalla tipo principal con lista de negocios arriba | F7 | `/customer/business/:id` |
| R27 | Compras y canjes del cliente con lista y detalle | F5/F7 | Rutas + detalle |

> La línea 37 del documento repite el texto de la línea 30 (QR en Configuración). Se
> interpreta como error de copia; el QR de compra vive en Inicio y en Registrar compra, no
> duplicado en Configuración.
>
> **R19 (campañas estáticas) se retira por decisión del cliente (25/10/2026).** No se
> modifica la pantalla de Campañas ni la lógica de acumulación por campañas: se conserva
> exactamente lo que ya existe.

---

## 8. Plan de pruebas

### 8.1 SQL (`tests/db/loopoint-tests.sql`)

Casos mínimos nuevos:

1. Nickname: formato inválido, duplicado por mayúsculas, autogeneración `nombre`, `nombre2`.
2. Nickname: 2 cambios explícitos permitidos; el tercero devuelve `nickname_change_limit`;
   el autogenerado no incrementa el contador.
3. Perfil: cliente edita su nombre/nickname; no puede editar el de otro.
4. Negocio: admin edita sus datos; encargado/cliente no; validación de WhatsApp/URL.
5. Storage/logo: ruta de otro negocio rechazada; URL guardada; auditada.
6. Frecuencia: 2 compras en 90 días → no frecuente; 3 → frecuente; gasto mínimo;
   ventana móvil; “activo” y “recuperación”; valores configurables por el admin.
7. Combos: componentes del mismo negocio, cantidad > 0, no auto-referencia, no ciclos,
   actualización reemplaza componentes.
8. Compra con ítems: suma correcta, producto ajeno rechazado, cantidad inválida, monto
   distinto, snapshot conservado tras cambiar precio/nombre.
9. Detalle de compra: admin de A no ve compra de B; cliente solo ve la propia.
10. Listas: `items_count`, paginación, filtro por negocio.
11. Cliente multi-negocio: 3 negocios con saldos distintos, `ready_rewards` correcto,
    sin filas de negocios ajenos.
12. Token de canje: contexto sin `business_id`, rol incorrecto, token vencido, token usado.
13. `redemption_redeem_by_token`: descuenta una sola vez, entrega, token consumido,
    auditoría, doble llamada idempotente/fallida.
14. Dashboard: métricas cuadran; sin datos devuelve 0/null; aislamiento por negocio.
15. Grants: `anon` no ejecuta RPC nuevas; `PUBLIC` sin EXECUTE en funciones internas.
16. Backfill: perfiles existentes reciben nickname; no se pisan los existentes.
17. Campañas: prueba de regresión de que la lógica actual de campañas dinámicas sigue
    funcionando sin cambios.

Integrar en `scripts/test-db.sh` y actualizar el conteo esperado.

### 8.2 Unitarias (Vitest)

- `ThemeProvider`: alterna, persiste, respeta preferencia inicial.
- `UserMenu`: opciones, cierre de sesión, modo oscuro.
- `useHideOnScroll`: umbral, dirección, top.
- `useFormDraft`: restaura, guarda, limpia, TTL, versiones.
- `Brand`/copy: Loopoint y loopoints.
- `StatCard`/dashboard: formato, ceros, carga/error.
- `PurchaseComposer`: manual vs. carta, cantidades, total, ítems, edición de importe.
- `ComboEditor`: validaciones y reemplazo.
- Config tabs: navegación, guardado, redirecciones.
- `ScanPage`: estados token, rol, confirmación, redirección.
- `AuditPage`: etiquetas, filtros, detalle.
- `CustomerBusinessesPage`: saldos, verde, selección.
- `CustomerBusinessHomePage`: negocio por URL, cabecera de negocios.
- `PurchaseDetail`: ítems y compra sin ítems.
- `ProfilePage`: nickname disponible/ocupado, autogenerado, contador de 2 cambios y bloqueo.
- `CustomerDetailPage`: sin redención, detalle de compra.

### 8.3 E2E (Playwright + fake Supabase)

1. Admin entra a Inicio, ve métricas reales y genera QR eligiendo combo + productos.
2. Invitación: despliega QR y copia enlace.
3. Configuración: edita negocio + criterios de frecuente + recompensa, recarga y persiste.
4. Borrador: escribe, recarga, recupera; guarda y el borrador se limpia.
5. Tema oscuro: activa, recarga, sigue activo; QR legible.
6. Menú móvil: sin “Ver portal”, sin logout suelto; FAB; header se oculta.
7. Cliente con dos negocios: ve saldos distintos, verde en uno, entra al detalle y vuelve.
8. Compra con ítems: admin crea QR, cliente reclama, ambos ven el detalle.
9. Canje manual: cliente solicita, admin aprueba/entrega, cliente ve estado.
10. Canje escaneado: cliente muestra URL, staff abre `/scan/:token`, confirma, vuelve a
    registrar compra.
11. Auditoría: se entiende la operación y se filtra.
12. Guards: cliente no entra a admin; encargado sin permiso no aprueba; negocio B no ve A.

Actualizar `tests/e2e/fake-supabase.ts` con las RPC nuevas y los nuevos campos.

### 8.4 Matriz de dispositivos

- 360×640 (Android pequeño), 390×844 (iPhone 13), 430×932, 768×1024 (tablet), 1280×800.
- Verificar: sin overflow horizontal, bottom nav no tapa contenido, FAB no tapa acciones,
  modales con scroll interno, tablas convertidas a tarjetas, QR descargable.

---

## 9. Despliegue y rollback

### Orden de despliegue

1. API local: `npx supabase db reset` + `npm test`.
2. API remoto: `npx supabase migration list` → `npx supabase db push`.
3. Verificar RPC nuevas y grants en remoto:
   ```sql
   select proname, pg_get_function_identity_arguments(oid)
   from pg_proc where proname in ('customer_businesses_summary','business_dashboard_summary');
   ```
4. Web: `npm run test:all && npm run build`.
5. Vercel: variables de entorno y deploy.
6. Smoke: `/login`, `/admin/inicio`, `/admin/config`, `/scan/:token`, `/join/:slug`,
   `/customer`; comprobar que el bundle apunta al Supabase correcto.

**Estado (27/10/2026):** los seis pasos se ejecutaron. Paridad **31/31**, web de
producción actualizada y smoke 200 en todas las rutas indicadas.

### Rollback

- Las migraciones son aditivas (columnas nullables, tablas nuevas, RPC nuevas). Un rollback
  de web no rompe la BD.
- Los wrappers de RPC antiguos se mantienen al menos un ciclo.
- La pantalla y la lógica de campañas no se modifican, así que no añaden riesgo nuevo.
- El logo/foto es opcional; si Storage falla, se usa el logo por defecto.
- Si una migración falla, no se edita la aplicada: se crea una correctiva.

---

## 10. Riesgos y mitigaciones

| Riesgo | Impacto | Mitigación |
| --- | --- | --- |
| Cambios de contrato RPC rompen web | Alto | RPC nuevas + wrappers; desplegar API y web juntos; E2E con fake actualizado |
| Migraciones locales/remotas en distinto orden | Alto | `migration list` antes/después; timestamp único; nunca editar aplicadas |
| Storage mal configurado permite escribir en otro negocio | Alto | Políticas por prefijo `business/<id>/` y pruebas con dos cuentas |
| Frecuencia “cliente frecuente” ambigua | Medio | Defaults configurables + UI explicativa + validación en servidor |
| Nickname usado para suplantación o cambios abusivos | Medio | Reservados, unicidad, límite de 2 cambios y auditoría |
| Modo oscuro con bajo contraste o QR ilegible | Medio | Tokens con contraste AA; QR siempre blanco; QA visual |
| Formularios se siguen perdiendo | Medio | `useFormDraft` en todos los formularios + quitar resets automáticos |
| Nickname expuesto en listas o QR | Bajo | RLS, no incluir en el QR de canje; solo mostrar al staff autorizado |
| Auditoría con metadata no confiable | Medio | Renderizar texto escapado; nunca `dangerouslySetInnerHTML` |
| Dashboard lento con muchos datos | Medio | Índices; agregados por rango; snapshots si hace falta |
| Complejidad de combos anidados | Medio | Solo un nivel, sin ciclos, validación en servidor |
| Pruebas E2E frágiles | Medio | Fake determinista, datos por prefijo, viewport fijo |
| Alcance grande en un solo ciclo | Alto | Fases con aceptación; no empezar F4 sin F1–F3 verdes |

---

## 11. Calendario propuesto

| Semana | Fases | Entregable |
| --- | --- | --- |
| 1 | F0 + F1 | Loopoint, temas, shells fijos, menú, tooltips, drafts, FAB |
| 2 | F2 + F3 | Identidad/perfil, negocio completo, frecuencia, Configuración unificada |
| 3 | F4 + F5 | Inicio con métricas y QR con carta/combos, detalle de compras y clientes |
| 4 | F6 | Canje por QR escaneado y solicitudes |
| 5 | F7 + F8 | Portal cliente multi-negocio, auditoría legible |
| 6 | F9 + buffer | Pruebas, documentación, migraciones remotas y despliegue |

**Total estimado:** 21.5 días de desarrollo + 20 % de buffer ≈ **5 semanas** con una
persona. Con API y web en paralelo se puede acercar a **4 semanas**, respetando las
dependencias.

### Dependencias

```
F0 → F1 → F2 → F3 → F4 → F5 → F6 → F7
F1 → F8 (auditoría visual depende del tema/shell)
F9 depende de todo
```

F6 puede ir en paralelo con F5 si el equipo separa API y web. F7 puede empezar cuando M3/M4
estén aplicadas.

---

## 12. Primeros pasos concretos

```bash
# 1. Crear ramas de trabajo
cd /home/leonardo/Fidelizacion/fidelizacionApi
git switch -c feat/loopoint-redesign

cd ../fidelizacionWeb
git switch -c feat/loopoint-redesign

# 2. Baseline (no seguir si algo falla)
cd ../fidelizacionApi && npm test
cd ../fidelizacionWeb && npm run test:all

# 3. F0: asset y .env.example
cp ../loopointCoinNoBG.png public/loopoint-coin.png   # desde fidelizacionWeb
# editar .gitignore para versionar .env.example

# 4. F1: empezar por ThemeProvider + Brand + shells
```

---

## 13. Decisiones cerradas (25/10/2026)

1. **Paleta admin:** aprobada turquesa/azul noche/dorado; tokens en §3.4.
2. **Cliente frecuente:** configurable por el admin, con los valores por defecto de §4/M1.
3. **NickName:** máximo **2 cambios** explícitos; el tercero se rechaza en servidor.
4. **Campañas:** no se modifican en este ciclo; se conserva la pantalla y la lógica actual.
5. **Documentación:** este plan se queda en `documentacion/` local, como el resto de la
   documentación del workspace.
6. **App Android:** se actualizará después de cerrar la web; no se toca en este ciclo.

---

## 14. Definición de terminado (DoD)

- [x] Las 26 filas activas de la matriz de trazabilidad tienen evidencia (R19 descartado).
- [x] `tsc -b`, unitarias, E2E y build en verde.
- [x] Pruebas SQL nuevas verdes y `scripts/test-db.sh` actualizado.
- [x] Migraciones aplicadas en local y remoto con paridad total (31/31).
- [x] Sin botones/textos obsoletos (“Ver portal del cliente”, “Balance”, “puntos” donde
      deba decir “loopoints”).
- [x] Sin formularios que pierdan datos al cambiar de pestaña o recargar.
- [x] Responsive verificado a 360 px y escritorio; sin scroll horizontal.
- [x] Modo oscuro y ambas paletas verificados; QR legible.
- [x] Documentación actualizada y web desplegada con smoke correcto.
- [x] Repositorios con commits pequeños y `main` sincronizado con `origin/main`.
