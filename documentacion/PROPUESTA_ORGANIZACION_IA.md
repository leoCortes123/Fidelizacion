# Propuesta: organización del repositorio y potenciación del desarrollo con IA

> Generada el 09/11/2026 tras analizar la estructura (sin código), herramientas instaladas y documentación del proyecto Fidelización/Loopoint.

## 1. Diagnóstico actual

### Estructura
- El directorio raíz `/home/leonardo/Fidelizacion` **no es un repositorio Git**. Cada componente (`fidelizacionWeb`, `fidelizacionApi`, `fidelizacionApp`) es un repositorio independiente con su propio `.git` y remote.
- La documentación (`documentacion/`) y los planes (`PLAN_IMPLEMENTACION.md`, `ENTREGA_FINAL.md`) viven fuera de cualquier repo → **no versionados**, frágiles ante pérdida o cambio de equipo.
- `graphify-out/` (grafo de conocimiento) está en la raíz y tampoco versionado; es regenerable pero útil como contexto para agentes.
- `fidelizacionApp` es solo un esqueleto (sin código Gradle).
- No hay `AGENTS.md` ni `CLAUDE.md` en ningún nivel → los agentes IA no tienen instrucciones de proyecto y deben redescubrir comandos/estructura cada sesión.
- No hay `opencode.json` en el proyecto → no se aprovechan `instructions` ni globs para cargar contexto modular.
- No hay linters/formatters/pre-commit hooks (ESLint, Prettier, EditorConfig, Husky).
- No hay templates de PR/issue ni `CONTRIBUTING.md`.

### Herramientas disponibles (ya instaladas)
- Node 22, npm, Docker 29, Supabase CLI (vía npx), gh, opencode, graphify, MCP: excel, libre, devcycle.
- Playwright, Vitest, TypeScript strict en web; pgTAP/SQL tests en API.
- graphify ya generó un grafo (789 nodos, 1818 aristas) que cabe en una ventana pero es costoso de cargar completo.

### Puntos fuertes
- Suites de pruebas sólidas (149 unit + 34 E2E + ~600 aserciones SQL).
- CI por repo con concurrencia y artefactos.
- Documentación extensa y bien estructurada.
- Separación clara de responsabilidades y contrato HTTP con Supabase.

### Riesgos para agentes IA
- Sin instrucciones de proyecto → más tokens gastados redescubriendo.
- Contexto monolítico: la documentación completa es ~ decenas de miles de palabras; cargarla entera en cada sesión es caro.
- Múltiples repos sin un punto de entrada único → el agente debe cambiar de directorio y no tiene visión global.
- Sin tipos generados desde Supabase → desincronización manual entre SQL y TS.
- Sin context packs → el agente lee migraciones completas para entender contratos.

---

## 2. Objetivos

1. **Reducir consumo de IA** (tokens y tiempo) entre 30–60% por tarea típica.
2. **Dar a los agentes un contexto mínimo, preciso y lazy-loaded**.
3. **Unificar el punto de entrada** del workspace sin romper la separación de repos.
4. **Estandarizar calidad** (lint, format, hooks, CI integrado, convenciones).
5. **Facilitar la incorporación de la app Android** con el mismo flujo.

---

## 3. Propuesta de organización del repositorio

### 3.1 Convertir la raíz en un "meta-repositorio" con submódulos

Mantener los tres repos independientes (contrato actual) pero versionar la raíz como un repositorio que los referencia:

```
Fidelizacion/                      ← nuevo repo "meta" (Git)
├── .gitmodules
├── fidelizacionWeb/               ← submodule → leoCortes123/fidelizacionWeb
├── fidelizacionApi/               ← submodule → leoCortes123/fidelizacionApi
├── fidelizacionApp/               ← submodule → leoCortes123/fidelizacionApp
├── documentacion/                 ← versionado aquí (docs compartidas)
├── AGENTS.md                      ← instrucciones globales para agentes
├── opencode.json                  ← config del proyecto para OpenCode
├── Makefile (o scripts/)          ← comandos unificados
├── .editorconfig
├── CONTRIBUTING.md
└── graphify-out/                  ← opcional, gitignored o versionado
```

**Ventajas**: un único `git clone --recurse-submodules` levanta todo; la documentación pasa a estar versionada; los agentes tienen un root con contexto global. **Costo**: disciplina de submódulos (commits en dos pasos). Alternativa más simple: mantener como está y solo añadir `AGENTS.md` + `opencode.json` en la raíz (sin convertir a repo). Recomendación: empezar por la alternativa simple y migrar a submódulos cuando haya un segundo colaborador.

### 3.2 Versionar la documentación

Mover `documentacion/` al meta-repo (o a `fidelizacionApi/docs` si se prefiere un único repo owner). Mínimo: crear un repo `fidelizacionDocs` o incluirla en el meta-repo. Esto evita pérdida y permite PRs de docs.

### 3.3 Estandarizar calidad (nuevo)
- Añadir ESLint + Prettier a `fidelizacionWeb` (config compartida).
- Añadir `.editorconfig` en raíz (indent, charset, EOL).
- Añadir pre-commit hooks (Husky + lint-staged) que corran `tsc --noEmit` sobre archivos cambiados y `prettier --check`.
- Añadir `CODEOWNERS`, templates de PR/issue en cada repo.
- Añadir `CONTRIBUTING.md` con flujo de ramas, commits convencionales y checklist de pruebas.

### 3.4 CI integrado
- Añadir un workflow en el meta-repo (o reusable workflows) que corra web + api en paralelo y un job final de "smoke de integración".
- Añadir job de lint/format/typecheck a los CI existentes.

### 3.5 Context packs para agentes (nuevo directorio)
Crear `documentacion/ai/` con resúmenes compactos y estables:
- `rpc-contract.md` — lista de RPCs públicas con firma, parámetros y retorno.
- `schema-summary.md` — tablas clave, columnas y relaciones (sin DDL completo).
- `routes-web.md` — rutas y guards por rol.
- `testing-commands.md` — comandos exactos y focalizados.
- `gotchas.md` — quirks (puerto 5199, E2E_PORT, etc.).

Estos archivos son la fuente de verdad para agentes y se actualizan cuando cambia el contrato.

### 3.6 Tipos generados desde Supabase
- Añadir script `npm run gen:types` en `fidelizacionApi` usando `supabase gen types typescript`.
- Guardar el resultado en `fidelizacionWeb/src/types/database.ts` (o paquete compartido) y regenerarlo en CI.
- Reduce desincronización y tokens al no tener que leer SQL para conocer formas.

---

## 4. Propuesta para potenciar agentes IA y ahorrar tokens

### 4.1 Instrucciones de proyecto (AGENTS.md)

Crear `AGENTS.md` en:
- Raíz (global del workspace): visión, estructura, comandos, convenciones, gotchas.
- `fidelizacionWeb/AGENTS.md`: stack, rutas, tests, cómo correr unit/E2E focalizados.
- `fidelizacionApi/AGENTS.md`: migraciones, tests SQL, cómo correr un archivo de test.
- `fidelizacionApp/AGENTS.md`: (cuando exista código) convenciones Kotlin/Compose.

Contenido mínimo y **lazy**: usar referencias `@documentacion/ai/...` en lugar de pegar texto. OpenCode soporta lazy loading si se instruye en el AGENTS.md ("no cargues todos los archivos; léelos solo cuando la tarea lo requiera").

### 4.2 Configuración de OpenCode (`opencode.json`)

En la raíz, crear `opencode.json` (o `.opencode/opencode.json`) con:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "AGENTS.md",
    "documentacion/ai/rpc-contract.md",
    "documentacion/ai/testing-commands.md",
    "fidelizacionWeb/AGENTS.md",
    "fidelizacionApi/AGENTS.md"
  ]
}
```

Esto carga contexto modular y cacheable; evitar incluir docs largos (ARQUITECTURA completa) en `instructions`.

### 4.3 Skills del proyecto
Crear skills reutilizables (en `~/.config/opencode/skills/` o en el repo bajo `.opencode/skills/`):
- `fidelizacion-web`: cómo correr typecheck/unit/E2E focalizado, convenciones de componentes.
- `fidelizacion-api`: cómo crear migración aditiva, correr test-db, validar grants.
- `fidelizacion-testing`: matriz de pruebas y cómo ejecutar subconjuntos.
- `fidelizacion-deploy`: pasos de despliegue web/api.

Los skills evitan repetir instrucciones largas en cada sesión y se activan solo cuando la tarea coincide.

### 4.4 Uso de graphify
- Ya existe `graphify-out/graph.json`. Usarlo para consultas de arquitectura (`graphify query`, `explain`, `path`) en lugar de leer todo el código.
- Regenerar el grafo con un hook post-commit o semanal; commitear solo `GRAPH_REPORT.md` (resumen) y gitignorar el resto del cache.
- Para cambios focalizados, pedir al agente que use `graphify query "<concepto>"` antes de leer archivos.

### 4.5 Lazy loading y búsqueda dirigida
- Preferir `grep`/`glob` sobre `read` de archivos completos.
- En AGENTS.md, instruir: "No leas migraciones ni tests completos salvo que la tarea lo requiera; usa grep para localizar."
- Usar `offset`/`limit` al leer archivos grandes.

### 4.6 Modelos y coste
- Usar modelos gratuitos/económicos (el entorno ya usa Beam Free) para exploración, búsqueda y ediciones mecánicas.
- Reservar modelos premium para diseño de arquitectura, refactor complejo y revisión de seguridad.
- Configurar `opencode` con un modelo por defecto económico y permitir override por tarea.

### 4.7 Worktrees para experimentos
- Usar `opencode worktree create <nombre>` para cambios riesgosos; evita contaminar `main` y reduce retrabajo (y tokens) al descartar experimentos fallidos.

### 4.8 Validación rápida y focalizada
- Añadir scripts npm:
  - `test:unit:file -- <path>` (vitest run <path>)
  - `test:sql:file -- <file>` (ejecutar un solo SQL de tests)
- Documentar en `testing-commands.md` los comandos exactos para correr un solo test.
- Esto evita correr toda la suite (149 unit + 34 E2E) en cada iteración.

### 4.9 Tipos compartidos y generación
- Generar tipos TS desde Supabase reduce la necesidad de que el agente lea SQL para entender formas de datos.

### 4.10 Contexto de navegador (skill browser)
- Usar la skill `browser` para verificar UI (screenshots, consola, red) en lugar de pedir al agente que "imagine" el resultado; reduce iteraciones.

---

## 5. Plan de implementación por fases

### Fase A — Bajo esfuerzo, alto impacto (1–2 días)
1. Crear `AGENTS.md` en raíz y en `fidelizacionWeb`/`fidelizacionApi`.
2. Crear `opencode.json` en raíz con `instructions` modulares.
3. Crear `documentacion/ai/` con context packs (rpc-contract, schema-summary, routes, testing-commands, gotchas).
4. Añadir `.editorconfig` y `CONTRIBUTING.md`.
5. Añadir scripts de tests focalizados.

### Fase B — Calidad y CI (2–4 días)
6. ESLint + Prettier en web; hooks pre-commit.
7. Templates PR/issue y CODEOWNERS.
8. Workflow integrado en meta-repo (o reusable workflows).
9. Job de lint/format/typecheck en CI existentes.

### Fase C — Tipos y contratos (2–3 días)
10. Script `gen:types` y tipos generados en web.
11. Validación de env con zod (web).
12. Regeneración de tipos en CI.

### Fase D — Versionado y submódulos (1 día)
13. Crear meta-repo y convertir subdirectorios en submódulos (o mantener como está si se prefiere simplicidad).
14. Versionar `documentacion/` y `graphify-out/GRAPH_REPORT.md`.

### Fase E — Skills y graphify (1–2 días)
15. Crear skills del proyecto (web, api, testing, deploy).
16. Hook post-commit para regenerar grafo; documentar uso.

---

## 6. Métricas de éxito

- Reducción del tamaño medio de contexto cargado por sesión (medir tokens de prompt).
- Tiempo para completar una tarea típica (ej. añadir un campo a una RPC + UI) reducido.
- Menos iteraciones fallidas en pruebas (medir re-runs).
- `npm run test:all` en verde tras cada cambio.
- Onboarding de un nuevo colaborador/agent en < 30 min leyendo solo `AGENTS.md` + `documentacion/ai/`.

---

## 7. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| Submódulos añaden fricción | Empezar sin submódulos; migrar solo si hace falta |
| Context packs se desactualizan | Actualizarlos en el mismo PR que cambie el contrato; checklist en CONTRIBUTING |
| Tipos generados rompen build | Generar en CI y fallar si hay diff no commiteado |
| AGENTS.md demasiado largo | Mantener < 200 líneas; usar lazy references |
| Skills no se activan | Nombrarlos con triggers claros y probar con tareas reales |

---

## 8. Recomendación inmediata

Implementar **Fase A** primero: es barato, no toca código de negocio y da el mayor retorno en ahorro de tokens y calidad de resultados con agentes. Después, Fase C (tipos generados) por su impacto en desincronización.

> Nota: la búsqueda web general de prácticas (HTTP 402) no estuvo disponible durante el análisis; las recomendaciones se basan en la documentación oficial de OpenCode (rules, skills, MCP, worktrees) y en las herramientas ya instaladas en el entorno.