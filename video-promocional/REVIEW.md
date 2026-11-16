# REVIEW — Loopoint ("El viaje de una moneda")

## Decisiones creativas y rutas descartadas
- **Historia elegida:** *El viaje de una moneda* (`31 s`, `1920x1080`, `30 fps`). La moneda pixel art oficial (`assets/loopoint-coin.png`) nace del QR generado en caja, viaja al teléfono en la pantalla real de reclamo, suma visitas en la `PLAYER CARD` hasta alcanzar `2.000 PTS` y se transforma en una taza de café pixel (`Café gratis`) con el sello `✓ ENTREGADO`.
- **Historias descartadas:** *La tarjeta de sellos perdida* (enfoque en el problema de tarjetas de cartón) y *Un día en el negocio* (enfoque B2B en el panel administrador).
- **Medio y fidelidad visual:** Se tomó exactamente el sistema visual neo-retro del portal cliente real (`fidelizacionWeb/src/features/customer/customerRetro.css`, `LandingPage.tsx`, `ClaimPage.tsx`, `PlayerCard.tsx`, `ScanRedemptionPage.tsx`): papel `#f6edda` con textura punteada/rejilla, tinta `#1e1c1a`, crema `#fffdf5`, azul `#467299`, rojo `#e6533f`, oro `#ffd166`, verde `#4e8c57`, sombras duras sin blur y tipografías reales (`Space Grotesk`, `Press Start 2P`, `DM Mono`) servidas localmente desde `assets/fonts/`.
- **Audio:** Sin sesión en HeyGen ni generador musical local instalado, la pieza lleva efectos de sonido (SFX) incluidos con la skill (`Pixabay`: `pop`, `click`, `ping`, `chime`, `notification`, `riser`, `impact-bass-1`, `sparkle`, `whoosh`) sincronizados al frame con los eventos en pantalla, y queda lista para añadir una pista de música de fondo (`<audio>`) desde Studio o tras iniciar sesión con `npx hyperframes auth login`.

## Qué se midió y qué se revisó visualmente
- **Medido con `npx hyperframes check --json` (tras el último cambio):** `ok: True`, `0` errores en `lint`, `runtime`, `layout`, `contrast`, `craft` y `audio`; `0` warnings en `runtime`, `layout`, `contrast`, `craft` y `audio`.
- **Inspección visual con `npx hyperframes snapshot --review` y `snapshot --at 0,5.9,17.5,19.8,23.2,24.9,29.8`:**
  - Se corrigió un solapamiento inicial de `#c-title` con `#c-window` en `caja.html`.
  - Se ocultó `#r-state-pending` en `reclamo.html` al aparecer `#r-state-done` y se reubicó `#r-coin` en el espacio libre sobre el CTA para no tapar `1.250`.
  - Se ajustó el zoom final de `caja.html` (`scaleX/Y: 420`) para cubrir el encuadre completo en amarillo oro al cortar a `reclamo.html`.
  - Se ajustó la entrada de las 3 monedas en `canje.html` para mantenerlas dentro del marco desde `t=19.5s`, se mejoró el contraste de `premios` con placa oro/tinta y se aplicó la textura punteada de papel al barrido pixel hacia `final.html`.
  - Se adelantó el cierre en `final.html` para garantizar > 2.5 s de lectura en la end card final.
- **No comprobado por oído:** El audio se midió con `npx hyperframes audio` (envelopes, picos y sonoridad), no se escuchó directamente en altavoces.

## Warnings conservados intencionalmente
- `lint: duplicate_media_discovery_risk` en `reclamo.html` (2 instancias), `saldo.html` (7 instancias) y `canje.html` (3 instancias): se reutiliza intencionalmente el mismo archivo `assets/loopoint-coin.png` para las distintas monedas que viajan y se acumulan como un mismo personaje.

## Toma más débil y mejora futura
- La transición `reclamo.html -> saldo.html` (`t=11.9s–12.0s`) hace un corte limpio tras la salida rápida de la moneda por la derecha sobre fondo oro hacia el papel de `saldo.html`. Con más tiempo (y una pista musical de fondo), se podría añadir una línea de velocidad o hacer que la moneda que entra en `saldo.html` conserve exactamente la altura vertical (`y`) de salida de `reclamo.html`.
