# Auditoría legal y lista de requisitos para producción — Fideliapp

> [!IMPORTANT]
> **Aviso orientativo:** Este documento es un diagnóstico técnico-legal basado en el análisis real del código fuente (`fidelizacionWebPage`, `fidelizacionWeb`, `fidelizacionApi` y plan de `fidelizacionApp`) y en la normativa aplicable en **Colombia** (moneda `COP`, zona horaria `America/Bogota`). Antes de publicar los textos definitivos, se recomienda su validación por un abogado especializado en protección de datos y comercio electrónico en Colombia.

## Resumen del contexto analizado

Fideliapp opera como una plataforma **SaaS multiempresa B2B2C** con tres frentes activos y una app futura:
- **Sitio comercial estático (`fidelizacionWebPage`):** `https://fideliapp.pages.dev` (Cloudflare Pages).
- **Aplicación / PWA (`fidelizacionWeb`):** `https://fideli-app.vercel.app` (Vercel; portales Cliente, Encargado y Administrador).
- **Backend / Base de datos (`fidelizacionApi`):** Supabase (PostgreSQL con RLS/RPC, Auth con correo/contraseña y Google OAuth, y Storage público `business-assets`).
- **App Android futura (`fidelizacionApp`):** planificada en [APP_ANDROID.md](file:///mnt/datos/Programacion/Fidelizacion/documentacion/APP_ANDROID.md).

**Marco regulatorio principal aplicable (Colombia + plataforma):**
- **Ley 1581 de 2012** y **Decreto 1377 de 2013** (compilado en Decreto 1074 de 2015) — Protección de Datos Personales / Habeas Data (SIC).
- **Ley 1480 de 2011** (Estatuto del Consumidor, en especial Arts. 29–30, 47 y 50) y **Decreto 587 de 2016** (reversión del pago).
- **Ley 527 de 1999** — Comercio electrónico, mensajes de datos y validez de aceptaciones digitales.
- **Ley 2300 de 2023** (*"Dejen de Fregar"*) — Canales y horarios para comunicaciones comerciales (crítica para la futura difusión).
- **Requisitos contractuales de terceros:** verificación de **Google OAuth** en producción, DPAs de subencargados (Supabase, Vercel, Cloudflare, Google) y futuras políticas de **Google Play** / **Meta WhatsApp Business**.

---

## 1. Hallazgos críticos encontrados en el código actual (Bloqueantes P0)

Antes de abrir Fideliapp al público general, el análisis del repositorio detectó **7 brechas técnicas y legales de riesgo alto**:

> [!CAUTION]
> **1.1. Exposición multiempresa de datos personales (`business_search_profiles`)**
> En [20261115000100_avatars_and_reward_images.sql](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionApi/supabase/migrations/20261115000100_avatars_and_reward_images.sql#L330-L365), la función `business_search_profiles(p_business_id, p_query)` permite que **cualquier administrador de cualquier negocio** busque y liste `full_name`, `email` y `avatar_url` sobre **toda la tabla `public.profiles`**, incluyendo usuarios que **nunca se afiliaron a su negocio**.
> Esto contradice directamente lo que la UI promete en [BusinessJoinPage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/loyalty/BusinessJoinPage.tsx#L262-L265) (*"No compartimos datos con otros negocios"*) y vulnera los principios de **finalidad y circulación restringida** de la Ley 1581 de 2012.
> **Acción requerida:** restringir la búsqueda a miembros existentes o coincidencia exacta de correo (o migrar totalmente el alta de equipo a invitaciones por QR `business_member_invites`).

1. **Consentimiento tácito inválido y avisos inexactos:**
   - [LoginPage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/auth/LoginPage.tsx#L1289-L1292): *"Al entrar aceptas que guardemos tu nombre y correo para asociar tus compras. No pedimos datos de tarjetas."*
   - [BusinessJoinPage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/loyalty/BusinessJoinPage.tsx#L262-L265): *"Al unirte aceptas que el negocio asocie tu nombre y correo a tu cuenta de monedas..."*
   - [ClaimPage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/purchases/ClaimPage.tsx#L343-L345): *"Tus datos se usan solo para el programa de monedas del negocio."*
   - **Problemas legales:**
     1. Bajo el **Art. 9 de la Ley 1581 de 2012** y el **Art. 7 del Decreto 1377 de 2013**, la autorización debe ser **previa, expresa e informada**; el silencio o el simple hecho de entrar **no sirve como consentimiento** y además debe conservarse **prueba verificable** (fecha, hora, versión de política, usuario).
     2. El aviso omite datos que la app **sí recolecta y almacena**: `nickname`, `phone`, `birth_date`, `avatar_url` (en Storage público), historial detallado de compras y productos (`purchases` + `purchase_items`), canjes, perfilamiento de frecuencia (`is_frequent`, `is_frequent_active`, `is_recovering`) y, para administradores, dirección, WhatsApp, redes sociales, datos financieros/económicos del negocio (`business_economic_profiles`) y registros de auditoría (`actor_email`).
     3. No existe enlace a Términos ni a la Política de Tratamiento de Datos.

2. **Ausencia total de páginas legales e identificación del responsable:**
   - En [App.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWebPage/src/app/App.tsx#L24-L31) (sitio comercial) y [router.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/app/router.tsx#L262-L393) (app) no existe ninguna ruta legal (`/privacidad`, `/terminos`, `/cookies`, `/eliminar-cuenta`).
   - En [SiteLayout.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWebPage/src/features/landing/SiteLayout.tsx#L140-L169) no figuran razón social/titular, NIT, domicilio, correo de contacto/PQR ni enlace a la SIC.
   - **Bloqueo técnico adicional:** Google Cloud exige URLs públicas y accesibles de *Homepage*, *Privacy Policy* y *Terms of Service* para aprobar la pantalla de consentimiento de **Google OAuth** en producción.

3. **Imposibilidad técnica actual de ejercer el derecho de supresión (eliminación de cuenta) y fuga de metadatos EXIF:**
   - En [20251021000100_schema.sql](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionApi/supabase/migrations/20251021000100_schema.sql#L98-L101), [L158](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionApi/supabase/migrations/20251021000100_schema.sql#L158), [L200](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionApi/supabase/migrations/20251021000100_schema.sql#L200) y [L333-L346](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionApi/supabase/migrations/20251021000100_schema.sql#L333-L346), las llaves foráneas con `ON DELETE RESTRICT` y el trigger inmutable `prevent_ledger_mutation()` impiden borrar un usuario si tiene compras, canjes o movimientos. No existe RPC ni botón para eliminar/anonimizar cuenta ni exportar datos personales (derechos Art. 8 Ley 1581).
   - En [ProfilePage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/profile/ProfilePage.tsx#L205-L215), quitar la foto de perfil solo limpia `profiles.avatar_url` en la base de datos, dejando el archivo **accesible públicamente** en el bucket `business-assets` ([20261025001100_business_assets_storage.sql](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionApi/supabase/migrations/20261025001100_business_assets_storage.sql#L18-L29)).
   - En [image.ts](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/lib/image.ts#L63-L70), las fotos de usuario ≤ 2 MB y ≤ 1200 px se suben **sin re-codificar en canvas**, conservando **metadatos EXIF (incluyendo ubicación GPS del dispositivo)** en un bucket público.

4. **Captura de `birth_date` sin restricción para menores de edad:**
   - Tanto [ProfilePage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/profile/ProfilePage.tsx#L85-L93) como [20261113000100_profile_phone_birthdate.sql](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionApi/supabase/migrations/20261113000100_profile_phone_birthdate.sql#L97-L104) aceptan cualquier fecha de nacimiento hasta hoy, permitiendo registrar datos de menores de 18 años sin control de edad ni autorización del representante legal (**Art. 7 Ley 1581 de 2012** y **Art. 12 Decreto 1377 de 2013**).

5. **Registro por correo sin verificación (`mailer_autoconfirm = true`) y sin recuperación de contraseña:**
   - Documentado en [SEGURIDAD.md](file:///mnt/datos/Programacion/Fidelizacion/documentacion/SEGURIDAD.md#L182-L192): cualquiera puede crear una cuenta usando el correo de un tercero sin demostrar titularidad, afectando el principio de **veracidad o calidad del dato** (Art. 4 Ley 1581) y generando riesgo de suplantación.

6. **Riesgos de información comercial en precios y promesas de roadmap ([PricingPage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWebPage/src/features/landing/pages/PricingPage.tsx#L152-L196)):**
   - Los planes `Level Up · Pro` (`$59.000` / `$49.000` COP) y `Modo Arcade · Suite` (`$129.000` / `$109.000` COP) **no indican si el precio incluye o excluye IVA (19%)**, ni muestran el valor total del cobro anual.
   - La promesa `"$0 para siempre · 1 local"` y `"se activarán sin costo adicional dentro de su capa correspondiente"` para funciones *"Próximamente"* pueden considerarse **información/publicidad vinculante** bajo los **Arts. 29–30 de la Ley 1480 de 2011** si no se matizan con condiciones en T&C y descargo de hoja de ruta.

7. **Inconsistencia de marca (`Fideliapp` vs. `Loopoint`):**
   - El sitio y la app se presentan como **Fideliapp**, pero documentación, claves internas (`loopoint:theme`, `loopoint:draft:*`) y referencias internas usan **Loopoint**. Antes de producción se debe unificar la marca oficial y verificar disponibilidad marcaria ante la **SIC** (Clases Niza 9, 35 y 42).

---

## 2. Lista completa de documentos y páginas legales que faltan crear

| # | Documento / Página | Destinatario | Ubicación sugerida | Prioridad | Contenido indispensable para Fideliapp |
|---|---|---|---|---|---|
| 1 | **Política de Tratamiento de Datos Personales (Privacidad / Habeas Data)** | Todos (Clientes, Encargados, Admins, Visitantes) | `fideliapp.pages.dev/privacidad` (+ enlace desde app y OAuth) | **P0** | Identificación del Responsable (razón social/titular, NIT, domicilio, correo, teléfono); distinción de roles (Fideliapp Responsable de cuenta vs. Encargado del negocio); inventario completo de datos tratados; finalidades por rol; derechos Art. 8 Ley 1581 (conocer, actualizar, rectificar, suprimir, revocar); procedimiento y plazos legales (**10 días hábiles consultas / 15 días hábiles reclamos**); autorización de **transmisión/transferencia internacional** (Supabase, Vercel, Cloudflare, Google); política sobre menores de edad; seguridad y plazos de conservación; vigencia y cambios. |
| 2 | **Aviso de Privacidad corto** | Usuarios en puntos de captura | Inline en `/login`, `/join/:slug`, `/claim/:token`, `/admin/onboarding` | **P0** | Resumen conforme Arts. 14–15 Decreto 1377: quién trata los datos, finalidad principal, mención de transferencia internacional, derechos del titular y enlace directo a la Política completa. |
| 3 | **Términos y Condiciones de Uso — Clientes (B2C)** | Consumidores finales | `fideliapp.pages.dev/terminos` | **P0** | Naturaleza jurídica de las **monedas/puntos** (sin valor monetario, NO son dinero electrónico, depósito, criptoactivo ni medio de pago; no canjeables por dinero; intransferibles entre usuarios ni entre negocios); **exención de responsabilidad frente a comercios** (Fideliapp provee software, cada negocio es el único responsable de sus productos, precios, entrega de premios, vigencia FIFO, cambios de programa o cierre del local); reglas de QR portador y antifraude; edad mínima; suspensión por abuso; propiedad intelectual; ley aplicable y jurisdicción (Colombia). |
| 4 | **Términos y Condiciones del Servicio SaaS — Negocios (B2B)** | Administradores / Comercios | `fideliapp.pages.dev/terminos-negocios` | **P0** | Licencia de uso SaaS; planes (`Gratis`, `Pro`, `Suite`), precios en COP con tratamiento de IVA, facturación, renovación, cancelación y cambios de plan; obligaciones del comercio bajo Ley 1480 (honrar premios, informar vencimiento FIFO y reglas a clientes, no hacer publicidad engañosa) y Ley 1581 (uso legítimo de datos de sus clientes); responsabilidad por cuentas de **encargados**; descargo sobre **panel económico** (cifras estimadas, no sustituyen contabilidad ni asesoría fiscal); disponibilidad/SLA y limitación de responsabilidad; propiedad de datos y exportación al terminar. |
| 5 | **Acuerdo de Transmisión / Encargado del Tratamiento de Datos (DPA)** | Comercios (anexo B2B) | `fideliapp.pages.dev/dpa` (aceptado en `/admin/onboarding`) | **P0** | **Obligatorio según Art. 25 Decreto 1377 de 2013** para regular la relación entre el Comercio (Responsable frente a sus clientes) y Fideliapp (Encargado): alcance del tratamiento, obligaciones de seguridad (RLS, cifrado en tránsito/reposo, auditoría), confidencialidad, autorización de **subencargados** (Supabase, Vercel, Cloudflare, Google), notificación de incidentes de seguridad, asistencia ante PQR y devolución/supresión de datos al finalizar. |
| 6 | **Política de Cookies y Almacenamiento Local** | Visitantes y usuarios | `fideliapp.pages.dev/cookies` | **P0** | Detalle real y honesto de tecnologías usadas (`localStorage`, `sessionStorage`, Service Worker/Cache Storage de la PWA, tokens de Supabase Auth, carga de Google Fonts y logs de Vercel/Cloudflare), finalidad, duración, cómo borrarlas en el navegador y aviso de que actualmente no se usan cookies publicitarias ni de rastreo de terceros (actualizable al activar analítica). |
| 7 | **Aviso Legal, Datos Corporativos, Canal PQR y Enlace a la SIC** | Todos | Footer global en `SiteLayout.tsx` + `/contacto` o `/legal` | **P0** | Razón social o nombre completo del responsable, NIT, ciudad/dirección, correo oficial de soporte y correo dedicado a Habeas Data/PQR (ej. `privacidad@tudominio.com`), horario de atención y enlace visible a la **Superintendencia de Industria y Comercio (`https://www.sic.gov.co`)** (Art. 50 literal g Ley 1480). |
| 8 | **Página pública de Eliminación de Cuenta y Datos** | Todos (requisito Habeas Data + Google Play) | `fideliapp.pages.dev/eliminar-cuenta` (+ botón en `/customer/perfil` y `/admin/perfil`) | **P0 / P1** | Explica paso a paso cómo eliminar la cuenta desde la app o por solicitud web/correo sin iniciar sesión, qué datos se borran inmediatamente (perfil, teléfono, fecha de nacimiento, avatar en Storage, membresías), qué datos transaccionales se anonimizan para integridad contable del comercio y en qué plazo máximo se completa (máx. 15 días hábiles por ley). |
| 9 | **Política de Uso Aceptable y Contenido Generado por Usuarios (UGC)** | Comercios y clientes | Integrada en T&C o `/uso-aceptable` | **P1** | Reglas sobre imágenes subidas al bucket público `business-assets` (logos, fotos de carta, recompensas, avatares): prohibición de infracción de derechos de autor/marcas, contenido ilegal, engañoso u ofensivo; licencia de visualización a favor de Fideliapp; mecanismo de reporte y retiro (*notice & takedown*). |
| 10 | **Política de Pagos, Reembolsos, Cancelaciones, Retracto y Reversión** | Comercios suscriptores | `fideliapp.pages.dev/pagos-y-reembolsos` | **P1 (al activar cobros)** | Condiciones de cobro recurrente (PSE, Nequi, tarjetas), emisión de factura electrónica DIAN, cancelación sin permanencia, política de reembolsos, **Derecho de Retracto** (Art. 47 Ley 1480, 5 días hábiles cuando aplique) y procedimiento de **Reversión del Pago** (Decreto 587 de 2016 por fraude, operación no solicitada o servicio no prestado). |

---

## 3. Inventario técnico real de Cookies, Almacenamiento Local y Terceros

Este inventario refleja exactamente lo que hoy ejecuta el código, para evitar publicar una política de cookies genérica o falsa:

### 3.1. Qué guarda hoy el navegador

| Aplicación | Tecnología | Clave / Recurso | Fuente en código | Finalidad y clasificación | Duración |
|---|---|---|---|---|---|
| `fidelizacionWeb` | `localStorage` | `sb-<ref>-auth-token` (Supabase JS) | [supabase.ts](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/lib/supabase.ts#L37-L45) | Mantener sesión autenticada (JWT + PKCE). **Estrictamente necesaria.** | Hasta cerrar sesión / expiración refresh token |
| `fidelizacionWeb` | `localStorage` | `loopoint:theme` | [theme-init.js](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/public/theme-init.js#L1-L12) | Recordar tema claro/oscuro. **Funcional.** | Persistente |
| `fidelizacionWeb` | `localStorage` | `fidelizacion:selected-business:<userId>` | [businessContext.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/loyalty/businessContext.tsx#L4-L36) | Recordar negocio activo seleccionado. **Funcional.** | Persistente |
| `fidelizacionWeb` | `localStorage` | `fidelizacion:pending-claim` | [pendingClaim.ts](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/lib/pendingClaim.ts#L1-L23) | Conservar token QR de compra durante el login/OAuth. **Estrictamente necesaria.** | 2 horas |
| `fidelizacionWeb` | `localStorage` | `loopoint:draft:*` (incl. `profile:<uid>`, onboarding) | [useFormDraft.ts](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/lib/useFormDraft.ts#L22-L42) | Evitar pérdida de formularios al cambiar de pestaña. **Funcional** *(nota: guarda borradores de teléfono/cumpleaños; limpiar en `signOut`)*. | 7 días |
| `fidelizacionWeb` | `sessionStorage` | `pendingAccountType` y tokens de canje | [AuthProvider.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/auth/AuthProvider.tsx#L77-L93), [redemptionTokens.ts](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/loyalty/redemptionTokens.ts#L1-L32) | Flujo temporal de registro OAuth y QR de canje pendiente. **Estrictamente necesaria.** | Sesión de pestaña |
| `fidelizacionWeb` | Service Worker / Cache API | Workbox precache + `google-fonts-*` | [vite.config.ts](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/vite.config.ts#L65-L94) | Funcionamiento offline/PWA y caché de fuentes. **Técnica.** | Hasta actualización / 1 año fuentes |
| `fidelizacionWebPage` | `localStorage` | `loopoint:theme` | `ThemeProvider.tsx` / `theme-init.js` | Recordar tema claro/oscuro. **Funcional.** | Persistente |
| `fidelizacionWebPage` | `sessionStorage` | Marca de recarga ante error de chunk | `fidelizacionWebPage/src/main.tsx` | Evitar bucles de recarga tras despliegues. **Estrictamente necesaria.** | Sesión de pestaña |

### 3.2. Terceros que reciben datos técnicos (IP / User-Agent / cuenta) hoy

1. **Supabase Inc.** — Base de datos, autenticación y almacenamiento de imágenes (`gxfytcquyobhhbjipbea.supabase.co`).
2. **Vercel Inc.** — Alojamiento y logs de red de la app/PWA (`fideli-app.vercel.app`).
3. **Cloudflare Inc.** — Alojamiento CDN y logs de red del sitio comercial (`fideliapp.pages.dev`).
4. **Google LLC** — Autenticación **Google OAuth** (nombre, correo, foto de perfil de Google) y carga externa de **Google Fonts** ([fidelizacionWeb/index.html](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/index.html#L20-L25), [fidelizacionWebPage/index.html](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWebPage/index.html#L30-L35)). *Recomendación opcional:* autoalojar las fuentes (`@fontsource`) elimina la transmisión de IPs a Google en cada visita anónima.

### 3.3. ¿Necesitas banner de cookies hoy?

- **Hoy (sin GA4, Meta Pixel ni analítica de terceros):** la app y la web **solo usan almacenamiento estrictamente necesario y funcional**. En este estado basta con un **aviso informativo discreto** (o enlace visible a la *Política de Cookies y Almacenamiento Local*) sin bloquear la navegación ni simular botones falsos de "Rechazar".
- **En el momento en que agregues analítica o píxeles (GA4, PostHog, Meta Pixel, TikTok Pixel, Clarity):** se vuelve **obligatorio** implementar un **banner de consentimiento real (CMP)** con opciones equivalentes (*Aceptar*, *Rechazar*, *Configurar*) que **bloquee la carga de scripts** hasta obtener consentimiento explícito y permita revocarlo desde el footer.

---

## 4. Cambios técnicos y de interfaz necesarios por capa

### 4.1. Base de datos y API (`fidelizacionApi`)
- [ ] **Nueva migración — Registro auditable de consentimientos (prueba legal Decreto 1377 Art. 8):**
  - Tabla `public.user_legal_consents` (`id`, `user_id`, `business_id` nullable, `document_type` [`terms_customer` | `terms_business` | `privacy_policy` | `dpa` | `marketing_whatsapp` | `marketing_email` | `marketing_push`], `document_version`, `accepted_at`, `revoked_at`, `source_route`).
  - RPCs `SECURITY DEFINER`: `legal_consent_record(...)`, `legal_consents_my_list()`, `legal_consent_revoke(...)`.
- [ ] **Corregir fuga multiempresa en `business_search_profiles`:** reemplazar búsqueda libre global por búsqueda solo dentro del negocio o coincidencia exacta por correo (o retirar en favor del flujo QR `business_member_invites`).
- [ ] **RPC de eliminación / anonimización de cuenta (`account_delete_my_account`):**
  - Resolver las restricciones `ON DELETE RESTRICT` e inmutabilidad de `points_ledger` sin dañar la auditoría financiera de los comercios: anonimizar `full_name`, `email` (`deleted+<uuid>@anonymized.local`), `nickname`, `phone`, `birth_date`, `avatar_url`; bloquear si es `last_admin` de un negocio activo (pedir transferir o cerrar negocio antes); desvincular/eliminar membresías de cliente; borrar objetos en Storage `avatars/<user_id>/`; registrar evento de supresión y eliminar el registro de `auth.users` (vía Edge Function o proceso con `service_role`).
- [ ] **RPC de portabilidad / consulta de datos (`profile_export_my_data`):** devuelve en JSON los datos del perfil, consentimientos, negocios afiliados, compras y canjes del usuario autenticado.
- [ ] **Validación de edad mínima en `profile_update`:** validar fecha mínima/edad (p. ej. ≥ 18 años) o bloquear registro de menores sin autorización verificable.
- [ ] **Eliminar archivos huérfanos en Storage:** al quitar o cambiar avatar (`profile_avatar_set`) o logo, eliminar el objeto anterior del bucket público `business-assets`.

### 4.2. Aplicación Web / PWA (`fidelizacionWeb`)
- [ ] **Registro y Google OAuth ([LoginPage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/auth/LoginPage.tsx#L1053-L1292)):**
  - Reemplazar el texto pasivo *"Al entrar aceptas..."* por **casilla(s) sin premarcar** con enlaces clicables a *Términos y Condiciones* y *Política de Tratamiento de Datos* (incluyendo autorización explícita de transferencia internacional de datos).
  - Para **usuarios nuevos vía Google OAuth**: mostrar una pantalla/modal de aceptación expresa de Términos y Política de Privacidad antes de finalizar el alta (si `user_legal_consents` aún no registra la versión vigente).
- [ ] **Afiliación a un negocio ([BusinessJoinPage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/loyalty/BusinessJoinPage.tsx#L262-L265)) y Reclamo de QR ([ClaimPage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/purchases/ClaimPage.tsx#L343-L345)):**
  - Indicar claramente qué datos verá ese comercio específico (nombre, alias, correo, teléfono/cumpleaños si los registró, foto y compras en ese negocio), mostrar la **vigencia/vencimiento de monedas** del negocio si aplica y enlazar a la Política de Privacidad y T&C.
- [ ] **Alta de negocio ([OnboardingWizardPage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/loyalty/OnboardingWizardPage.tsx#L610-L679)):**
  - Exigir aceptación expresa (checkbox registrado en `user_legal_consents`) de **Términos para Negocios (B2B)** + **Acuerdo de Transmisión de Datos (DPA)** + declaración de veracidad y facultad para representar al comercio antes de crear el negocio/activar el programa.
- [ ] **Sección "Privacidad y cuenta" en [ProfilePage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/features/profile/ProfilePage.tsx):**
  - Ver versión y fecha de políticas aceptadas.
  - Botón **Descargar mis datos** (JSON).
  - Botón **Eliminar mi cuenta** con confirmación explícita (y aviso de pérdida de monedas acumuladas).
  - Enlaces permanentes a Privacidad, Términos, Cookies y canal PQR (también accesibles desde el footer/menú de `LoginPage`, `CustomerShell`, `AdminShell` y `EncargadoShell`).
- [ ] **Sanitización EXIF en [image.ts](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWeb/src/lib/image.ts#L63-L70):** pasar siempre los avatares (e idealmente toda imagen subida) por `canvas` para eliminar metadatos EXIF/GPS antes de subirlos a `business-assets`.
- [ ] **Limpieza de borradores locales al cerrar sesión (`signOut`):** purgar claves `loopoint:draft:*` y `fidelizacion:selected-business:*` para no dejar `phone`/`birthDate` en navegadores compartidos (frecuente en tablets de caja).
- [ ] **Autenticación de producción:** activar verificación de correo en Supabase (`mailer_autoconfirm = false` + SMTP propio con SPF/DKIM/DMARC) y añadir flujo **"¿Olvidaste tu contraseña?"** en `/login`.
- [ ] **Visibilidad de vencimiento de puntos:** en la vista del cliente (`CustomerBusinessHomePage`), mostrar de forma clara la regla de vencimiento FIFO del negocio y próximos vencimientos para transparencia bajo Ley 1480.

### 4.3. Sitio Comercial (`fidelizacionWebPage`)
- [ ] **Crear rutas y páginas legales** en [App.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWebPage/src/app/App.tsx): `/privacidad`, `/terminos`, `/terminos-negocios`, `/dpa`, `/cookies`, `/eliminar-cuenta` y `/contacto` (o sección PQR).
- [ ] **Actualizar footer** en [SiteLayout.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWebPage/src/features/landing/SiteLayout.tsx#L140-L169):
  - Columna **"Legal"** con enlaces a todas las políticas anteriores.
  - Identificación del operador (nombre/razón social, NIT, ciudad/Colombia, correo de contacto y PQR).
  - Enlace visible a la **SIC (`https://www.sic.gov.co`)**.
- [ ] **Ajustar textos comerciales en [PricingPage.tsx](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWebPage/src/features/landing/pages/PricingPage.tsx#L152-L196) y [webContent.ts](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWebPage/src/features/landing/webContent.ts):**
  - Especificar claramente *"Precios en pesos colombianos (COP) + IVA (19%)"* o *"IVA incluido"* (según régimen tributario del titular).
  - Al activar *Pago anual*, mostrar el valor total anual facturado (ej. `$588.000 COP / año`).
  - Matizar `"para siempre"` → `"Plan gratuito sin costo fijo para 1 local (sujeto a Términos de Uso)"`.
  - Añadir nota legal explícita indicando que los módulos marcados como **«Próximamente»** forman parte de la hoja de ruta informativa, no están activos aún y no constituyen compromiso de fecha de entrega; y evitar redirigir CTAs de planes pagos sin indicar que actualmente se ingresa en acceso inicial / plan gratuito.
- [ ] **Actualizar SEO y metadatos:** incluir las nuevas URLs legales en [sitemap.xml](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWebPage/public/sitemap.xml), [llms.txt](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWebPage/public/llms.txt) y completar `contactPoint` / `email` en el bloque JSON-LD `Organization` de [index.html](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWebPage/index.html#L43-L49).

---

## 5. Obligaciones legales y administrativas fuera del código (Operación + Roadmap)

### 5.1. Antes de lanzar producción pública (P0)
- **Formalización del titular:** definir si opera como **Persona Natural comerciante** (RUT + Cámara de Comercio) o **S.A.S.** (NIT, representante legal, actividad CIIU 6201/6311) para firmar contratos, facturar y figurar como Responsable del Tratamiento.
- **Correo corporativo / legal:** habilitar al menos `soporte@<dominio>` y `privacidad@<dominio>` (o `datos@<dominio>`) en dominio propio, con procedimiento interno para responder consultas de Habeas Data en **≤ 10 días hábiles** y reclamos en **≤ 15 días hábiles**.
- **Registro Nacional de Bases de Datos (RNBD — SIC):** según el **Decreto 090 de 2018**, la inscripción formal en el RNBD solo es obligatoria para sociedades/ESAL con **activos totales superiores a 100.000 UVT** (y entidades públicas). Si Fideliapp está por debajo de ese umbral, **no está obligada a inscribirse en el RNBD**, pero **SÍ está obligada desde el día 1** a cumplir toda la Ley 1581 (Política, Aviso, autorizaciones con prueba, atención de PQR y reporte de incidentes de seguridad relevantes).
- **Verificación de Google OAuth:** registrar las URLs definitivas de *Homepage*, *Privacy Policy* y *Terms of Service* en Google Cloud Console y verificar el dominio final (dejar atrás `fideli-app.vercel.app` / `fideliapp.pages.dev` si habrá dominio propio).
- **Acuerdos DPA con proveedores:** revisar y aceptar los Data Processing Addenda vigentes de **Supabase**, **Vercel** y **Cloudflare**.
- **Búsqueda y registro de marca (SIC):** verificar disponibilidad del nombre definitivo (`Fideliapp` vs. `Loopoint`) antes de invertir en marketing y dominios.

### 5.2. Al activar funciones del roadmap ya anunciadas en el sitio (P1 / P2)

> [!WARNING]
> Varias funciones ya están publicadas en [webContent.ts](file:///mnt/datos/Programacion/Fidelizacion/fidelizacionWebPage/src/features/landing/webContent.ts#L231-L425). Cada una activa normativa específica en Colombia:

1. **Suscripciones y pasarela de pago (`TAREA-1`: PSE, Nequi, tarjetas):**
   - Habilitación de **Facturación Electrónica ante la DIAN** (según régimen del responsable).
   - Uso de pasarela certificada **PCI-DSS** (Wompi, Mercado Pago, ePayco, PayU) sin almacenar tarjetas en Fideliapp.
   - Publicación de **Derecho de Retracto** (Art. 47 Ley 1480) y **Reversión del Pago** (Decreto 587 de 2016) + comprobantes automáticos.
2. **Difusiones por WhatsApp, Correo, Web Push y Cumpleaños (`TAREA-3`):**
   - Consentimiento **separado y granular por canal** (nunca mezclado con T&C de cuenta) y opción de baja (*opt-out*) en un clic.
   - Cumplimiento estricto de la **Ley 2300 de 2023 ("Ley Dejen de Fregar")**: envíos comerciales solo por canales autorizados, en horario permitido (**lunes a viernes 7:00 a.m. – 7:00 p.m., sábados 8:00 a.m. – 3:00 p.m.; prohibido domingos y festivos**) y respetando topes de frecuencia.
   - Cumplimiento de políticas de **Meta / WhatsApp Business Platform** (opt-in explícito con nombre del comercio y tipo de mensaje).
3. **Plataforma de juegos para clientes (`Modo Arcade · Suite`):**
   - **Alerta Coljuegos (Ley 643 de 2001 / Decreto 2104 de 2016):** evitar mecánicas de azar/rifa/sorteo con premios sin autorización de juegos promocionales de Coljuegos; diseñar los minijuegos como **mecánicas de destreza/habilidad o logros** ligados a puntos del programa sin costo de participación ni componente aleatorio regulado (o tramitar permisos si hay sorteos).
4. **Comandera y "Facturación" (`Modo Arcade · Suite`):**
   - **Alerta DIAN (Resolución 000165 de 2023):** en Colombia no se puede emitir un documento llamado *"Factura"* o *"Factura POS"* si no cumple con **Facturación Electrónica / Documento Equivalente Electrónico POS** validado ante la DIAN. Si inicialmente es control interno de comandas/caja, debe etiquetarse estrictamente como ***"Comanda / Resumen de pedido (no válido como factura)"***.
5. **Chatbot con IA (`TAREA-4`):**
   - Aviso visible al usuario de que interactúa con una **inteligencia artificial** y que sus respuestas (especialmente sobre margen/presupuesto) son orientativas y no vinculantes.
   - Declarar el proveedor del modelo LLM como subencargado en la Política de Privacidad y minimizar el envío de PII en los prompts.
6. **App Android futura (`fidelizacionApp` — Google Play Store):**
   - Completar el formulario **Seguridad de los Datos (*Data Safety*)** de Google Play con correspondencia exacta al código.
   - Mantener activa la URL pública de **Política de Privacidad** y la URL pública + botón interno de **Eliminación de cuenta** (obligatorio en Google Play).
   - Declarar y justificar el permiso `CAMERA` únicamente para lectura local de códigos QR (sin almacenamiento de imágenes).

---

## 6. Orden recomendado de ejecución

1. **Fase 0 — Decisiones del titular (1 día):** definir persona natural/SAS, NIT, correo legal/PQR, marca oficial, dominio definitivo, tratamiento de IVA y edad mínima.
2. **Fase 1 — Bloqueantes de seguridad/privacidad en DB y código (P0):**
   - Corregir `business_search_profiles` (fuga multiempresa).
   - Crear tabla/RPC `user_legal_consents`.
   - Limpiar EXIF en `image.ts`, borrar avatares antiguos en Storage y purgar borradores en `signOut`.
   - Añadir validación de edad mínima en `birth_date`.
   - Evaluar activación de verificación de correo + recuperación de contraseña.
3. **Fase 2 — Páginas legales y UI de consentimiento (P0):**
   - Crear las páginas legales en `fidelizacionWebPage` (`/privacidad`, `/terminos`, `/terminos-negocios`, `/dpa`, `/cookies`, `/eliminar-cuenta`) y actualizar footer + `PricingPage.tsx` + `sitemap.xml` + `llms.txt`.
   - Integrar checkboxes de aceptación + enlaces en `LoginPage`, flujo Google OAuth, `BusinessJoinPage`, `ClaimPage` y `OnboardingWizardPage`.
   - Añadir sección **Privacidad y cuenta** (exportar + eliminar cuenta) en `ProfilePage` + RPC `account_delete_my_account`.
4. **Fase 3 — Validación legal y alta en producción:** revisión por abogado en Colombia, configuración de URLs legales en Google OAuth y retiro de *Deployment Protection* de Vercel.
5. **Fase 4 — Cumplimiento incremental del roadmap (P1/P2):** CMP real si se agrega analítica, Ley 2300 + opt-in multicanal antes de `TAREA-3`, DIAN/Retracto antes de `TAREA-1`, y *Data Safety* antes de Play Store.
