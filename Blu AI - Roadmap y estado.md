---
tags:
  - blu
  - roadmap
  - estado
---

# Blu AI — Roadmap y estado

> Estado real del proyecto (2026) y dirección. Fuente: repo oficial `blutechrobotics/Proyecto-BLU-IA`.

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
| Datos | PostgreSQL (Neon, pgvector para RAG) + Redis (Upstash) — ⚠️ en revisión: Cloudflare D1 + Vectorize (bitácora 28-jul) |
| IA | Gateway multi-proveedor; tiers Blu Light/Flash/Ultra + Claude/Gemini/GPT + Auto |
| Modelos propios | Fine-tuning de open-source (Qwen/Llama), no desde cero |
| Autenticación | Email+contraseña, Google, teléfono (SMS/WhatsApp OTP) |
| Monetización | Freemium: Gratis / BYOK $10 / Créditos $30 (Stripe) |
| Colaboración | Proyectos con permisos, memoria compartida, cobro por usuario |
| V1 | Sin Enterprise, sin voz en tiempo real; con voz en notas (STT) y TTS |

## Roadmap a 3 meses (Notion)

> Objetivo: producto lanzado y cobrando en 3 meses. Meta a 6 meses: **500 usuarios de pago a $10/mes = $5,000/mes**. Detalle operativo: [[Blu AI - Kanban]] · [[Blu AI - Tareas]].

- **Mes 1 — Base (agosto):** infraestructura funcionando y contenido corriendo desde el día 1 (landing + waitlist, login, gateway, BYOK, aviso de privacidad, contenido 5 publicaciones/semana).
- **Mes 2 — Producto (septiembre):** el producto hace lo que promete y se puede cobrar (memoria RAG, Blu Code con GitHub, créditos con soft caps, Stripe, panel de usuario, beta cerrada con los 30 usuarios actuales).
- **Mes 3 — Lanzamiento (octubre):** abrir pagos y meter usuarios (app móvil TestFlight + App Store, onboarding <5 min, monitoreo de caídas, apertura de pagos a la waitlist; meta: **primeros 100 usuarios de pago**).
- **Meses 4-6 — Escala:** extensión Chrome, sistema de Skills, agentes especializados, desktop Windows/macOS; meta: **500 usuarios de pago**.

## Historial del repo

- v0: bot de WhatsApp (Blu WhatsApp bot)
- MCP: sistema con 9 herramientas estandarizadas (Node y Python)
- Migración SaaS: monorepo pnpm/turbo, auth Fase 1 completo, 68 tests
- **AI gateway** con adapters reales (OpenAI/Anthropic/Gemini/OpenRouter) + BYOK, fallbacks por tier, `503 PROVIDER_NOT_CONFIGURED`, **78/78 tests**

## Referencias

- Visión general: [[Blu AI - Vision]]
- Arquitectura y stack: [[Blu AI - Stack tecnologico]]
- Plan completo en el repo: `docs/PLAN-MIGRACION-APP.md`

## Próximos frentes probables

1. Terminar auth y onboarding multidispositivo
2. Memoria compartida RAG end-to-end ([[Blu AI - Memoria compartida]])
3. Modo Auto refinado del gateway ([[Blu AI - Gateway y Modelos]])
4. Blu Code local + web ([[Blu AI - Blu Code]])
5. Mini-apps / sistema de Skills ([[Blu AI - Skills y mini-apps]])