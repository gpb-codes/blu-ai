# API BLU IA — Clean Architecture

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
