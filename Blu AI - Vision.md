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

# Blu AI â€” VisiÃ³n y plataforma

> **Blu AI â€” Tu agente de inteligencia artificial que trabaja contigo en cualquier lugar.**
> Una capa inteligente (AI Operating Layer) que conecta tus modelos de IA, aplicaciones, archivos, cÃ³digo, navegador y dispositivos en un solo ecosistema.

Repositorio oficial: `blutechrobotics/Proyecto-BLU-IA` (copia de trabajo en `gpb-codes/Proyecto-BLU-IA`)

## QuÃ© es Blu

No es un "chatbot con varios modelos". Es una **plataforma de IA con agentes, proyectos, Blu Code y memoria compartida**, multi-dispositivo (Web, Windows, macOS, Android, iOS y extensiÃ³n de Chrome).

- **IA multi-modelo**: tiers propios **Blu Light / Blu Flash / Blu Ultra** + Claude, Gemini, GPT y futuros, con **modo Auto** que elige el modelo segÃºn la tarea.
- **Memoria compartida**: unificada entre todos los modelos, con recuperaciÃ³n RAG.
- **Multidispositivo**: Web, desktop, mÃ³vil y Chrome en tiempo real.
- **Diferenciador clave**: orquestador agnÃ³stico sobre mÃºltiples proveedores, frente al ecosistema cerrado de Claude (Anthropic).

```
                     BLU AI
                       â”‚
        â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
        â–¼              â–¼              â–¼
   Model Router    Agent System     Memory
        â”‚              â”‚              â”‚
  Claude Gemini   Code Browser     RAG Graph
  Kimi  OpenAI    Desktop Agent     â”‚
  Ollama          â””â”€â”€ Shared Context
```

## MÃ³dulos de Blu

| MÃ³dulo | Rol | Nota |
|--------|-----|------|
| [[Blu AI - Blu Chat]] | NÃºcleo conversacional + Model Router | Chat |
| [[Blu AI - Blu Code]] | EdiciÃ³n de cÃ³digo web + CLI local | Code |
| [[Blu AI - Gateway y Modelos]] | Gateway multi-proveedor, tiers y modo Auto | Models |
| [[Blu AI - Memoria compartida]] | Memoria unificada + RAG | Memory |
| [[Blu AI - Agentes]] | Plan, Build, Cowork, Research, QA, Automation, Knowledge | Agents |
| [[Blu AI - Skills y mini-apps]] | Mini-apps generadas + sistema de Skills | Skills |

**MÃ³dulos futuros (a detallar):** Browser (extensiÃ³n Chrome / agente de navegador), Desktop (agente de escritorio y archivos), Design (UI/UX y presentaciones), Workspace (Office / Google Workspace), Automations (workflows en lenguaje natural), Mobile (control remoto del ecosistema).

## VisiÃ³n estratÃ©gica

Claude tiene un ecosistema muy potente alrededor de sus propios modelos; **Blu se posiciona como el orquestador independiente que utiliza el mejor modelo disponible para cada trabajo**. Por eso el pilar es el gateway multi-modelo + memoria compartida.

- [[Blu AI - Stack tecnologico]]
- [[Blu AI - Planes y monetizacion]]
- [[Blu AI - Roadmap y estado]]

## Estado (repo, 2026)

- Tareas del equipo: [[Blu AI - Tareas]] (backlog desde Notion, 20 tareas) + tablero [[Blu AI - Kanban]]
- MigraciÃ³n de bot de WhatsApp a plataforma SaaS (WhatsApp **descontinuado** por polÃ­tica de Meta, 15-ene-2026).
- Monorepo pnpm/turbo: `apps/{api, blu-code, extension, mobile, web}`, `packages/{ai-gateway, memory, shared}`.
- AI gateway con adapters reales (OpenAI/Anthropic/Gemini/OpenRouter), BYOK, fallbacks por tier, 78/78 tests.
- Plan completo: `docs/PLAN-MIGRACION-APP.md`.
