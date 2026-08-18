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

# Blu AI — Gateway y Modelos

> Corazón del diferenciador de Blu: un gateway multi-proveedor en lugar de un ecosistema cerrado.

## Qué es

Blu combina múltiples proveedores de IA bajo un solo gateway, con **tiers propios** y **modo Auto**.

- **Tiers propios (fine-tunes sobre modelos open-source):** Blu Light / Blu Flash / Blu Ultra
  - **Blu Light** → base **DeepSeek** (versión estándar)
  - **Blu Flash** → base **DeepSeek Pro**
  - **Blu Ultra** → base **Kimi K3** (Moonshot AI) — *sujeto a la advertencia de seguridad en [[Blu AI - Cumplimiento y Seguridad]]*
    - **Aviso al usuario:** al intentar usar este tier, Blu muestra una advertencia que indica que **no se compartirán los datos de usuario con el modelo** y que, si el usuario decide enviar datos sensibles por su cuenta, **la responsabilidad es exclusiva del propio usuario**.
- **Proveedores externos:** Claude (Anthropic), Gemini, GPT (OpenAI), OpenRouter, y otros vía adapters
- **BYOK:** el usuario puede conectar sus propias keys (encriptadas, AES-256-GCM)
- **Orquestación multiagente:** inspirado en proyectos tipo `opencodex` (proxy universal de proveedores), Blu permitirá sub-agentes en cualquier modelo/tier, control de superficie v1/v2 y *combos* (id virtual con failover/round-robin) para delegar tareas entre agentes — ver [[Blu AI - Agentes]].

## Adapters por proveedor

`Anthropic | Gemini | OpenAI | OpenRouter | fine-tunes (Together/Fireworks)`

Cada adapter habla con el provider correspondiente; si uno falla, hay **fallbacks por tier**.

## Modo Auto

Clasificador de tarea (tipo Gemini Flash o reglas + embedding similarity) que decide el modelo según:
- charla / código / investigación / agente
- calidad / velocidad / costo

El usuario nunca elige modelo manualmente salvo que quiera.

## Estado real (2026)

- Implementado en `packages/ai-gateway` con adapters reales (OpenAI/Anthropic/Gemini/OpenRouter) y BYOK.
- Fallbacks por tier y error `503 PROVIDER_NOT_CONFIGURED` legible.
- **78/78 tests pasando.**

Modelos propios: **fine-tuning de DeepSeek (Light/Flash) y Kimi K3 (Ultra)** sobre modelos open-source (no entrenamiento desde cero). El tier **Blu Ultra** (base Kimi K3) queda sujeto a la postura de seguridad de [[Blu AI - Cumplimiento y Seguridad]]: solo tareas sin datos personales y DPA pendiente de firma.

Ver también: [[Blu AI - Blu Chat]] (Model Router), [[Blu AI - Memoria compartida]].