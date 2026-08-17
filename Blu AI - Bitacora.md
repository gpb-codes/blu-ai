---
tags:
  - blu
  - bitacora
tipo: bitacora
estado: activo
prioridad: media
responsable: equipo
---

# Blu AI - Bitacora de actualizaciones

> Registro de decisiones y cambios importantes. Lo más reciente arriba.
> Fuente: Notion (subpágina "Bitácora de actualizaciones" de BLU IA) · Sincronizado 14-ago-2026.

## 17 de agosto de 2026

- **Confirmado: migración de base de datos.** Se cierra la revisión abierta el 28-jul — la base de datos pasa de Supabase/PostgreSQL (Neon, pgvector) a **Cloudflare D1 (SQLite) + Vectorize**. Nota: D1 no es PostgreSQL, no trae pgvector nativo (por eso Vectorize para los vectores). Queda pendiente definir: solución de auth (D1 no la incluye), ORM/capa de acceso a datos (Prisma no soporta D1 nativamente), y si el hosting se mueve de Vercel a Cloudflare Workers/Pages.
- Marcadas como Listo: "Documentar cumplimiento legal de la arquitectura" y "Enrutamiento multi-modelo básico" (Gabriel).
- **Auditoría de código del fork `gpb-codes/Proyecto-BLU-IA`.** El repo oficial (`blutechrobotics/Proyecto-BLU-IA`) y el otro nombre citado en el vault (`gpb-codes/blu-ai`) no son accesibles desde esta sesión; se revisó en su lugar el fork clonado localmente. Hallazgos vs. el Kanban:
  - **Esquema de base de datos** y **Login y registro funcionando**: ya implementados (`schema.prisma` con 2 migraciones, AuthController completo con JWT+refresh, hash Argon2, test e2e) → pasan a Listo.
  - **Sistema BYOK**: el modelo `UserApiKey` ya prevé cifrado AES-256-GCM, pero falta el servicio/controlador real → pasa a En progreso.
  - **Diseño del frontend (Pablo)**: avanzado en mobile/Flutter (tema + widgets), pero `apps/web` sigue siendo el boilerplate de `create-next-app` → pasa a En progreso.
  - **Configurar Cloudflare D1** y **Desplegar Next.js en Vercel**: confirmado que siguen sin empezar (el código todavía usa Prisma/PostgreSQL, y `apps/web` no tiene contenido propio).

## 1 de agosto de 2026

Nota de estrategia de contenido: ningún guion debe asumir audiencia previa (ej. "me preguntan...", "la gente comenta..."). Todavía nadie conoce la marca — el objetivo de esta etapa es captar audiencia desde cero, no responder a una comunidad que aún no existe. Los ganchos deben plantearse como apertura ("voy a mostrarte...", "esto es...") y no como respuesta a interés previo.

## 29 de julio de 2026

- Manual de marca completo generado: concepto, paleta (#0A34F5 azul cobalto, #3D6BFF azul claro, #0B0F1A negro suave), ícono en claro/oscuro perfectamente centrado, favicon en 6 tamaños, wordmark "blu ia". PDF + zip con todos los PNG/SVG entregados directamente a Ignacio.
- Se suma **Pablo** al equipo como desarrollador frontend. Es amigo de Gabriel y trabajarán en conjunto. Condiciones: 2% de equity con vesting a 4 años y cliff de 1 año, más $150 USD/mes a partir de que BLU llegue a 1,000 usuarios (misma estructura de hito que Gabriel). Equity comprometido total: Gabriel 10%, Seguridad 5% (sin cerrar), Pablo 2%. Ignacio conserva 83%.

## 28 de julio de 2026

- **Decisión mayor: se elimina WhatsApp como canal.** Meta prohíbe desde el 15 de enero de 2026 que proveedores de IA distribuyan asistentes de propósito general vía la WhatsApp Business API. BLU entraba directo en la categoría prohibida. La reapertura de marzo aplica solo a Europa y Brasil, con tarifa por mensaje que rompe la economía del plan barato. Se lanza como **app + web**.
- **Precio sube de $5 a $10/mes.** A $10, 500 usuarios dan los $5,000/mes en vez de necesitar 1,000. El plan con créditos (BLU pone las APIs) queda en $30/mes.
- **Diferenciador confirmado: Blu Code.** El enrutamiento multi-modelo ya está comoditizado (OpenRouter, Poe, TypingMind, Aymo). Lo que nadie hace bien en español es controlar proyectos de código desde el celular. Ese es el filo.
- **Stack actualizado: Supabase → Cloudflare (D1 + Vectorize).** Cambia la base de datos de Postgres/Supabase a Cloudflare D1 (SQLite) para memoria/datos, con Cloudflare Vectorize para la memoria vectorial (D1 no trae pgvector). ⚠️ *Falta definir solución de auth (D1 no la incluye) y si el hosting también se mueve de Vercel a Cloudflare Workers/Pages para aprovechar la latencia de edge. Ver alerta en [[Blu AI - Stack tecnologico]].*

## 25 de julio de 2026

Reporte técnico completo de BLU. 12,273 mensajes procesados, 54 usuarios por DM, 13 grupos activos. Auditoría de seguridad con 133 intentos de jailbreak y cero fugas. Detección de prospectos desactivada por dudas legales.

---

Relacionado: [[Bienvenido]] · [[Blu AI - Roadmap y estado]]
