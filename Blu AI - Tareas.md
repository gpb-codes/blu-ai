---
tags:
  - blu
  - tareas
  - equipo
tipo: tareas
estado: activo
source: Notion - Base "Tareas BLU IA"
actualizacion: 14-ago-2026
---

# Blu AI - Tareas

> Backlog del equipo, sincronizado desde Notion (base "Tareas BLU IA"). Tablero visual: [[Blu AI - Kanban]]. Fuente viva: Notion > BLU IA.

## Resumen

| Estado | Conteo |
|---|---|
| Listo | 7 |
| En progreso | 2 |
| Sin empezar | 11 |

### Por área

| Área | Conteo |
|---|---|
| Legal | 6 |
| Backend | 5 |
| Contenido | 2 |
| Infraestructura | 2 |
| Marketing | 2 |
| Negocio | 2 |
| Frontend | 1 |

### Prioridades

| Prioridad | Conteo |
|---|---|
| Alta | 17 |
| Media | 3 |

---

## Tareas por área

> Leyenda: **Alta** = bloquea el avance · **Media** = se puede posponer. Fase actual: Mes 1 - Base (agosto).

### Legal

| Tarea | Estado | Prioridad | Fecha | Responsable | Notas |
|---|---|---|---|---|---|
| Redactar aviso de privacidad completo (LFPDPPP) | Listo | Alta | 2026-07-25 | Ignacio | Falta: identidad del responsable, derechos ARCO completos, finalidades que requieren consentimiento, y aviso integral en la web. |
| Firmar acuerdo con Gabriel | Listo | Alta | 2026-07-28 | Ignacio | — |
| Firmar acuerdo con Pablo (frontend) | Sin empezar | Alta | 2026-08-01 | Ignacio | Mismas condiciones que Gabriel en vesting: 4 años, cliff de 1 año. |
| Cerrar conversación con el de seguridad | Sin empezar | Alta | 2026-08-03 | Ignacio | Definir alcance, frecuencia, compensación e incompatibilidades por su empleo actual antes de comprometer equity. |
| Documentar cumplimiento legal de la arquitectura (residencia, transferencias, certificaciones, retención, DPA) | Listo | Alta | 2026-08-04 | Gabriel | Puntos a documentar: residencia de datos, transferencias internacionales, certificaciones de seguridad (ISO 27001, SOC 2, EU Cloud CoC), política de retención, y DPA. Importante para futuras auditorías técnicas/legales si se trabaja con clientes corporativos. Propuesto por Gabriel. |
| Publicar aviso de privacidad en la web | Sin empezar | Media | 2026-08-26 | Ignacio | — |

### Backend

| Tarea | Estado | Prioridad | Fecha | Responsable | Notas |
|---|---|---|---|---|---|
| Configurar Cloudflare D1 (SQLite) + Vectorize + auth | Sin empezar | Alta | 2026-08-05 | Gabriel | Reemplaza a Supabase/Postgres+pgvector (decisión confirmada 17-ago). Falta definir solución de auth (D1 no la incluye) y ORM/capa de datos. |
| Esquema de base de datos | Listo | Alta | 2026-08-08 | Gabriel | Verificado en el fork (gpb-codes/Proyecto-BLU-IA, 17-ago): `schema.prisma` completo (User, RefreshToken, UserApiKey, ConnectedRepo, etc.) con 2 migraciones aplicadas. |
| Login y registro funcionando | Listo | Alta | 2026-08-12 | Gabriel | Verificado en el fork (17-ago): AuthController completo (register/login/refresh/logout/me), JWT+refresh, hash Argon2, guard y test e2e. |
| Enrutamiento multi-modelo básico | Listo | Alta | 2026-08-18 | Gabriel | Claude + Gemini + GPT, con selección de modelo según tipo de tarea. Verificado en el fork: TierRouter con fallback entre proveedores (anthropic/gemini/openai/openrouter). |
| Sistema BYOK con API keys encriptadas | En progreso | Alta | 2026-08-25 | Gabriel | Verificado en el fork (17-ago): el modelo `UserApiKey` ya tiene los campos para AES-256-GCM (encryptedKey, maskedKey), pero falta el controlador/servicio que realmente cifre y guarde las keys. |

### Contenido

| Tarea | Estado | Prioridad | Fecha | Responsable | Notas |
|---|---|---|---|---|---|
| Definir 20 ganchos para el primer mes de contenido | Sin empezar | Alta | 2026-07-29 | Ignacio + Marketing | — |
| Arrancar contenido: 10 publicaciones por semana | Sin empezar | Alta | 2026-08-01 | Ignacio + Marketing | 5 en cuenta personal + 5 en cuenta oficial de BLU. Empieza sin esperar al producto. |

### Infraestructura

| Tarea | Estado | Prioridad | Fecha | Responsable | Notas |
|---|---|---|---|---|---|
| Crear repositorio y entornos dev/producción | Listo | Alta | 2026-06-27 | Gabriel | — |
| Desplegar Next.js en Vercel | Sin empezar | Alta | 2026-08-03 | Gabriel | — |

### Marketing

| Tarea | Estado | Prioridad | Fecha | Responsable | Notas |
|---|---|---|---|---|---|
| Landing page con waitlist | Sin empezar | Alta | 2026-08-20 | Ignacio + Marketing | La hacen Ignacio y el de marketing juntos, no Gabriel. |
| Llegar a 100 personas en waitlist | Sin empezar | Alta | 2026-08-31 | Ignacio + Marketing | — |

### Negocio

| Tarea | Estado | Prioridad | Fecha | Responsable | Notas |
|---|---|---|---|---|---|
| Comprar dominio definitivo | Sin empezar | Media | 2026-08-08 | Ignacio | — |
| Cierre de mes 1 y ajuste de roadmap | Sin empezar | Media | 2026-08-31 | Ignacio | Revisar métricas, qué se cumplió y qué se mueve al mes 2. |

### Frontend

| Tarea | Estado | Prioridad | Fecha | Responsable | Notas |
|---|---|---|---|---|---|
| Definir sistema de diseño del frontend (componentes base) | En progreso | Alta | 2026-08-05 | Pablo | Coordinado con Gabriel para no chocar con el backend. Verificado en el fork (17-ago): avanzado en mobile/Flutter (tema + librería de widgets reutilizables), pero `apps/web` (Next.js) sigue siendo el boilerplate default — sin diseño propio todavía. |

---

## Actualización

- **Origen único:** Notion (base "Tareas BLU IA") — si cambias algo en Notion, pedir re-sincronización para volcarlo aquí.
- **Visualización:** arrastrar tarjetas se hace en [[Blu AI - Kanban]]; esta nota refleja el estado de Notion.
- Última sincronización: **14-ago-2026**.
- **Actualización manual 17-ago-2026:** marcadas como Listo "Documentar cumplimiento legal de la arquitectura" y "Enrutamiento multi-modelo básico" (confirmado por Gabriel). Además se confirmó el cambio de Supabase/Postgres a Cloudflare D1 + Vectorize (renombrada la tarea de Backend).
- **Auditoría de código 17-ago-2026** (fork `gpb-codes/Proyecto-BLU-IA`): "Esquema de base de datos" y "Login y registro funcionando" pasan a Listo (ya implementados). "Sistema BYOK" y "Definir sistema de diseño del frontend" pasan a En progreso (avance parcial, ver notas en la tabla). "Configurar Cloudflare D1..." y "Desplegar Next.js en Vercel" se confirman Sin empezar. Pendiente reflejar todo en Notion.
- **Reorganización 17-ago-2026:** [[Blu AI - Kanban]] pasa de columnas por estado a columnas por responsable (Gabriel, Pablo, Ignacio, Ignacio + Marketing); el estado ahora se marca con casilla (✅ listo), 🔄 (en progreso) o ⚠️ (atrasada) dentro de cada tarjeta.