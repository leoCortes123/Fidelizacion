# Estado del proyecto

**Última actualización:** 27/10/2026
**Workspace:** `/home/leonardo/Fidelizacion`
**Estado:** módulo multiempresa **completo y desplegado** (fases 0–7) y rediseño
Loopoint **cerrado hasta F9** (auditoría legible, pruebas, documentación y
despliegue final). Web en producción, 31 migraciones en paridad con Supabase remoto
y suites en verde.

> **Para una sesión nueva:** lee este archivo, `PLAN_IMPLEMENTACION.md` y
> `documentacion/PRUEBAS.md`. Los valores operativos reales están en
> `documentacion/privado/CREDENCIALES.local.md` (no se versiona).

---

## 1. Estructura y repositorios

```text
/home/leonardo/Fidelizacion/
├── fidelizacionWeb/     React + Vite + Tailwind + Playwright
├── fidelizacionApi/     Supabase: migraciones, RPC, RLS, seed y pruebas SQL
├── fidelizacionApp/     Espacio reservado para Android (sin código aún)
├── documentacion/       Documentación, negocio y datos privados
├── PLAN_IMPLEMENTACION.md
└── ENTREGA_FINAL.md
```

| Proyecto | GitHub | Estado |
| --- | --- | --- |
| Web | `https://github.com/leoCortes123/fidelizacionWeb` | Funcional y desplegada en Vercel |
| API | `https://github.com/leoCortes123/fidelizacionApi` | 31 migraciones aplicadas en local y remoto |
| App | `https://github.com/leoCortes123/fidelizacionApp` | Espacio reservado |

Supabase: proyecto `fidelizacion01` (`gxfytcquyobhhbjipbea`).
Web: `https://fidelizacion01.vercel.app` (con Deployment Protection de Vercel).

El repositorio anterior `leoCortes123/fidelizacion01` (`~/Mi_Negocio`) queda como
referencia histórica.

---

## 2. Qué está implementado

### Base de datos / API

- **Multiempresa:** `businesses`, `business_memberships` (roles `admin`,
  `encargado`, `cliente`), productos, programas, cuentas y libro de puntos.
- **Canje con QR:** solicitud con reserva, token SHA-256, vigencia, reemisión,
  aprobación con permiso, entrega y cancelación con devolución. El QR codifica
  `/scan/<token>`: el negocio escanea, confirma la entrega en un solo paso y el
  token se consume. El listado distingue origen `manual` / `qr_scan`.
- **Acumulación:** compras presenciales con importe elegible, idempotencia, reverso
  auditado y campañas con multiplicador/bono.
- **Vencimiento FIFO** por lote con job diario (`pg_cron` cuando está disponible).
- **Economía:** perfil con datos confirmados/estimados/desconocidos, panel de
  presupuesto, alertas y snapshots mensuales reproducibles.
- **Auditoría** paginada por operación.
- **Seguridad:** RLS por negocio, RPC `SECURITY DEFINER`, hardening de grants,
  `last_admin`, límites por cliente/periodo/total y validación de descuentos.
- **Afiliación** pública por enlace `/join/:slug` y alta de miembros por correo.

### Web

- **Cliente:** portal multi-negocio con tarjetas por negocio (logo, loopoints, badge
  verde si hay recompensas listas, frecuencia y última compra), inicio del negocio con
  saldo, recompensas, movimientos y compras, historial global de compras y canjes con
  filtro por negocio y detalle, solicitud con QR, “Mis canjes”, reemisión y perfil.
- **Administrador:** dashboard, programa, carta, recompensas, campañas, solicitudes,
  miembros, compras, panel económico, auditoría y wizard de configuración.
- **Encargado:** validación de QR, aprobación/rechazo, confirmación de entrega y
  formulario de venta en `/encargado/venta`.
- **Escaneo:** `/scan/:token` resuelve el negocio desde el token, valida permisos,
  muestra recompensa/nickname/vencimiento y, al confirmar, redirige a registrar
  compra.
- **Guards** por negocio y por rol, con selector de negocio persistido.

### App Android

- Repositorio creado con README, `.gitignore`, `.env.example` y carpeta `app/`.
- Plan técnico en `documentacion/APP_ANDROID.md`. Sin proyecto Gradle todavía.

---

## 3. Última ejecución verificada (27/10/2026)

| Suite | Resultado |
| --- | --- |
| TypeScript (`tsc -b`) | Sin errores |
| Unitarias/componentes | **149/149** |
| E2E Playwright | **34/34** |
| SQL (PostgreSQL 16 efímero) | **600 aserciones** + 4 pruebas de concurrencia |
| Casos de aceptación | **20/20** (`tests/db/loyalty-tests.sql`) |
| Build + smoke | Correcto (`dist/`) |
| Paridad de migraciones | 31/31 local y remoto |
| Despliegue web | Producción actualizada en Vercel |

Verificación remota:

- Migración `20261026000200_backfill_grants_indexes.sql` aplicada; paridad
  local/remoto **31/31**.
- `business_public_get('tacos-don-pepe')` responde con el negocio de prueba.
- `customer_businesses_summary`, `business_dashboard_summary`,
  `business_recent_activity`, `purchase_qr_create_with_items`, `product_combo_set`,
  `redemption_redeem_by_token` y `business_audit_log_page` existen en remoto.
- El barrido de grants deja a `anon` solo con `business_public_get` y
  `purchase_qr_preview`.
- Web desplegada en producción (`fidelizacion01.vercel.app`): smoke 200 en `/login`,
  `/admin/inicio`, `/admin/config`, `/customer`, `/join/:slug` y `/scan/:token`.
- El bundle desplegado apunta a `gxfytcquyobhhbjipbea.supabase.co` y el fallback SPA
  responde 200.

---

## 4. Cómo retomar

```bash
# API
cd /home/leonardo/Fidelizacion/fidelizacionApi
npm run db:start
npm run db:reset
npm test

# Web
cd /home/leonardo/Fidelizacion/fidelizacionWeb
npm ci
npm run dev
npm run test:all      # typecheck + unitarias + E2E (puerto 5199)
```

Si Playwright no tiene navegador:

```bash
npx playwright install chromium
```

Remoto:

```bash
cd /home/leonardo/Fidelizacion/fidelizacionApi
npx supabase migration list --linked
npx supabase db push
```

Web:

```bash
cd /home/leonardo/Fidelizacion/fidelizacionWeb
npx vercel deploy --prod --yes
```

---

## 5. Pendientes para producción pública

1. **Decidir acceso:** el proyecto de Vercel mantiene Deployment Protection
   (`vercel_authentication`). Si la demo debe ser pública, desactivarla.
2. **Dominio definitivo:** si cambia, actualizar `VITE_PUBLIC_APP_URL`, Site URL y
   Redirect URLs de Supabase, el JavaScript origin de Google y `vercel.json` (CSP).
3. **Google OAuth real** con la cuenta titular en el dominio final.
4. **Prueba manual con dos dispositivos** del QR de canje y del enlace de afiliación.
5. **Rotar** el token personal de Supabase usado para las migraciones.
6. **CI de GitHub:** los workflows existen, pero la cuenta tiene un bloqueo de
   facturación que impide que los jobs arranquen.
7. **App Android:** crear proyecto Gradle y su CI.
8. **Cron:** confirmar que `pg_cron` está habilitado en el proyecto remoto; si no,
   programar el vencimiento y los snapshots con un job externo.

---

## 6. Limitaciones conocidas

- Una moneda (COP), una zona horaria de presentación y un local por negocio.
- El registro por correo no verifica el correo (decisión de esta etapa).
- El E2E usa un backend en memoria; RLS y transacciones se prueban en PostgreSQL.
- El QR es una credencial portadora hasta que se consume (compra) o se aprueba
  (canje).
- El panel económico estima el costo de premios con el precio de la carta; los
  productos sin costo se excluyen del costo contable.
- No hay tiempo real: el cliente ve el saldo al reabrir o enfocar la vista.
- No hay una API HTTP propia: el API es Supabase (PostgREST + RPC).
- La app Android no existe todavía.

---

## 7. Archivos clave para revisar primero

### Web

- `src/app/router.tsx` — rutas, guards y carga diferida.
- `src/features/loyalty/businessContext.tsx` — negocio y rol seleccionados.
- `src/features/customer/CustomerBusinessesPage.tsx` — tarjetas por negocio e invitación.
- `src/features/customer/CustomerBusinessHomePage.tsx` — saldo, recompensas y compras
  del negocio elegido.
- `src/features/admin/RedemptionsPage.tsx` — aprobación, origen y entrega.
- `src/features/loyalty/ScanRedemptionPage.tsx` — `/scan/:token` y confirmación.
- `src/features/admin/OnboardingWizardPage.tsx` — configuración guiada.
- `src/features/admin/auditLabels.ts` — catálogo de operaciones de auditoría.
- `src/features/admin/AuditPage.tsx` — auditoría legible con filtros y detalle.
- `tests/e2e/loyalty.spec.ts` — 34 flujos de navegador.
- `vercel.json` / `public/_headers` — despliegue y CSP.

### API

- `supabase/migrations/` — 31 migraciones; la última cierra backfill, grants e índices.
- `tests/db/loyalty-tests.sql` — 20 casos de aceptación.
- `tests/db/loopoint-f6-tests.sql` — 32 aserciones del canje escaneado.
- `tests/db/loopoint-f7-tests.sql` — 26 aserciones del portal multi-negocio.
- `tests/db/loopoint-f8-tests.sql` — 24 aserciones de la auditoría legible.
- `tests/db/loopoint-f9-tests.sql` — 85 aserciones de cierre (grants, backfill, listas y regresión).
- `tests/db/loyalty-phase0-tests.sql` — cobertura detallada del módulo.
- `scripts/test-db.sh` — PostgreSQL efímero y concurrencia.

### Documentación

- `PLAN_IMPLEMENTACION.md` y `ENTREGA_FINAL.md` (workspace).
- `documentacion/BASE_DE_DATOS.md`, `SEGURIDAD.md`, `PRUEBAS.md`, `DESPLIEGUE.md`.

---

## 8. Handoff para la próxima sesión

> “Lee `ESTADO_PROYECTO.md` y `PRUEBAS.md`. El módulo multiempresa está completo y el
> rediseño Loopoint cerró en F9 (pruebas, documentación y despliegue). Antes de tocar
> código ejecuta `npm test` en la API y `npm run test:all` en la web. No edites
> migraciones ya aplicadas: crea una nueva. Si cambias reglas de negocio, actualiza
> `tests/db/loyalty-tests.sql`, `tests/db/loopoint-f6-tests.sql`,
> `tests/db/loopoint-f7-tests.sql`, `tests/db/loopoint-f8-tests.sql`,
> `tests/db/loopoint-f9-tests.sql` y las pruebas unitarias/E2E correspondientes. Los
> pendientes son operativos (dominio, OAuth real, protección de Vercel, cron y app
> Android).”
