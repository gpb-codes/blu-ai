---
tags:
  - soybluia
  - roadmap
  - estado
estado: activo
responsable: Ignacio
tipo: roadmap
actualizacion: 24-ago-2026
---

# SoyBluAI — Roadmap y estado

> Estado real del proyecto (2026) y dirección. Fuente: repo oficial `blutechrobotics/Proyecto-BLU-IA`.
>
> **Actualización 24-ago-2026:** se integró la visión de evolución de SoyBluAI hacia un "AI Work Operating System" (Studios, Agent Builder, Workflow Builder, Mission Mode, SOUP Lab, Marketplaces, etc.). Ese roadmap ampliado vive en la sección nueva "Roadmap ampliado — AI Work Operating System" más abajo, **por encima** del roadmap a 3 meses que sigue siendo la prioridad activa (ver [[SoyBluAI - Decisiones (ADRs)|ADR-003]] sobre alcance vs. capacidad del equipo). No cambia ninguna fecha ni meta del roadmap a 3 meses.

## Decisión de producto

- Migración del bot de WhatsApp a **plataforma SaaS** multi-dispositivo.
- **WhatsApp descontinuado** (prohibición de Meta a asistentes de propósito general vía WA Business API desde 15-ene-2026; reapertura solo UE/BR con tarifas que rompen la economía del plan).

## Decisiones clave

| Tema | Decisión |
|------|----------|
| Producto | Plataforma SaaS: Web + Windows + macOS + Android + iOS + Chrome ext |
| Frontend principal | Flutter (móvil + desktop) — una base para 4 plataformas |
| Web | Next.js 15 (landing, pricing, login web, panel admin) + Chrome ext MV3 |
| Backend | NestJS + TypeScript, monorepo pnpm + turborepo |
| Datos | Cloudflare D1 (SQLite) + Vectorize — migración **confirmada** (bitácora 17-ago-2026), reemplaza a PostgreSQL (Neon)/pgvector; aún no implementada en el fork auditado el 17-ago-2026 · Redis (Upstash) |
| IA | Gateway multi-proveedor; tiers SoyBluAI Light/Flash/Ultra + Claude/Gemini/GPT + Auto |
| Modelos propios | Fine-tuning sobre DeepSeek (Light/Flash) y Kimi K3 (Ultra), no desde cero |
| Autenticación | Email+contraseña, Google, teléfono (SMS/WhatsApp OTP) |
| Monetización | Freemium: Gratis / BYOK $10 / Créditos $30 (Stripe) |
| Colaboración | Proyectos con permisos, memoria compartida, cobro por usuario |
| V1 | Sin Enterprise, sin voz en tiempo real; con voz en notas (STT) y TTS |

## Roadmap a 3 meses (Notion)

> Objetivo: producto lanzado y cobrando en 3 meses. Meta a 6 meses: **500 usuarios de pago a $10/mes = $5,000/mes**. Detalle operativo: [[SoyBluAI - Kanban]] · [[SoyBluAI - Tareas]].

- **Mes 1 — Base (agosto):** infraestructura funcionando y contenido corriendo desde el día 1 (landing + waitlist, login, gateway, BYOK, aviso de privacidad, contenido 5 publicaciones/semana).
- **Mes 2 — Producto (septiembre):** el producto hace lo que promete y se puede cobrar (memoria RAG, SoyBluAI Code con GitHub, créditos con soft caps, Stripe, panel de usuario, beta cerrada con los 30 usuarios actuales).
- **Mes 3 — Lanzamiento (octubre):** abrir pagos y meter usuarios (app móvil TestFlight + App Store, onboarding <5 min, monitoreo de caídas, apertura de pagos a la waitlist; meta: **primeros 100 usuarios de pago**).
- **Meses 4-6 — Escala:** extensión Chrome, sistema de Skills, agentes especializados, desktop Windows/macOS; meta: **500 usuarios de pago**.

## Historial del repo

- v0: bot de WhatsApp (SoyBluAI WhatsApp bot)
- MCP: sistema con 9 herramientas estandarizadas (Node y Python)
- Migración SaaS: monorepo pnpm/turbo, auth Fase 1 completo, 68 tests
- **AI gateway** con adapters reales (OpenAI/Anthropic/Gemini/OpenRouter) + BYOK, fallbacks por tier, `503 PROVIDER_NOT_CONFIGURED`, **78/78 tests**

## Referencias

- Visión general: [[SoyBluAI - Vision]]
- Arquitectura y stack: [[SoyBluAI - Stack tecnologico]]
- Plan completo en el repo: `docs/PLAN-MIGRACION-APP.md`

## Próximos frentes probables

1. Terminar auth y onboarding multidispositivo
2. Memoria compartida RAG end-to-end ([[SoyBluAI - Memoria compartida]])
3. Modo Auto refinado del gateway ([[SoyBluAI - Gateway y Modelos]])
4. SoyBluAI Code local + web ([[SoyBluAI - Code]])
5. Mini-apps / sistema de Skills ([[SoyBluAI - Skills y mini-apps]])

## Roadmap ampliado — AI Work Operating System (24-ago-2026)

> Clasificación de la nueva visión de producto, reconciliada con el roadmap de 3 meses de arriba (que no cambia). "P0" aquí no reemplaza los hitos de Mes 1-3 — son P0 **dentro del roadmap ampliado**, a trabajar en cuanto el roadmap de 3 meses lo permita, priorizando lo que es prerrequisito de seguridad. Detalle de cada funcionalidad en las notas enlazadas.

### P0 — Core (prerrequisito de seguridad y base de todo lo demás)

| Funcionalidad | Nota | Motivo P0 |
|---|---|---|
| Agent Builder (creación/configuración básica) | [[SoyBluAI - Agent Builder y Marketplace]] | Base de Mission Mode, Studios y Workflow Builder |
| Permission System por agente | [[SoyBluAI - Workflow Builder y Automatizacion]] | Requisito de seguridad antes de dar a un agente capacidad de acción real |
| Human-in-the-loop | [[SoyBluAI - Workflow Builder y Automatizacion]] | Mismo motivo — deploy, borrado, pagos, acciones externas |
| Memory 2.0 (estructura Global/User/Org/Project) | [[SoyBluAI - Memoria compartida]] | Evolución de la memoria compartida ya en roadmap (Mes 2) |
| SOUP (naming + reconciliación con fine-tuning ya decidido) | [[SoyBluAI - SOUP y AI Core]] | No bloquea nada técnico, pero requiere el ADR-001 confirmado antes de comunicarse externamente |

### P1 — Expansión

SoyBluAI Connect (ampliar Plugins existente) · Creative Studio · Design Agent · App Builder · Asset Library · Workflow Builder (producto visual) · Research Studio · Development Studio (extensión de SoyBluAI Code) — ver [[SoyBluAI - Studios y Mission Mode]], [[SoyBluAI - Conectores, MCP y Assets]].

### P2 — Ecosistema

MCP Marketplace · Agent Marketplace · AI Control Center · Templates · Model Router avanzado (criterios ampliados, ya iniciado en [[SoyBluAI - Gateway y Modelos]]) · SoyBluAI Local (🔴 bloqueado por [[SoyBluAI - Decisiones (ADRs)|ADR-002]], no avanza hasta que el equipo decida) · Mission Mode completo (depende de que P0 esté cerrado).

### 🟣 Experimental (no tratar como oficial todavía)

SOUP Lab como infraestructura de experimentación (evaluación, checkpoints) — ver [[SoyBluAI - SOUP y AI Core]].

### 🔴 Conflicto — bloqueado, requiere decisión del equipo antes de avanzar

SoyBluAI Local (Ollama/LM Studio/llama.cpp) — ver [[SoyBluAI - Decisiones (ADRs)|ADR-002]].