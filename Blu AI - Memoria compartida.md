---
tags:
  - blu
  - memoria
  - rag
estado: pendiente
fase: Mes 2 - Producto
responsable: Gabriel
tipo: modulo
---

# Blu AI — Memoria compartida

> El diferenciador estratégico: memoria unificada entre todos los modelos y dispositivos.

## Idea

No es solo memoria de conversaciones. Es una **memoria compartida** que permite:

- Empezar algo con Claude y continuar con Kimi sin perder contexto.
- Trabajar desde PC → teléfono → navegador → VS Code sin perder el hilo.
- Recuperación inteligente (RAG) independientemente del modelo usado.

## Diseño

```
                    Blu Memory
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
- PostgreSQL (Neon) con **pgvector** para recuperación semántica. ⚠️ En revisión: Cloudflare D1 + Vectorize (bitácora 28-jul, ver [[Blu AI - Stack tecnologico]]). ⚠️ En revisión: Cloudflare D1 + Vectorize (bitácora 28-jul, ver [[Blu AI - Stack tecnologico]]).
- Memoria por usuario (`user_memory`) + memoria de proyecto compartida con permisos.
- **Redis (Upstash)** para colas, límites y presencia.

Ver también: [[Blu AI - Gateway y Modelos]], [[Blu AI - Blu Chat]].