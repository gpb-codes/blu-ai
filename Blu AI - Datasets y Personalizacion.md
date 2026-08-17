---
tags:
  - blu
  - dataset
  - personalizacion
  - jsonl
  - fine-tuning
estado: pendiente
fase: Mes 2 - Producto
responsable: Gabriel
tipo: modulo
---

# Blu AI — Datasets y Personalización

> Cómo Blu junta señales de uso para personalizar respuestas por usuario y para entrenar/afinar los tiers propios (Blu Light / Flash / Ultra). Formato de almacenamiento: **JSONL, no JSON.**

## Qué es

Todo lo que Blu aprende de un usuario o de una conversación (preferencias, feedback, memoria persistente, ejemplos para fine-tuning) se registra como una serie de **eventos independientes**, uno por línea, en archivos `.jsonl`. No es un único documento JSON gigante que se reescribe — es un log append-only de registros pequeños.

Alimenta directamente:
- [[Blu AI - Memoria compartida]] (preferencias y contexto persistente por usuario/proyecto)
- [[Blu AI - Gateway y Modelos]] (datos de entrenamiento para el fine-tuning de Blu Light/Flash/Ultra, y señal para el clasificador del modo Auto)

## Por qué JSONL y no JSON

Un archivo `.json` tradicional es un único objeto o array: para agregar un registro hay que leer el archivo entero, parsearlo, insertar el nuevo dato y reescribirlo completo. Con miles de eventos por usuario llegando en paralelo (chat, feedback, agentes corriendo tareas), eso no escala y es frágil. JSONL (`.jsonl` / *JSON Lines*) resuelve esto:

- **Un registro JSON válido por línea** — se puede hacer `append` al archivo sin tocar lo que ya existe.
- **Corrupción acotada**: si un proceso se corta a la mitad de una escritura, se pierde como mucho la última línea, no el archivo completo.
- **Streaming-friendly**: se puede leer y procesar línea por línea sin cargar todo el archivo en memoria — clave cuando el dataset crece a millones de eventos.
- **Es el formato que ya piden las APIs de fine-tuning** (OpenAI, Anthropic, Together AI, Fireworks) — si el dataset ya está en JSONL, se sube directo, sin conversión.
- **Fácil de filtrar/particionar** con herramientas estándar de línea de comandos (`jq`, `grep`, `split`) por usuario, fecha o tipo de evento, sin herramientas especiales.

## Tipos de evento

Todos los eventos comparten un campo `event` (o `type`) que identifica qué son. Cuatro categorías cubren el sistema hoy:

| Categoría | Para qué sirve | Va a |
|---|---|---|
| `preference_update` | Preferencias explícitas del usuario (tono, idioma, formato de respuesta) | Memoria compartida |
| `feedback` | Señal implícita (thumbs up/down, edición de una respuesta, regeneración) | Modo Auto / dataset de fine-tuning |
| `memory_entry` | Contexto persistente para RAG (hechos sobre el usuario o el proyecto) | Memoria compartida |
| `finetune_example` | Ejemplo conversacional completo, curado para entrenar un tier propio | Fine-tuning Blu Light/Flash/Ultra |

## Ejemplos (JSONL)

Cada línea de abajo es un registro independiente y válido por sí solo — así se ven guardadas una tras otra en el mismo archivo `.jsonl`:

```jsonl
{"event": "preference_update", "user_id": "usr_8f2a1c", "field": "tono_respuesta", "value": "directo_sin_rodeos", "source": "chat", "timestamp": "2026-08-17T14:32:00Z"}
{"event": "feedback", "user_id": "usr_8f2a1c", "conversation_id": "conv_5521", "message_id": "msg_990", "rating": "thumbs_up", "model_used": "claude-sonnet", "timestamp": "2026-08-17T14:35:12Z"}
{"event": "memory_entry", "user_id": "usr_8f2a1c", "project_id": "proj_112", "content": "Prefiere que el código venga comentado en español.", "embedding_model": "text-embedding-3-large", "timestamp": "2026-08-17T14:40:00Z"}
{"event": "finetune_example", "messages": [{"role": "system", "content": "Eres Blu, un asistente directo y sin rodeos."}, {"role": "user", "content": "Resume este PR en 3 líneas."}, {"role": "assistant", "content": "1) Agrega auth JWT+refresh. 2) Cierra el gap de BYOK a medias. 3) No toca el frontend."}], "metadata": {"tier_objetivo": "Blu Flash", "fuente": "conversacion_real_anonimizada", "fecha": "2026-08-17"}}
```

Notar: cada línea es un objeto JSON válido y completo — se puede copiar una sola línea y parsearla sin las demás. Eso es lo que un `.json` normal no permite.

## Dónde viven los archivos (propuesta)

```
packages/memory/datasets/
  events/
    2026-08-17.jsonl        ← todos los eventos preference_update/feedback/memory_entry del día, todos los usuarios
  finetune/
    blu-flash-v1.jsonl      ← ejemplos curados para el próximo fine-tuning de un tier
```

Separar `events/` (log crudo, crece todos los días) de `finetune/` (subconjunto curado y revisado antes de mandarlo a entrenar) evita que datos de uso sin filtrar terminen directo en un fine-tuning.

## Cruce con cumplimiento y privacidad

Estos archivos van a contener datos de comportamiento de usuarios reales — hay que tratarlos con las mismas reglas que el resto de datos personales en [[Blu AI - Cumplimiento y Seguridad]]:

- `user_id` debe ser un identificador interno (no email/teléfono en crudo).
- Los eventos usados para `finetune_example` deben pasar por un paso de anonimización/revisión antes de salir del sistema (ej. si algún día se entrena vía un proveedor externo como Together/Fireworks, aplica la misma política de "DPA antes de mandar datos" que ya rige para proveedores de IA).
- Falta definir plazo de retención específico para `events/` (hoy el documento de cumplimiento no distingue este dataset de los demás datos de uso).

## Pendiente / decisiones abiertas

- Mecanismo de opt-out: si un usuario no quiere que su uso alimente fine-tuning, cómo se excluye.
- Quién revisa/cura `finetune/` antes de un entrenamiento (¿Gabriel solo, o requiere otro par de ojos?).
- Retención: por cuánto tiempo se guarda `events/` antes de comprimir/purgar.
- Si el volumen crece mucho, evaluar mover `events/` de archivos planos a un bucket (Cloudflare R2, ya elegido para storage — ver [[Blu AI - Cumplimiento y Seguridad]]) particionado por fecha, en vez de archivos locales.

Ver también: [[Blu AI - Memoria compartida]], [[Blu AI - Gateway y Modelos]], [[Blu AI - Cumplimiento y Seguridad]].
