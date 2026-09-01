# BLU IA — API Go

> **API oficial del proyecto.** Port completo de `legacy/api-nest` (NestJS) + `packages/ai-gateway` + `packages/memory` + `packages/shared` a **Go** con Clean Architecture preservada. La versión NestJS queda en `legacy/api-nest/` solo como referencia.

## Stack

- **Router:** chi v5 + cors + middleware
- **DB:** pgx/v5 (pgxpool) — mismo Postgres/pgvector que Prisma. Migraciones en `migrations/` (idénticas a las de Prisma).
- **Auth:** JWT (golang-jwt) + refresh tokens con hash SHA256 y rotación, password con bcrypt (reemplazo de argon2 sin CGO; cambiar a `matthewhartstonge/argon2` si se quiere argon2id puro).
- **IA Gateway:** mismo contrato que `packages/ai-gateway`: `TierRouter`, `classifyTask`, `JailbreakGuard`, `costUsd`, adapters HTTP para Anthropic / OpenAI / Gemini / OpenRouter (blu-finetune vía OpenRouter).

## Arquitectura

```
cmd/server              → composición (equivalente a apps/api/src/app.module.ts + main.ts)
internal/shared         → port de packages/shared/src/index.ts
internal/gateway        → port de packages/ai-gateway/src/* (types, router, cost, security, invoke)
  └ adapters            → anthropic, gemini, openai, openrouter, http
internal/memory         → port de packages/memory/src/* (types, graph, context-builder)
internal/domain         → entities + repository interfaces + auth ports (sin deps externas)
internal/application    → use-cases: auth (register/login/refresh/logout) + chat
internal/infrastructure → pgx repos, auth (jwt, bcrypt), database pool, migraciones
internal/presentation   → dto validation, handlers (auth, chat, health), middleware JWT
```

Regla de dependencia hacia adentro: `presentation → application → domain ← infrastructure` — igual que el NestJS original.

## Migraciones

`migrations/001_init.sql` y `002_add_password_hash.sql` son copias 1:1 de `apps/api/prisma/migrations/`. Para generar código sqlc:

```sh
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
sqlc generate
```

## Desarrollo

```sh
cd apps/api
go mod tidy
cp ../../.env.example .env  # ajusta DATABASE_URL, JWT_SECRET
go run ./cmd/server          # :3000
# o
make build && ./bin/server
# o desde la raíz
pnpm dev:api
```

Endpoints (mismos que NestJS):
- `GET /health`
- `POST /auth/register` `POST /auth/login` `POST /auth/refresh` `POST /auth/logout` `GET /auth/me` (Bearer)
- `POST /chat/` (Bearer, { tier, text, history, projectId, agentId })

## Diferencias con el TS original

- Password: bcrypt en vez de argon2 (sin CGO). Interfaz `PasswordHasher` idéntica, swap trivial.
- `PrismaService` → `pgxpool.Pool` (pool directo, sin ORM).
- `JwtStrategy` (passport) → middleware `JWTAuth` con `golang-jwt`.
- `ValidationPipe` (class-validator) → `dto.Validate()` manual (mismas reglas).
- `TierRouter` y `gateway` sin cambios de semántica; `invokeChat` → `gateway.InvokeChat`.

## Roadmap pendiente (fases del PLAN-MIGRACION-APP)

Fase 5 pgvector híbrido (ahora LIKE), Fase 9/10 billing/stripe, Fase 11 mini-apps — mismas TODOs que en el TS.
