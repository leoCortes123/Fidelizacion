# Graph Report - Fidelizacion  (2026-11-09)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 222 nodes · 162 edges · 91 communities (10 shown, 81 thin omitted)
- Extraction: 2% EXTRACTED · 98% INFERRED · 0% AMBIGUOUS · INFERRED: 159 edges (avg confidence: 0.99)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `6fb42e9b`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Rutas y páginas de la Web
- Componentes compartidos de la Web
- Documentación de la base de datos
- Estado del servidor y diálogos
- Configuración de pruebas E2E
- Canje, base de datos y app móvil
- Documentación de la app Android
- Integración continua de la Web
- Dependencias de npm de la Web
- Insignias de estado y tipos
- Configuración de TypeScript (app)
- Documentación de seguridad
- Dependencias de desarrollo
- Propuesta de negocio (tacos)
- Integración continua de la API
- Configuración de TypeScript (node)
- Paquete de la API
- Hooks de administración
- Autenticación y raíz de la app
- Pruebas unitarias de la Web
- Archivos README
- Hooks de puntos y recompensas
- Scripts de npm
- Documentación de arquitectura
- Configuración de Supabase JS
- Configuración de pruebas Jest
- Herramienta de construcción Vite
- Decisiones de arquitectura
- Tailwind CSS
- Pruebas del panel de cliente
- Pruebas y repositorios
- Scripts de base de datos de prueba
- Favicon (SVG)
- Variables de entorno de Vite
- Configuración de TypeScript
- Configuración de despliegue en Vercel
- Comunidad 36
- Comunidad 37
- Comunidad 38
- Comunidad 39
- Comunidad 40
- Comunidad 41
- Comunidad 42
- Comunidad 43
- Comunidad 44
- Comunidad 45
- Documentacion PRUEBAS Playwright
- Documentacion PRUEBAS Smoke Build
- Documentacion PRUEBAS Tests E2e
- Documentacion PRUEBAS Tests Unit
- Documentacion PRUEBAS Vitest
- Documentacion README Documentacion No Gi
- Documentacion README Workspace
- Documentacion REPOSITORIOS Estado
- Documentacion SEGURIDAD Admin Revoke Rol
- Documentacion SEGURIDAD Bootstrap Admins
- Documentacion SEGURIDAD Codigo Canje
- Documentacion SEGURIDAD Config History
- Documentacion SEGURIDAD Csrf
- Documentacion SEGURIDAD Customer Redeem 
- Documentacion SEGURIDAD Google Oauth
- Documentacion SEGURIDAD Idempotencia
- Documentacion SEGURIDAD Points Ledger
- Documentacion SEGURIDAD Profiles
- Documentacion SEGURIDAD Rls Publicas
- Documentacion SEGURIDAD Sha256 Qr
- Documentacion SEGURIDAD Token Compra
- Documentacion SEGURIDAD User Roles
- Documentacion SEGURIDAD Xss
- Documentacion Arquitectura Profiles
- Documentacion Arquitectura Require Admin
- Documentacion Arquitectura Require Auth
- Documentacion Arquitectura User Roles
- Documentacion Despliegue
- Documentacion Despliegue Auth Google
- Documentacion Despliegue Bootstrap Admin
- Documentacion Despliegue Csp
- Documentacion Despliegue Operacion
- Documentacion Despliegue Orden Despliegu
- Documentacion Despliegue Rollback
- Documentacion Despliegue Supabase
- Documentacion Despliegue Variables Build
- Documentacion Despliegue Verificacion
- Documentacion Estado Proyecto
- Documentacion Estado Proyecto Fidelizaci
- Documentacion Estado Proyecto Fidelizaci

## God Nodes (most connected - your core abstractions)
1. `App Android` - 24 edges
2. `Base de datos, RPC y RLS` - 21 edges
3. `Configuración` - 12 edges
4. `Fidelización — sistema/workspace de fidelización` - 12 edges
5. `Taquería Tradicional de Alta Rotación` - 9 edges
6. `Desarrollo local` - 8 edges
7. `tabla purchases` - 6 edges
8. `fidelizacion.code-workspace — workspace VS Code` - 5 edges
9. `tabla points_ledger` - 4 edges
10. `tabla redemptions` - 4 edges

## Surprising Connections (you probably didn't know these)
- `Taquería Tradicional de Alta Rotación` ----> `Barra de salsas de chiles secos`  [INFERRED]
  documentacion/negocio/propuesta_negocio_tacos.pdf → documentacion/negocio/propuesta_negocio_tacos.md
- `Taquería Tradicional de Alta Rotación` ----> `Productos cruzados`  [INFERRED]
  documentacion/negocio/propuesta_negocio_tacos.pdf → documentacion/negocio/propuesta_negocio_tacos.md
- `estado actual` ----> `Base de datos, RPC y RLS`  [INFERRED]
  documentacion/CONFIGURACION.md → documentacion/BASE_DE_DATOS.md
- `API (primero)` ----> `Base de datos, RPC y RLS`  [INFERRED]
  documentacion/DESARROLLO.md → documentacion/BASE_DE_DATOS.md
- `variables de entorno web` ----> `Base de datos, RPC y RLS`  [INFERRED]
  documentacion/CONFIGURACION.md → documentacion/BASE_DE_DATOS.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Workspace compuesto por cuatro componentes** —  [INFERRED 0.75]
- **Principios de seguridad** —  [INFERRED 0.75]
- **Concepto de negocio taquería** —  [INFERRED 0.75]
- **tablas de la base de datos** —  [INFERRED 0.75]
- **repositorios implicados** —  [INFERRED 0.75]
- **flujo recomendado de desarrollo** —  [INFERRED 0.75]
- **Workspace Fidelización (fidelizacion.code-workspace)** —  [INFERRED 0.75]
- **Stack tecnológico de la app Android** —  [INFERRED 0.75]
- **Flujo de compra y reclamación** —  [INFERRED 0.90]

## Communities (91 total, 81 thin omitted)

### Community 0 - "Rutas y páginas de la Web"
Cohesion: 0.09
Nodes (25): admin_redeem_reward (operación exclusiva del panel web), BASE_DE_DATOS.md, CameraX, DataStore, App Android, google-services.json, Historial de compras y canjes, Jetpack Compose + Material 3 (+17 more)

### Community 1 - "Componentes compartidos de la Web"
Cohesion: 0.10
Nodes (20): Barra de salsas de chiles secos, Barrio Popular, Bogotá, Colombia, Capital de Arranque Recomendado ($5.500.000 COP), Estrategia de combos y precios psicológicos, Inversión Inicial en Equipos y Utensilios ($3.280.000 COP), Estrategia de Combos y Precios Psicológicos, Toque Auténtico: Doble tortilla de maíz, cebolla, cilantro, limón, Inventario recomendado de apertura (+12 more)

### Community 2 - "Documentación de la base de datos"
Cohesion: 0.17
Nodes (19): Base de datos, RPC y RLS, tipo app_role, tabla audit_log, concurrencia e idempotencia, tabla config_history, tabla points_ledger, tipo points_movement_type, tabla private.rate_limits (+11 more)

### Community 3 - "Estado del servidor y diálogos"
Cohesion: 0.15
Nodes (11): admin_cancel_redemption, audit_log, auth.uid(), Autorización en el servidor, Cero confianza en el navegador, Clave anon, Escrituras mediadas, Mínimo privilegio (+3 more)

### Community 4 - "Configuración de pruebas E2E"
Cohesion: 0.15
Nodes (13): tabla private.bootstrap_admins, Configuración, administrador inicial, ejecutar la web, estado actual, Google OAuth, repositorios implicados, requisitos (+5 more)

### Community 5 - "Canje, base de datos y app móvil"
Cohesion: 0.24
Nodes (13): documentacion — documentación, propuesta de negocio y datos privados, documentacion/ESTADO_PROYECTO.md, documentacion/privado/ — valores operativos reales ignorados por Git, documentacion/README.md, Fidelización — sistema/workspace de fidelización, fidelizacion.code-workspace — workspace VS Code, fidelizacionApi — backend (Supabase: SQL, RPC, RLS), fidelizacionApp — espacio para app Android (+5 more)

### Community 6 - "Documentación de la app Android"
Cohesion: 0.25
Nodes (9): variables de entorno web, Desarrollo local, API (primero), App Android, flujo recomendado, problemas frecuentes, pruebas web, requisitos desarrollo (+1 more)

### Community 7 - "Integración continua de la Web"
Cohesion: 0.29
Nodes (7): Arquitectura del sistema de fidelización, Repositorio fidelizacionApi, Repositorio fidelizacionApp, Repositorio fidelizacionWeb, Row Level Security (RLS), Supabase (Auth, PostgREST, PostgreSQL), TanStack Query

### Community 8 - "Dependencias de npm de la Web"
Cohesion: 0.40
Nodes (3): RPC create_purchase, Libro points_ledger, Hash SHA-256 de tokens

### Community 9 - "Insignias de estado y tipos"
Cohesion: 0.67
Nodes (3): Repositorio API fidelizacionApi, PostgreSQL 16 efímero en Docker, API: Supabase migraciones, RPC, RLS, seed

## Knowledge Gaps
- **149 isolated node(s):** `CameraX`, `DataStore`, `google-services.json`, `Historial de compras y canjes`, `JUnit` (+144 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 162 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **81 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Base de datos, RPC y RLS` connect `Documentación de la base de datos` to `Configuración de pruebas E2E`, `Documentación de la app Android`?**
  _High betweenness centrality (0.021) - this node is a cross-community bridge._
- **Are the 24 inferred relationships involving `App Android` (e.g. with `admin_redeem_reward (operación exclusiva del panel web)` and `BASE_DE_DATOS.md`) actually correct?**
  _`App Android` has 24 INFERRED edges - model-reasoned connections that need verification._
- **What connects `CameraX`, `DataStore`, `google-services.json` to the rest of the system?**
  _149 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Rutas y páginas de la Web` be split into smaller, more focused modules?**
  _Cohesion score 0.09 - nodes in this community are weakly interconnected._
- **Why does `Configuración` connect `Configuración de pruebas E2E` to `Documentación de la base de datos`, `Documentación de la app Android`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **Are the 21 inferred relationships involving `Base de datos, RPC y RLS` (e.g. with `tipo app_role` and `tabla audit_log`) actually correct?**
  _`Base de datos, RPC y RLS` has 21 INFERRED edges - model-reasoned connections that need verification._
- **Should `Componentes compartidos de la Web` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._