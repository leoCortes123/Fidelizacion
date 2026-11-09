# Arquitectura

## Repositorios

El proyecto está separado en tres repositorios independientes y un directorio de
documentación compartido:

| Componente | Repositorio | Responsabilidad |
| --- | --- | --- |
| Web | `fidelizacionWeb` | Portal del cliente y panel de administración |
| API | `fidelizacionApi` | Supabase: esquema, RPC, RLS, Auth y seed |
| App | `fidelizacionApp` | App Android (Kotlin/Compose), en fase de espacio reservado |
| Documentación | `documentacion/` | Arquitectura, negocio y operación (local) |

## Vista general

```text
┌──────────────────────────────┐        ┌──────────────────────────────┐
│ Portal del cliente (React)   │        │ Panel de administración      │
│ /customer, /claim/:token     │        │ /admin/*                     │
└──────────────┬───────────────┘        └──────────────┬───────────────┘
               │  Supabase JS (clave publicable, JWT)   │
               └───────────────────┬────────────────────┘
                                   ▼
                    ┌──────────────────────────────┐
                    │ Supabase Auth                │
                    │ Google OAuth + correo/clave  │
                    ├──────────────────────────────┤
                    │ PostgREST + RPC PostgreSQL   │
                    │  · RLS en todas las tablas   │
                    │  · funciones SECURITY DEFINER│
                    │  · transacciones y bloqueos  │
                    └──────────────────────────────┘
                                   ▲
                                   │  (fase futura)
                    ┌──────────────┴───────────────┐
                    │ App Android (Kotlin/Compose) │
                    │ login, saldo, historial, QR  │
                    └──────────────────────────────┘
```

No hay una API HTTP propia: el API **es Supabase**, y la web y la futura app llaman
directamente a Auth/PostgREST/RPC con la clave pública. Toda la lógica sensible vive
en funciones PostgreSQL invocadas por RPC. Los clientes nunca reciben la clave
secreta (`service_role` / `sb_secret_…`).

El repositorio anterior (`fidelizacion01`) queda congelado como referencia
histórica; el desarrollo se organiza en el workspace nuevo.

## Arquitectura multiempresa (v2)

El módulo nuevo convive con el flujo legacy:

```text
Cliente ── /join/:slug ──▶ business_join ──▶ membresía "cliente" + cuenta
Cliente ── solicitar ────▶ reward_request_redemption
                              ├─ valida membresía, vigencia y límites
                              ├─ reserva puntos (redemption_debit)
                              └─ genera token QR (hash SHA-256)
Encargado ─ validar ─────▶ redemption_token_validate
Encargado ─ aprobar ─────▶ redemption_approve (consume token)
Encargado ─ entregar ────▶ redemption_deliver
Admin ──── cancelar ─────▶ redemption_cancel (devuelve puntos)
```

- **`businesses` + `business_memberships`** deciden el negocio y el rol
  (`admin`/`encargado`/`cliente`). `user_roles` queda como rol global legacy.
- **Todo recurso lleva `business_id`** y RLS limita la lectura a miembros; las
  mutaciones pasan por RPC que validan la membresía en el servidor.
- **El cliente web** elige negocio (`BusinessProvider`), persiste la elección por
  usuario y los guards (`RequireBusinessRole`) ocultan rutas no permitidas.
- **Puntos:** libro inmutable con lotes (`expires_at`), reserva al solicitar,
  devolución al cancelar y consumo al entregar. El saldo es una proyección.
- **Economía:** perfil por negocio → panel de presupuesto y snapshots mensuales.
- **Automatización:** jobs de `pg_cron` para vencimiento FIFO y snapshots; si no
  existe la extensión, las RPC quedan para ejecución manual.

El flujo legacy (compra con QR reclamable y canje aplicado por caja) sigue descrito
más abajo y se conserva para compatibilidad.

## Modelo de usuarios

- `profiles`: nombre, correo y fechas.
- `user_roles`: enum `app_role` con `customer`, `admin` y el valor histórico
  `registrar`, que ya no otorga acceso al panel.
- Todo registro crea `customer`. El correo listado en
  `private.bootstrap_admins` recibe además `admin` en el alta.
- Los roles se gestionan por base de datos en esta etapa; la interfaz no permite
  crearlos ni revocarlos.

## Decisiones principales

### 1. El servidor es la única autoridad

- El importe lo envía el administrador autenticado; el cliente no puede modificarlo.
- Los puntos se calculan al reclamar, con la configuración congelada al crear la
  compra (`purchases.settings_snapshot`).
- El saldo es la suma del libro `points_ledger`; no hay un campo editable.
- Los roles se validan dentro de PostgreSQL (`has_role`, `is_staff`), no en el
  cliente. `is_staff()` equivale a `admin` desde la migración del 23/10/2026.

### 2. Dinero exacto

Los importes se almacenan como `integer` en pesos colombianos. El COP se maneja sin
centavos en este negocio; un entero evita errores de coma flotante. La interfaz usa
`Intl.NumberFormat('es-CO', { currency: 'COP' })`.

### 3. Tiempo

La base usa `timestamptz`. La interfaz presenta fechas en `America/Bogota` mediante
`Intl.DateTimeFormat`. Las reglas de vigencia se evalúan en el servidor con `now()`.

### 4. Tokens de compra

- El token se genera con 32 bytes criptográficos y se codifica en Base64 URL-safe.
- Solo se guarda `SHA-256(token)` en `purchases.token_hash`.
- El QR contiene únicamente `/claim/<token>`; nunca importe ni puntos.
- El token viaja al cliente en la respuesta de `purchase_qr_create` y en el QR,
  no se registra en auditoría.
- El QR apunta siempre al dominio publicado (`VITE_PUBLIC_APP_URL`, por defecto
  `https://fidelizacion01.vercel.app`), aunque la venta se genere en local.
- `purchase_qr_preview` permite mostrar negocio, importe y puntos estimados antes
  de iniciar sesión; `purchase_qr_claim` acredita los puntos en la cuenta del
  cliente y lo afilia al negocio si aún no era miembro.

### 5. Canje aplicado en caja

El cliente ya no reserva recompensas ni genera códigos. El administrador elige la
recompensa en el detalle del cliente y `admin_redeem_reward`:

1. exige rol `admin`;
2. bloquea al cliente con `pg_advisory_xact_lock`;
3. valida saldo y recompensa activa;
4. inserta el canje como `redeemed` y el débito en el libro;
5. audita la operación.

Un canje equivocado se corrige con `admin_cancel_redemption`, que devuelve los
puntos y conserva la trazabilidad de la entrega y de la anulación.

## Flujo de compra y reclamación

```text
Administrador                   Servidor                        Cliente
     │                            │                               │
     │ purchase_qr_create(importe)│                               │
     ├───────────────────────────►│ valida rol, importe, programa │
     │                            │ genera token + hash           │
     │                            │ guarda snapshot de reglas     │
     │◄───────────────────────────┤ devuelve token (una vez)      │
     │ muestra QR                 │                               │
     │                            │◄──────────────────────────────┤ escanea /claim/token
     │                            │◄──────────────────────────────┤ purchase_qr_preview
     │                            │                               │ crea cuenta o entra
     │                            │◄──────────────────────────────┤ purchase_qr_claim(token)
     │                            │ bloquea la compra (FOR UPDATE)│
     │                            │ calcula puntos y acredita     │
     │                            │◄──────────────────────────────┤ saldo actualizado
```

## Flujo de canje

```text
Administrador                   Servidor                        Cliente
     │                            │                               │
     │ abre /admin/customers/:id  │                               │
     │ admin_redeem_reward(...)   │                               │
     ├───────────────────────────►│ valida admin y saldo          │
     │                            │ bloquea cliente y recompensa  │
     │                            │ inserta canje + débito        │
     │                            │ audita                        │
     │◄───────────────────────────┤ saldo nuevo                   │
     │                            │                               │
     │ (si hubo error)            │                               │
     │ admin_cancel_redemption    │                               │
     ├───────────────────────────►│ revierte y devuelve puntos    │
```

El cliente ve el cambio al volver a abrir o enfocar la app: TanStack Query
revalida al recuperar el foco. No hay suscripciones en tiempo real.

## Frontend

- **Rutas:** `src/app/router.tsx`, con carga diferida y `Suspense`. Incluye
  `/scan/:token` (canje escaneado) y `/encargado/venta` (registrar compra).
- **Guards:** `RequireAuth` para el portal del cliente, `RequireAdmin` para `/admin`
  y `RequireBusinessRole` para admin/encargado.
- **Shells:** `CustomerShell` (Inicio, Compras, Canjes) y `AdminShell` (Inicio,
  Configuración, Campañas, Solicitudes, Auditoría, Clientes y Compras), con
  navegación inferior en móvil.
- **Diseño móvil primero:** saldo en tipografía grande, tarjetas en lugar de tablas
  en pantallas pequeñas, objetivos táctiles amplios y navegación fija inferior.
- **Estado del servidor:** TanStack Query; las mutaciones invalidan cliente,
  clientes, catálogo, auditoría y panel del cliente.
- **Repositorio:** `fidelizacionWeb`. Las pruebas SQL no viven aquí: pertenecen a
  `fidelizacionApi`.

## App Android (fase futura)

- **Repositorio:** `fidelizacionApp` (espacio reservado, sin código todavía).
- **Alcance:** cliente (login, saldo, recompensas, historial, escaneo de QR).
- **Backend:** el mismo Supabase de `fidelizacionApi`; no se crea una API paralela.
- **Plan y convenciones:** `APP_ANDROID.md`.
