---
tags:
  - soybluia
  - legal
  - cumplimiento
  - seguridad
  - privacidad
estado: borrador
fase: Mes 1 - Base
responsable: Gabriel
tipo: legal
actualizacion: 24-ago-2026
---

# SoyBluAI — Cumplimiento y Seguridad

> Arquitectura de cumplimiento legal y seguridad de SoyBluAI para **Chile, México y España**. Cierra la tarea de [[SoyBluAI - Kanban|Kanban]] *"Documentar cumplimiento legal de la arquitectura"*. Es un documento de arquitectura y política — no incluye implementación de código. Contiene una sección final de huecos y decisiones pendientes que el equipo debe resolver antes de tratarlo como aplicado en producción.
>
> **Revisión de consistencia 17-ago-2026:** auditoría completa contra el resto del vault (incluyendo el fork de código) y verificación externa de las fechas legales citadas. Cambios de esa revisión: (1) la migración de base de datos pasó de "en revisión" a confirmada — actualizado en todo el documento; (2) se aclara que Kimi y el hosting de fine-tunes vía Together AI/Fireworks son parte de la visión de producto, no adapters implementados hoy; (3) se agrega Ollama, ausente hasta ahora del registro de subencargados. Las fechas legales citadas (Chile Ley 21.719, disolución del INAI en México, EU AI Act Art. 50, fallo *Latombe*, PCI-DSS 4.0.1) se verificaron contra fuentes externas y no se encontraron errores.
>
> **Actualización 18-ago-2026:** se definió la base de los tiers propios ([[SoyBluAI - Gateway y Modelos]]): SoyBluAI Light → DeepSeek (estándar), SoyBluAI Flash → DeepSeek Pro, SoyBluAI Ultra → **Kimi K3** (Moonshot AI). La postura de seguridad sobre Kimi (punto 3 de la sección 2 y sección 4/5) se mantiene intacta y ahora aplica directamente al tier Ultra: solo tareas sin datos personales, excluido del modo Auto por defecto, DPA pendiente.
>
> **Actualización 24-ago-2026:** al integrar la visión de Agent Builder/Workflow Builder, se formaliza un **Permission System por agente** (permisos granulares por herramienta: files/GitHub/database, independiente de los roles owner/admin/editor/viewer de esta sección) y **Human-in-the-loop** para acciones sensibles (deploy, borrado, pagos, acciones externas) — ambos descritos en [[SoyBluAI - Workflow Builder y Automatizacion]], que reutiliza el estándar de MFA/auditoría ya exigido en la sección 6 de este documento, sin reemplazarlo. Además, la nueva visión propone "SoyBluAI Local" (Ollama/LM Studio/llama.cpp), lo que **contradice directamente** la decisión de esta misma sección (5) de descartar Ollama del gateway (17-ago-2026) — el conflicto se documenta sin resolver en [[SoyBluAI - SOUP y AI Core]] y [[SoyBluAI - Decisiones (ADRs)|ADR-002]]; esta sección y la 5 **no cambian** hasta que el equipo decida.

## 0. Alcance y supuestos

- Plataforma SaaS multi-dispositivo (Web, Windows, macOS, Android, iOS, extensión Chrome) — ver [[SoyBluAI - Vision]] y [[SoyBluAI - Stack tecnologico]].
- Mercados objetivo: **Chile, México y España**, con perfiles de cliente mayoritariamente hispanohablantes ([[SoyBluAI - Clientes ideales]]).
- Modelo de negocio freemium + BYOK ($10) + Créditos ($30), con Stripe como procesador de pagos ([[SoyBluAI - Planes y monetizacion]]).
- Gateway de IA multi-proveedor (Anthropic, Gemini, OpenAI, OpenRouter implementados; fine-tunes propios sobre DeepSeek/Kimi K3 vía Together AI/Fireworks en definición 18-ago-2026 — ver sección 5; **Ollama descartado del gateway, decisión 17-ago-2026**) + memoria compartida RAG con pgvector ([[SoyBluAI - Gateway y Modelos]], [[SoyBluAI - Memoria compartida]]).
- Este documento parte de la arquitectura descrita en el vault, actualizada al 17-ago-2026: la migración de PostgreSQL/Neon a Cloudflare D1 + Vectorize ya está **confirmada** (bitácora 17-ago-2026, cierra la revisión abierta el 28-jul), aunque el código del fork auditado ese mismo día todavía corre sobre Prisma/PostgreSQL — es una decisión cerrada pendiente de implementar, no una opción abierta entre dos escenarios.
- **Entidad legal (confirmado 17-ago-2026):** SoyBluAI operará como **una única entidad**, constituida en **México**, sirviendo los tres mercados (Chile, México, España) desde ahí — sin entidades separadas por país. Falta todavía la razón social exacta y la fecha de constitución (sección 9), pero la estructura ya está definida. Esto activa dos consecuencias directas: (1) al no tener establecimiento en la UE, SoyBluAI necesita representante legal en la UE (Art. 27 GDPR) para atender a usuarios de España; (2) para Chile, SoyBluAI opera como responsable extranjero bajo el ámbito extraterritorial de la Ley 21.719 — falta confirmar con abogado local si exige designar representante en Chile. Detalle en sección 8.

## 1. Tratamiento de datos de usuarios

| Categoría de dato | Ejemplos | Finalidad | Base legal — España/UE (GDPR) | Base legal — Chile (19.628 / 21.719) | Base legal — México (LFPDPPP reformada) |
|---|---|---|---|---|---|
| Identificación y contacto | Nombre, email, teléfono | Alta y gestión de cuenta, comunicaciones transaccionales | Art. 6.1.b — ejecución de contrato | Ejecución de contrato / consentimiento | Consentimiento tácito (regla general) |
| Credenciales de autenticación | Hash de contraseña, tokens OTP (SMS/WhatsApp), tokens de sesión/refresh | Autenticación y seguridad de la cuenta | Art. 6.1.b + 6.1.f (interés legítimo de seguridad) | Ejecución de contrato | Consentimiento tácito + deber de seguridad del responsable |
| Contenido generado por el usuario | Prompts, conversaciones, archivos subidos, notas de memoria compartida, código en SoyBluAI Code | Prestar el servicio (chat, memoria RAG, agentes, edición de código) | Art. 6.1.b; si el usuario introduce datos sensibles voluntariamente, tratar como categoría especial incidental (Art. 9) | Consentimiento / ejecución de contrato; cuidado reforzado si hay datos sensibles bajo 21.719 | Consentimiento expreso si hay datos sensibles |
| API keys BYOK de terceros | Claves de Anthropic/OpenAI/Gemini del usuario, cifradas AES-256-GCM | Permitir que el usuario use sus propias keys | Art. 6.1.b | Ejecución de contrato | Consentimiento tácito |
| Datos de uso y telemetría | Eventos de producto, logs de aplicación, IP, información de dispositivo | Analítica, soporte, prevención de fraude/abuso | Art. 6.1.f (interés legítimo), con opción de oposición para analítica no esencial | Interés legítimo / ejecución de contrato | Consentimiento tácito |
| Datos de pago | Token de Stripe, últimos 4 dígitos, marca de tarjeta (SoyBluAI **no** almacena el PAN completo) | Cobro de suscripción | Art. 6.1.b | Ejecución de contrato | Consentimiento tácito + normativa financiera aplicable |
| Comunicaciones de soporte | Tickets, correos de soporte | Atención al cliente | Art. 6.1.b / 6.1.f | Ejecución de contrato | Consentimiento tácito |
| Datos de marketing | Waitlist, suscripción a newsletter/contenido | Marketing directo | Art. 6.1.a — consentimiento explícito | Consentimiento | Consentimiento expreso |
| Menores de edad | Fecha de nacimiento / edad declarada en el registro; para 13-17 además contacto y consentimiento verificable de padre/madre/tutor | **18+:** acceso pleno, autoservicio. **13-17:** permitido solo con cuenta supervisada por un adulto (consentimiento + funciones restringidas). **Menores de 13:** no permitido. Política de producto actualizada 17-ago-2026 — detalle completo en sección 7 | Art. 8 GDPR / LOPDGDD (España permite autoconsentimiento desde los 14; SoyBluAI exige representante hasta los 18 igualmente, por diseño de producto, más estricto que el mínimo legal) | Consentimiento de representante legal para 13-17 (más estricto que "18 sin representante" documentado; ahora explícito) | Consentimiento de quien ejerce la patria potestad para 13-17 (LFPDPPP), ahora con flujo definido |

**Nota de diseño:** como SoyBluAI combina chat conversacional libre con memoria compartida entre proyectos, es razonablemente previsible que usuarios introduzcan datos sensibles (salud, afiliación sindical, orientación, datos biométricos si suben fotos, etc.) sin que el sistema los distinga de contenido normal. Esto se documenta como riesgo en la sección 6 y debería resolverse con una política de uso aceptable clara más que con detección automática en V1.

## 2. Residencia de datos y transferencias internacionales

### Estado actual de la arquitectura

- **Base de datos:** hoy en código PostgreSQL gestionado en Neon (región no confirmada en el vault, típicamente AWS us-east-1 salvo configuración explícita) con pgvector para RAG. **Migración confirmada** (bitácora 17-ago-2026, cierra la revisión abierta el 28-jul) a Cloudflare D1 (SQLite) + Vectorize — todavía no implementada en el fork auditado el 17-ago-2026.
- **Redis:** Upstash (región configurable, no confirmada).
- **Storage de archivos:** S3-compatible — **Cloudflare R2** (decisión 17-ago-2026); región/configuración de residencia todavía por definir (ver sección 9).
- **IA:** Claude (Anthropic) y GPT (OpenAI) procesan por defecto en EE.UU.; Gemini (Google) en infraestructura global de Google; OpenRouter enruta dinámicamente a múltiples proveedores y países según el modelo elegido; Kimi (Moonshot AI) tiene sede en China y no publica dónde residen los datos.

### Por qué esto importa por país

- **España/UE (GDPR):** cualquier transferencia de datos personales fuera del Espacio Económico Europeo (EE.UU., China, etc.) requiere un mecanismo válido: decisión de adecuación, Cláusulas Contractuales Tipo (SCC 2021) o normas corporativas vinculantes. El **EU-US Data Privacy Framework** sigue vigente en 2026 — el Tribunal General de la UE lo respaldó en septiembre de 2025 — pero hay una apelación pendiente ante el TJUE (caso *Latombe*, presentada en octubre de 2025) y el PCLOB (organismo de supervisión de EE.UU.) perdió quórum en enero de 2025, lo que genera riesgo real de una eventual invalidación ("Schrems III"). Por eso **no conviene depender solo del DPF**: cada proveedor en EE.UU. debería tener SCC 2021 firmadas y una Evaluación de Impacto de Transferencia (TIA) documentada como respaldo.
- **Chile (Ley 19.628 vigente / Ley 21.719):** la Ley 21.719 fue publicada el 13-dic-2024 y entra en **plena vigencia el 1-dic-2026** (todavía no rige hoy). Restringe las transferencias internacionales a países con "protección equivalente" y exige documentación probatoria del mecanismo usado. Como SoyBluAI ya transfiere datos a proveedores de IA en EE.UU. y potencialmente en otros países, conviene preparar ahora (cláusulas contractuales tipo con cada proveedor, registro de transferencias) para no llegar tarde a diciembre de 2026, en vez de esperar a la entrada en vigor.
- **México (LFPDPPP reformada, vigente desde el 21-mar-2025):** exige que el aviso de privacidad declare expresamente las transferencias a terceros — incluidos proveedores de IA en el extranjero — y su finalidad, con consentimiento tácito como regla general salvo datos sensibles (consentimiento expreso).

### Arquitectura recomendada

1. **Registro de subencargados y transferencias** (ver sección 4) como fuente única de verdad: proveedor, rol, país de procesamiento, mecanismo de transferencia, tipo de dato.
2. **Estrategia de residencia por segmento de usuario:** evaluar si usuarios de España/UE necesitan procesamiento dentro del EEE (por ejemplo, Claude vía Amazon Bedrock región Frankfurt/eu-central-1 en vez de la API directa de Anthropic) frente a aceptar transferencia bajo SCC + TIA. Con la migración a Cloudflare D1 ya confirmada (arquitectura edge, sin una única "región hogar" clara, a diferencia de Neon con región fija configurable), esta política de residencia debe definirse **antes** de implementar la migración, no después — ver riesgo elevado en la sección 6.
3. **Kimi / proveedores en China — postura confirmada (17-ago-2026), ahora base de SoyBluAI Ultra (18-ago-2026):** el tier SoyBluAI Ultra usa Kimi K3 (Moonshot AI) y se limita a tareas sin datos personales (ej. generación de código genérico), nunca prompts con datos identificables de usuarios. Sin residencia de datos pública, sujetos a legislación china de seguridad nacional (acceso potencial del Estado), sin DPA/SCC verificados — mientras no se firme un DPA y se complete una evaluación de transferencia, mantener a SoyBluAI Ultra excluido del modo Auto por defecto y bloqueado a nivel de producto para cualquier flujo que pueda incluir datos personales, en las tres jurisdicciones cubiertas por este documento. **Aviso en producto (18-ago-2026):** al intentar usar SoyBluAI Ultra, SoyBluAI muestra una advertencia explícita de que no compartirá los datos de usuario con el modelo y que, si el usuario envía datos sensibles por su cuenta, la responsabilidad es exclusiva del propio usuario.
4. **OpenRouter:** al ser un enrutador hacia múltiples proveedores, cada modelo detrás de OpenRouter es, en la práctica, un subencargado adicional. Recomendación: mantener un *allowlist* explícito de modelos/proveedores permitidos detrás de OpenRouter (excluyendo por defecto proveedores sin DPA verificado), en vez de exponer el catálogo completo.

## 3. Retención y eliminación de datos

| Tipo de dato | Retención propuesta | Mecanismo de eliminación |
|---|---|---|
| Cuenta activa (perfil, credenciales) | Mientras exista la cuenta | Solicitud de baja → eliminación de datos primarios en ≤30 días, purga de backups en el siguiente ciclo (≤90 días) |
| Conversaciones, prompts, memoria compartida | Indefinido mientras la cuenta esté activa, con control granular del usuario (borrar conversación/proyecto) | Borrado inmediato en DB primaria + purga de embeddings asociados en pgvector/Vectorize; purga de backups en el siguiente ciclo |
| Logs de aplicación / telemetría de producto | 12 meses | Rotación automática |
| Logs de seguridad y auditoría (accesos admin, cambios de permisos, exportaciones, inicios de sesión) | 24 meses | Rotación automática, acceso restringido a roles de seguridad |
| API keys BYOK cifradas | Mientras estén conectadas | Eliminación inmediata e irreversible al desconectar la integración |
| Datos de pago | SoyBluAI no almacena PAN; retención a cargo de Stripe según sus propias políticas (procesador con certificación PCI-DSS) | Gestionado por Stripe |
| Backups completos de base de datos | Rolling 30-90 días | Purga automática por antigüedad |
| Tickets y correos de soporte | 24 meses tras cierre | Eliminación o anonimización |
| Datos de marketing / waitlist | Hasta baja de suscripción o 24 meses de inactividad | Eliminación o anonimización |
| Logs retenidos por proveedores de IA (Anthropic, OpenAI, etc.) | Según política propia de cada proveedor (p. ej. Anthropic retiene ~30 días para confianza y seguridad salvo que se contrate *Zero Data Retention*) | Fuera del control directo de SoyBluAI — documentar en el registro de subencargados (sección 4) |
| Datos heredados del bot de WhatsApp (descontinuado) | Ninguna — **eliminación completa decidida (17-ago-2026)** | Borrado total de los 12.273 mensajes y datos de los 54 usuarios por DM (reporte 25-jul), sin migrar ni anonimizar; falta solo definir el plazo de ejecución (ver sección 9) |

**Flujo de eliminación recomendado (arquitectura, sin código):** solicitud del usuario (panel o soporte) → validación de identidad → eliminación en cascada (perfil, mensajes, embeddings de memoria, archivos en storage, API keys BYOK) → marca de "eliminación solicitada" con fecha para excluir el registro de backups en el próximo ciclo de purga → confirmación al usuario → registro del evento en el log de auditoría (sin contenido personal, solo metadatos de que ocurrió). Este flujo todavía no existe como automatización — hoy es un gap operativo (sección 9).

## 4. Acuerdos de tratamiento de datos (DPA) necesarios

Registro de encargados/subencargados de tratamiento (equivalente al Art. 30 GDPR), a mantener vivo:

| Proveedor | Rol | Datos que procesa | Sede/región conocida | DPA / SCC | Estado |
|---|---|---|---|---|---|
| Neon (PostgreSQL + pgvector) | Encargado (infraestructura de datos — en transición de salida hacia Cloudflare D1, migración confirmada) | Todos los datos de producto (hoy) | AWS, región configurable (no confirmada) | DPA estándar disponible | Por firmar/confirmar mientras siga en uso |
| Cloudflare (D1 / Vectorize / Workers / Pages / FLUX) | Encargado (infraestructura — migración confirmada 17-ago-2026, pendiente de implementar) | Datos de producto (tras la migración) + imágenes generadas | Red global tipo edge | Cloudflare Customer DPA | Por firmar/confirmar; **prioridad alta** — aclarar política de residencia por el modelo edge antes de implementar |
| Upstash (Redis) | Encargado (colas, rate limiting, presencia) | Metadatos operativos, posible caché de sesión | Región configurable | DPA disponible | Por firmar/confirmar |
| Stripe | Encargado (pagos) | Datos de pago tokenizados, identificación básica | EE.UU./UE según cuenta | DPA estándar de Stripe | Por firmar/confirmar |
| Cloudflare R2 (storage S3-compatible) | Encargado (archivos, mini-apps generadas) — proveedor decidido 17-ago-2026 | Archivos subidos por usuarios | Red global tipo edge (Cloudflare) | Cloudflare Customer DPA | Por firmar/confirmar; definir región/residencia igual que D1 |
| Anthropic (Claude) | Subencargado (IA) | Prompts y contenido enviado al modelo | EE.UU. por defecto (opción EU vía Amazon Bedrock, Frankfurt) | DPA vía consola + SCC 2021; por defecto **no** entrena modelos con datos de la API; existe modo *Zero Data Retention* para clientes enterprise | Por firmar/confirmar; evaluar ZDR |
| OpenAI (GPT) | Subencargado (IA) | Prompts y contenido | EE.UU. | DPA disponible (verificar términos vigentes) | Por firmar/confirmar |
| Google (Gemini + login OAuth) | Subencargado (IA) + proveedor de login | Prompts/contenido + datos de autenticación | Infraestructura global de Google | DPA de Google Cloud/Workspace | Por firmar/confirmar |
| OpenRouter | Subencargado (enrutador hacia múltiples proveedores de IA) | Prompts/contenido | Variable según modelo | Verificar DPA propio + de cada proveedor detrás | **Gap** — requiere *allowlist* de modelos permitidos |
| Moonshot AI (Kimi) | Subencargado (IA) — **base del tier SoyBluAI Ultra** (modelo **Kimi K3**, definido 18-ago-2026 en [[SoyBluAI - Gateway y Modelos]]); antes solo era visión de producto | **Solo tareas sin datos personales** — nunca prompts con datos identificables de usuarios; SoyBluAI Ultra queda excluido del modo Auto por defecto (postura confirmada 17-ago-2026, ratificada 18-ago-2026) | China (no confirmado públicamente) | No verificado | Postura definida; **igual requiere DPA antes de implementar** cualquier uso, incluso sin datos personales |
| Together AI / Fireworks (fine-tunes SoyBluAI Light/Flash/Ultra) | Subencargado (hosting de modelos propios) — igual que Kimi, **no confirmado como implementado**: `Gateway y Modelos.md` lista como implementados solo Anthropic/Gemini/OpenAI/OpenRouter (verificado 17-ago-2026) | Prompts/contenido (si se implementa) | No confirmado | No confirmado | Por firmar/confirmar antes de implementar |
| ~~Ollama~~ | **Descartado (decisión 17-ago-2026)** — no se implementará en el gateway; era solo parte de la visión inicial en [[SoyBluAI - Vision]] | N/A | N/A | N/A | Cerrado — no requiere DPA. Pendiente actualizar el diagrama en Vision.md para quitarlo |
| Groq (Whisper STT) | Subencargado (IA, voz) | Audio de voz del usuario | No confirmado | No confirmado | Por firmar/confirmar |
| ElevenLabs (TTS) | Subencargado (IA, voz) | Texto a convertir en voz | EE.UU./UE según plan | DPA disponible en planes empresariales | Por firmar/confirmar |
| Tavily / DuckDuckGo Lite | Subencargado (búsqueda web) | Consultas de búsqueda del usuario | No confirmado | No confirmado | Por firmar/confirmar |
| Vercel (hosting Next.js) | Encargado (infraestructura web) | Tráfico web, logs | Global/EE.UU. | DPA disponible | Por firmar/confirmar |
| Postmark (email transaccional) | Encargado — proveedor decidido 17-ago-2026 | Direcciones de correo, contenido de notificaciones | EE.UU. | DPA disponible | Por firmar/confirmar |

Recomendación: antes de dar de alta cualquier proveedor nuevo (o de cerrar la migración a Cloudflare), pasar por esta tabla y no activarlo en producción con datos reales hasta que la columna "Estado" diga DPA firmado.

## 5. Proveedores de IA — responsabilidades, transferencias internacionales y cláusulas contractuales

- **Claude (Anthropic):** actúa como **encargado de tratamiento** (Art. 28 GDPR) sobre lo que el usuario envía al modelo; SoyBluAI sigue siendo el responsable del tratamiento. Anthropic ofrece un DPA vía su consola que incorpora SCC 2021 para la transferencia UE→EE.UU., divulgación de subencargados y compromisos de seguridad/notificación de brechas. Por defecto **no** usa los datos de la API para entrenar sus modelos; para datos especialmente sensibles conviene evaluar el modo *Zero Data Retention* (enterprise) o enrutar vía Amazon Bedrock en Frankfurt para usuarios UE.
- **OpenAI (GPT):** rol equivalente de encargado; procesamiento en EE.UU. por defecto. Verificar vigencia y alcance exacto del DPA antes de habilitarlo como opción del gateway para datos de usuarios europeos.
- **Gemini (Google):** encargado de tratamiento vía los términos de Google Cloud/AI; además Google es proveedor de login OAuth, lo que agrega una segunda relación de tratamiento (autenticación) que conviene documentar por separado.
- **OpenRouter:** agrega una capa extra de indirección — cada modelo al que enruta es, en la práctica, un subencargado adicional con su propio país de procesamiento y sus propias garantías (o falta de ellas). No asumir que el DPA de OpenRouter cubre automáticamente a todos los proveedores detrás.
- **Kimi (Moonshot AI):** es la **base del tier SoyBluAI Ultra (modelo Kimi K3)** desde el 18-ago-2026 ([[SoyBluAI - Gateway y Modelos]]) — antes solo aparecía en la visión de producto. **Postura de producto confirmada (17-ago-2026) y ratificada (18-ago-2026): SoyBluAI Ultra se limita a tareas sin datos personales** (ej. generación de código genérico), nunca prompts con datos identificables de usuarios — excluido del modo Auto por defecto. Con sede en China, sujeta a legislación china de seguridad nacional que puede habilitar acceso estatal a los datos; no publica ubicación de sus centros de datos ni ofrece, hasta donde se pudo verificar, DPA o cláusulas contractuales estándar equivalentes a las de Anthropic/OpenAI. Aun limitado a tareas sin datos personales, sigue necesitando DPA antes de implementarse — volver a pasar por esta sección antes de habilitarlo en producción.
- **Fine-tunes propios (Together AI / Fireworks, sobre DeepSeek para Light/Flash y Kimi K3 para Ultra):** aunque el modelo es "propio" de SoyBluAI, el hosting es de un tercero — se necesita el mismo tratamiento contractual que con cualquier otro subencargado de IA. El tier Ultra (Kimi K3) hereda la postura de seguridad de Kimi de arriba. No está confirmado como implementado en el fork auditado el 17-ago-2026 (el propio `Gateway y Modelos.md` lista los adapters reales sin incluirlo) — tratar como pendiente de contrato antes de activarlo, no como algo ya en producción.
- **Ollama — descartado (decisión 17-ago-2026):** no se va a implementar en el gateway. Aparecía en el diagrama de arquitectura de [[SoyBluAI - Vision]] como parte de la visión inicial del ecosistema de modelos, pero el equipo decidió no incluirlo. No requiere DPA ni entrada en el registro de subencargados. Pendiente: actualizar el diagrama de Vision.md para quitarlo y evitar confusión futura.
- **Cláusulas mínimas a exigir a todo proveedor de IA:** (1) DPA firmado con SCC 2021 u otro mecanismo válido de transferencia; (2) compromiso explícito de no usar los prompts/datos del cliente para entrenar modelos sin opt-in; (3) plazos de retención y eliminación declarados; (4) divulgación de subencargados propios; (5) capacidad de responder solicitudes de derechos de los titulares (acceso, supresión) en cascada; (6) notificación de brechas de seguridad en un plazo definido (recomendado ≤72 horas desde que el proveedor la detecta).

## 6. Seguridad y riesgos

### Cifrado

- **En tránsito:** TLS 1.2+ (idealmente 1.3) en toda comunicación — API REST, WebSocket de chat/presencia, conexiones a la base de datos, llamadas a proveedores de IA y a storage.
- **En reposo:** cifrado nativo de la base de datos (Neon/Cloudflare D1), cifrado de storage de archivos, y cifrado de API keys BYOK con **AES-256-GCM** (ya documentado en [[SoyBluAI - Stack tecnologico]]). Recomendación adicional: mover la clave maestra de un simple valor de entorno a un gestor de secretos/KMS dedicado (AWS KMS, Cloudflare Secrets Store o equivalente) con rotación periódica, en vez de una variable de entorno estática.

### Gestión de acceso

- Extender el modelo de permisos por proyecto (owner/admin/editor/viewer, ya definido en [[SoyBluAI - Planes y monetizacion]]) a un modelo de **acceso interno del equipo**: mínimo privilegio para quien accede a producción, roles diferenciados para soporte vs. ingeniería, y **MFA obligatorio** para cualquier cuenta con acceso administrativo o a la base de datos de producción.
- Política de rotación de secretos (API keys de proveedores, clave maestra BYOK, credenciales de infraestructura).
- Revisión periódica de accesos (quién tiene qué permiso, retirar accesos al salir del equipo).

### Auditoría

- Log de auditoría de acciones sensibles: accesos administrativos, exportaciones de datos, eliminaciones, cambios de permisos en proyectos compartidos.
- El Kanban ya identifica la necesidad de certificaciones de seguridad a futuro (ISO 27001, SOC 2, EU Cloud CoC) — no son exigibles para operar en V1, pero conviene mantener desde ahora prácticas compatibles (control de acceso, cifrado, logs, gestión de incidentes) para no tener que rehacer arquitectura cuando se persigan esas certificaciones, algo relevante si SoyBluAI quiere vender a clientes corporativos.
- Recomendado: primera auditoría/pentest externo antes de abrir pagos a la waitlist (Mes 3 del roadmap).

### Respuesta a incidentes / notificación de brechas

- **España/UE:** notificación a la AEPD en un plazo de 72 horas desde que se tiene conocimiento de la brecha (Art. 33 GDPR), y a los afectados si hay alto riesgo (Art. 34).
- **Chile:** la Ley 21.719 introduce notificación obligatoria en 72 horas a la nueva Agencia de Protección de Datos Personales, exigible desde su plena vigencia (1-dic-2026). Recomendación: adoptar el estándar de 72 horas como práctica interna desde ya, aunque hoy no sea obligatorio bajo la Ley 19.628.
- **México:** la ley reformada exige informar a los titulares afectados sin dilación indebida ante vulneraciones que afecten significativamente sus derechos.

### Matriz de riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Exposición de API keys BYOK por fallo de cifrado o de gestión de la clave maestra | Media | Alto | KMS dedicado, rotación de clave maestra, auditoría de acceso al almacén de secretos |
| Filtración de datos personales hacia un proveedor de IA sin garantías adecuadas (p. ej. Kimi) | Media | Alto | Allowlist de proveedores por tipo de dato, excluir proveedores sin DPA del enrutamiento con datos personales |
| Incumplimiento de plazos de transferencia internacional al entrar en vigor la Ley 21.719 (Chile, dic-2026) | Alta si no se actúa antes | Alto (sanciones hasta 20.000 UTM o 4% de ingresos por reincidencia) | Cerrar SCC/registro de transferencias antes de dic-2026, no esperar a la entrada en vigor |
| Filtración cruzada de datos entre usuarios por bug de permisos en memoria compartida de proyectos | Baja-media | Alto (afecta confianza y puede ser brecha reportable) | Pruebas de aislamiento por proyecto, revisión de permisos antes de cada release que toque memoria |
| Brecha en un subencargado (proveedor cloud, IA, pagos) | Baja-media | Alto | DPA con obligación de notificación, cláusula de auditoría, diversificación de proveedores críticos |
| Datos de pago mal manejados (almacenamiento accidental de PAN, logs con datos de tarjeta) | Baja si se usa Stripe correctamente | Alto (incumplimiento PCI-DSS) | Nunca tocar el PAN en servidor propio, usar Stripe Elements/Checkout, revisar logs para asegurarse de que no capturan datos de tarjeta |
| Falta de automatización de retención/eliminación (proceso manual, riesgo de error humano) | Alta hoy (no existe automatización) | Medio-alto | Construir el flujo de eliminación en cascada descrito en la sección 3 antes de escalar usuarios |
| Ambigüedad de residencia de datos por el modelo edge de Cloudflare D1 (migración ya confirmada, pendiente de implementar) | Alta | Alto | Definir explícitamente política de residencia por región de usuario **antes de implementar** la migración — ya no es una decisión abierta, es un riesgo activo con fecha límite (Ley 21.719 de Chile, 1-dic-2026) |
| Ausencia de responsable de privacidad/DPO designado | Baja — **Ignacio designado 17-ago-2026** | Medio (bloquea respuesta a autoridades y a titulares) | Formalizar el rol: punto de contacto ante AEPD, la futura Agencia chilena y la Secretaría Anticorrupción y Buen Gobierno (México); evaluar si conviene apoyo externo dado el volumen regulatorio de tres jurisdicciones |
| Uso de OpenRouter sin control de qué proveedores hay detrás | Media | Medio-alto | Allowlist explícito, revisión periódica del catálogo permitido |
| Datos heredados del bot de WhatsApp descontinuado sin política definida | Baja — **eliminación decidida 17-ago-2026** | Medio | Ejecutar el borrado completo (falta solo definir el plazo) y confirmar que no queda copia más allá del ciclo de purga normal de backups |

## 7. Datos sensibles

### Contraseñas

- Hashing con **Argon2id** (recomendado) o, si no es viable en el stack elegido, **bcrypt** con factor de costo ≥ 12, siempre con sal única por contraseña.
- Nunca almacenar ni registrar contraseñas en texto plano, incluidos logs de aplicación y de errores.
- Rate limiting en intentos de login y en el flujo de OTP (SMS/WhatsApp), bloqueo temporal tras intentos fallidos repetidos.
- Flujo de reseteo de contraseña con token de un solo uso y expiración corta.

### Menores de edad

> **Política de producto definitiva (17-ago-2026):** SoyBluAI sí permite el uso por menores de edad, pero con un modelo de dos niveles pensado para no chocar con ninguna de las tres jurisdicciones:
>
> - **18 años o más:** registro estándar, autoservicio, sin restricciones ni intervención de terceros.
> - **13 a 17 años:** permitido, pero **solo mediante cuenta supervisada** — requiere contacto y consentimiento verificable de un padre/madre/tutor antes de activarse.
> - **Menores de 13 años:** no permitido en ninguna circunstancia.
>
> Esto resuelve el conflicto legal anterior: al exigir consentimiento del representante para *todo* el rango 13-17 en los tres mercados (en vez de solo para menores de 14 como exige España), SoyBluAI queda **por encima del mínimo legal**, no por debajo — no hay jurisdicción de las tres donde esto sea insuficiente. El piso duro de 13 años evita además la zona más sensible (tratamiento de datos de niños pequeños), alineado con el estándar que usa la gran mayoría de plataformas online aunque ninguna de las tres leyes locales lo exija expresamente a ese nivel.

**Cuenta supervisada (13-17 años) — qué implica:**

- **Alta:** el menor puede iniciar el registro, pero la cuenta queda inactiva hasta que un adulto confirma (flujo de doble opt-in: correo/contacto del padre/madre/tutor, confirmación explícita, registro con fecha y método guardado como evidencia auditable).
- **Titularidad de la cuenta y pago:** la suscripción y el método de pago quedan a nombre del adulto — el menor nunca introduce datos de tarjeta ni gestiona el billing directamente (esto también simplifica el cumplimiento PCI-DSS descrito más abajo).
- **Funciones restringidas para cuentas de menor:**
  - Sin BYOK — no administran sus propias API keys de terceros.
  - Sin SoyBluAI Code / conexión a repositorios externos (GitHub, etc.).
  - Memoria y proyectos no compartidos fuera del espacio supervisado del menor.
  - El adulto responsable debe poder ver/gestionar la cuenta (nivel de visibilidad exacto por definir en producto: ¿acceso total a conversaciones, o solo a configuración y actividad agregada?).
- **No** se usan datos de cuentas de menores para entrenar modelos, marketing o perfilado — más allá de lo que exija la ley, para reducir riesgo.

**Gaps abiertos (ver también sección 9):**

- **Verificación de edad:** hoy no hay mecanismo real, solo autodeclaración de fecha de nacimiento en el registro. Suficiente como punto de partida, pero conviene reforzarlo (ej. verificación del adulto vía tarjeta o ID) antes de escalar el volumen de cuentas de menores.
- **Definición de producto de "cuenta supervisada":** falta especificar el flujo exacto de consentimiento del adulto, el nivel de visibilidad/control que tiene sobre la cuenta del menor, y cómo se revoca.
- **Validación legal local:** este diseño reduce el riesgo respecto a la política anterior, pero sigue sin reemplazar la revisión de un abogado en cada uno de los tres mercados antes de lanzarlo en producción.

### Medios de pago

- SoyBluAI **no debe almacenar ni procesar directamente** números de tarjeta (PAN), CVV ni fecha de expiración: usar Stripe Checkout/Elements para que la captura ocurra en el frontend de Stripe o en campos tokenizados, de forma que SoyBluAI nunca "toque" el dato de tarjeta en su propio servidor.
- Con ese diseño, el alcance de cumplimiento **PCI-DSS** de SoyBluAI se reduce al nivel más bajo (equivalente a SAQ A), porque el manejo de datos de tarjeta queda tercerizado en Stripe, que mantiene su propia certificación PCI-DSS (versión actual 4.0.1).
- Verificar firma de webhooks de Stripe (evitar eventos falsificados) y que ningún log de aplicación capture accidentalmente payloads completos de pago.
- Documentar esto explícitamente en política interna: "ningún servicio de SoyBluAI debe recibir, almacenar o loguear el número de tarjeta completo".

## 8. Requisitos por mercado para operar legalmente

### Chile

- Marco vigente hoy: **Ley 19.628**. Marco que entra en plena vigencia el **1-dic-2026**: **Ley 21.719**, que crea una nueva Agencia de Protección de Datos Personales con potestad sancionatoria directa (reemplaza el rol del Consejo para la Transparencia en esta materia), exige base de licitud documentada para cada tratamiento, designación de un delegado de protección de datos, restringe transferencias internacionales a destinos con protección equivalente, incorpora derechos ARCO+ completos (acceso, rectificación, cancelación, oposición) y notificación de brechas en 72 horas. Sanciones: hasta 5.000 UTM (leves), 10.000 UTM (graves), 20.000 UTM (gravísimas), hasta 4% de ingresos anuales en Chile por reincidencia.
- Acción recomendada: usar los meses restantes antes de diciembre de 2026 como plazo de adecuación real (política de privacidad actualizada, registro de transferencias, designación de responsable) en vez de esperar a la fecha límite.
- Protección al consumidor (Ley del Consumidor / SERNAC) aplica a los términos de suscripción: derecho a retracto en compras a distancia, claridad en el cobro recurrente y en la cancelación — esto aplica independientemente de dónde esté constituida la empresa, por vender a consumidores en Chile.
- **Entidad legal confirmada (17-ago-2026): SoyBluAI no constituirá entidad en Chile** — operará como una única sociedad mexicana (sección 0). No aplican, entonces, las obligaciones de facturación electrónica ante el SII que sí aplicarían con una entidad chilena. En cambio, SoyBluAI opera como responsable de datos **extranjero** bajo el ámbito de aplicación extraterritorial de la Ley 21.719 (aplica a quien procese datos de personas en Chile aunque no esté domiciliado ahí, de forma similar al GDPR). **Gap:** no se pudo confirmar con las fuentes disponibles si la ley (o su reglamento, aún pendiente de publicarse antes de dic-2026) exige designar un representante local en Chile para responsables extranjeros — verificar con abogado local (sección 9).

### México

- **Jurisdicción de origen de SoyBluAI (confirmado 17-ago-2026):** la entidad matriz —y única— de SoyBluAI se constituye aquí (sección 0). Esto simplifica el cumplimiento en este mercado (SoyBluAI "es de casa"), pero significa que Chile y España se tratan como mercados donde opera sin presencia local — ver representante en la UE y gap de representante en Chile.
- Marco vigente: **Ley Federal de Protección de Datos Personales en Posesión de los Particulares**, reformada y en vigor desde el **21-mar-2025**. El INAI fue disuelto y sus funciones de protección de datos pasaron a la Secretaría Anticorrupción y Buen Gobierno.
- El aviso de privacidad que ya redactó el equipo (Kanban: "Redactar aviso de privacidad completo (LFPDPPP)", cerrado 25-jul-2026) debe revisarse contra la ley reformada (no la anterior), asegurando identidad del responsable —ahora que la razón social debería quedar definida, sección 9—, derechos ARCO completos, finalidades que requieren consentimiento expreso, y declaración de transferencias internacionales (incluidos los proveedores de IA en el extranjero). Publicarlo en la web sigue pendiente en el Kanban (fecha objetivo 26-ago-2026).
- Reglamento complementario de la ley reformada estaba pendiente de expedirse dentro de 90 días desde su publicación — verificar si ya se publicó y si introduce requisitos adicionales antes de cerrar el aviso de privacidad definitivo.
- Ley Federal de Protección al Consumidor aplica a la transparencia de suscripciones y cancelaciones.

### España (y UE en general, dado que GDPR es un marco común)

- Marco: **Reglamento General de Protección de Datos (UE 2016/679)** + **Ley Orgánica 3/2018 (LOPDGDD)**. Autoridad: **AEPD**.
- Requisitos clave: base legal explícita por tratamiento (Art. 6), Registro de Actividades de Tratamiento (Art. 30), evaluación de impacto (DPIA) recomendable dado que SoyBluAI combina IA a gran escala con memoria compartida entre usuarios — perfil de riesgo que suele justificar una DPIA aunque no sea automáticamente obligatoria; evaluar la designación de un Delegado de Protección de Datos (DPO) — no siempre obligatorio por umbral pero recomendable dado el tratamiento a gran escala de datos mediante IA; mecanismo de transferencia válido para todo proveedor fuera del EEE (sección 2); notificación de brechas en 72 horas a la AEPD; derechos de acceso, rectificación, supresión, limitación, portabilidad y oposición.
- **EU AI Act — Artículo 50 (obligaciones de transparencia):** entró en aplicación el **2 de agosto de 2026** (hace apenas unos días respecto a la fecha de este documento). Exige que los sistemas de IA que interactúan directamente con personas —como el chat de SoyBluAI— estén diseñados para que el usuario sepa que está interactuando con una máquina, salvo que sea evidente por el contexto. Como proveedor del sistema, SoyBluAI debe incorporar ese aviso de forma visible (por ejemplo, en el propio producto, no solo en términos legales) y no puede diluirlo con patrones de diseño engañosos.
- **Representante en la UE — ya no es condicional (Art. 27 GDPR):** con la entidad legal confirmada como una única sociedad mexicana sin establecimiento en la UE (sección 0), SoyBluAI necesita designar un representante en la UE para responder ante la AEPD y ante los titulares de datos en España. La excepción del Art. 27.2 (tratamiento solo ocasional, sin datos sensibles a gran escala) probablemente **no** aplica: SoyBluAI procesa a escala regular y puede tocar datos sensibles incidentalmente (nota de diseño, sección 1). Tratar como acción pendiente a ejecutar, no como evaluación abierta (sección 9).

## 9. Huecos y decisiones pendientes del equipo

- **Entidad legal — parcialmente cerrado (17-ago-2026):** confirmado que SoyBluAI operará como una única entidad, constituida en México (no una entidad separada por mercado). Falta todavía: razón social exacta y fecha de constitución. Esta decisión ya activa acciones concretas: (1) **representante en la UE obligatorio** (Art. 27 GDPR) para atender a España — falta designarlo, ver sección 8; (2) falta confirmar con abogado chileno si la Ley 21.719 exige representante local en Chile para responsables extranjeros — no se pudo confirmar con las fuentes disponibles; (3) el aviso de privacidad de México (sección 8) debería actualizarse con la identidad del responsable en cuanto se defina la razón social.
- **Política de residencia de datos para la migración a Cloudflare D1** (ya no es "si se migra" — la decisión está confirmada desde el 17-ago-2026, ver [[SoyBluAI - Stack tecnologico]] y [[SoyBluAI - Bitacora]]): falta definir qué implica el modelo edge de D1 para la residencia de datos de usuarios europeos, y completar la implementación (el fork auditado el 17-ago-2026 seguía en Prisma/PostgreSQL) antes de la fecha límite de la Ley 21.719 de Chile (1-dic-2026).
- **Hosting de Ollama — cerrado (17-ago-2026):** decidido no usarlo; se descarta del gateway. Ya no es un gap, solo queda actualizar el diagrama de [[SoyBluAI - Vision]] para reflejarlo (sección 5).
- **Proveedor de storage de archivos — decidido (17-ago-2026): Cloudflare R2.** Falta firmar el DPA y definir la región/política de residencia (mismo tema que la migración a D1, sección 2).
- **Proveedor de email transaccional — decidido (17-ago-2026): Postmark.** Falta firmar el DPA.
- **Postura sobre Kimi/Moonshot AI — decidida (17-ago-2026): limitar a tareas sin datos personales**, nunca prompts con datos identificables de usuarios (secciones 4 y 5). Falta firmar DPA antes de implementar cualquier uso, incluso limitado. La postura sobre **otros proveedores de IA en China** más allá de Kimi, y sobre el hosting de fine-tunes vía Together AI/Fireworks, sigue sin definir — ninguno de los dos está implementado todavía en el código (verificado 17-ago-2026).
- **Allowlist de modelos permitidos detrás de OpenRouter**, para no exponer el catálogo completo sin control de subencargados.
- **Responsable/DPO de privacidad — designado (17-ago-2026): Ignacio.** Falta formalizar el rol como punto de contacto ante la AEPD (España), la futura Agencia de Protección de Datos (Chile, desde dic-2026) y la Secretaría Anticorrupción y Buen Gobierno (México) — y evaluar si conviene apoyo externo dado que son tres marcos regulatorios distintos.
- **Firma efectiva de los DPAs** listados en la sección 4 con cada proveedor — hoy son "por confirmar", no firmados (incluye a los proveedores recién decididos: Cloudflare R2, Postmark).
- **Automatizar el flujo de eliminación de datos** (sección 3) — hoy no hay evidencia de que exista.
- **Datos del bot de WhatsApp descontinuado — decidido (17-ago-2026): eliminación completa**, sin migrar ni anonimizar (secciones 3 y 6). Falta solo definir y ejecutar el plazo.
- **Presupuesto/calendario para revisión legal local** en Chile, México y España — este documento es una arquitectura técnico-legal de referencia, no reemplaza la revisión de un abogado local en cada jurisdicción antes de publicar términos y avisos definitivos.
- **Cierre de la conversación con la persona de seguridad** ya listada en el Kanban (alcance, frecuencia, compensación) — condiciona buena parte de la ejecución de la sección 6 (auditoría, pentest, roadmap de certificaciones).
- **Zero Data Retention / Bedrock EU con Anthropic — decidido (17-ago-2026): evaluarlo más adelante, fuera del alcance de V1.** No se implementa ahora; revisar cuando haya más usuarios europeos o presupuesto para el costo/latencia adicional.
- **Política de menores de edad (cerrada 17-ago-2026, sin conflicto legal pendiente):** 18+ acceso pleno; 13-17 solo con cuenta supervisada por un adulto (consentimiento verificable, sin BYOK/SoyBluAI Code/memoria compartida, pago a nombre del adulto); menores de 13 no permitido. Ver detalle completo en sección 7. Falta todavía: (1) mecanismo real de verificación de edad (hoy solo autodeclaración), (2) especificación de producto del flujo de consentimiento y del nivel de visibilidad del adulto sobre la cuenta del menor, (3) validación con abogado local en cada uno de los tres mercados antes de habilitarlo en producción.
- **SoyBluAI Local (Ollama/LM Studio/llama.cpp) — nuevo gap (24-ago-2026):** contradice la decisión de la sección 5 de descartar Ollama. No se resuelve aquí — ver [[SoyBluAI - Decisiones (ADRs)|ADR-002]]. Mientras no haya decisión, esta sección sigue vigente sin cambios: Ollama descartado, no requiere DPA.
- **Permission System por agente y Human-in-the-loop — nuevo (24-ago-2026):** diseño conceptual en [[SoyBluAI - Workflow Builder y Automatizacion]], pendiente de implementación real (igual que el resto de esta sección 9). Debe pasar por la misma revisión de seguridad que el resto de accesos administrativos antes de dar a un agente capacidad de acción sobre datos de producción.

## Referencias

- [Ley 21.719: guía 2026 para cumplir con la ley de protección de datos en Chile](https://preyproject.com/es/blog/ley-de-proteccion-de-datos-en-chile)
- [EY México — Entrada en vigor de la nueva Ley Federal de Protección de Datos Personales en Posesión de los Particulares](https://www.ey.com/es_mx/technical/tax/boletines-fiscales/nueva-ley-federal-proteccion-datos-personal-posesion-particulares)
- [GT Law — Nueva Ley General de Protección de Datos (México, 2025)](https://www.gtlaw.com/en/insights/2025/3/nueva-ley-general-proteccion-de-datos)
- [EU-US Data Privacy Framework en 2026 — estado actual](https://europeanmartech.eu/blog/eu-us-data-privacy-framework-2026-status)
- [Anthropic API and GDPR: DPA, EU Data Residency & Compliance Guide](https://compound.law/en-DE/tools/anthropic-api/)
- [Kimi Data Handling & Privacy Considerations: Security Risk Analysis](https://aihackers.net/risks/kimi/)
- [Empresas preparando las obligaciones del AI Act en agosto de 2026 (Artículo 50)](https://www.spaincompliance.com/compliance/inteligencia-artificial/compliance-ai-act-obligaciones-transparencia-agosto-2026/)

---

Relacionado: [[SoyBluAI - Vision]] · [[SoyBluAI - Stack tecnologico]] · [[SoyBluAI - Gateway y Modelos]] · [[SoyBluAI - Memoria compartida]] · [[SoyBluAI - Roadmap y estado]] · [[SoyBluAI - Kanban]]
