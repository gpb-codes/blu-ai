---
tags:
  - blu
  - chat
  - router
estado: activo
fase: Mes 1 - Base
responsable: Gabriel
tipo: modulo
---

# Blu AI — Blu Chat

> Núcleo de Blu. Aquí vive la conversación, el razonamiento y la decisión de qué modelo usar.

## Capacidades del núcleo

- Conversar y razonar
- Analizar documentos, imágenes y código
- Trabajar con proyectos (con permisos por rol: owner/admin/editor/viewer)
- Recordar contexto (sesión + memoria de proyecto)
- Utilizar herramientas y ejecutar agentes
- Cambiar de modelo automáticamente

## Model Router

El usuario no debería preocuparse por qué modelo usar. Blu decide según la tarea:

| Petición | Decisión de Blu |
|----------|-----------------|
| "Analiza este código" | Claude → razonamiento/código |
| "Genera una presentación" | Gemini/otro modelo → contenido multimodal |
| "Haz una tarea pesada / contexto largo" | Claude u otro proveedor del tier, según el clasificador |

> Nota (18-ago-2026): la tabla de arriba refleja proveedores ya implementados (Anthropic/Gemini/OpenAI/OpenRouter, ver [[Blu AI - Gateway y Modelos]]). **Blu Ultra usa Kimi K3 (Moonshot AI) como base** — definido el 18-ago-2026 — y, por postura de seguridad ([[Blu AI - Cumplimiento y Seguridad]]), queda limitado a tareas sin datos personales y excluido del modo Auto por defecto. Blu Light/Flash usan DeepSeek (estándar / Pro). Ejecutar modelos localmente vía Ollama fue descartado (ver [[Blu AI - Bitacora]]).

En la plataforma real esto se implementa como **modo Auto** dentro del [[Blu AI - Gateway y Modelos]]: un clasificador de tarea elige entre los tiers Blu Light/Flash/Ultra y los proveedores externos.

## Flujo del chat (núcleo, según plan)

```
POST /v1/chat { userId, projectId, sessionId, tier|auto, agentId?, messages }
   → Router de tier/modelo (modo Auto = clasificador de tarea)
   → Carga de contexto: historial de sesión + memoria de proyecto (RAG)
     + memoria de usuario + fecha/hora real
   → Provider adapter (fallback si falla) → streaming (SSE/WS) → UI
   → Costeo → ai_usage → contadores de cuota por plan
```

Ver también: [[Blu AI - Memoria compartida]], [[Blu AI - Agentes]], [[Blu AI - Planes y monetizacion]].