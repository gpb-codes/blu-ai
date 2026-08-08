# BLU IA — plataforma

Migración del bot de WhatsApp a una plataforma multi-dispositivo (Web, Windows, macOS, Android, iOS + extensión Chrome).

**Plan completo:** [docs/PLAN-MIGRACION-APP.md](docs/PLAN-MIGRACION-APP.md)

## Estructura

```
apps/
  api/        NestJS — API Gateway (auth, proyectos, chat, agentes, billing, memoria)
  web/        Next.js — landing, pricing, Blu Code web, panel admin
  mobile/     Flutter — app Android/iOS/Windows/macOS (base: diseño aprobado)
  blu-code/   CLI/daemon local estilo Claude Code (módulo avanzado)
  extension/  Extensión Chrome (MV3)
packages/
  shared/     Contrato API: types, zod schemas, pesos de créditos
  ai-gateway/ Adapters multi-proveedor, tiers Blu, modo Auto, seguridad, costeo
  memory/     Vault second brain (notas, wikilinks, backlinks, RAG)
legacy/
  bot/        Bot de WhatsApp archivado (whatsapp-web.js + scripts) — NO usar, referencia
docs/
  PLAN-MIGRACION-APP.md  Plan de migración y arquitectura
  flutter_chat_ref/      Diseño Flutter de referencia (repo PABLOESTRADA20/flutter_chat)
  iconos_blu/            Iconos oficiales (mark, wordmark, app icons, favicons)
```

## Comandos

```bash
pnpm install        # instala todo el workspace
pnpm dev            # corre api + web en modo desarrollo
pnpm build          # compila todo
pnpm typecheck      # chequeo de tipos en todo el monorepo
```

## Convenciones de Clean Architecture

La regla de dependencia apunta hacia adentro (nada de `infrastructure` importa de `presentation`):

```
presentation/  (controllers, dto, guards)   → application/
application/   (use-cases, ports)           → domain/
domain/        (entities, value objects, interfaces de repositorio)  ← sin dependencias externas
infrastructure/ (prisma, proveedores externos, auth)                 → domain/
```

- Los casos de uso NO conocen NestJS, Prisma ni proveedores de IA.
- `domain` no importa nada de Node/npm — solo tipos locales.
- Los adapters de IA (`packages/ai-gateway`) son intercambiables: 1 archivo por proveedor.

## Estado

- [x] Fase 0 (parcial): monorepo + esqueletos + diseño de referencia
- [ ] Fase 1: Auth (email/Google/teléfono-OTP)
- [ ] Fase 2: AI Gateway (adapters, tiers, Auto, costeo)
- [ ] … ver [docs/PLAN-MIGRACION-APP.md](docs/PLAN-MIGRACION-APP.md) §10

**El bot de WhatsApp está retirado** (política de Meta 15-ene-2026). El código vive en `legacy/bot/` solo como referencia.
