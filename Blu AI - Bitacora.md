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

## 14 de agosto de 2026

- **Cumplimiento y seguridad documentado:** se cierra la tarea de Kanban "Documentar cumplimiento legal de la arquitectura" con el nuevo documento [[Blu AI - Cumplimiento y Seguridad]] — tratamiento de datos por país, residencia y transferencias internacionales (GDPR, Ley 19.628/21.719 de Chile, LFPDPPP reformada de México), retención y eliminación, registro de DPAs por proveedor, riesgo de proveedores de IA (Claude, OpenAI, Gemini, OpenRouter, y **Kimi/Moonshot AI marcado como riesgo crítico** por falta de residencia de datos pública y de DPA verificado), matriz de riesgos, manejo de contraseñas/pagos, y requisitos legales por mercado. Kanban y Roadmap actualizados (4 tarjetas nuevas en "Sin empezar", tarjeta original movida a "Listo").
- **Gabriel toma la responsabilidad de elegir proveedor de storage S3-compatible y proveedor de email transaccional** — quedaban sin responsable asignado en el vault.
- **Decisiones legales pendientes del equipo** (no técnicas, salen del documento de cumplimiento):
  - Definir la entidad legal de Blu (razón social, país de constitución, una entidad o varias por mercado).
  - Postura sobre Kimi y proveedores de IA en China para datos personales (excluir, limitar a tareas sin datos personales, o firmar DPA).
  - Designar responsable de privacidad / DPO y contacto ante AEPD (España), la futura Agencia chilena (vigencia plena dic-2026) y la nueva autoridad mexicana (Secretaría Anticorrupción y Buen Gobierno).
  - Presupuesto y calendario para revisión legal local en Chile, México y España.
  - Cerrar la conversación pendiente con la persona de seguridad (alcance, frecuencia, compensación).
  - Definir mecanismo real de verificación de edad mínima.

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
