---
tags:
  - soybluia
  - memoria
  - rag
estado: pendiente
fase: Mes 2 - Producto
responsable: Gabriel
tipo: modulo
actualizacion: 24-ago-2026
---

# SoyBluAI — Memoria compartida

> El diferenciador estratégico: memoria unificada entre todos los modelos y dispositivos.
>
> **Actualización 24-ago-2026 — Memory 2.0:** se incorpora la estructura jerárquica pedida por la nueva visión de producto, como evolución de este mismo diseño (no un sistema aparte):
>
> ```
> GLOBAL MEMORY
> │
> ├── USER
> ├── ORGANIZATION
> └── PROJECT
>       │
>       ├── Knowledge
>       ├── Files
>       ├── Agents
>       ├── Conversations
>       ├── Decisions
>       └── Assets
> ```
>
> Mapeo contra el diseño ya construido más abajo: "Proyectos" = nivel `PROJECT`; "Usuario" = nivel `USER`. `ORGANIZATION` es 🔵 nuevo — hoy la colaboración es por proyecto con roles owner/admin/editor/viewer ([[SoyBluAI - Planes y monetizacion]]), sin nivel de organización superior; evaluar si hace falta antes de construirlo, ya que hoy el equipo es una sola organización. Los sub-nodos de `PROJECT` formalizan lo que hoy vive disperso: Knowledge/Files = memoria de proyecto + storage ya decidido (Cloudflare R2); Agents = [[SoyBluAI - Agentes]]; Conversations = ya existente; Decisions = hoy solo vive en [[SoyBluAI - Bitacora]] sin ligarse a un proyecto específico; Assets = 🔵 nuevo, ver [[SoyBluAI - Conectores, MCP y Assets]]. El principio central de memoria compartida entre modelos y agentes no cambia.

## Idea

No es solo memoria de conversaciones. Es una **memoria compartida** que permite:

- Empezar algo con Claude y continuar con Kimi sin perder contexto.
- Trabajar desde PC → teléfono → navegador → VS Code sin perder el hilo.
- Recuperación inteligente (RAG) independientemente del modelo usado.

## Diseño

```
                    SoyBluAI Memory
                        │
       ┌────────────────┼────────────────┐
       ▼                ▼                ▼
   Proyectos          Usuario         Trabajo
       │                │                │
       ▼                ▼                ▼
    GitHub           Preferencias      Docs
       │                │                │
       └────────────────┼────────────────┘
                        ▼
                  Shared Context
                        │
          ┌─────────────┼─────────────┐
          ▼             ▼             ▼
       Claude         Gemini         Kimi
```

## Implementación real

- **Vault de notas del proyecto** estilo *second brain* (tipo Obsidian): wikilinks, tags, backlinks, grafo y **RAG**.
- PostgreSQL (Neon) con **pgvector** para recuperación semántica, en transición hacia **Cloudflare D1 + Vectorize** (migración confirmada 17-ago-2026, ver [[SoyBluAI - Stack tecnologico]] y [[SoyBluAI - Bitacora]]) — todavía no implementada en el fork auditado el 17-ago-2026.
- Memoria por usuario (`user_memory`) + memoria de proyecto compartida con permisos.
- **Redis (Upstash)** para colas, límites y presencia.

Ver también: [[SoyBluAI - Gateway y Modelos]], [[SoyBluAI - Chat]].