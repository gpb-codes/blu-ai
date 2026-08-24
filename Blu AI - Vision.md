---
tags:
  - blu
  - vision
  - index
aliases:
  - Blu
  - Blu AI
  - BLU IA
estado: activo
responsable: equipo
tipo: vision
actualizacion: 24-ago-2026
---

# Blu AI — Visión y plataforma

> **Blu AI — Tu agente de inteligencia artificial que trabaja contigo en cualquier lugar.**
> Una capa inteligente (AI Operating Layer) que conecta tus modelos de IA, aplicaciones, archivos, código, navegador y dispositivos en un solo ecosistema.
>
> **Actualización 24-ago-2026:** se integró la visión de evolución hacia un **AI Work Operating System** (Studios, Agent Builder, Workflow Builder, Mission Mode, SOUP, Marketplaces). El encuadre "AI Core" de esa visión ya describe lo que este documento llama Model Router + Gateway — ver [[Blu AI - SOUP y AI Core]]. El detalle de cada pieza nueva vive en notas propias enlazadas en "Módulos de Blu" más abajo; auditoría completa y contradicciones detectadas en [[Blu AI - Decisiones (ADRs)]].

Repositorio oficial: `blutechrobotics/Proyecto-BLU-IA` (copia de trabajo en `gpb-codes/Proyecto-BLU-IA`)

## Qué es Blu

No es un "chatbot con varios modelos". Es una **plataforma de IA con agentes, proyectos, Blu Code y memoria compartida**, multi-dispositivo (Web, Windows, macOS, Android, iOS y extensión de Chrome).

- **IA multi-modelo**: tiers propios **Blu Light / Blu Flash / Blu Ultra** + Claude, Gemini, GPT y futuros, con **modo Auto** que elige el modelo según la tarea.
- **Memoria compartida**: unificada entre todos los modelos, con recuperación RAG.
- **Multidispositivo**: Web, desktop, móvil y Chrome en tiempo real.
- **Diferenciador clave**: orquestador agnóstico sobre múltiples proveedores, frente al ecosistema cerrado de Claude (Anthropic).

```
                     BLU AI
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
   Model Router    Agent System     Memory
        │              │              │
  Claude Gemini   Code Browser     RAG Graph
  OpenAI Kimi*    Desktop Agent     │
                  └── Shared Context
```
   \* Kimi K3 (Moonshot AI) es la base del tier Blu Ultra desde el 18-ago-2026 — ver [[Blu AI - Gateway y Modelos]] y la postura de seguridad en [[Blu AI - Cumplimiento y Seguridad]] (limitado a tareas sin datos personales). Ollama fue descartado del gateway (decisión 17-ago-2026, ver [[Blu AI - Bitacora]]) y se quita de este diagrama.

## Módulos de Blu

| Módulo | Rol | Nota |
|--------|-----|------|
| [[Blu AI - Blu Chat]] | Núcleo conversacional + Model Router | Chat |
| [[Blu AI - Blu Code]] | Edición de código web + CLI local | Code |
| [[Blu AI - Web y Extension Chrome]] | Frontend web (Next.js) + side panel de Chrome | Web/Ext |
| [[Blu AI - Gateway y Modelos]] | Gateway multi-proveedor, tiers y modo Auto | Models |
| [[Blu AI - Memoria compartida]] | Memoria unificada + RAG | Memory |
| [[Blu AI - Agentes]] | Plan, Build, Cowork, Research, QA, Automation, Knowledge | Agents |
| [[Blu AI - Skills y mini-apps]] | Mini-apps generadas + sistema de Skills | Skills |
| [[Blu AI - Datasets y Personalizacion]] | Datasets JSONL para personalización y fine-tuning de los tiers propios | Data |
| [[Blu AI - Studios y Mission Mode]] | AI Workspace, Studios (Creative/Development/Research/Agent/Workflow), Mission Mode | Studios · nuevo 24-ago-2026 |
| [[Blu AI - Agent Builder y Marketplace]] | Creación de agentes propios, Agent Marketplace (roadmap) | Agents · nuevo 24-ago-2026 |
| [[Blu AI - Workflow Builder y Automatizacion]] | Editor de workflows, Automation Hub, Human-in-the-loop, Permission System por agente | Workflows · nuevo 24-ago-2026 |
| [[Blu AI - SOUP y AI Core]] | AI Core, SOUP (I+D de fine-tuning), Model Router ampliado | Models · nuevo 24-ago-2026, contiene conflictos sin resolver |
| [[Blu AI - Conectores, MCP y Assets]] | BLU Connect, MCP Marketplace, Asset Library | Integrations · nuevo 24-ago-2026 |

**Módulos futuros (a detallar):** Desktop (agente de escritorio y archivos), Workspace (Office / Google Workspace), Mobile (control remoto del ecosistema). El resto de los módulos futuros listados hasta la revisión anterior (Browser, Design, Automations) ya quedaron cubiertos por las notas nuevas de arriba — ver [[Blu AI - Roadmap y estado]] para la clasificación P0/P1/P2 completa.

## Visión estratégica

Claude tiene un ecosistema muy potente alrededor de sus propios modelos; **Blu se posiciona como el orquestador independiente que utiliza el mejor modelo disponible para cada trabajo**. Por eso el pilar es el gateway multi-modelo + memoria compartida.

- [[Blu AI - Stack tecnologico]]
- [[Blu AI - Planes y monetizacion]]
- [[Blu AI - Roadmap y estado]]

## Estado (repo, 2026)

- Tareas del equipo: [[Blu AI - Tareas]] (backlog desde Notion, 20 tareas) + tablero [[Blu AI - Kanban]]
- Migración de bot de WhatsApp a plataforma SaaS (WhatsApp **descontinuado** por política de Meta, 15-ene-2026).
- Monorepo pnpm/turbo: `apps/{api, blu-code, extension, mobile, web}`, `packages/{ai-gateway, memory, shared}`.
- AI gateway con adapters reales (OpenAI/Anthropic/Gemini/OpenRouter), BYOK, fallbacks por tier, 78/78 tests.
- Plan completo: `docs/PLAN-MIGRACION-APP.md`.