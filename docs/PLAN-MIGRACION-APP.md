# Plan de Migración: BLU de Bot WhatsApp a Plataforma

> Estado: DRAFT v2 — actualizado 04-ago-2026 según la especificación de producto completa.
> Deja de ser una "app de chat" y se convierte en **plataforma de IA con agentes, proyectos
> colaborativos, Blu Code y memoria compartida**. El bot de WhatsApp se descontinúa
> (prohibición de Meta a asistentes de propósito general vía WA Business API desde 15-ene-2026).

---

## 1. Visión del producto (según especificación)

- **IA multi-modelo**: modelos propios **Blu Light / Blu Flash / Blu Ultra** + Claude, Gemini, GPT y futuros. **Modo Auto**: elige el modelo según la tarea (calidad/velocidad/costo).
- **Memoria compartida**: unificada entre todos los modelos; historial y contexto compartidos; recuperación inteligente (RAG) sin importar el modelo.
- **Multidispositivo**: Web, Windows, macOS, Android, iOS en tiempo real + **extensión Chrome**.
- **Productividad**: asistencia tipo Claude Code/Cursor; **chat multiusuario con memoria compartida real** (proyectos con permisos, cada persona con su agente/sesión, cada quien paga su uso).
- **Agentes**: Plan, Build, Cowork, Research, QA, Automation, Knowledge.
- **Blu Code**: editar código y commitear desde la web (GitHub conectado); **Blu Code Local**: CLI/daemon en la máquina del usuario.
- **Proyectos interactivos**: mini-apps (calendario, checklist, tracker) generadas dentro del chat, guardadas en la barra lateral, personalizables — base del futuro sistema de Skills.
- **Planes**: Gratis (embudo), BYOK $10/mes (keys propias), Créditos $30/mes (soft caps por modelo).
- **Enterprise**: visión futura (estudiantes/trabajadores), no V1.
- **WhatsApp: FUERA** — prohibido por Meta (política 15-ene-2026); reapertura solo UE/BR con tarifas que rompen la economía del plan.

---

## 2. Decisiones tomadas

| Tema | Decisión |
|---|---|
| Producto | Plataforma SaaS: Web + Windows + macOS + Android + iOS + extensión Chrome |
| Frontend principal | **Flutter** (móvil + desktop) — una base de código para 4 plataformas |
| Web | **Next.js 15** (landing, pricing, login web, panel admin) + **Chrome extension (MV3)** |
| Backend | **NestJS + TypeScript**, monorepo pnpm + turborepo |
| Datos | **PostgreSQL** (Neon, con pgvector para RAG) + **Redis** (Upstash) |
| IA | Gateway propio multi-proveedor; tiers Blu Light/Flash/Ultra + Claude/Gemini/GPT + modo Auto |
| Modelos propios | **Fine-tuning de open-source (Qwen/Llama)** — no entrenamiento desde cero |
| Autenticación | Email+contraseña, Google (Gmail) y teléfono (SMS o WhatsApp OTP) |
| Monetización | Freemium: Gratis / BYOK $10 / Créditos $30 (Stripe) |
| Colaboración | Proyectos con permisos (owner/admin/editor/viewer), memoria compartida por proyecto, cobro por usuario |
| V1 | Sin Enterprise, sin voz en tiempo real; con voz en notas (STT) y TTS de respuestas |

---

## 3. Arquitectura objetivo

```
┌────────────────────────────── CLIENTS ──────────────────────────────────┐
│ Flutter (Android/iOS/Win/macOS)   Next.js web   Chrome ext (MV3)         │
│        Blu Code Local (CLI/daemon, solo módulo avanzado)                 │
└───────┬───────────────┬──────────────────┬───────────────┬──────────────┘
        │ HTTPS/WS      │ HTTPS/WS         │ HTTPS         │ WS/HTTPS
┌───────▼───────────────▼──────────────────▼───────────────▼──────────────┐
│                              API Gateway (NestJS)                        │
│  auth │ users │ proyectos │ permisos │ chat │ agentes │ memoria │ billing│
│  blu-code │ mini-apps │ voz │ imágenes │ agenda │ BYOK │ créditos        │
└──────┬───────────────┬──────────────────┬───────────────┬───────────────┘
       │               │                  │               │
┌──────▼─────┐  ┌──────▼───────┐  ┌───────▼────────┐  ┌───▼────────────────┐
│ PostgreSQL │  │ Redis        │  │ AI Gateway     │  │ Proveedores        │
│ + pgvector │  │ colas/limits │  │ (tiers + Auto) │  │ Anthropic│Gemini   │
│ + S3 (files)│  │             │  │ agentes        │  │ OpenAI│OpenRouter │
└────────────┘  └──────────────┘  │ fine-tunes Blu │  │ Cloudflare│Composio│
                                  └───────┬────────┘  │ Stripe│GitHub      │
                                          │ BYOK user keys (encriptadas)   │
                                          ▼                                │
                                     Provider adapters ────────────────────┘
```

### Flujo del chat (núcleo)

```
POST /v1/chat { userId, projectId, sessionId, tier|auto, agentId?, messages }
   → Router de tier/modelo (modo Auto = clasificador de tarea → modelo)
   → Carga de contexto: historial de sesión + memoria de proyecto (RAG pgvector)
     + memoria de usuario + fecha/hora real
   → Provider adapter (fallback si falla) → streaming (SSE/WS) → UI
   → Costeo → ai_usage → contadores de cuota por plan
```

---

## 4. Stack técnico

### Backend (monorepo pnpm + turborepo)
- **NestJS** — REST + WebSocket (chat streaming, presencia)
- **Prisma + PostgreSQL (Neon)** — datos + **pgvector** para memoria RAG
- **Redis (Upstash)** — rate limits, colas (BullMQ), caché, presencia
- **Stripe** — checkout, portal, webhooks (BYOK y Créditos)
- **Zod + OpenAPI** — contrato con Flutter/web/ext
- **Auth**: Passport/Auth.js — `local`, `google`, `phone+OTP`; JWT + refresh
- **Encriptación BYOK**: AES-256-GCM con clave maestra en el secreto del proveedor (KMS de Fly/Render), separada de la DB
- **S3-compatible storage** (archivos, mini-apps generadas)

### Frontends
- **Flutter** — app principal: chat con streaming, proyectos, agentes, mini-apps (WebView), perfil/planes, voz
- **Next.js 15** — landing, pricing, login web, editor **Blu Code web** (Monaco + GitHub OAuth), **panel admin**
- **Chrome extension MV3** — side panel: chat rápido, accesos a proyectos, nota rápida a memoria

### Blu Code Local
- CLI/daemon **TypeScript (Node)** instalable (`npx blu-code`), patrón Claude Code:
  - herramientas locales: Read/Write/Edit/Bash/Grep/Glob en la máquina del usuario
  - se conecta al backend en la nube (WS/HTTPS) → **misma memoria, mismos agentes, mismo gateway**
  - **nunca** sube el contenido de los archivos al servidor salvo lo que el usuario pida para compartir/commitear

### IA (gateway)
- Adapter por proveedor: `Anthropic | Gemini | OpenAI | OpenRouter | fine-tunes (Together/Fireworks)`
- Modo Auto: clasificador ligero (Ollama/API barata local no — en nube: clasificador tipo Gemini Flash o reglas + embedding similarity) → decide modelo según tipo de tarea (charla/código/investigación/agente)
- STT: Whisper API (Groq) • TTS: ElevenLabs • Imágenes: FLUX (Cloudflare) • Búsqueda: DuckDuckGo Lite (gratis) o Tavily

---

## 5. Mapa de funcionalidades: bot → plataforma

### ✅ Se hereda y se reimplementa
| Del bot | En la plataforma |
|---|---|
| Chat /BLU (Ollama, 2 cerebros) | Chat con gateway multi-modelo + tiers Blu + modo Auto |
| Filtros anti-jailbreak, fuga de identidad, eco, límites (probados en producción) | Se portan TAL CUAL al gateway (capa `security`) |
| Memoria por usuario (JSON) | `user_memory` + vault de notas del proyecto (**second brain estilo Obsidian**: wikilinks, tags, backlinks, gráfico, RAG) |
| Agenda/recordatorios + zonas horarias | `reminders` + `users.timezone` + push (FCM/APNs) |
| Google Calendar (Composio) | Composio cloud (o OAuth directo) — mismo flujo confirmar/listar/borrar |
| Imágenes FLUX + captions | Mismo endpoint + límites por plan |
| Búsqueda web RAG (DuckDuckGo) | Mismo, + Tavily opcional |
| Confirmaciones pendientes (JSON+regex) | UI con botones (confirmar/cancelar) — adiós al regex |
| ToS/privacidad + borrado ARCO | Onboarding con consentimiento + "borrar mis datos" en perfil |
| Rate limits por usuario | Redis, escalonados por plan |
| Briefing matutino | Push de briefing (plan de pago) |
| Notas de voz → texto (faster-whisper local) | Whisper en la nube |

### ❌ Muere (con el bot)
- whatsapp-web.js, Puppeteer, sesión, QR — **WhatsApp fuera por política de Meta**
- Cerebro personal (Claude CLI + control total de PC: screenshot, mouse, self-modificación)
- Glue de Windows: watchdog, autostart, .bat/.vbs, scheduled tasks
- Claude CLI en todos los scripts → APIs directas
- `blu-send/notify` (puerto 5052), `blu-history.json` de Ignacio, `blu-leads.json`, gráficas del asistente personal

### 🆕 Nuevo (producto)
- Cuentas + perfiles + onboarding con consentimiento
- **Proyectos**: multiusuario, permisos (owner/admin/editor/viewer), sesiones independientes por persona, cobro por usuario
- **Memoria compartida** real por proyecto (RAG + UI de administración)
- **7 agentes**: Plan / Build / Cowork / Research / QA / Automation / Knowledge (personas con tools propias sobre el gateway; Knowledge = gestor de memoria)
- **Blu Code web**: GitHub OAuth → repos → editor (Monaco) → commit sin salir
- **Blu Code Local**: CLI/daemon con herramientas locales
- **Proyectos interactivos (mini-apps)**: HTML/JS autocontenido generado por IA, sandbox, WebView en móvil, iframe en web; estadísticas por mini-app; base de Skills
- **BYOK**: keys del usuario encriptadas; su consumo va contra sus proveedores
- **Créditos**: ledger con soft caps por modelo (ej. GPT-4o-mini=1, Sonnet=15); freeze a medianoche
- **Modo Auto**: router inteligente de modelo
- Notificaciones push, panel admin (moderación, costos por usuario, baneos), landing/pricing

---

## 6. AI Gateway — diseño detallado

### 6.1 Tiers y modelos (config hot-swap, no código)

| Tier | V1 (sin fine-tune aún) | Con fine-tunes (Fase 15) |
|---|---|---|
| **Blu Light** | Gemini Flash / DeepSeek (barato y rápido) | fine-tune Qwen 3B-8B |
| **Blu Flash** | Claude Sonnet / GPT-4o-mini | fine-tune Qwen 14B / Llama 8B |
| **Blu Ultra** | Claude Opus / GPT-5 | fine-tune Llama 70B (o vía provider) |

- **Modo Auto**: clasificador de tarea (charla casual / código / investigación / documentación / agente X) → mapa de modelo con presupuesto de costo. El usuario siempre puede forzar tier/modelo.
- **Memoria compartida**: un solo `context_builder` que arma el prompt para CUALQUIER modelo — historial de sesión + memoria de proyecto (embedding search) + memoria de usuario + reglas de seguridad. Por eso "la memoria no depende del modelo".
- **Fallback + retry + timeout** por proveedor (lección del bot: llamadas que se colgaban).
- **Costeo por llamada** → `ai_usage` (provider, model, tokens, costo) → contadores de plan.

### 6.2 Agentes (V1 = personas + tools sobre el mismo gateway)

| Agente | Rol | Tools iniciales |
|---|---|---|
| Plan | Roadmaps, tareas, docs | chat + memoria + mini-apps (tablero) |
| Build | Código, refactor, tests | Blu Code (web/local), GitHub |
| Cowork | Colaboración, code review, dudas | chat + repos + memoria |
| Research | Búsqueda y resúmenes | web search + RAG + memoria |
| QA | Detección de errores, rendimiento | repos, análisis, mini-app de reportes |
| Automation | Flujos y orquestación | webhooks, integraciones, agenda |
| Knowledge | Memoria compartida (vault) | crear/editar/enlazar notas, resolver [[links]] rotos, indexación, RAG |

Cada agente = prompt de sistema + set de tools + su propia sesión de chat. Todos leen/escriben la MISMA memoria de proyecto (requisito "memoria unificada").

### 6.3 BYOK (plan $10/mes)
- Usuario pega su API key (Anthropic/OpenAI/Gemini) → se encripta **AES-256-GCM** con KMS → se guarda en tabla `user_api_keys`
- El gateway usa la key del usuario para sus llamadas; el costeo marca `billed: "provider"` (no consume créditos BLU)
- Nunca se devuelve la key al cliente; solo se muestra máscara + rotación

### 6.4 Créditos (plan $30/mes)
- Tabla `credit_ledger` (grants diarios, gastos por llamada con peso del modelo)
- Soft caps: config `model_credits` (ej. mini=1, sonnet=15, opus=60)
- Al llegar a 0: cuenta congelada hasta reset automático a medianoche (job BullMQ), aviso antes de congelar

### 6.5 Seguridad (heredada del bot, probada 19-27 jul)
- Anti-jailbreak con cooldown por usuario • filtro de fuga de identidad/modelo • anti-eco (Jaccard) • sanitización de nombres • límite de longitud • separación estricta de contexto (memoria de un usuario nunca en el contexto de otro, mismo patrón que el bot usaba con Ignacio)

---

## 7. Memoria compartida — Second Brain (estilo Obsidian)

La memoria de proyecto es un **vault de notas en Markdown con enlaces bidireccionales**, no un blob de texto. Cualquier modelo, agente o humano lee/escribe/enlaza las mismas notas — por eso "la memoria no depende del modelo".

### Modelo de datos

- `notes` — project_id, title, body_md, frontmatter (tags, source: chat|manual|agente|import), created_by, updated_by, updated_at
- `note_links` — aristas derivadas de [[wikilinks]] (se reindexan al guardar); **backlinks = aristas inversas** (query, no duplicado)
- `note_chunks` — chunks de cada nota con embedding (pgvector) para búsqueda semántica
- `note_versions` — snapshot por edición (quién cambió qué, cuándo)

### Reglas del vault

- **Wikilinks**: en el chat, Blu o los agentes citan notas existentes con `[[Nota]]`; al guardar se crea la arista y el backlink. Link a una nota inexistente → propuesta de creación (no error silencioso).
- **Tags** `#tag` en frontmatter para filtros y carpetas virtuales.
- **Gráfico de conocimiento**: nodos = notas, aristas = links, **con la misma experiencia que el Graph View de Obsidian**:
  - layout **force-directed** (d3-force) con nodos **arrastrables**
  - **hover sobre un nodo** → resalta sus vecinos de 1er grado y atenúa el resto
  - **click en un nodo** → enfoca la nota (panel lateral con contenido + backlinks)
  - **búsqueda/filtro** arriba (por título/tag) que resalta coincidencias
  - **colores por carpeta/tag** (leyenda) y control de **profundidad** (1-3 saltos)
  - zoom/pan, botón de re-centrar, ocultar notas sin links (toggle)
  - versión web completa (d3/cytoscape); en móvil versión simplificada (pan/zoom + tap para enfocar)
- **Búsqueda híbrida** para armar contexto: semántica (embeddings) + tags + vecinos en el grafo (links de 1er grado). El `context_builder` del gateway entrega la ruta de notas relevantes a CUALQUIER modelo, no chunks sueltos.
- **Permisos**: mismo modelo de `project_members` (viewer lee, editor escribe/edita, admin borra/fusiona).
- **Portabilidad**: exportar el vault como carpeta de Markdown (compatible Obsidian) — backup y salida del usuario.

### En la UI

- Sección **"Memoria"** en la app = lector del vault: lista de notas, árbol, tags, backlinks, gráfico, búsqueda.
- Edición: editor Markdown en web; edición básica en móvil; creación desde el chat con consentimiento visible ("¿guardo esto en la memoria del proyecto?").
- El chat muestra qué notas usó para responder (citas/backlinks visibles).

### Agente Knowledge

Dueño del vault: crea/organiza/indexa notas, resuelve wikilinks rotos, propone fusiones de notas duplicadas, responde "¿qué hay en la memoria?" con el gráfico y backlinks como evidencia.

## 8. Datos — esquema Postgres (borrador)

- `users` (email, phone, google_sub, tz, tos_accepted_at, role USER/ADMIN, status)
- `projects` (owner_id, name, slug, settings) • `project_members` (project_id, user_id, role OWNER/ADMIN/EDITOR/VIEWER)
- `sessions` (usuario → agentes con estado propio) • `messages` (session_id, agent_id, role, content, tokens, cost)
- `project_memory` → **vault second brain**: `notes` + `note_links` + `note_chunks` + `note_versions` (ver §7)
- `user_memory` • `reminders` • `mini_apps` (project_id, title, html_bundle, stats_schema) • `mini_app_entries`
- `repos_connected` (user_id, github_install_id, repo) • `user_api_keys` (encrypted) • `ai_usage` • `credit_ledger` • `subscriptions` • `push_tokens` • `image_jobs`

### Migración del bot (script one-off)
| JSON del bot | Destino |
|---|---|
| blu-memoria-publica.json | user_memory (match por teléfono del JID) |
| blu-zonas.json | users.timezone |
| blu-agenda-publico.json | reminders |
| blu-tos-aceptados.json | users.tos_accepted_at |

---

## 9. Planes

| | **Gratis $0** | **BYOK $10/mes** | **Créditos $30/mes** |
|---|---|---|---|
| Blu Light | Casi ilimitado (embudo) | ilimitado (paga él) | ilimitado (1 crédito) |
| Blu Flash | 1-3 usos | ilimitado | soft caps (pesos por modelo) |
| Blu Ultra | — | ilimitado | soft caps |
| Claude/Gemini/GPT | — | sus keys | incluidos con pesos |
| Proyectos interactivos | 2-3 | ilimitados | ilimitados |
| Blu Code (web/local) | — | ✓ | ✓ |
| Memoria largo plazo | limitada | ✓ | ✓ |
| Briefing/push | — | ✓ | ✓ |
| Modelo de costo | BLU absorbe (Light barato) | usuario paga a proveedores | BLU pone APIs, créditos diarios con freeze a medianoche |

Enterprise (IA estudiantes / IA trabajadores): **visión**, no V1 — requiere diseño pedagógico, guardrails, cumplimiento menores de edad (LFPDPPP/GDPR+) y ciclo de venta institucional. Leads: exprofesor de Ignacio (2027) y Cedros International School (sin respuesta) → llamadas de descubrimiento antes de construir nada.

---

## 10. Roadmap por fases

| Fase | Entregable | Estimado |
|---|---|---|
| 0 | Monorepo pnpm+turborepo, NestJS+Prisma+Postgres+Redis en la nube, CI/deploy | 1 sem |
| 1 | Auth (email/Google/tel-OTP) + roles + onboarding/consentimiento | 1 sem |
| 2 | AI Gateway: adapters Anthropic/Gemini/OpenAI/OpenRouter, tiers, fallback, costeo | 1 sem |
| 3 | Chat: streaming WS/SSE, historial, capa de seguridad portada del bot | 1 sem |
| 4 | Flutter app v1: login, chat con tiers/Auto, tema | 2-3 sem |
| 5 | Memoria: vault de notas (wikilinks, tags, backlinks, versionado) + RAG híbrido + gráfico de conocimiento | 1-2 sem |
| 6 | Proyectos y multiusuario: permisos, sesiones independientes, cobro por usuario | 1-2 sem |
| 7 | Agentes: los 7 con tools + Knowledge sobre RAG | 1-2 sem |
| 8 | Voz (STT/TTS) + imágenes (FLUX) | 1 sem |
| 9 | Agenda/recordatorios + zonas horarias + push | 1 sem |
| 10 | Billing: Stripe, planes Gratis/BYOK/Créditos, credit_ledger, soft caps, freeze | 1-2 sem |
| 11 | Proyectos interactivos (mini-apps): generación, sandbox, WebView/iframe, stats | 2 sem |
| 12 | Blu Code web: GitHub OAuth, repos, Monaco, commits | 2 sem |
| 13 | Blu Code Local: CLI/daemon con tools locales conectado al backend | 2 sem |
| 14 | Next.js web (landing/pricing/admin) + Chrome extension MV3 | 2 sem |
| 15 | Migración de datos del bot + sunset definitivo | 2-3 días |
| 16 | Fine-tuning Blu Light (paralelo): exportar datos reales, dataset, primer run | 2-4 sem |

Orden de implementación: **0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 10 → 8 → 9 → 11 → 12 → 13 → 14 → 15** (facturación antes de abrir a público).

---

## 11. Costos estimados (nube, sin tráfico pesado)

| Ítem | /mes |
|---|---|
| Backend + DB + Redis (Fly/Render + Neon + Upstash) | $10–50 |
| LLMs (según uso; absorbidos en Gratis solo Light barato) | $10–100 controlable |
| STT/TTS (Groq gratis / ElevenLabs starter) | $0–5 |
| Embeddings para el vault (bge/voyage vía provider) | $0–5 |
| FLUX (Cloudflare 10k neuronas/día gratis) | $0–230 img/día |
| S3 storage (archivos y mini-apps) | $1–5 |
| Twilio (solo si se usa OTP por SMS) | $0–10 |
| Fine-tune run (una vez) | $100–500 |

---

## 12. Riesgos y decisiones abiertas

- **Modelos propios**: fine-tuning es el camino real; los tiers V1 enrutan a modelos cloud baratos con marca Blu hasta tener el primer fine-tune.
- **Gratis "casi sin límite de Blu Light"**: si Light mapea a Gemini Flash, ~$0.0004/msg → viable. Vigilar con ai_usage; si se dispara, se ajusta el tier mapping (no el producto).
- **Mini-apps**: se deciden como HTML/JS en sandbox (iframe/WebView). Rendimiento y seguridad del sandbox son el riesgo principal; alternativa futura: render nativo de primitivas (checklist/calendario/tracker como componentes Flutter).
- **Vault**: reindexar embeddings al editar notas (jobs asíncronos BullMQ); el gráfico con muchas notas necesita lazy-load/paginación; el límite práctico de `note_chunks` por proyecto evita contextos gigantes (se entrega la ruta de notas relevantes, no el vault completo).
- **WhatsApp OTP vs SMS**: WhatsApp OTP necesita cuenta Meta Business verificada; SMS necesita Twilio con saldo. V1: email + Google + WhatsApp OTP.
- **Push en iOS**: requiere cuenta de desarrollador Apple ($99/año) — solo al llegar al build iOS.
- **Composio vs OAuth directo para Google Calendar**: decidir en Fase 9.
- **Chrome extension**: scoping mínimo en V1 (side panel: chat + nota rápida).
- **Enterprise**: no construir hasta tener llamadas de descubrimiento reales.
- **El bot sigue vivo** hasta la Fase 15 para no dejar a la comunidad sin /BLU.

---

## 13. Estructura del repo (propuesta)

```
Proyecto-BLU-IA/
├── docs/PLAN-MIGRACION-APP.md        ← este plan
├── apps/
│   ├── api/          (NestJS — gateway, auth, proyectos, billing, agentes)
│   ├── web/          (Next.js — landing, pricing, Blu Code web, admin)
│   ├── mobile/       (Flutter — Android/iOS/Win/macOS)
│   ├── extension/    (Chrome MV3)
│   └── blu-code/     (CLI/daemon local, patrón Claude Code)
├── packages/
│   ├── shared/       (types, zod, contrato API, weights de créditos)
│   ├── ai-gateway/   (adapters, tiers, Auto, seguridad heredada, costeo)
│   └── memory/       (RAG pgvector, vault, context builder)
└── scripts/migrate-bot-data.ts
```

---

## 14. Anexo A — Diseño aprobado

### Referencias (recibidas del dueño)
- **Diseño Flutter**: clonado en `docs/flutter_chat_ref/` (repo `PABLOESTRADA20/flutter_chat`). Base oficial para la app.
- **Iconos**: `docs/iconos_blu/` (extraídos de `BLU_IA_Assets_2.zip`):
  - `mark-*.png|svg` (azul #0A34F5, azul-claro, blanco, negro) — logo/avatar AI
  - `wordmark-*.png|svg` (claro, oscuro, transparente) — logo + texto "soybluia"
  - `app-icon-claro.png|svg`, `app-icon-oscuro.png|svg` — iconos de app
  - `favicon-*.png|svg` (16/32/48/64/192/512) — favicons web
  - `icono-transparente.png|svg`, `icono-fondo-blanco.png|svg`

### Marca
- Producto: **BLU IA / soybluia**. Marca = trazos horizontales + rombo (rhombus).
- Color primario **#0A34F5** (el mismo del diseño + marca).

### Tema Flutter (de la referencia)
- **Oscuro por defecto** (acorde al diseño HTML original): fondo `#0F131E`, superficies `#171B27–#313441`, texto `#DFE2F2`, primario `#BCC3FF`, contenedor primario `#0A34F5`.
- Tema claro definido en `AppColors` (blanco, primario `#0A34F5`, `#F8FAFC` superficie baja) — la app debe soportar claro/oscuro (ya existe `AppearanceCard` en settings).
- **Tipografías**: Inter (sistema), Geist (display/títulos) y JetBrains Mono (código). La referencia trae los TTFs en `assets/fonts/`.

### Estructura UI de la referencia (base para la app)
- `ChatScreen`: layout responsivo — sidebar 280px en pantallas ≥768px, drawer en móvil; landing card vacía con sugerencias; lista de mensajes con `UserBubble`/`AiBubble` + `TypingIndicator`; `BottomInputArea` + `ModelPill`.
- **ModelSelector**: pill con modelo actual → dropdown "OTROS MODELOS" (Claude/ChatGPT/Gemini con iconos+colores) + sección "SOYBLUIA" (Blu Light/Flash/Ultra con check). **Falta opción "Auto" — se añade al portar.**
- `AppSidebar`: logo, Nuevo chat, Recientes, tarjeta de usuario con **plan (BYOK/Free/Créditos)**, Configuración.
- Screens: `ChatScreen`, `ProfileScreen` (hero, info personal, preferencias, seguridad, zona de peligro = borrado de datos), `SettingsScreen` (cuenta, **API keys = BYOK**, apariencia, notificaciones).
- `SuggestionCardTile` (sugerencias clicables), `TypingIndicator`.

### Integración con el plan
- Los estados de la UI (modelo seleccionado, plan, tz, consentimiento) se alimentan del contrato API (`packages/shared`).
- El `ModelDropdown` enruta al gateway: tier Blu → gateway decide modelo; "Otros modelos" → provider directo (respeta BYOK/permisos del plan).
- La referencia tiene el SDK del ecosistema (sin backend aún): como base de `apps/mobile/` en Fase 4.
