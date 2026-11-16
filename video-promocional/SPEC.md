# SPEC — Loopoint · "El viaje de una moneda"

GOAL:    el espectador entiende que cada compra en un negocio se convierte en loopoints que viajan a su teléfono y terminan en un premio real, y quiere registrarse.
OUTPUT:  HyperFrames, 1920 x 1080, 30 fps
TIME:    31 s x 30 fps = 930 frames. Sin música (sin sesión HeyGen); SFX incluidos con la skill (Pixabay).

LOOK:    el medio es el portal cliente real de Loopoint (neo-retro pixel):
         - papel #f6edda con puntos 0.75 px cada 6 px (ink 13%) y rejilla 24 px (ink 3.5%);
         - tinta #1e1c1a: todo texto legible, bordes 4–6 px, sombras duras 10–16 px sin blur;
         - crema #fffdf5 en ventanas; barra de ventana azul #467299;
         - acento rojo #e6533f: una palabra por plano, el saldo, el CTA; oro #ffd166 en pills; verde #4e8c57 en progreso;
         - tipos: Space Grotesk 700 (títulos 104–140 px, tracking -2%), Press Start 2P (cifras/etiquetas pixel), DM Mono 500 (texto UI).
         - sin blur de profundidad, sin degradados, sin glow; la profundidad es la sombra dura desplazada.
OBJECTS: la moneda Loopoint (assets/loopoint-coin.png, pixelated); caja "QR de la venta" con QR real;
         teléfono (bisel tinta 22 px, radio 64 px) con la pantalla de reclamo real ("Confirmar y sumar loopoints",
         "¡Loopoints acreditados!", "Nuevo saldo"); PLAYER CARD real (saldo, barra retro, "PREMIO LISTO");
         taza de café pixel (SVG del landing) y ventana "Entrega confirmada" / "Entregado".
MOTION:  llegadas expo.out 0.5–0.7 s; cámara/inundaciones power2.inOut 0.5 s; salidas power3.in 0.3 s;
         la moneda es un personaje: anticipación (squash 0.8) → salto → aterrizaje con squash y back.out(2);
         contadores y barras en steps(6) como el CSS real; títulos por palabra blur 6→0 en 0.13 s, 0.067 s de separación.
SHOTS:
  1 caja    0.0–6.0   caja de Café Aurora genera el QR (impresión por filas), escáner rojo lo barre, la moneda nace del QR y salta hacia cámara → zoom a través de la moneda.   "Cada compra cuenta"
  2 reclamo 6.0–12.0  fondo oro; teléfono grande; moneda cae en la celda "+150"; dedo toca "Confirmar y sumar loopoints"; el botón crece y se vuelve la cabecera "¡Loopoints acreditados!"; la moneda salta fuera por la derecha.   "Escanea el QR / Confirma y suma"
  3 saldo   12.0–19.5 PLAYER CARD entra desde la derecha; tres monedas (3 visitas) aterrizan, saldo 1.100→1.250→1.600→2.000, barra 55→100 %, "PREMIO LISTO"; toque en "Canjear ahora" → el botón inunda la pantalla de rojo.   "Cada visita suma"
  4 canje   19.5–25.0 fondo rojo; las monedas convergen y se convierten en la taza "Café gratis"; ventana "Entrega confirmada" entra; sello "ENTREGADO" golpea. Payoff (una vez, impacto). Barrido pixel a papel.   "Tus loopoints se vuelven premios"
  5 final   25.0–31.0 "Compra. Acumula. Gana más." por palabra; la moneda cae girando, el wordmark "loopoint." se revela, CTA "Quiero registrarme →" + URL; se sostiene 2 s.
BANNED:  vacío oscuro; glow/partículas decorativas; degradados morados/azules; cristal; todo centrado; todo entrando con fade+slide-up;
         títulos que siguen moviéndose; tres tarjetas en fila; logo pegado en una esquina; UI inventada (solo textos reales del portal);
         emojis como iconos.
QA:      t=0 (miniatura no vacía), 3.3 (moneda nace), 8.4 (acreditado), 17.2 (premio listo), 21.0 (taza), 22.9 (sello), 29.8 (end card).
