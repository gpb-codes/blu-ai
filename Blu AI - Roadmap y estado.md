---
tags:
  - blu
  - roadmap
  - estado
---

# Blu AI — Roadmap y estado

> Estado real del proyecto (2026) y dirección. Fuente: repo `gpb-codes/Proyecto-BLU-IA`.

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
| Datos | PostgreSQL (Neon, pgvector para RAG) + Redis (Upstash) |
| IA | Gateway multi-proveedor; tiers Blu Light/Flash/Ultra + Claude/Gemini/GPT + Auto |
| Modelos propios | Fine-tuning de open-source (Qwen/Llama), no desde cero |
| Autenticación | Email+contraseña, Google, teléfono (SMS/WhatsApp OTP) |
| Monetización | Freemium: Gratis / BYOK $10 / Créditos $30 (Stripe) |
| Colaboración | Proyectos con permisos, memoria compartida, cobro por usuario |
| V1 | Sin Enterprise, sin voz en tiempo real; con voz en notas (STT) y TTS |

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