# Fidelización — workspace

**Loopoint**, sistema de fidelización por loopoints **multiempresa**: cada negocio
configura su programa, su carta y sus recompensas. Cada venta en caja genera un QR con
su valor; el cliente lo escanea, confirma la compra y recibe los loopoints en su
cuenta (se afilia en ese momento si aún no estaba registrado). Para canjear, el
cliente muestra un QR y el negocio lo escanea en `/scan/<token>` para confirmar la
entrega en el acto.

```text
Fidelizacion/
├── fidelizacionWeb/     Web (React + Vite + Tailwind), desplegada en Vercel
├── fidelizacionApi/     API (Supabase: SQL, RPC, RLS, pruebas)
├── fidelizacionApp/     Espacio reservado para la app Android
└── documentacion/       Arquitectura, pruebas, operación y datos privados
```

El repositorio anterior (`~/Mi_Negocio`, `fidelizacion01`) queda aparte como
referencia histórica.

## Estado

Módulo multiempresa completo (fases 0–7) y rediseño Loopoint **cerrado hasta F9**:
programa, carta con combos, recompensas, campañas, canje escaneado, roles por
negocio, afiliación, compras con detalle, económico, auditoría legible, cliente
frecuente, vencimiento FIFO, snapshots, onboarding, pruebas y despliegue final.

| Verificación | Resultado |
| --- | --- |
| TypeScript | limpio |
| Unitarias | 149/149 |
| E2E Playwright | 34/34 |
| SQL + concurrencia | 600 aserciones + 4 pruebas |
| Migraciones | 31/31 en local y remoto |
| Web | producción en `https://fidelizacion01.vercel.app` |

Detalle en [`PLAN_IMPLEMENTACION.md`](PLAN_IMPLEMENTACION.md),
[`documentacion/PLAN_CAMBIOS_PLATAFORMA.md`](documentacion/PLAN_CAMBIOS_PLATAFORMA.md)
y [`ENTREGA_FINAL.md`](ENTREGA_FINAL.md).

## Repositorios

- Web: https://github.com/leoCortes123/fidelizacionWeb
- API: https://github.com/leoCortes123/fidelizacionApi
- App: https://github.com/leoCortes123/fidelizacionApp

## Empezar

Abre `fidelizacion.code-workspace` en VS Code para ver los tres repositorios y la
documentación en un solo workspace.

```bash
# API
cd fidelizacionApi
npm ci
npm test               # PostgreSQL 16 efímero en Docker

# Web
cd fidelizacionWeb
npm ci
npm run test:all       # tipos + unitarias + E2E (puerto 5199)
npm run dev            # http://127.0.0.1:5173
```

Guía completa en [`documentacion/DESARROLLO.md`](documentacion/DESARROLLO.md) y
[`documentacion/PRUEBAS.md`](documentacion/PRUEBAS.md).

## Seguridad

Ningún `.env`, token, contraseña, keystore o correo personal se versiona. Los valores
operativos reales viven en `documentacion/privado/` (ignorado por Git) y en los
`.env` locales. La autorización real está en PostgreSQL (RLS + RPC); el navegador solo
usa la clave pública.
