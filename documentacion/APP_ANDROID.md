# App Android — plan

## Alcance

La app será la experiencia del **cliente** del programa de fidelización. El panel
administrativo seguirá en la web.

Funciones previstas:

1. Inicio de sesión con Google y correo/contraseña (Supabase Auth).
2. Sesión persistente y cierre de sesión.
3. Saldo de puntos y catálogo de recompensas.
4. Historial de compras y canjes.
5. Escaneo del QR de compra para reclamar puntos.
6. Estado de canjes aplicados por caja.
7. Notificaciones (fase posterior, si se decide).

## Stack propuesto

| Capa | Tecnología |
| --- | --- |
| Lenguaje | Kotlin |
| UI | Jetpack Compose + Material 3 |
| Arquitectura | MVVM + repositorios + estado unidireccional |
| Navegación | Navigation Compose |
| Backend | Supabase (Auth, PostgREST, RPC) |
| Cliente | `supabase-kt` o Ktor contra REST/RPC |
| Cámara/QR | CameraX + ML Kit Barcode Scanning |
| Preferencias seguras | DataStore + Keystore |
| Pruebas | JUnit, Compose UI Test y E2E manual en staging |

## Estructura propuesta

```text
app/src/main/java/com/fidelizacion/app/
  data/
    remote/          Supabase/HTTP, DTOs
    local/           sesión y preferencias
    repository/      implementaciones
  domain/
    model/           modelos de negocio
    usecase/         casos de uso
  ui/
    auth/            login, callback
    home/            saldo y recompensas
    history/         compras y canjes
    scan/            cámara y reclamo
    theme/           Material 3
    navigation/      grafo de navegación
```

## Contrato con el API

- Se reutilizan las RPC documentadas en
  [`BASE_DE_DATOS.md`](BASE_DE_DATOS.md): `get_my_dashboard`,
  `list_my_purchases`, `list_active_rewards`, `list_my_redemptions`,
  `claim_purchase`, etc.
- La app **no** aplica canjes: esa operación es exclusiva del panel web
  (`admin_redeem_reward`).
- La sesión se envía como JWT de Supabase; nunca se envía un `user_id` propio.
- La clave usada es la pública (`anon` / `publishable`). `service_role` no se
  incluye en la app.

## Seguridad

- No versionar `local.properties`, keystores, `google-services.json` ni `.env`.
- Guardar la sesión con DataStore/Keystore; no en texto plano.
- Validar el dominio de los enlaces y no aceptar tokens de QR externos.
- El QR es una credencial portadora: la app debe confirmar el reclamo y mostrar el
  resultado una sola vez.
- Ofuscar/optimizar con R8 en release; conservar reglas necesarias para el cliente
  HTTP.
- Firma de release en CI segura (variables protegidas), nunca en el repo.

## Fases

| Fase | Entregable |
| --- | --- |
| 0 | Proyecto Android Studio, tema, navegación y CI |
| 1 | Login Google/correo, sesión y perfil |
| 2 | Saldo, recompensas e historial |
| 3 | Escaneo de QR y reclamo |
| 4 | Pulido, accesibilidad, pruebas y beta cerrada |
| 5 | Publicación en Play Store |

## Pendientes de decisión

- Paquete definitivo y marca.
- `supabase-kt` vs. Ktor.
- Política de notificaciones.
- Si la app permitirá registro o solo login (la web ya permite registro).
- Estrategia de distribución (Play Store interna/cerrada/abierta).
