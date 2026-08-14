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
actualizacion: 14-ago-2026
---

# BLU IA — Contexto del proyecto

> **Documento de contexto para el equipo** — desarrollo (Gabriel, Pablo), coordinación (Ignacio) y marketing.
> Última actualización: **14-ago-2026** · Repositorio oficial: `blutechrobotics/Proyecto-BLU-IA`

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
- Migración en curso hacia **plataforma SaaS** multi-dispositivo. Detalles e historia: [[Blu AI - Roadmap y estado]] y [[Blu AI - Bitacora]].

### Lo que ya está construido (repo, 14-ago-2026)

| Componente | Estado |
|---|---|
| Monorepo pnpm/turbo (`apps/` + `packages/`) | ✅ Funcional |
| **AI Gateway** multi-proveedor (OpenAI, Anthropic, Gemini, OpenRouter) + BYOK | ✅ **78/78 tests pasando** |
| Autenticación Fase 1 (auth local + social) | ✅ 68 tests |
| Base del sistema MCP (9 herramientas) | ✅ |
| Documento de plan completo (`docs/PLAN-MIGRACION-APP.md`) | ✅ DRAFT v2 |

> ⚠️ **Decisión pendiente de confirmar (28-jul):** la Bitácora movió datos de Supabase/Postgres a **Cloudflare D1 + Vectorize**; el repo y la base de Tareas aún referencian Supabase/pgvector. Ver [[Blu AI - Stack tecnologico]].

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
PostgreSQL + pgvector (RAG) * · Redis · AI Gateway (tiers + Auto + BYOK) · Stripe
```
\* Postgres/pgvector en revisión → Cloudflare D1 + Vectorize (ver alerta arriba).

Stack: **NestJS** (backend) · **Flutter** (móvil/desktop) · **Next.js 15** (web/landing/admin) · **TypeScript** en todo el monorepo.

---

## 4. Módulos (mapa de notas)

| Nota | Rol |
|------|-----|
| [[Blu AI - Vision]] | **Índice general** — visión, módulos, estado |
| [[Blu AI - Blu Chat]] | Chat con Model Router y modo Auto |
| [[Blu AI - Blu Code]] | Edición de código web + CLI local |
| [[Blu AI - Gateway y Modelos]] | Gateway multi-proveedor, tiers y BYOK |
| [[Blu AI - Memoria compartida]] | Memoria unificada + RAG |
| [[Blu AI - Agentes]] | 7 agentes de tareas |
| [[Blu AI - Skills y mini-apps]] | Sistema extensible de capacidades |
| [[Blu AI - Stack tecnologico]] | Arquitectura y stack |
| [[Blu AI - Planes y monetizacion]] | Gratis / BYOK $10 / Créditos $30 |
| [[Blu AI - Roadmap y estado]] | Decisiones, historial y hitos |
| [[Blu AI - Tareas]] · [[Blu AI - Kanban]] | Backlog (Notion) y tablero del sprint |
| [[Blu AI - Clientes ideales]] · [[Blu AI - Metricas semanales]] · [[Blu AI - Bitacora]] | Negocio |

---

## 5. Equipo y roles (equity según Notion, 29-jul)

| Rol | Persona | Equity | Ámbito |
|-----|---------|--------|--------|
| Fundador / coordinación | **Ignacio** | 83% | Decisiones, contenido, legal, waitlist, métricas |
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
- **Tareas**: usa el formato `- [ ] #task ... 📅 fecha` (plugin Tasks) o arrastra tarjetas en [[Blu AI - Kanban]].
- **Diaria**: `Ctrl/Cmd + P` → *Periodic Notes: Open today's daily note*.
- **Vista tipo Notion**: abre "BLU Roadmap" desde el icono de Projects (board por estado / tabla).
- **Vista dinámica de módulos** (Dataview):

```dataview
TABLE estado, prioridad, responsable, fase
FROM #blu
WHERE tipo = "modulo"
SORT fase ASC
```

- Las notas de Blu tienen prefijo `Blu AI -` y viven en la raíz; todo se sincroniza con GitHub (`gpb-codes/blu-ai`, privado).

---

## 7. Para el equipo

- **Desarrollo:** el punto de partida es [[Blu AI - Roadmap y estado]] y el plan del repo (`docs/PLAN-MIGRACION-APP.md`).
- **Coordinación (Ignacio):** [[Blu AI - Roadmap y estado]] resume decisiones y próximos hitos; cualquier cambio relevante se refleja aquí.
- **Marketing:** [[Blu AI - Clientes ideales]] define a quién le hablamos; [[Blu AI - Planes y monetizacion]] la oferta; [[Blu AI - Metricas semanales]] lo que importa. Preguntas de contexto: Gabriel o Pablo.
