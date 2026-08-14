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

# Blu AI â€” Blu Chat

> NÃºcleo de Blu. AquÃ­ vive la conversaciÃ³n, el razonamiento y la decisiÃ³n de quÃ© modelo usar.

## Capacidades del nÃºcleo

- Conversar y razonar
- Analizar documentos, imÃ¡genes y cÃ³digo
- Trabajar con proyectos (con permisos por rol: owner/admin/editor/viewer)
- Recordar contexto (sesiÃ³n + memoria de proyecto)
- Utilizar herramientas y ejecutar agentes
- Cambiar de modelo automÃ¡ticamente

## Model Router

El usuario no deberÃ­a preocuparse por quÃ© modelo usar. Blu decide segÃºn la tarea:

| PeticiÃ³n | DecisiÃ³n de Blu |
|----------|-----------------|
| "Analiza este cÃ³digo" | Claude â†’ razonamiento/cÃ³digo |
| "Genera una presentaciÃ³n" | Gemini/otro modelo â†’ contenido multimodal |
| "Haz una tarea pesada" | Kimi/Claude â†’ contexto largo |
| "Ejecuta esto localmente" | Ollama â†’ modelo local |

En la plataforma real esto se implementa como **modo Auto** dentro del [[Blu AI - Gateway y Modelos]]: un clasificador de tarea elige entre los tiers Blu Light/Flash/Ultra y los proveedores externos.

## Flujo del chat (nÃºcleo, segÃºn plan)

```
POST /v1/chat { userId, projectId, sessionId, tier|auto, agentId?, messages }
   â†’ Router de tier/modelo (modo Auto = clasificador de tarea)
   â†’ Carga de contexto: historial de sesiÃ³n + memoria de proyecto (RAG)
     + memoria de usuario + fecha/hora real
   â†’ Provider adapter (fallback si falla) â†’ streaming (SSE/WS) â†’ UI
   â†’ Costeo â†’ ai_usage â†’ contadores de cuota por plan
```

Ver tambiÃ©n: [[Blu AI - Memoria compartida]], [[Blu AI - Agentes]], [[Blu AI - Planes y monetizacion]].
