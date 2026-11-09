# Pruebas

Las pruebas están separadas por repositorio: la web valida interfaz y contrato; el
API valida base de datos, RLS, RPC, límites y concurrencia.

## Web (`fidelizacionWeb`)

```bash
cd fidelizacionWeb

npm run typecheck   # TypeScript
npm test            # Vitest + Testing Library (149 pruebas)
npm run test:build  # build + smoke del bundle servido desde dist/
npm run test:e2e    # Playwright (backend Supabase en memoria, 34 flujos)
npm run test:all    # typecheck + unitarias + E2E
```

> Los E2E usan el puerto **5199** por defecto para no reutilizar un `npm run dev`
> abierto en 5173 que apunte a otro backend. Si está ocupado:
> `E2E_PORT=5200 npm run test:e2e`.

### Unitarias y de componentes

`tests/unit` (149 pruebas en 30 archivos):

| Área | Archivos | Cubre |
| --- | --- | --- |
| Navegación y roles | `navigation`, `RequireAuth`, `RequireBusinessRole`, `businessContext` | Destino por rol, guards, selector de negocio, permisos |
| Formato y errores | `format`, `errors` | COP, fechas de Bogotá, puntos y traducción de códigos de negocio |
| Autenticación | `LoginPage`, `AuthCallbackPage` | Google, correo/contraseña, destino seguro |
| Programa y carta | `ProgramPage`, `ProductsPage` | Valores por defecto, validación, costo y activación |
| Recompensas | `RewardsPage` | Producto obligatorio, límites, porcentaje y descuento ≤ mínimo |
| Canje con QR | `ClaimPage`, `CustomerRedemptions`, `EncargadoPage`, `ScanRedemptionPage` | QR, reemisión, vencimiento, aprobación, entrega y `/scan/:token` |
| Cliente | `CustomerBusinessesPage`, `CustomerRedemptions`, `BusinessJoinPage` | Negocios con saldo por negocio, invitación, canjes globales, QR y afiliación pública |
| Administración | `MembersPage`, `RedemptionsPage`, `AuditPage`, `EconomicPage`, `CampaignsPage`, `OnboardingWizardPage` | Miembros, solicitudes (origen y entrega), auditoría, panel económico, campañas y wizard |
| Rediseño Loopoint | `ProfilePage`, `BusinessProfileForm`, `FrequentCriteriaCard`, `PurchaseRegistrationPage`, `theme`, `Brand` | Alias, ficha de negocio, frecuencia, combos, marca/copy y tema |
| Auditoría legible | `auditLabels` | Etiquetas de las 31 operaciones por negocio, resumen humano, detalle formateado y catálogo legado |

### E2E

`tests/e2e` usa Playwright con un backend Supabase en memoria
(`fake-supabase.ts`). No sustituye a Supabase: valida la interfaz y el contrato de
las RPC.

Flujos (34):

1. Registro de negocio.
2. Gestión de recompensas.
3. Programa, carta y recompensas persistentes tras recargar.
4. Saldo por negocio y solicitud de recompensa.
5. Encargado valida QR y aprueba.
6. Aislamiento entre negocios.
7. Cliente no entra a `/admin`.
8. Flujo completo de QR: solicitud, recuperación, entrega y estado final.
9. Admin aprueba, entrega y cancela con motivo.
10. Encargado sin permiso no aprueba.
11. Afiliación pública `/join/:slug`.
12. Invitación con enlace/QR y alta de encargado por correo.
13. Encargado redirigido a su portal.
14. Compra → auditoría → panel económico.
15. Wizard de configuración inicial en cuatro pasos.
16. Dashboard enlaza a completar configuración.
17. Campaña que duplica puntos.
18. Snapshot mensual del panel económico.
19. Borrador de configuración tras recargar.
20. Shell móvil: menú fijo, cabecera fija, FAB y modo oscuro.
21. Perfil: alias disponible, dos cambios y persistencia.
22. Ficha pública del negocio y logo.
23. Criterios del cliente frecuente.
24. Clientes: alias y distintivo de frecuente activo.
25. Configuración unificada: pestañas, borrador y redirecciones.
26. Configuración móvil sin scroll horizontal a 360 px.
27. Compra con carta y combos, total y detalle en ambos portales.
28. Compra manual sin productos.
29. Detalle de cliente sin canje manual y compras clicables.
30. QR escaneado: `/scan/:token`, entrega atómica y vuelta a registrar compra.
31. Portal cliente multi-negocio: tres tarjetas con saldos separados, recompensas
    listas, sin entrada de Balance y redirección de `/customer/balance`.
32. Compras y canjes globales del cliente con filtro por negocio y detalle.
33. Auditoría legible: etiquetas, detalle formateado, “Ver JSON”, filtros por
    categoría, texto libre y fecha, y estado vacío.
34. Auditoría legible en móvil: tarjetas y detalle.

El script `scripts/smoke-build.mjs` sirve `dist/` y comprueba que `/`, `/login` y
la página 404 renderizan con el bundle minificado (sin sesión, `/` redirige a
`/login`).

## API (`fidelizacionApi`)

```bash
cd fidelizacionApi
npm test            # PostgreSQL 16 efímero en Docker
```

`scripts/test-db.sh` levanta PostgreSQL 16, crea un stub de Supabase
(`auth`, roles, `auth.uid()`), aplica las 31 migraciones y la semilla, y ejecuta:

1. `tests/db/run-tests.sql` — flujo legacy de compras, RLS y libro de puntos.
2. `tests/db/loyalty-phase0-tests.sql` — módulo multiempresa, roles, QR,
   acumulación, económico, auditoría y Fase 6.
3. `tests/db/purchase-qr-tests.sql` — venta con QR por negocio.
4. `tests/db/loyalty-tests.sql` — **20 casos de aceptación** de Fase 7.
5. `tests/db/loopoint-tests.sql` y `loopoint-f4-tests.sql` — identidad, negocio,
   frecuencia, combos, ítems, detalle y métricas.
6. `tests/db/loopoint-f6-tests.sql` — **32 aserciones** del canje escaneado:
   contexto sin `business_id`, permisos, entrega atómica, token vencido/reutilizado,
   origen `manual`/`qr_scan`, auditoría y aislamiento.
7. `tests/db/loopoint-f7-tests.sql` — **26 aserciones** del portal multi-negocio:
   saldo, recompensas listas, frecuencia y solicitudes por negocio, aislamiento entre
   clientes, canjes con slug/logo y permisos.
8. `tests/db/loopoint-f8-tests.sql` — **24 aserciones** de la auditoría legible:
   nombre del actor, filtro por operación y por varias categorías, filtro por
   actor, rango de fechas (con `p_to` exclusivo), búsqueda libre con comodines
   literales, paginación con `total_count`, orden descendente determinista,
   permisos (admin/encargado leen, cliente y usuario ajeno no) y rango inválido.
9. `tests/db/loopoint-f9-tests.sql` — **85 aserciones** de cierre: duplicados de
   nickname sin distinguir caja, RLS de perfiles, auditoría del logo, reemplazo de
   componentes de combos, snapshot de precio, aislamiento de compras, paginación y
   filtros, tokens consumidos, dashboard vacío, matriz de grants, backfill
   idempotente y regresión de campañas.
10. Concurrencia real: dos reclamos del mismo QR legacy, dos reclamos del QR de
    venta, dos aprobaciones simultáneas y dos escaneos simultáneos del mismo canje.

Resultado actual: **600 aserciones SQL en verde** y 4 pruebas de concurrencia.

### Casos de aceptación (`loyalty-tests.sql`)

| # | Caso | Evidencia principal |
| --- | --- | --- |
| 1 | Registro de negocio | Programa/perfil por defecto, slug duplicado rechazado |
| 2 | Roles por negocio | `admin`/`registrar`/`customer`, `last_admin`, guards |
| 3 | Aislamiento y RLS | Sin acceso a otro negocio ni escritura directa |
| 4 | Recompensas | Producto obligatorio, puntos, porcentaje e importe |
| 5 | Acumulación | `floor(15500/1000)=15`, saldo, libro y auditoría |
| 6 | Reverso | Devuelve puntos, es idempotente y queda auditado |
| 7 | Duplicados | Misma clave no duplica; clave de otro cliente entra en conflicto |
| 8 | Saldo insuficiente | `insufficient_points` sin crear redención |
| 9 | Reserva y liberación | Reserva al solicitar, libera al cancelar, consume al entregar |
| 10 | QR vigente | Validación, cliente y permiso de aprobación |
| 11 | QR vencido | `token_expired` al validar y al aprobar; cancelación libera |
| 12 | QR reutilizado | `redemption_not_pending`; reemisión invalida el anterior |
| 13 | Doble aprobación | Una sola auditoría y un solo token consumido (concurrencia real en el script) |
| 14 | Vencimiento FIFO | Solo vence el lote antiguo, idempotente y auditado |
| 15 | Presupuesto | Ventas, referencia, máximo, costo redimido y % comprometido |
| 16 | Datos incompletos | “Desconocido” limpia el dato y el panel marca estimado |
| 17 | Límites | Por cliente, por periodo y total; validaciones de descuento |
| 18 | Datos ajenos | Cliente, encargado sin permiso y otro negocio rechazados |
| 19 | Campañas | Multiplicador, bono, mínimo, vigencia y solo admin |
| 20 | Snapshots | Reproducible por mes; funciones de cron solo para `service_role` |

### Garantías cubiertas en PostgreSQL real

- trigger de perfiles y roles;
- autorización: cliente vs. admin/encargado, incluido `admin_redeem_reward`;
- compras legacy, reclamación atómica y QR expirado;
- RLS por tabla y denegación de escrituras directas;
- libro inmutable, saldo no negativo y trigger diferido;
- hardening de `loyalty_transaction_post` (sin `EXECUTE` para clientes);
- vencimiento por lote, campañas y snapshots reproducibles.

## Qué no cubren las pruebas

- Google OAuth contra Google real (requiere interacción del titular).
- Un E2E contra Supabase alojado con datos reales.
- Pruebas de carga o de accesibilidad automatizada con axe.
- Envío real de correos (la confirmación está desactivada).
- App Android (aún sin proyecto).
- Las funciones `SECURITY DEFINER` rechazan llamadas sin sesión con
  `not_authenticated`, pero conservan `EXECUTE` para `anon` por los privilegios por
  defecto de Supabase; la autorización real está en `auth.uid()` y en la membresía.
