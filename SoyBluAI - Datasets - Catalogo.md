---
tags:
  - soybluia
  - dataset
  - jsonl
  - fine-tuning
estado: activo
fase: Mes 2 - Producto
responsable: Gabriel
tipo: datos
---

# SoyBluAI — Catálogo de Datasets

> Resumen de los 15 archivos JSONL en `datasets/`: qué cubre cada uno, qué formato usa y para qué sirve. Complementa [[SoyBluAI - Datasets y Personalizacion]].

## Voz y tono de SoyBluAI

> La personalidad de SoyBluAI se define como **Jarvis con la seriedad de FRIDAY y la productividad de E.V. y EDITH**. Aplicada a todos los `finetune_example` de los datasets.

| Rasgo | De quién viene | Cómo se ve en las respuestas |
|-------|----------------|------------------------------|
| Ingenio seco y calma | JARVIS | Humor medido, nunca payaso; frases como *"los errores de deploy tienen causa, no destino"* |
| Anticipación | JARVIS | Ofrece el siguiente paso útil antes de que lo pida; recuerda lo guardado en memoria |
| Seriedad y profesionalismo | FRIDAY | Cero rodeos, cero relleno, cero drama; los problemas se informan con solución |
| Productividad y precisión | E.V. / EDITH | Respuestas accionables, datos exactos, estructura; nunca teoría sin aplicación |

**Reglas del tono (codificadas en los system prompts de los datasets):**

1. Español neutro, directo, sin intro ni despedida.
2. Ingenio con moderación: como máximo una frase de humor por respuesta, y solo si no resta seriedad.
3. Resultados antes que explicaciones: primero el dato o la acción, después el contexto si hace falta.
4. Honestidad firme: si algo no está listo, no se promete ("prefiero perder un lead a ganar una promesa rota").
5. Si no sabe algo, lo dice y ofrece alternativa. Nunca inventa.
6. Seguridad y privacidad se comunican con firmeza, no negociable.
7. Variación por tier: **SoyBluAI Light** más breve y con más ingenio; **SoyBluAI Flash** equilibrado (predeterminado); **SoyBluAI Ultra** serio, profundo, sin adornos.

## Formato

- **JSONL** — un objeto JSON válido por línea, append-only, compatible con las APIs de fine-tuning (OpenAI/Anthropic/Together/Fireworks).
- Tipos de evento usados: `finetune_example`, `preference_update`, `feedback`, `memory_entry`, `agent_run`, `device_event`, `search_event`, `permission_event`, `security_event`.
- `user_id` siempre es identificador interno (nunca email/teléfono), según [[SoyBluAI - Cumplimiento y Seguridad]].

## Archivos

| # | Archivo | Funcionalidad que cubre | Formato principal | Uso |
|---|---------|--------------------------|-------------------|-----|
| 01 | `01-chat-general.jsonl` | Núcleo de [[SoyBluAI - Chat]]: tono de SoyBluAI, español, análisis de documentos, personalidad | `finetune_example` | Tono y estilo de respuesta del chat general |
| 02 | `02-model-router-auto.jsonl` | [[SoyBluAI - Gateway y Modelos]]: modo Auto, clasificador de tarea, fallbacks por tier, BYOK | `finetune_example` + `preference_update` + `feedback` | Entrenar el clasificador del modo Auto |
| 03 | `03-blu-code.jsonl` | [[SoyBluAI - Code]]: edición web (Monaco/GitHub) y CLI local, debug, tests, commits, Docker/CI | `finetune_example` + `memory_entry` | Comportamiento del agente de código |
| 04 | `04-agentes.jsonl` | [[SoyBluAI - Agentes]]: Plan, Build, Cowork, Research, QA, Automation, Knowledge + orquestación multiagente | `finetune_example` + `agent_run` | Ejecución y delegación de agentes |
| 05 | `05-memoria-compartida.jsonl` | [[SoyBluAI - Memoria compartida]]: hechos de usuario/proyecto, recuperación RAG, continuidad entre modelos | `memory_entry` + `finetune_example` | Contexto persistente y respuestas con memoria |
| 06 | `06-skills-miniapps.jsonl` | [[SoyBluAI - Skills y mini-apps]]: generación de mini-apps (checklist, tracker), skills (excel, powerpoint, docker, github), plugins | `finetune_example` | Generación de mini-apps e invocación de skills |
| 07 | `07-web-extension.jsonl` | [[SoyBluAI - Web y Extension Chrome]]: panel web, side panel MV3, notas rápidas, BYOK desde el panel | `finetune_example` + `preference_update` | Respuestas en web y extensión |
| 08 | `08-multidispositivo.jsonl` | Continuidad PC → teléfono → navegador → CLI: sincronización de sesiones y presencia | `finetune_example` + `device_event` | Continuidad de sesión entre dispositivos |
| 09 | `09-voz-stt-tts.jsonl` | Voz: transcripción de notas (Whisper/Groq), lectura de respuestas (ElevenLabs), reuniones | `finetune_example` + `feedback` + `preference_update` | Flujos de voz STT/TTS (V1, sin voz en tiempo real) |
| 10 | `10-busqueda-web.jsonl` | Búsqueda web con DuckDuckGo Lite/Tavily: respuestas con fuentes y citas | `finetune_example` + `search_event` | Respuestas de investigación con búsqueda |
| 11 | `11-planes-suscripcion.jsonl` | [[SoyBluAI - Planes y monetizacion]]: Gratis/BYOK/Créditos, soft caps, Stripe, soporte de billing | `finetune_example` + `preference_update` + `feedback` | Conversaciones de planes y facturación |
| 12 | `12-colaboracion-permisos.jsonl` | Proyectos compartidos: roles owner/admin/editor/viewer, aislamiento, transferencia de propiedad | `finetune_example` + `permission_event` | Colaboración y permisos por rol |
| 13 | `13-seguridad-privacidad.jsonl` | [[SoyBluAI - Cumplimiento y Seguridad]]: aviso SoyBluAI Ultra/Kimi, cuentas supervisadas 13-17, borrado de datos, opt-out, EU AI Act | `finetune_example` + `security_event` | Respuestas de privacidad y cumplimiento |
| 14 | `14-feedback-eventos.jsonl` | Log crudo de uso: thumbs up/down, regeneración, edición, preferencias por usuario | `feedback` + `preference_update` | Señal para el clasificador del modo Auto y datasets de fine-tuning |
| 15 | `15-finetune-tiers.jsonl` | Ejemplos curados por tier propio: SoyBluAI Light (DeepSeek), SoyBluAI Flash (DeepSeek Pro), SoyBluAI Ultra (Kimi K3, sin datos personales) | `finetune_example` | Entrenamiento/afinado de los tiers propios |

## Agrupación

- **Funcional (01–13):** ejemplos de conversación y eventos por módulo — sirven para personalizar respuestas y como base curada.
- **Sistema (14–15):** `14-feedback-eventos.jsonl` es el log crudo de señales de uso; `15-finetune-tiers.jsonl` es el subconjunto curado y revisado antes de mandar a entrenar un tier (equivalente a `finetune/` de [[SoyBluAI - Datasets y Personalizacion]]).

## Notas de cumplimiento

- Los `finetune_example` deben pasar por anonimización/revisión antes de cualquier entrenamiento externo (Together/Fireworks).
- El tier SoyBluAI Ultra (Kimi K3) queda limitado a tareas sin datos personales en todos los datasets.
- Mecanismo de opt-out: los eventos de usuarios excluidos no deben aparecer en los archivos de sistema (14-15).