---
tags:
  - soybluia
  - gateway
  - models
estado: funcional
fase: Mes 1 - Base
progreso: 90
responsable: Gabriel
tipo: modulo
actualizacion: 24-ago-2026
---

# SoyBluAI — Gateway y Modelos

> Corazón del diferenciador de SoyBluAI: un gateway multi-proveedor en lugar de un ecosistema cerrado.
>
> **Actualización 24-ago-2026:** este gateway es, conceptualmente, el **AI Core** de la nueva visión de producto (SOUP + GPT + Claude + Gemini + Kimi + Local Models bajo un mismo núcleo). No cambia la arquitectura ya implementada — ver el encuadre completo, incluyendo dos contradicciones sin resolver (SOUP vs. homelab descartado, y modelos locales vs. Ollama descartado), en [[SoyBluAI - SOUP y AI Core]].

## Qué es

SoyBluAI combina múltiples proveedores de IA bajo un solo gateway, con **tiers propios** y **modo Auto**.

- **Tiers propios (fine-tunes sobre modelos open-source):** SoyBluAI Light / SoyBluAI Flash / SoyBluAI Ultra
  - **SoyBluAI Light** → base **DeepSeek** (versión estándar)
  - **SoyBluAI Flash** → base **DeepSeek Pro**
  - **SoyBluAI Ultra** → base **Kimi K3** (Moonshot AI) — *sujeto a la advertencia de seguridad en [[SoyBluAI - Cumplimiento y Seguridad]]*
    - **Aviso al usuario:** al intentar usar este tier, SoyBluAI muestra una advertencia que indica que **no se compartirán los datos de usuario con el modelo** y que, si el usuario decide enviar datos sensibles por su cuenta, **la responsabilidad es exclusiva del propio usuario**.
- **Proveedores externos:** Claude (Anthropic), Gemini, GPT (OpenAI), OpenRouter, y otros vía adapters
- **BYOK:** el usuario puede conectar sus propias keys (encriptadas, AES-256-GCM)
- **Orquestación multiagente:** inspirado en proyectos tipo `opencodex` (proxy universal de proveedores), SoyBluAI permitirá sub-agentes en cualquier modelo/tier, control de superficie v1/v2 y *combos* (id virtual con failover/round-robin) para delegar tareas entre agentes — ver [[SoyBluAI - Agentes]].

## Adapters por proveedor

`Anthropic | Gemini | OpenAI | OpenRouter | fine-tunes (Together/Fireworks)`

Cada adapter habla con el provider correspondiente; si uno falla, hay **fallbacks por tier**.

## Modo Auto

Clasificador de tarea (tipo Gemini Flash o reglas + embedding similarity) que decide el modelo según:
- charla / código / investigación / agente
- calidad / velocidad / costo

El usuario nunca elige modelo manualmente salvo que quiera.

**Criterios ampliados (24-ago-2026, 🟡 actualización pendiente de implementar):** además de calidad/velocidad/costo, el Model Router debe considerar context window, capabilities (multimodal, tool use), tool support, disponibilidad, privacidad (ej. excluir SoyBluAI Ultra/Kimi de flujos con datos personales, ya vigente vía [[SoyBluAI - Cumplimiento y Seguridad]]) y cost limits por usuario/proyecto (reutiliza los soft caps ya definidos en [[SoyBluAI - Planes y monetizacion]]). No cambia el clasificador ya implementado, amplía sus señales de entrada.

## Estado real (2026)

- Implementado en `packages/ai-gateway` con adapters reales (OpenAI/Anthropic/Gemini/OpenRouter) y BYOK.
- Fallbacks por tier y error `503 PROVIDER_NOT_CONFIGURED` legible.
- **78/78 tests pasando.**

Modelos propios: **fine-tuning de DeepSeek (Light/Flash) y Kimi K3 (Ultra)** sobre modelos open-source (no entrenamiento desde cero). El tier **SoyBluAI Ultra** (base Kimi K3) queda sujeto a la postura de seguridad de [[SoyBluAI - Cumplimiento y Seguridad]]: solo tareas sin datos personales y DPA pendiente de firma.

Ver también: [[SoyBluAI - Chat]] (Model Router), [[SoyBluAI - Memoria compartida]].