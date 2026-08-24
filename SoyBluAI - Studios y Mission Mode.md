---
tags:
  - soybluia
  - studios
  - mission-mode
  - vision
estado: planificacion
fase: Meses 4-6 (Mission Mode y Studios base) / Roadmap (Studios avanzados)
responsable: equipo
tipo: modulo
actualizacion: 24-ago-2026
---

# SoyBluAI — Studios, AI Workspace y Mission Mode

> Nota nueva (24-ago-2026), creada al integrar la visión de evolución de SoyBluAI hacia un **AI Work Operating System**. No reemplaza ninguna nota existente: agrupa la organización de superficie de producto (Workspace + Studios) y el modo de ejecución de objetivos complejos (Mission Mode) que hoy no estaban documentados. Ver auditoría completa en [[SoyBluAI - Decisiones (ADRs)]] y clasificación de roadmap en [[SoyBluAI - Roadmap y estado]].

## 0. Qué ya existía vs. qué es nuevo

SoyBluAI ya es, en la visión documentada ([[SoyBluAI - Vision]]), mucho más que un chat: agentes ([[SoyBluAI - Agentes]]), SoyBluAI Code ([[SoyBluAI - Code]]), memoria compartida ([[SoyBluAI - Memoria compartida]]), gateway multi-modelo ([[SoyBluAI - Gateway y Modelos]]) y un sistema de Skills/mini-apps ([[SoyBluAI - Skills y mini-apps]]). Lo que **no existía** en el vault era:

1. Una organización explícita de esa superficie como **AI Workspace** (un lugar central: Chat, Agents, Projects, Code, Research, Creative, Workflows, Automations, Assets, Memory, Integrations, SOUP Lab).
2. El concepto de **Studios** especializados (Creative, Development, Research, Agent, Workflow).
3. **Mission Mode**: descomponer un objetivo complejo en tareas ejecutadas por varios agentes, con supervisión humana.

Todo esto se documenta aquí como 🔵 **NUEVO**, salvo donde se indica que ya hay una base construida.

## 1. AI Workspace

Experiencia centralizada. Mapeo contra lo ya documentado:

| Sección del Workspace | Estado | Nota existente |
|---|---|---|
| Chat | 🟢 Existente | [[SoyBluAI - Chat]] — núcleo conversacional y Model Router |
| Agents | 🟡 Existe, requiere ampliación | [[SoyBluAI - Agentes]] documenta 7 agentes fijos (Plan/Build/Cowork/Research/QA/Automation/Knowledge); falta el framework de creación de agentes propios — ver [[SoyBluAI - Agent Builder y Marketplace]] |
| Projects | 🟢 Existente | [[SoyBluAI - Planes y monetizacion]] (permisos owner/admin/editor/viewer) + [[SoyBluAI - Memoria compartida]] (memoria por proyecto) |
| Code | 🟢 Existente | [[SoyBluAI - Code]] |
| Research | 🟡 Parcial | Agente "Research" ya definido en [[SoyBluAI - Agentes]] y búsqueda web (DuckDuckGo Lite/Tavily) ya en el stack ([[SoyBluAI - Stack tecnologico]]), pero no hay un espacio de investigación estructurado (fuentes, cross-check, informe) — ver sección 4 |
| Creative | 🔵 Nuevo (parcial) | Hoy solo existe generación de imágenes FLUX (Cloudflare) para mini-apps y voz STT/TTS ([[SoyBluAI - Stack tecnologico]]); no hay Creative Studio como tal — ver sección 3 |
| Workflows | 🔵 Nuevo | Ver [[SoyBluAI - Workflow Builder y Automatizacion]] |
| Automations | 🟡 Parcial | Agente "Automation" ya nombrado en [[SoyBluAI - Agentes]] sin diseño propio — ver [[SoyBluAI - Workflow Builder y Automatizacion]] |
| Assets | 🔵 Nuevo | Ver [[SoyBluAI - Conectores, MCP y Assets]] |
| Memory | 🟡 Existe, requiere evolución | [[SoyBluAI - Memoria compartida]] — ver Memory 2.0 en esa misma nota (actualizada 24-ago-2026) |
| Integrations | 🟡 Parcial | Sección "Plugins" de [[SoyBluAI - Skills y mini-apps]] (Slack, Notion, Discord, Jira) — ver [[SoyBluAI - Conectores, MCP y Assets]] |
| SOUP Lab | 🔴 Conflicto a resolver | Ver [[SoyBluAI - SOUP y AI Core]] y [[SoyBluAI - Decisiones (ADRs)|ADR-001]] |

**Decisión de alcance:** el AI Workspace no es una superficie nueva a construir desde cero — es la reorganización de navegación de lo que ya está en el roadmap (SoyBluAI Chat, Agentes, SoyBluAI Code, Memoria, Skills) más los módulos nuevos de esta ronda. Se documenta como ⚪ **ROADMAP** de UI/IA de producto para Meses 4-6 en adelante, no como tarea de V1 (que sigue siendo Mes 1-3, ver [[SoyBluAI - Roadmap y estado]]).

## 2. Studios especializados

Adaptación del concepto a la arquitectura de SoyBluAI (no se copia literal de otros productos, según se pidió):

- **Development Studio** = evolución de [[SoyBluAI - Code]] (Editor, Terminal, Git, GitHub, Debugging, Testing, Code Review, Refactoring, Dependencies, Deploy, Agent Coding, Multi-Agent Development). 🟡 SoyBluAI Code ya cubre editor, terminal, git/GitHub, debugger, tests, Docker, CI/CD, deploy, browser ([[SoyBluAI - Code]]); faltan Code Review y Multi-Agent Development como flujos explícitos — se agregan como extensión, sin tocar la nota original.
- **Creative Studio** — ver sección 3 (🔵 nuevo, con bases parciales).
- **Research Studio** — ver sección 4 (🟡 parcial).
- **Agent Studio** = Agent Builder (Create/Configure/Test) — ver [[SoyBluAI - Agent Builder y Marketplace]] (🔵 nuevo).
- **Workflow Studio** = Workflow Builder (Build/Test/Deploy) — ver [[SoyBluAI - Workflow Builder y Automatizacion]] (🔵 nuevo).

Todos los Studios comparten memoria y gateway ([[SoyBluAI - Memoria compartida]], [[SoyBluAI - Gateway y Modelos]]), igual que los agentes existentes.

## 3. Creative Studio y Design Agent

🔵 Nuevo. Base parcial ya construida: generación de imágenes vía **FLUX (Cloudflare)** para mini-apps y voz (STT Whisper/Groq, TTS ElevenLabs) — ambos en [[SoyBluAI - Stack tecnologico]].

Capacidades a incorporar (clasificadas, no todas para V1):

| Área | Capacidades | Estado |
|---|---|---|
| Imagen | Text/Image to Image, edición, quitar fondo, upscaling, variaciones, múltiples referencias | 🔵 Nuevo — hoy solo hay generación FLUX básica |
| Video | Text/Image to Video, edición, clipping, storyboards | 🔵 Nuevo, sin base |
| Audio | TTS/STT ya existen (ElevenLabs/Whisper); voice generation y procesamiento de audio avanzado | 🟡 Parcial |
| Diseño | Logos, UI, landing pages, social media, presentaciones, branding | 🔵 Nuevo |

**Design Agent** (flujo Idea → Brief → Brand → Wireframe → UI → Assets → Frontend → QA): 🔵 nuevo, debe usar la memoria de proyecto para mantener coherencia visual (reutiliza [[SoyBluAI - Memoria compartida]], no crea un sistema de memoria aparte). Se documenta como ⚪ **ROADMAP P1**, no bloqueante para el lanzamiento V1 (Mes 3).

## 4. Research Studio

🟡 Parcial: el agente **Research** ya existe en [[SoyBluAI - Agentes]] y la búsqueda web con fuentes/citas ya está en el roadmap de datasets (`10-busqueda-web.jsonl`, ver [[SoyBluAI - Datasets - Catalogo]]). Falta estructurar el flujo completo:

```
Pregunta → Web → Documentos → Fuentes → Análisis → Cross-check → Informe
```

Capacidades a formalizar: investigación web, análisis documental, informes, comparativas, resúmenes, bibliografía, verificación de información. Se integra con Knowledge Hub — ver Memory 2.0 en [[SoyBluAI - Memoria compartida]].

## 5. App Builder

🔵 Nuevo. Flujo: Idea → Requirements → Architecture → Database → Backend → Frontend → Testing → Deployment. Se integra conceptualmente con SoyBluAI Code, GitHub, Agentes y Workflows — es una aplicación **compuesta** de piezas que ya existen o están en roadmap (SoyBluAI Code para código, Agentes para orquestación, Workflow Builder para pipeline de build/test/deploy), no un sistema aparte. Clasificado ⚪ **ROADMAP P1**.

## 6. Mission Mode

🔵 Nuevo, sin equivalente documentado. El usuario da un objetivo complejo ("Construye una tienda online") y SoyBluAI lo descompone:

```
Objetivo
   ↓
Planning
   ↓
Research · Design · Code · QA (en paralelo o secuencia, vía Agentes existentes)
   ↓
Deploy
```

Requiere **supervisión humana** en los puntos críticos — reutiliza el mecanismo de Human-in-the-loop de [[SoyBluAI - Workflow Builder y Automatizacion]], no un sistema de aprobación aparte. Mission Mode es, en esencia, un **orquestador de alto nivel sobre Agentes + Workflow Builder + Studios** ya descritos — no introduce infraestructura nueva más allá de esa capa de planificación.

Clasificación: ⚪ **ROADMAP**, depende de que Agent Builder y Workflow Builder existan primero (P0 → habilita Mission Mode en P1/P2).

## 7. Prioridad y dependencias

Mission Mode y los Studios avanzados (Creative, Research, App Builder) dependen de que existan primero: Agent Builder, Workflow Builder, Memory 2.0 y Permission System (todos en [[SoyBluAI - Roadmap y estado]], bloque P0). No se recomienda empezar Studios/Mission Mode antes de cerrar esa base — ver riesgo de alcance en [[SoyBluAI - Decisiones (ADRs)]].

---

Relacionado: [[SoyBluAI - Vision]] · [[SoyBluAI - Agent Builder y Marketplace]] · [[SoyBluAI - Workflow Builder y Automatizacion]] · [[SoyBluAI - SOUP y AI Core]] · [[SoyBluAI - Conectores, MCP y Assets]] · [[SoyBluAI - Roadmap y estado]] · [[SoyBluAI - Decisiones (ADRs)]]
