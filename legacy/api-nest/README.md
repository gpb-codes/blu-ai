> ⚠️ **LEGACY — Reemplazada por `apps/api` (Go).** Este código NestJS se conserva solo como referencia histórica. No se desarrolla ni se despliega. Ver `apps/api/README.md` para la implementación actual en Go (chi + pgx).

# API BLU IA — Clean Architecture (NestJS, legacy)

```
src/
├── domain/           # Entidades y contratos (interfaces de repositorios) — SIN dependencias externas
│   ├── entities/
│   └── repositories/
├── application/      # Casos de uso — orquestan dominio + paquetes @blu-ia/*
│   └── use-cases/
├── infrastructure/   # Adaptadores concretos: Prisma, auth, proveedores externos
│   ├── database/
│   ├── repositories/
│   └── auth/         # (Fase 1)
└── presentation/     # HTTP: controllers, dto, guards
    └── controllers/
```

Regla de dependencia: `presentation → application → domain ← infrastructure`.
Nunca al revés. Prisma y NestJS no se filtran hacia el dominio.

**Reemplazo Go:** `apps/api/internal/` replica esta misma arquitectura con `pgx` en lugar de Prisma y `chi` en lugar de NestJS.
