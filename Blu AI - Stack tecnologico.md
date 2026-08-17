---
tags:
  - blu
  - stack
estado: activo
responsable: Gabriel
tipo: stack
---

# Blu AI — Stack tecnológico

> Monorepo pnpm + turborepo. Backend NestJS, web Next.js, app Flutter, CLI TypeScript.

## Backend (`apps/api`, `packages/*`)

- **NestJS** — REST + WebSocket (chat streaming, presencia)
- **Cloudflare D1 (SQLite) + Vectorize** — datos + memoria RAG. Reemplaza a Supabase/PostgreSQL (Neon) + pgvector. **Confirmado 17-ago-2026.**

> ⚠️ **Nota:** D1 es SQLite, no PostgreSQL — no hay pgvector nativo (por eso Vectorize aparte para vectores). Pendiente: ORM/capa de acceso a datos (Prisma no soporta D1 nativamente), solución de auth (D1 no la incluye), y si el hosting se mueve de Vercel a Cloudflare Workers/Pages. Fuente: [[Blu AI - Bitacora]].
- **Redis (Upstash)** — rate limits, colas (BullMQ), caché, presencia
- **Stripe** — checkout, portal, webhooks (BYOK y Créditos)
- **Zod + OpenAPI** — contrato con Flutter/web/ext
- **Auth**: Passport/Auth.js — `local`, `google`, `phone+OTP`; JWT + refresh
- **Encriptación BYOK**: AES-256-GCM con clave maestra separada de la DB
- **S3-compatible storage** (archivos, mini-apps generadas)

## Frontends

- **Flutter** — app principal: chat streaming, proyectos, agentes, mini-apps, perfil/planes, voz. Una base para Android/iOS/Windows/macOS.
- **Next.js 15** — landing, pricing, login web, editor **Blu Code web** (Monaco + GitHub OAuth), panel admin.
- **Chrome extension MV3** — side panel: chat rápido, accesos a proyectos, nota rápida a memoria.

## IA (gateway)

- Adapters: `Anthropic | Gemini | OpenAI | OpenRouter | fine-tunes`
- Modo Auto: clasificador (Gemini Flash o reglas + embedding) → decide modelo
- STT: Whisper API (Groq) · TTS: ElevenLabs · Imágenes: FLUX (Cloudflare) · Búsqueda: DuckDuckGo Lite/Tavily

## Estructura del repo

```
apps/
  api          → backend NestJS
  blu-code     → CLI local
  extension    → Chrome MV3
  mobile       → Flutter
  web          → Next.js
packages/
  ai-gateway   → gateway multi-proveedor
  memory       → memoria compartida / RAG
  shared       → tipos y utilidades compartidas
```

Ver también: [[Blu AI - Gateway y Modelos]], [[Blu AI - Roadmap y estado]].