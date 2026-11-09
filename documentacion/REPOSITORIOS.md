# Repositorios y separación de responsabilidades

## Decisión

El proyecto se dividió en tres repositorios independientes y un directorio de
documentación compartido:

| Componente | Directorio local | Repositorio | Contenido |
| --- | --- | --- | --- |
| Web | `fidelizacionWeb/` | `leoCortes123/fidelizacionWeb` | React, Vite, Tailwind, portal y panel |
| API | `fidelizacionApi/` | `leoCortes123/fidelizacionApi` | Supabase: migraciones, RPC, RLS, seed |
| App | `fidelizacionApp/` | `leoCortes123/fidelizacionApp` | Espacio para Android/Kotlin/Compose |
| Documentación | `documentacion/` | — (local) | Arquitectura, negocio, operación |

El repositorio anterior (`fidelizacion01`, en `~/Mi_Negocio`) queda **congelado como
referencia**. No se usa para el desarrollo nuevo ni se mezcla con los repositorios
nuevos.

## Qué NO va en cada repositorio

| Archivo / dato | Dónde vive |
| --- | --- |
| `.env`, `.env.local` con valores reales | Solo en el equipo; `gitignore` |
| Tokens de Supabase CLI (`sbp_…`) | Fuera del repo; preferir `supabase login` |
| Contraseña de base de datos | Gestor de secretos / panel de Supabase |
| `service_role` / `sb_secret_…` | Solo backend/administración; nunca web ni app |
| `supabase/.temp` y estado de vinculación | Local; `gitignore` |
| `.vercel/` (IDs de proyecto/organización) | Local; `gitignore` |
| Keystores Android, `google-services.json` | Local/CI seguro; `gitignore` |
| Correo del administrador inicial | Solo base de datos; no se versiona |
| Documentación y propuesta de negocio | `documentacion/`, fuera de los repos |

## Contrato entre repositorios

La web y la app **no** importan código del API: se comunican por HTTP con Supabase.

```text
fidelizacionWeb ─┐
                 ├── HTTPS + JWT (clave pública anon/publishable)
fidelizacionApp ─┘              │
                                ▼
                    Supabase (fidelizacionApi)
                    Auth · PostgREST · RPC · RLS
```

Reglas:

1. Toda escritura sensible pasa por una RPC `SECURITY DEFINER`; no hay escrituras
   directas a tablas críticas desde el cliente.
2. El cliente solo usa la clave pública. La autorización real está en PostgreSQL.
3. Los cambios de esquema se hacen en `fidelizacionApi` con migraciones aditivas.
4. Si cambia el contrato de una RPC, se actualizan web, app y documentación en el
   mismo ciclo de trabajo.
5. La app Android y la web comparten el mismo proyecto Supabase; no se crea una API
   HTTP propia en esta etapa.
6. Si más adelante se añade un API HTTP propio (por ejemplo, para integraciones o
   pagos), el punto de cambio en la web son `src/lib/supabase.ts` y los hooks de
   `src/features/*/hooks.ts`. La app deberá usar el mismo contrato.

## Flujo de trabajo sugerido

- Una rama por cambio en cada repositorio (`feat/...`, `fix/...`, `docs/...`).
- Commits pequeños y con mensaje en español o inglés consistente.
- Antes de abrir un PR: `npm run typecheck`, pruebas y build en la web; `npm test`
  en el API.
- Los cambios de base de datos se prueban primero con PostgreSQL efímero
  (`fidelizacionApi/scripts/test-db.sh`) y luego en staging.
- No se hace `supabase db reset` contra producción.
- La documentación se actualiza en `documentacion/` cuando cambie una decisión,
  un flujo o un contrato.

## Estado de los repositorios

Los tres repositorios de GitHub se crearon vacíos y se inicializan con la rama
`main`. La web y el API incluyen CI:

- **Web:** tipos, unitarias, build, smoke del bundle y E2E.
- **API:** PostgreSQL efímero, migraciones, RLS, RPC y concurrencia.
- **App:** sin CI todavía; se añadirá al crear el proyecto Android.
