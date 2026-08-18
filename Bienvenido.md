---
tags:
  - blu
  - index
  - equipo
  - contexto
aliases:
  - Inicio
  - Home
  - Bienvenida
  - Contexto del proyecto
tipo: index
estado: activo
prioridad: alta
responsable: equipo
actualizacion: 17-ago-2026
---

# BLU IA — Contexto del proyecto

> **Documento de contexto para el equipo** — desarrollo (Gabriel, Pablo), coordinación (Ignacio) y marketing.
> Última actualización: **17-ago-2026** · Repositorio oficial: `blutechrobotics/Proyecto-BLU-IA` (copia de trabajo en `gpb-codes/Proyecto-BLU-IA`) · Entidad legal: **una única sociedad, constituida en México** ([[Blu AI - Cumplimiento y Seguridad]])

**Estado del sprint (Mes 1 - Base, agosto):** 7/20 tareas listas · 2 en progreso · 11 pendientes (varias ya atrasadas) · Tablero por responsable: [[Blu AI - Kanban]] · Backlog: [[Blu AI - Tareas]]

---

## Índice

1. [[#1. Qué es BLU]]
2. [[#2. Estado actual del proyecto]]
3. [[#3. Arquitectura en una línea]]
4. [[#4. Mapa de notas]]
5. [[#5. Equipo y roles]]
6. [[#6. Cómo usar esta bóveda]]
7. [[#7. Para el equipo — qué revisar]]

---

## 1. Qué es BLU

**BLU es una plataforma de inteligencia artificial multi-dispositivo**: Web, Windows, macOS, Android, iOS y extensión de Chrome.

> *"Una capa inteligente que conecta tus modelos de IA, aplicaciones, archivos, código, navegador y dispositivos en un solo ecosistema."*

### La diferencia estratégica

| | Claude (Anthropic) | BLU |
|---|---|---|
| Modelos | Ecosistema cerrado (solo Claude) | **Multi-modelo**: Claude + Gemini + GPT + modelos propios |
| Posicionamiento | Solución de un proveedor | **Orquestador independiente**: el mejor modelo para cada tarea |
| Memoria | Memoria de Claude | **Memoria compartida** entre todos los modelos y dispositivos |

### Qué resuelve

- Un solo chat para todo: código, documentos, imágenes, proyectos.
- **Blu Code**: editar código y commitear desde la web o desde un CLI local (`npx blu-code`), estilo Claude Code. Es el **diferenciador confirmado** (bitácora 28-jul).
- **Agentes** (Plan, Build, Cowork, Research, QA, Automation, Knowledge) que ejecutan tareas de extremo a extremo.
- **Memoria compartida** con recuperación RAG: empiezas con un modelo y continúas con otro sin perder contexto.
- Proyectos colaborativos con permisos (cada persona con su agente y su propia facturación).

---

## 2. Estado actual del proyecto

### Origen

- BLU nació como un **bot de WhatsApp**, que quedó **descontinuado** (prohibición de Meta a asistentes de propósito general vía WA Business API, 15-ene-2026).
- Migración en curso hacia **plataforma SaaS** multi-dispositivo. Historia completa: [[Blu AI - Bitacora]].

### Lo que ya está construido (verificado en el fork, 17-ago-2026)

| Componente | Estado |
|---|---|
| Monorepo pnpm/turbo (`apps/` + `packages/`) | ✅ Funcional |
| **AI Gateway** multi-proveedor (OpenAI, Anthropic, Gemini, OpenRouter) + BYOK (routing) | ✅ **78/78 tests pasando** |
| **Esquema de base de datos** (`schema.prisma`: User, RefreshToken, UserApiKey, ConnectedRepo...) | ✅ 2 migraciones aplicadas |
| **Login y registro** (AuthController, JWT+refresh, hash Argon2, test e2e) | ✅ Funcional |
| Sistema BYOK con API keys **encriptadas** | 🔄 En progreso — el modelo de datos ya está listo (AES-256-GCM), falta el servicio/controlador que cifre y guarde las keys |
| Base del sistema MCP (9 herramientas) | ✅ |
| `apps/web` (Next.js, landing/waitlist) | ⬜ Sigue siendo el boilerplate default — sin diseño ni contenido propio |
| Diseño de frontend (Pablo) | 🔄 Avanzado en mobile/Flutter, cero en web |
| Documento de plan completo (`docs/PLAN-MIGRACION-APP.md`) | ✅ DRAFT v2 |
| Arquitectura de cumplimiento legal y seguridad | ✅ [[Blu AI - Cumplimiento y Seguridad]] — cierra la tarea del Kanban, con huecos ya en su mayoría decididos |

> **Migración de base de datos — confirmada (17-ago-2026):** de Supabase/Postgres a **Cloudflare D1 + Vectorize**. Es una decisión cerrada, pero el código auditado ese mismo día seguía corriendo sobre Prisma/PostgreSQL — falta implementarla, y falta definir la política de residencia de datos antes de hacerlo (ver [[Blu AI - Cumplimiento y Seguridad]]). Ver también [[Blu AI - Stack tecnologico]].

### Próximos hitos (agosto)

| Fecha | Hito | Responsable |
|---|---|---|
| 20-ago | Landing page con waitlist | Ignacio + Marketing |
| 25-ago | Sistema BYOK con API keys encriptadas (en progreso) | Gabriel |
| 26-ago | Aviso de privacidad publicado en la web | Ignacio |
| 31-ago | 100 personas en waitlist · Cierre de mes 1 y ajuste de roadmap | Ignacio + Marketing |

> ⚠️ Varios hitos anteriores del sprint ya están atrasados (ej. despliegue en Vercel, configuración de Cloudflare D1, acuerdo con Pablo, conversación con seguridad) — ver el detalle por responsable en [[Blu AI - Kanban]].

### Pendiente / próximos frentes

1. Terminar onboarding multidispositivo (web + móvil + desktop).
2. **Memoria compartida RAG** end-to-end.
3. Refinar **modo Auto** del gateway (clasificador de tarea → mejor modelo).
4. **Blu Code** local + web con GitHub conectado.
5. **Mini-apps / sistema de Skills**.

---

## 3. Arquitectura en una línea

```
Clients (Flutter · Next.js · Chrome ext · Blu Code CLI)
        │
API Gateway (NestJS) — auth · proyectos · chat · agentes · memoria · billing
        │
PostgreSQL + pgvector (RAG) * · Redis · AI Gateway (tiers + Auto + BYOK) · Stripe · Cloudflare R2 (storage) †
```
\* Postgres/pgvector → migración confirmada a Cloudflare D1 + Vectorize (17-ago-2026), aún no implementada en código (ver alerta arriba).
† Storage de archivos definido el 17-ago-2026 ([[Blu AI - Cumplimiento y Seguridad]]); DPA pendiente de firmar.

Stack: **NestJS** (backend) · **Flutter** (móvil/desktop) · **Next.js 15** (web/landing/admin) · **TypeScript** en todo el monorepo.

---

## 4. Mapa de notas

| Nota | Rol |
|------|-----|
| [[Blu AI - Vision]] | **Índice general** — visión, módulos, estado |
| [[Blu AI - Blu Chat]] · [[Blu AI - Blu Code]] · [[Blu AI - Web y Extension Chrome]] · [[Blu AI - Gateway y Modelos]] · [[Blu AI - Memoria compartida]] · [[Blu AI - Agentes]] · [[Blu AI - Skills y mini-apps]] | Módulos del producto |
| [[Blu AI - Stack tecnologico]] | Arquitectura y stack |
| [[Blu AI - Cumplimiento y Seguridad]] | Cumplimiento legal (Chile/México/España), seguridad, DPAs, huecos y decisiones |
| [[Blu AI - Datasets y Personalizacion]] | Sistema de datasets (JSONL) para personalización y fine-tuning |
| [[Blu AI - Planes y monetizacion]] | Gratis / BYOK $10 / Créditos $30 |
| [[Blu AI - Roadmap y estado]] | Decisiones, historial y hitos |
| [[Blu AI - Tareas]] · [[Blu AI - Kanban]] | Backlog (Notion) y tablero del sprint |
| [[Blu AI - Clientes ideales]] · [[Blu AI - Metricas semanales]] · [[Blu AI - Bitacora]] | Negocio |

---

## 5. Equipo y roles (equity según Notion, 29-jul)

| Rol | Persona | Equity | Ámbito |
|-----|---------|--------|--------|
| Fundador / coordinación | **Ignacio** | 83% | Decisiones, contenido, legal, waitlist, métricas · **Responsable de privacidad/DPO** (designado 17-ago-2026, ver [[Blu AI - Cumplimiento y Seguridad]]) |
| Desarrollador principal | **Gabriel** | 10% (vesting 4a, cliff 1a) | Backend, gateway, memoria, Blu Code, Stripe, infra |
| Frontend | **Pablo** | 2% (vesting 4a, cliff 1a) | Frontend web+app, identidad visual |
| Marketing (contenido) | Hernández · Guionista · Grabador · Editor | Comisión 5–10% por venta | Contenido en las dos cuentas |
| Seguridad | Contacto en España | 5% (propuesto, sin cerrar) | Auditorías, credenciales, API keys |

- Efectivo desde **1,000 usuarios**: Gabriel $500/mes · Pablo $150/mes.
- Compromisos: Gabriel 5 h diarias, 4 años.

---

## 6. Cómo usar esta bóveda

- **Wikilinks**: escribe `[[` para enlazar notas (ej. `[[Blu AI - Gateway y Modelos]]`).
- **Templates**: `Ctrl/Cmd + P` → *Templater: Insert template* → "BLU - Nota de proyecto" (o "BLU - Tarea").
- **Tareas**: arrastra tarjetas en [[Blu AI - Kanban]]; el estado de Notion se vuelca en [[Blu AI - Tareas]].
- **Diaria**: `Ctrl/Cmd + P` → *Periodic Notes: Open today's daily note* (queda en `Diarias/`).
- **Vista tipo Notion**: desde el icono **Projects** podes crear un proyecto con vistas board/tabla usando los campos del frontmatter (`estado`, `prioridad`, `responsable`, `fase`).
- **Vista dinámica de módulos** (Dataview):

```dataview
TABLE estado, prioridad, responsable, fase
FROM #blu
WHERE tipo = "modulo"
SORT fase ASC
```

- Las notas de Blu tienen prefijo `Blu AI -` y viven en la raíz; **esta bóveda** se sincroniza sola con GitHub (`gpb-codes/blu-ai`, privado — ver [[Setup del equipo - dispositivos]]).
- Ojo, no confundir dos repos distintos: **`gpb-codes/blu-ai`** es el repo de esta bóveda de notas; **`gpb-codes/Proyecto-BLU-IA`** (copia de trabajo del repo oficial `blutechrobotics/Proyecto-BLU-IA`) es el repo del código del producto, donde se hizo la auditoría técnica del 17-ago-2026.

---

## 7. Para el equipo — qué revisar

| Rol | Punto de entrada | Ritmo |
|-----|------------------|-------|
| **Desarrollo** (Gabriel, Pablo) | [[Blu AI - Roadmap y estado]] + [[Blu AI - Tareas]] + plan del repo (`docs/PLAN-MIGRACION-APP.md`) | Diario: Kanban → tus tareas con fecha |
| **Coordinación** (Ignacio) | [[Blu AI - Roadmap y estado]] (decisiones) + [[Blu AI - Bitacora]] (historial) + [[Blu AI - Metricas semanales]] + [[Blu AI - Cumplimiento y Seguridad]] (rol de DPO/privacidad) | Semanal (lunes): métricas + mover roadmap |
| **Marketing** | [[Blu AI - Clientes ideales]] (a quién hablamos) + [[Blu AI - Planes y monetizacion]] (oferta) + [[Blu AI - Metricas semanales]] (views) | Semanal: llenar métricas; contenido 10 piezas/semana |

Preguntas de contexto: Gabriel o Pablo. Cualquier cambio relevante se refleja en [[Blu AI - Roadmap y estado]] y [[Blu AI - Bitacora]].