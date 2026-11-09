# Entrega final — Fidelización por puntos multiempresa (v2)

**Fecha:** 25/10/2026
**Alcance:** completo según `PLAN_IMPLEMENTACION.md` (fases 0–7).
**Estado:** implementado, probado y desplegado. La verificación manual con cuentas
reales y el dominio definitivo quedan como tareas de operación.

---

## 1. Resumen

Se completó el módulo de fidelización por puntos con aislamiento multiempresa sobre
Supabase + React, conservando el flujo legacy de un solo negocio. El servidor es la
única autoridad: el navegador nunca decide el negocio, el rol ni los puntos.

| Área | Estado |
| --- | --- |
| Esquema, RLS y RPC | 28 migraciones en local y remoto (`fidelizacion01`) |
| Reglas de puntos | Acumulación, reverso, reserva, vencimiento FIFO y campañas |
| Canje | Solicitud, QR, reemisión, aprobación, entrega y cancelación |
| UI administrador | Programa, carta, recompensas, campañas, solicitudes, miembros, compras, económico, auditoría y onboarding |
| UI cliente | Saldo, historial, recompensas, QR, “Mis canjes” y afiliación |
| UI encargado | Validación, aprobación con permiso y entrega |
| Multinegocio | Roles por negocio, selector, guards y aislamiento |
| Pruebas | 124 unitarias, 30 E2E, 465 aserciones SQL y 4 pruebas de concurrencia |
| Despliegue | API al día; web en producción en Vercel |

---

## 2. Funcionalidad entregada

### Administrador del negocio

- Registro de negocio y wizard de configuración en cuatro pasos.
- Datos del negocio (zona horaria y días de operación).
- Programa de puntos (equivalencia, presupuesto, vencimiento y vigencia del QR).
- Carta con precios y costos.
- Recompensas: producto gratis, descuento fijo, porcentaje o beneficio
  configurable; vigencia y límites por cliente, periodo y total.
- Campañas con multiplicador, bono, compra mínima y vigencia.
- Solicitudes de canje: aprobar, rechazar, entregar y cancelar con motivo.
- Miembros: invitar encargados y clientes, permiso de aprobación y protección del
  último administrador.
- Compras presenciales con importe elegible, vista previa de puntos, idempotencia y
  reverso.
- Panel económico con datos confirmados/estimados/desconocidos, presupuesto,
  alertas y snapshots mensuales.
- Auditoría paginada con filtro y metadata.
- Enlace público de afiliación y QR para compartir.

### Cliente

- Selección de negocio y saldo por negocio.
- Historial de puntos y movimientos.
- Recompensas disponibles con progreso.
- Solicitud de canje con QR, cuenta atrás y reemisión si pierde el código.
- “Mis canjes” con estado y seguimiento.
- Afiliación por `/join/:slug` conservando el destino de login.

### Encargado

- Portal propio para escanear/validar el QR.
- Aprobación solo con `can_approve_redemptions`.
- Rechazo con devolución automática de puntos.
- Confirmación de entrega desde el mismo diálogo o la lista de aprobadas.
- Formulario de venta en `/encargado/venta` para retomar la compra tras un canje.

### Canje escaneado

- El QR contiene `/scan/<token>` y se abre con la sesión del negocio.
- La pantalla muestra recompensa, loopoints, nickname y vencimiento.
- “Confirmar entrega” consume el token, entrega la recompensa y audita el escaneo.
- La solicitud queda con origen `QR escaneado` y se ofrece “Registrar compra”.

---

## 3. Seguridad

- RLS por `business_id` y membresía en todas las tablas nuevas.
- Roles por negocio en `business_memberships`; `user_roles` queda como legacy.
- Tokens QR de 32 bytes; se guarda solo SHA-256, con vigencia y consumo.
- Funciones `SECURITY DEFINER` con `search_path` fijo y validación de rol.
- `loyalty_transaction_post` no es ejecutable por clientes (prueba SQL incluida).
- Idempotencia en compras, solicitudes, reversos y vencimientos.
- Límites de canje y validación de descuentos en el servidor.
- Auditoría de las operaciones sensibles.
- `service_role` y secretos fuera de web, app y repositorios.

---

## 4. Pruebas ejecutadas (25/10/2026)

```bash
# API
cd fidelizacionApi
npm test            # 465 aserciones + concurrencia de QR, aprobación y escaneo

# Web
cd fidelizacionWeb
npm run typecheck   # limpio
npm test            # 124/124
npm run test:e2e    # 30/30 (puerto 5199)
npm run test:build  # build + smoke del bundle
```

Los 20 casos de aceptación están en `fidelizacionApi/tests/db/loyalty-tests.sql` y
se detallan en `documentacion/PRUEBAS.md`.

---

## 5. Despliegue

| Componente | Destino | Estado |
| --- | --- | --- |
| Base de datos | Supabase `fidelizacion01` (`gxfytcquyobhhbjipbea`) | 28/28 migraciones en paridad |
| Web | Vercel `fidelizacion01` | Producción actualizada |
| API HTTP | PostgREST + RPC de Supabase | Sin servidor propio |

La web mantiene Deployment Protection de Vercel. Para una demo pública hay que
desactivarla en Project Settings → Deployment Protection.

---

## 6. Decisiones de arquitectura

1. **Servidor como autoridad.** `auth.uid()` y `business_memberships` deciden todo.
2. **Roles por negocio.** Un usuario puede ser admin en un negocio y cliente en otro.
3. **Libro de puntos inmutable.** El saldo es una proyección; el libro manda.
4. **Reserva al solicitar.** Evita dobles canjes; cancelar libera y entregar consume.
5. **Token QR sin PII.** Hash en base, token solo en la pestaña del cliente.
6. **Migraciones aditivas.** No se editan migraciones ya aplicadas.
7. **Idempotencia en todo lo crítico.** Compras, canjes, reversos y vencimientos.
8. **Legacy etiquetado.** `/admin/settings` sigue disponible como “Sistema anterior”.

---

## 7. Pendientes de operación (no de código)

1. Desactivar Deployment Protection si la entrega debe ser pública.
2. Definir el dominio definitivo y actualizar URL pública, Supabase, Google y CSP.
3. Probar Google OAuth real con la cuenta titular.
4. Probar el QR y la afiliación con dos dispositivos reales.
5. Rotar el token personal de Supabase usado para migraciones.
6. Confirmar `pg_cron` en remoto o programar los jobs externamente.
7. Habilitar GitHub Actions (bloqueo de facturación de la cuenta).
8. Crear el proyecto Android.

---

## 8. Limitaciones conocidas

- Moneda COP y una zona horaria de presentación.
- Registro por correo sin verificación (decisión de esta etapa).
- E2E con backend simulado; la base real se valida con PostgreSQL efímero.
- Sin tiempo real ni notificaciones push.
- App Android sin implementar.
