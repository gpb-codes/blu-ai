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

# Blu AI â€” Memoria compartida

> El diferenciador estratÃ©gico: memoria unificada entre todos los modelos y dispositivos.

## Idea

No es solo memoria de conversaciones. Es una **memoria compartida** que permite:

- Empezar algo con Claude y continuar con Kimi sin perder contexto.
- Trabajar desde PC â†’ telÃ©fono â†’ navegador â†’ VS Code sin perder el hilo.
- RecuperaciÃ³n inteligente (RAG) independientemente del modelo usado.

## DiseÃ±o

```
                    Blu Memory
                        â”‚
       â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
       â–¼                â–¼                â–¼
   Proyectos          Usuario         Trabajo
       â”‚                â”‚                â”‚
       â–¼                â–¼                â–¼
    GitHub           Preferencias      Docs
       â”‚                â”‚                â”‚
       â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                        â–¼
                  Shared Context
                        â”‚
          â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
          â–¼             â–¼             â–¼
       Claude         Gemini         Kimi
```

## ImplementaciÃ³n real

- **Vault de notas del proyecto** estilo *second brain* (tipo Obsidian): wikilinks, tags, backlinks, grafo y **RAG**.
- PostgreSQL (Neon) con **pgvector** para recuperaciÃ³n semÃ¡ntica. âš ï¸ En revisiÃ³n: Cloudflare D1 + Vectorize (bitÃ¡cora 28-jul, ver [[Blu AI - Stack tecnologico]]).
- Memoria por usuario (`user_memory`) + memoria de proyecto compartida con permisos.
- **Redis (Upstash)** para colas, lÃ­mites y presencia.

Ver tambiÃ©n: [[Blu AI - Gateway y Modelos]], [[Blu AI - Blu Chat]].
