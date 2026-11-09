# Documentación — Fidelización

Documentación funcional, técnica y operativa del sistema de fidelización. Está en
un directorio propio, **al mismo nivel que los repositorios**, para poder trabajar
en la web, el API y la app sin mezclar documentación con código.

**Estado (27/10/2026):** fases 0–7 completas y rediseño Loopoint cerrado hasta F9; 31
migraciones en paridad, 600 aserciones SQL, 149 unitarias, 34 E2E y web desplegada en
Vercel. Detalle en [`ESTADO_PROYECTO.md`](ESTADO_PROYECTO.md).

## Workspace

```text
Fidelizacion/
├── fidelizacionWeb/     Repositorio del sitio web (React + Vite)
├── fidelizacionApi/     Repositorio del backend (Supabase: SQL, RPC, RLS)
├── fidelizacionApp/     Repositorio reservado para la app Android
└── documentacion/       Este directorio (no se publica en GitHub)
```

Repositorios:

| Proyecto | GitHub | Rama |
| --- | --- | --- |
| Web | `https://github.com/leoCortes123/fidelizacionWeb` | `main` |
| API | `https://github.com/leoCortes123/fidelizacionApi` | `main` |
| App | `https://github.com/leoCortes123/fidelizacionApp` | `main` |

El repositorio anterior (`fidelizacion01` / `Mi_Negocio`) se deja aparte como
referencia histórica. El desarrollo nuevo se hace en este workspace.

## Por dónde empezar

1. [`ESTADO_PROYECTO.md`](ESTADO_PROYECTO.md): estado actual, pendientes y handoff.
2. [`REPOSITORIOS.md`](REPOSITORIOS.md): qué va en cada repositorio y cómo se
   relacionan.
3. [`DESARROLLO.md`](DESARROLLO.md): comandos para levantar web y API en local.
4. [`ARQUITECTURA.md`](ARQUITECTURA.md): visión general y flujos.
5. [`BASE_DE_DATOS.md`](BASE_DE_DATOS.md): tablas, RPC y RLS.
6. [`SEGURIDAD.md`](SEGURIDAD.md): amenazas, secretos y política de repositorios.
7. [`CONFIGURACION.md`](CONFIGURACION.md): Supabase, Auth, Google y variables.
8. [`PRUEBAS.md`](PRUEBAS.md): suites de la web y del API.
9. [`DESPLIEGUE.md`](DESPLIEGUE.md): Supabase + Vercel + dominio.
10. [`APP_ANDROID.md`](APP_ANDROID.md): plan y convenciones de la app.
11. [`INFORME_FINAL.md`](INFORME_FINAL.md): resumen de lo entregado.
12. [`PLAN_CAMBIOS_PLATAFORMA.md`](PLAN_CAMBIOS_PLATAFORMA.md): plan del rediseño
    Loopoint (fases, migraciones, rutas y pruebas).
13. [`negocio/`](negocio/): propuesta de negocio (Markdown y PDF).

## Regla de secretos

- Ningún valor real de `.env`, token, contraseña, keystore o correo personal se
  versiona en los repositorios.
- Los valores operativos reales viven en `privado/`, que está ignorado por Git, y en
  los archivos `.env` locales de cada proyecto.
- Los repositorios solo incluyen `.env.example` con marcadores.
- Antes de publicar documentación, revisa [`SEGURIDAD.md`](SEGURIDAD.md).

> `documentacion/` no es un repositorio Git en esta etapa. Si más adelante se publica,
> el directorio `privado/` ya está excluido por `.gitignore`.
