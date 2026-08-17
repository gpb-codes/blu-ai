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

## 17 de agosto de 2026 (5)

- **Ronda de decisiones cerrando huecos de [[Blu AI - Cumplimiento y Seguridad]] (sección 9).** Gabriel respondió una tanda de preguntas sobre las decisiones pendientes del equipo:
  - **Ollama:** descartado — no se implementa en el gateway (pendiente actualizar el diagrama de [[Blu AI - Vision]]).
  - **Kimi/Moonshot AI y proveedores de IA en China:** se limitan a tareas sin datos personales, nunca prompts con datos identificables de usuarios; sigue pendiente firmar DPA antes de implementar cualquier uso.
  - **Responsable/DPO de privacidad:** Ignacio, como punto de contacto ante AEPD (España), la futura Agencia chilena y la Secretaría Anticorrupción y Buen Gobierno (México).
  - **Datos del bot de WhatsApp descontinuado:** eliminación completa, sin migrar ni anonimizar — falta solo definir el plazo de ejecución.
  - **Proveedor de storage de archivos:** Cloudflare R2.
  - **Proveedor de email transaccional:** Postmark.
  - **Zero Data Retention / Bedrock EU con Anthropic:** se evalúa más adelante, fuera del alcance de V1.
  - Todo esto se refleja en el documento (secciones 0, 2, 3, 4, 5, 6 y 9); los DPAs de los proveedores recién decididos (R2, Postmark) siguen pendientes de firmar.

## 17 de agosto de 2026 (4)

- **Entidad legal definida.** Confirmado por Gabriel: Blu operará como **una única entidad, constituida en México** — no habrá entidades separadas por mercado (Chile/México/España). Se actualiza [[Blu AI - Cumplimiento y Seguridad]] (secciones 0, 8 y 9), cerrando parcialmente ese gap (falta aún razón social y fecha de constitución). Consecuencias que se documentan como acciones a ejecutar, no evaluaciones abiertas:
  - **España/UE:** al no haber establecimiento en la UE, Blu necesita designar un **representante en la UE (Art. 27 GDPR)**.
  - **Chile:** al no constituirse entidad ahí, no aplican las obligaciones de facturación electrónica ante el SII; Blu opera como responsable extranjero bajo el alcance extraterritorial de la Ley 21.719. Queda como gap sin resolver si esa ley exige representante local en Chile — no se pudo confirmar con las fuentes disponibles.
  - **México** pasa a ser la jurisdicción de origen de Blu — el mercado donde el cumplimiento es más directo.

## 17 de agosto de 2026 (3)

- **Auditoría de consistencia de [[Blu AI - Cumplimiento y Seguridad]].** Revisión completa del documento contra el resto del vault y verificación externa de las fechas legales citadas.
  - **Desactualización corregida:** el documento seguía tratando la migración a Cloudflare D1 + Vectorize como "en revisión" (una de dos opciones), cuando ya estaba confirmada desde antes ese mismo día (ver entrada de arriba y [[Blu AI - Stack tecnologico]]). Se actualizó en las secciones 0, 2, 4, 6 y 9: ahora es una decisión cerrada pendiente de implementar (el fork auditado seguía en Prisma/PostgreSQL), y el riesgo de residencia de datos por el modelo edge de D1 pasa de "medio, si se migra" a "alto, con fecha límite" (Ley 21.719 de Chile, 1-dic-2026). Se corrigió el mismo problema (más una frase duplicada) en [[Blu AI - Memoria compartida]].
  - **Precisión sobre proveedores de IA:** se aclaró que Kimi (Moonshot AI) y el hosting de fine-tunes vía Together AI/Fireworks aparecen en la visión de producto ([[Blu AI - Vision]], [[Blu AI - Memoria compartida]]) pero no están confirmados como implementados — el fork solo tiene adapters de Anthropic/Gemini/OpenAI/OpenRouter. Se agregó **Ollama** (mencionado en el diagrama de Vision.md) al registro de subencargados de la sección 4, marcado como gap: falta confirmar si corre autohospedado o vía un tercero.
  - **Verificación externa de fechas legales:** Ley 21.719 de Chile (1-dic-2026), disolución del INAI en México, EU AI Act Art. 50 (2-ago-2026), fallo *Latombe* del Tribunal General de la UE (sep-2025), y PCI-DSS v4.0.1 — todas confirmadas correctas contra fuentes externas, sin errores encontrados.

## 17 de agosto de 2026 (2)

- **Política de menores de edad — versión definitiva.** Se actualiza [[Blu AI - Cumplimiento y Seguridad]] (sección 7). Primero se propuso "acceso completo desde los 13, control parental ≤12", lo que entraba en conflicto con las bases legales de España (14 sin representante), Chile y México (18 sin representante). Se ajustó a un modelo de dos niveles: **18+ acceso pleno y autoservicio; 13-17 solo con cuenta supervisada por un adulto** (consentimiento verificable, sin BYOK/Blu Code/memoria compartida, pago a nombre del adulto); **menores de 13, no permitido**. Al exigir consentimiento del representante para todo el rango 13-17 en los tres mercados, la política queda por encima del mínimo legal en los tres — se cierra el conflicto anterior. Quedan pendientes: mecanismo real de verificación de edad, especificación de producto del flujo de consentimiento, y validación legal local antes de lanzarlo.

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
