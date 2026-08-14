---
kanban-plugin: basic
tags:
  - blu
  - tareas
  - kanban
source: Notion - Base "Tareas BLU IA"
estado: activo
tipo: tareas
---

# Blu AI - Kanban

> Tablero del sprint, generado desde [[Blu AI - Tareas]] (Notion). Arrastra las tarjetas entre columnas para actualizar el estado.

## Sin empezar

- [ ] **Firmar DPAs con proveedores críticos (Neon, Cloudflare/Upstash, Stripe, Anthropic, OpenAI, Google)** `📅 2026-08-31`
  - Responsable: Gabriel · Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base
  - Nota: Surge de [[Blu AI - Cumplimiento y Seguridad]] (sección 4): hoy ningún DPA está firmado, solo identificados como disponibles.

- [ ] **Decidir postura sobre Kimi/Moonshot AI y otros proveedores de IA en China para datos personales** `📅 2026-08-31`
  - Responsable: Gabriel · Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base
  - Nota: Sin residencia de datos pública ni DPA verificado; riesgo de acceso estatal bajo ley china. Ver [[Blu AI - Cumplimiento y Seguridad]] (secciones 2 y 5).

- [ ] **Designar responsable de privacidad / DPO y contacto ante AEPD, futura Agencia (Chile) y nueva autoridad (México)** `📅 2026-08-31`
  - Responsable: Ignacio · Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base
  - Nota: Hoy no hay nadie designado. Ver [[Blu AI - Cumplimiento y Seguridad]] (sección 9).

- [ ] **Confirmar región de datos definitiva (Neon vs. Cloudflare D1 + Vectorize) antes de recibir usuarios UE** `📅 2026-08-31`
  - Responsable: Gabriel · Prioridad: Alta · Area: Backend · Fase: Mes 1 - Base
  - Nota: La decisión de stack (en revisión desde bitácora 28-jul) tiene implicancias directas de residencia de datos para GDPR y Ley 21.719 (Chile). Ver [[Blu AI - Cumplimiento y Seguridad]] (sección 2).

- [ ] **Cerrar conversación con el de seguridad** `📅 2026-08-03`
  - Responsable: Ignacio · Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base
  - Nota: Definir alcance, frecuencia, compensación e incompatibilidades por su empleo actual antes de comprometer equity.

- [ ] **Definir sistema de diseño del frontend (componentes base)** `📅 2026-08-05`
  - Responsable: Pablo · Prioridad: Alta · Area: Frontend · Fase: Mes 1 - Base
  - Nota: Coordinado con Gabriel para no chocar con el backend.

- [ ] **Configurar Supabase: Postgres + pgvector + auth** `📅 2026-08-05`
  - Responsable: Gabriel · Prioridad: Alta · Area: Backend · Fase: Mes 1 - Base

- [ ] **Arrancar contenido: 10 publicaciones por semana** `📅 2026-08-01`
  - Responsable: Ignacio + Marketing · Prioridad: Alta · Area: Contenido · Fase: Mes 1 - Base
  - Nota: 5 en cuenta personal + 5 en cuenta oficial de BLU. Empieza sin esperar al producto.

- [ ] **Definir 20 ganchos para el primer mes de contenido** `📅 2026-07-29`
  - Responsable: Ignacio + Marketing · Prioridad: Alta · Area: Contenido · Fase: Mes 1 - Base

- [ ] **Desplegar Next.js en Vercel** `📅 2026-08-03`
  - Responsable: Gabriel · Prioridad: Alta · Area: Infraestructura · Fase: Mes 1 - Base

- [ ] **Firmar acuerdo con Pablo (frontend)** `📅 2026-08-01`
  - Responsable: Ignacio · Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base
  - Nota: Mismas condiciones que Gabriel en vesting: 4 años, cliff de 1 año.

- [ ] **Esquema de base de datos** `📅 2026-08-08`
  - Responsable: Gabriel · Prioridad: Alta · Area: Backend · Fase: Mes 1 - Base
  - Nota: Usuarios, proyectos, mensajes, memoria vectorial.

- [ ] **Publicar aviso de privacidad en la web** `📅 2026-08-26`
  - Responsable: Ignacio · Prioridad: Media · Area: Legal · Fase: Mes 1 - Base

- [ ] **Sistema BYOK con API keys encriptadas** `📅 2026-08-25`
  - Responsable: Gabriel · Prioridad: Alta · Area: Backend · Fase: Mes 1 - Base
  - Nota: El usuario mete su propia API key, guardada encriptada.

- [ ] **Cierre de mes 1 y ajuste de roadmap** `📅 2026-08-31`
  - Responsable: Ignacio · Prioridad: Media · Area: Negocio · Fase: Mes 1 - Base
  - Nota: Revisar métricas, qué se cumplió y qué se mueve al mes 2.

- [ ] **Llegar a 100 personas en waitlist** `📅 2026-08-31`
  - Responsable: Ignacio + Marketing · Prioridad: Alta · Area: Marketing · Fase: Mes 1 - Base

- [ ] **Login y registro funcionando** `📅 2026-08-12`
  - Responsable: Gabriel · Prioridad: Alta · Area: Backend · Fase: Mes 1 - Base

- [ ] **Comprar dominio definitivo** `📅 2026-08-08`
  - Responsable: Ignacio · Prioridad: Media · Area: Negocio · Fase: Mes 1 - Base

- [ ] **Landing page con waitlist** `📅 2026-08-20`
  - Responsable: Ignacio + Marketing · Prioridad: Alta · Area: Marketing · Fase: Mes 1 - Base
  - Nota: La hacen Ignacio y el de marketing juntos, no Gabriel.

- [ ] **Enrutamiento multi-modelo básico** `📅 2026-08-18`
  - Responsable: Gabriel · Prioridad: Alta · Area: Backend · Fase: Mes 1 - Base
  - Nota: Claude + Gemini + GPT, con selección de modelo según tipo de tarea.

## Listo

- [ ] **Documentar cumplimiento legal de la arquitectura (residencia, transferencias, certificaciones, retención, DPA)** `📅 2026-08-04`
  - Responsable: Gabriel · Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base
  - Nota: Cerrado 14-ago-2026. Documento completo en [[Blu AI - Cumplimiento y Seguridad]]: tratamiento de datos por país, residencia/transferencias (GDPR, Ley 19.628/21.719 Chile, LFPDPPP reformada México), retención y eliminación, DPAs por proveedor, riesgos de proveedores de IA (Claude/Kimi/OpenRouter/etc.), matriz de riesgos y requisitos por mercado (CL/MX/ES). Quedan decisiones pendientes del equipo — ver sección 9 del documento y las 4 tarjetas nuevas en "Sin empezar".

- [ ] **Crear repositorio y entornos dev/producción** `📅 2026-06-27`
  - Responsable: Gabriel · Prioridad: Alta · Area: Infraestructura · Fase: Mes 1 - Base

- [ ] **Redactar aviso de privacidad completo (LFPDPPP)** `📅 2026-07-25`
  - Responsable: Ignacio · Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base
  - Nota: Falta: identidad del responsable, derechos ARCO completos, finalidades que requieren consentimiento, y aviso integral en la web.

- [ ] **Firmar acuerdo con Gabriel** `📅 2026-07-28`
  - Responsable: Ignacio · Prioridad: Alta · Area: Legal · Fase: Mes 1 - Base



