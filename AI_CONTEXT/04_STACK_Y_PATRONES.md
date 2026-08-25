# Stack, tecnologías y patrones de trabajo

## Stack documentado

### Monorepo
- pnpm + Turborepo.
- `apps/api` → NestJS backend.
- `apps/blu-code` → CLI local.
- `apps/extension` → Chrome MV3.
- `apps/mobile` → Flutter.
- `apps/web` → Next.js.
- `packages/ai-gateway` → gateway multi-proveedor.
- `packages/memory` → memoria compartida/RAG.
- `packages/shared` → tipos y utilidades compartidas.

### Backend
- NestJS + TypeScript.
- REST + WebSocket para streaming/presencia.
- Cloudflare D1 (SQLite) + Vectorize para datos y vectores RAG.
- Upstash Redis para rate limits, colas/BullMQ, caché y presencia.
- Stripe para pagos, checkout, portal y webhooks.
- Zod + OpenAPI para contratos.
- Auth documentada con Passport/Auth.js, local/Google/phone OTP, JWT + refresh.
- BYOK cifrado con AES-256-GCM y clave maestra separada de la DB.
- S3-compatible storage para archivos y mini-apps.

### Frontend
- Flutter como app principal multi-plataforma: Android/iOS/Windows/macOS.
- Next.js 15 para landing, pricing, login, editor web de SoyBluAI Code y admin.
- Monaco + GitHub OAuth para Code web.
- Chrome Extension Manifest V3 para side panel.

### IA
- Gateway con adapters Anthropic, Gemini, OpenAI, OpenRouter y fine-tunes.
- Modo Auto / Model Router.
- BYOK.
- Fallbacks por tier.
- Tiers Light / Flash / Ultra.
- Claude/Gemini/GPT y otros proveedores como componentes intercambiables del gateway.

### Servicios de IA documentados
- STT: Whisper API vía Groq.
- TTS: ElevenLabs.
- Imágenes: FLUX vía Cloudflare.
- Búsqueda: DuckDuckGo Lite/Tavily.

## Patrones arquitectónicos preferidos
- Mantener separación entre dominio de producto y proveedores externos.
- Encapsular proveedores mediante adapters/interfaces.
- Compartir tipos y contratos en `packages/shared`.
- Evitar duplicar lógica entre Flutter/web/extension cuando pueda vivir en backend o paquete compartido.
- Mantener memoria como componente desacoplado del proveedor de modelo.
- Diseñar agentes con permisos explícitos y límites.
- Preferir interfaces estables y evolución incremental.

## Regla de evidencia técnica
Antes de afirmar que una tecnología o módulo está implementado, revisar el código y/o tests. La documentación puede describir intención; el código determina el estado real.

## Nota sobre cambios de stack
El stack puede evolucionar. Esta nota resume el estado documentado a 24-ago-2026 y no debe usarse para ignorar decisiones posteriores del vault.