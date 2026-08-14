---
tags:
  - blu
  - gateway
  - models
estado: funcional
fase: Mes 1 - Base
progreso: 90
responsable: Gabriel
tipo: modulo
---

# Blu AI â€” Gateway y Modelos

> CorazÃ³n del diferenciador de Blu: un gateway multi-proveedor en lugar de un ecosistema cerrado.

## QuÃ© es

Blu combina mÃºltiples proveedores de IA bajo un solo gateway, con **tiers propios** y **modo Auto**.

- **Tiers propios (fine-tunes de open-source):** Blu Light / Blu Flash / Blu Ultra
- **Proveedores externos:** Claude (Anthropic), Gemini, GPT (OpenAI), OpenRouter, y otros vÃ­a adapters
- **BYOK:** el usuario puede conectar sus propias keys (encriptadas, AES-256-GCM)

## Adapters por proveedor

`Anthropic | Gemini | OpenAI | OpenRouter | fine-tunes (Together/Fireworks)`

Cada adapter habla con el provider correspondiente; si uno falla, hay **fallbacks por tier**.

## Modo Auto

Clasificador de tarea (tipo Gemini Flash o reglas + embedding similarity) que decide el modelo segÃºn:
- charla / cÃ³digo / investigaciÃ³n / agente
- calidad / velocidad / costo

El usuario nunca elige modelo manualmente salvo que quiera.

## Estado real (2026)

- Implementado en `packages/ai-gateway` con adapters reales (OpenAI/Anthropic/Gemini/OpenRouter) y BYOK.
- Fallbacks por tier y error `503 PROVIDER_NOT_CONFIGURED` legible.
- **78/78 tests pasando.**

Modelos propios: **fine-tuning de Qwen/Llama** (no entrenamiento desde cero).

Ver tambiÃ©n: [[Blu AI - Blu Chat]] (Model Router), [[Blu AI - Memoria compartida]].
