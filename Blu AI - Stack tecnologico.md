---
tags:
  - blu
  - stack
estado: activo
responsable: Gabriel
tipo: stack
---

# Blu AI â€” Stack tecnolÃ³gico

> Monorepo pnpm + turborepo. Backend NestJS, web Next.js, app Flutter, CLI TypeScript.

## Backend (`apps/api`, `packages/*`)

- **NestJS** â€” REST + WebSocket (chat streaming, presencia)
- **Prisma + PostgreSQL (Neon)** â€” datos + **pgvector** para memoria RAG

> âš ï¸ **En revisiÃ³n (28-jul, Notion):** datos migran de Supabase/Postgres a **Cloudflare D1 (SQLite) + Vectorize**. Falta confirmar auth (D1 no la incluye) y hosting (Vercel vs Cloudflare Workers/Pages). Fuente: [[Blu AI - Bitacora]].
- **Redis (Upstash)** â€” rate limits, colas (BullMQ), cachÃ©, presencia
- **Stripe** â€” checkout, portal, webhooks (BYOK y CrÃ©ditos)
- **Zod + OpenAPI** â€” contrato con Flutter/web/ext
- **Auth**: Passport/Auth.js â€” `local`, `google`, `phone+OTP`; JWT + refresh
- **EncriptaciÃ³n BYOK**: AES-256-GCM con clave maestra separada de la DB
- **S3-compatible storage** (archivos, mini-apps generadas)

## Frontends

- **Flutter** â€” app principal: chat streaming, proyectos, agentes, mini-apps, perfil/planes, voz. Una base para Android/iOS/Windows/macOS.
- **Next.js 15** â€” landing, pricing, login web, editor **Blu Code web** (Monaco + GitHub OAuth), panel admin.
- **Chrome extension MV3** â€” side panel: chat rÃ¡pido, accesos a proyectos, nota rÃ¡pida a memoria.

## IA (gateway)

- Adapters: `Anthropic | Gemini | OpenAI | OpenRouter | fine-tunes`
- Modo Auto: clasificador (Gemini Flash o reglas + embedding) â†’ decide modelo
- STT: Whisper API (Groq) Â· TTS: ElevenLabs Â· ImÃ¡genes: FLUX (Cloudflare) Â· BÃºsqueda: DuckDuckGo Lite/Tavily

## Estructura del repo

```
apps/
  api          â†’ backend NestJS
  blu-code     â†’ CLI local
  extension    â†’ Chrome MV3
  mobile       â†’ Flutter
  web          â†’ Next.js
packages/
  ai-gateway   â†’ gateway multi-proveedor
  memory       â†’ memoria compartida / RAG
  shared       â†’ tipos y utilidades compartidas
```

Ver tambiÃ©n: [[Blu AI - Gateway y Modelos]], [[Blu AI - Roadmap y estado]].
