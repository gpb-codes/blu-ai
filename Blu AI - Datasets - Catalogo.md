---
tags:
  - blu
  - dataset
  - jsonl
  - fine-tuning
estado: activo
fase: Mes 2 - Producto
responsable: Gabriel
tipo: datos
---

# Blu AI — Catálogo de Datasets

> Resumen de los 15 archivos JSONL en `datasets/`: qué cubre cada uno, qué formato usa y para qué sirve. Complementa [[Blu AI - Datasets y Personalizacion]].

## Formato

- **JSONL** — un objeto JSON válido por línea, append-only, compatible con las APIs de fine-tuning (OpenAI/Anthropic/Together/Fireworks).
- Tipos de evento usados: `finetune_example`, `preference_update`, `feedback`, `memory_entry`, `agent_run`, `device_event`, `search_event`, `permission_event`, `security_event`.
- `user_id` siempre es identificador interno (nunca email/teléfono), según [[Blu AI - Cumplimiento y Seguridad]].

## Archivos

| # | Archivo | Funcionalidad que cubre | Formato principal | Uso |
|---|---------|--------------------------|-------------------|-----|
| 01 | `01-chat-general.jsonl` | Núcleo de [[Blu AI - Blu Chat]]: tono de Blu, español, análisis de documentos, personalidad | `finetune_example` | Tono y estilo de respuesta del chat general |
| 02 | `02-model-router-auto.jsonl` | [[Blu AI - Gateway y Modelos]]: modo Auto, clasificador de tarea, fallbacks por tier, BYOK | `finetune_example` + `preference_update` + `feedback` | Entrenar el clasificador del modo Auto |
| 03 | `03-blu-code.jsonl` | [[Blu AI - Blu Code]]: edición web (Monaco/GitHub) y CLI local, debug, tests, commits, Docker/CI | `finetune_example` + `memory_entry` | Comportamiento del agente de código |
| 04 | `04-agentes.jsonl` | [[Blu AI - Agentes]]: Plan, Build, Cowork, Research, QA, Automation, Knowledge + orquestación multiagente | `finetune_example` + `agent_run` | Ejecución y delegación de agentes |
| 05 | `05-memoria-compartida.jsonl` | [[Blu AI - Memoria compartida]]: hechos de usuario/proyecto, recuperación RAG, continuidad entre modelos | `memory_entry` + `finetune_example` | Contexto persistente y respuestas con memoria |
| 06 | `06-skills-miniapps.jsonl` | [[Blu AI - Skills y mini-apps]]: generación de mini-apps (checklist, tracker), skills (excel, powerpoint, docker, github), plugins | `finetune_example` | Generación de mini-apps e invocación de skills |
| 07 | `07-web-extension.jsonl` | [[Blu AI - Web y Extension Chrome]]: panel web, side panel MV3, notas rápidas, BYOK desde el panel | `finetune_example` + `preference_update` | Respuestas en web y extensión |
| 08 | `08-multidispositivo.jsonl` | Continuidad PC → teléfono → navegador → CLI: sincronización de sesiones y presencia | `finetune_example` + `device_event` | Continuidad de sesión entre dispositivos |
| 09 | `09-voz-stt-tts.jsonl` | Voz: transcripción de notas (Whisper/Groq), lectura de respuestas (ElevenLabs), reuniones | `finetune_example` + `feedback` + `preference_update` | Flujos de voz STT/TTS (V1, sin voz en tiempo real) |
| 10 | `10-busqueda-web.jsonl` | Búsqueda web con DuckDuckGo Lite/Tavily: respuestas con fuentes y citas | `finetune_example` + `search_event` | Respuestas de investigación con búsqueda |
| 11 | `11-planes-suscripcion.jsonl` | [[Blu AI - Planes y monetizacion]]: Gratis/BYOK/Créditos, soft caps, Stripe, soporte de billing | `finetune_example` + `preference_update` + `feedback` | Conversaciones de planes y facturación |
| 12 | `12-colaboracion-permisos.jsonl` | Proyectos compartidos: roles owner/admin/editor/viewer, aislamiento, transferencia de propiedad | `finetune_example` + `permission_event` | Colaboración y permisos por rol |
| 13 | `13-seguridad-privacidad.jsonl` | [[Blu AI - Cumplimiento y Seguridad]]: aviso Blu Ultra/Kimi, cuentas supervisadas 13-17, borrado de datos, opt-out, EU AI Act | `finetune_example` + `security_event` | Respuestas de privacidad y cumplimiento |
| 14 | `14-feedback-eventos.jsonl` | Log crudo de uso: thumbs up/down, regeneración, edición, preferencias por usuario | `feedback` + `preference_update` | Señal para el clasificador del modo Auto y datasets de fine-tuning |
| 15 | `15-finetune-tiers.jsonl` | Ejemplos curados por tier propio: Blu Light (DeepSeek), Blu Flash (DeepSeek Pro), Blu Ultra (Kimi K3, sin datos personales) | `finetune_example` | Entrenamiento/afinado de los tiers propios |

## Agrupación

- **Funcional (01–13):** ejemplos de conversación y eventos por módulo — sirven para personalizar respuestas y como base curada.
- **Sistema (14–15):** `14-feedback-eventos.jsonl` es el log crudo de señales de uso; `15-finetune-tiers.jsonl` es el subconjunto curado y revisado antes de mandar a entrenar un tier (equivalente a `finetune/` de [[Blu AI - Datasets y Personalizacion]]).

## Notas de cumplimiento

- Los `finetune_example` deben pasar por anonimización/revisión antes de cualquier entrenamiento externo (Together/Fireworks).
- El tier Blu Ultra (Kimi K3) queda limitado a tareas sin datos personales en todos los datasets.
- Mecanismo de opt-out: los eventos de usuarios excluidos no deben aparecer en los archivos de sistema (14-15).