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
---

# Blu AI — Visión y plataforma

> **Blu AI — Tu agente de inteligencia artificial que trabaja contigo en cualquier lugar.**
> Una capa inteligente (AI Operating Layer) que conecta tus modelos de IA, aplicaciones, archivos, código, navegador y dispositivos en un solo ecosistema.

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
  Kimi  OpenAI    Desktop Agent     │
  Ollama          └── Shared Context
```

## Módulos de Blu

| Módulo | Rol | Nota |
|--------|-----|------|
| [[Blu AI - Blu Chat]] | Núcleo conversacional + Model Router | Chat |
| [[Blu AI - Blu Code]] | Edición de código web + CLI local | Code |
| [[Blu AI - Gateway y Modelos]] | Gateway multi-proveedor, tiers y modo Auto | Models |
| [[Blu AI - Memoria compartida]] | Memoria unificada + RAG | Memory |
| [[Blu AI - Agentes]] | Plan, Build, Cowork, Research, QA, Automation, Knowledge | Agents |
| [[Blu AI - Skills y mini-apps]] | Mini-apps generadas + sistema de Skills | Skills |
| [[Blu AI - Datasets y Personalizacion]] | Datasets JSONL para personalización y fine-tuning de los tiers propios | Data |

**Módulos futuros (a detallar):** Browser (extensión Chrome / agente de navegador), Desktop (agente de escritorio y archivos), Design (UI/UX y presentaciones), Workspace (Office / Google Workspace), Automations (workflows en lenguaje natural), Mobile (control remoto del ecosistema).

## Visión estratégica

Claude tiene un ecosistema muy potente alrededor de sus propios modelos; **Blu se posiciona como el orquestador independiente que utiliza el mejor modelo disponible para cada trabajo**. Por eso el pilar es el gateway multi-modelo + memoria compartida.

- [[Blu AI - Stack tecnologico]]
- [[Blu AI - Planes y monetizacion]]
- [[Blu AI - Roadmap y estado]]

## Estado (repo, 2026)

- Tareas del equipo: [[Blu AI - Tareas]] (backlog desde Notion, 20 tareas) + tablero [[Blu AI - Kanban]] + tablero [[Blu AI - Kanban]]
- Migración de bot de WhatsApp a plataforma SaaS (WhatsApp **descontinuado** por política de Meta, 15-ene-2026).
- Monorepo pnpm/turbo: `apps/{api, blu-code, extension, mobile, web}`, `packages/{ai-gateway, memory, shared}`.
- AI gateway con adapters reales (OpenAI/Anthropic/Gemini/OpenRouter), BYOK, fallbacks por tier, 78/78 tests.
- Plan completo: `docs/PLAN-MIGRACION-APP.md`.