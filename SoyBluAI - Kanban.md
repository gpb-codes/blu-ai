---
kanban-plugin: basic
tags:
  - soybluia
  - tareas
  - kanban
source: Notion - Base "Tareas SoyBluAI"
estado: activo
tipo: tareas
---

# SoyBluAI - Kanban

> Tablero del sprint, generado desde [[SoyBluAI - Tareas]] (Notion), organizado por responsable. Dentro de cada columna: ⚠️ atrasada · 🔄 en progreso · ✅ listo (tarjeta marcada). Última reorganización: 17-ago-2026.

## Gabriel

- [ ] **Desplegar Next.js en Vercel** ⚠️ `📅 2026-08-03`
  - Prioridad: Alta · Area: Infraestructura · Fase: Mes 1 - Base
  - Nota: `apps/web` sigue siendo el boilerplate default de create-next-app, sin contenido propio (verificado 17-ago).

- [ ] **Configurar Cloudflare D1 (SQLite) + Vectorize + auth** ⚠️ `📅 2026-08-05`
  - Prioridad: Alta · Area: Backend · Fase: Mes 1 - Base
  - Nota: Reemplaza a Supabase/Postgres+pgvector (decisión confirmada 17-ago). El código sigue en Prisma/PostgreSQL. Falta definir solución de auth (D1 no la incluye) y ORM/capa de datos.

- [ ] **Sistema BYOK con API keys encriptadas** 🔄 `📅 2026-08-25`
  - Prioridad: Alta · Area: Backend · Fase: Mes 1 - Base
  - Nota: El usuario mete su propia API key, guardada encriptada. Verificado en el fork (17-ago): modelo `UserApiKey` listo (AES-256-GCM, maskedKey), falta el controlador/servicio de cifrado.

- [x] **Crear repositorio y entornos dev/producción** `📅 2026-06-27`
  - Prioridad: Alta · Area: Infraestructura · Fase: Mes 1 - Base

- [x] **Documentar cumplimiento legal de la arquitectura (residencia, transferencias, certificaciones, retención, DPA)** `📅 2026-08-04`
  - Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base
  - Nota: Puntos a documentar: residencia de datos, transferencias internacionales, certificaciones de seguridad (ISO 27001, SOC 2, EU Cloud CoC), política de retención, y DPA. Importante para futuras auditorías técnicas/legales si se trabaja con clientes corporativos. Propuesto por Gabriel.

- [x] **Esquema de base de datos** `📅 2026-08-08`
  - Prioridad: Alta · Area: Backend · Fase: Mes 1 - Base
  - Nota: Usuarios, proyectos, mensajes, memoria vectorial. Verificado en el fork (17-ago): `schema.prisma` completo con 2 migraciones aplicadas.

- [x] **Login y registro funcionando** `📅 2026-08-12`
  - Prioridad: Alta · Area: Backend · Fase: Mes 1 - Base
  - Nota: Verificado en el fork (17-ago): AuthController completo, JWT+refresh, hash Argon2, test e2e.

- [x] **Enrutamiento multi-modelo básico** `📅 2026-08-18`
  - Prioridad: Alta · Area: Backend · Fase: Mes 1 - Base
  - Nota: Claude + Gemini + GPT, con selección de modelo según tipo de tarea. Verificado en el fork: TierRouter con fallback entre proveedores.

## Pablo

- [ ] **Definir sistema de diseño del frontend (componentes base)** 🔄 `📅 2026-08-05`
  - Prioridad: Alta · Area: Frontend · Fase: Mes 1 - Base
  - Nota: Coordinado con Gabriel para no chocar con el backend. Verificado en el fork (17-ago): avanzado en mobile/Flutter (tema + librería de widgets), `apps/web` sigue en boilerplate — falta extenderlo a la web.

## Ignacio

- [ ] **Firmar acuerdo con Pablo (frontend)** ⚠️ `📅 2026-08-01`
  - Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base
  - Nota: Mismas condiciones que Gabriel en vesting: 4 años, cliff de 1 año.

- [ ] **Cerrar conversación con el de seguridad** ⚠️ `📅 2026-08-03`
  - Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base
  - Nota: Definir alcance, frecuencia, compensación e incompatibilidades por su empleo actual antes de comprometer equity.

- [ ] **Comprar dominio definitivo** ⚠️ `📅 2026-08-08`
  - Prioridad: Media · Area: Negocio · Fase: Mes 1 - Base

- [ ] **Publicar aviso de privacidad en la web** `📅 2026-08-26`
  - Prioridad: Media · Area: Legal · Fase: Mes 1 - Base

- [ ] **Cierre de mes 1 y ajuste de roadmap** `📅 2026-08-31`
  - Prioridad: Media · Area: Negocio · Fase: Mes 1 - Base
  - Nota: Revisar métricas, qué se cumplió y qué se mueve al mes 2.

- [x] **Redactar aviso de privacidad completo (LFPDPPP)** `📅 2026-07-25`
  - Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base
  - Nota: Falta: identidad del responsable, derechos ARCO completos, finalidades que requieren consentimiento, y aviso integral en la web.

- [x] **Firmar acuerdo con Gabriel** `📅 2026-07-28`
  - Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base

## Ignacio + Marketing

- [ ] **Definir 20 ganchos para el primer mes de contenido** ⚠️ `📅 2026-07-29`
  - Prioridad: Alta · Area: Contenido · Fase: Mes 1 - Base

- [ ] **Arrancar contenido: 10 publicaciones por semana** ⚠️ `📅 2026-08-01`
  - Prioridad: Alta · Area: Contenido · Fase: Mes 1 - Base
  - Nota: 5 en cuenta personal + 5 en cuenta oficial de SoyBluAI. Empieza sin esperar al producto.

- [ ] **Landing page con waitlist** `📅 2026-08-20`
  - Prioridad: Alta · Area: Marketing · Fase: Mes 1 - Base
  - Nota: La hacen Ignacio y el de marketing juntos, no Gabriel.

- [ ] **Llegar a 100 personas en waitlist** `📅 2026-08-31`
  - Prioridad: Alta · Area: Marketing · Fase: Mes 1 - Base
