---
tags:
  - soybluia
  - bitacora
tipo: bitacora
estado: activo
prioridad: media
responsable: equipo
actualizacion: 24-ago-2026
---

# SoyBluAI - Bitacora de actualizaciones

> Registro de decisiones y cambios importantes. Lo más reciente arriba.
> Fuente: Notion (subpágina "Bitácora de actualizaciones" de SoyBluAI) · Sincronizado 14-ago-2026.

## 24 de agosto de 2026 (3) — README, template de marca y limpieza pendiente

- **README mejorado.** Se reescribió `README.md`: agrega una descripción del proyecto, enlaces por área (producto, evolución AI Work OS, marca, negocio, tareas), lista actualizada de templates (incluye el nuevo `SoyBluAI - Activo de marca`), instrucciones para forzar sync de Git manualmente, y una nota fijando que el nombre oficial es **SoyBluAI**.
- **Template de marca creado:** `Templates/SoyBluAI - Activo de marca.md`. Para documentar cualquier asset de marca nuevo (logo, banner, post, ícono) con un checklist de cumplimiento contra [[SoyBluAI - Marca]] (paleta, tipografía, símbolo, y una verificación explícita de que el wordmark usado dice "SoyBluAI" y no el "bluia"/"blu ia" antiguo).
- **Nombre del proyecto:** se confirma que sigue siendo **SoyBluAI** — ya ejecutado el 24-ago-2026 (ver [[SoyBluAI - Decisiones (ADRs)|ADR-004]] y [[SoyBluAI - Decisiones (ADRs)|ADR-005]]); no hubo cambios adicionales de naming en esta entrada.
- **Borrado de archivos huérfanos — pendiente, sin ejecutar.** Se pidió borrar los 28 archivos con nombre antiguo (`Blu AI - X.md` en la raíz, `Templates\BLU - X.md`). Esta sesión de trabajo remota no tiene una herramienta de borrado ni de ejecución de comandos en el dispositivo del usuario — solo puede leer y escribir archivos nuevos. Se generó `limpiar-archivos-viejos.ps1` (fuera de la bóveda, entregado como descarga) para que el equipo lo corra manualmente y borre esos 28 archivos.
- **Push a GitHub — pendiente de acción manual o del auto-sync.** Esta sesión tampoco tiene acceso a `git` en el dispositivo del usuario. La bóveda ya sincroniza sola (plugin Git: commit cada 10 min, push cada 30 min) — los cambios de esta sesión y los borrados que se hagan con el script van a subirse solos, o se puede forzar con `Ctrl/Cmd+P` → *Git: Commit and push* en Obsidian.

## 24 de agosto de 2026

- **Auditoría completa del vault e integración de la visión "AI Work Operating System".** Se leyeron las 20 notas existentes y se compararon contra una propuesta de evolución de producto (AI Workspace, Studios, Agent Builder, Workflow Builder, Mission Mode, SOUP/SOUP Lab, SoyBluAI Connect, MCP Marketplace, Asset Library, Permission System, Human-in-the-loop, AI Control Center, Templates). No se borró ni se reemplazó ninguna nota existente.
  - **6 notas nuevas creadas:** [[SoyBluAI - Studios y Mission Mode]], [[SoyBluAI - Agent Builder y Marketplace]], [[SoyBluAI - Workflow Builder y Automatizacion]], [[SoyBluAI - SOUP y AI Core]], [[SoyBluAI - Conectores, MCP y Assets]], [[SoyBluAI - Decisiones (ADRs)]].
  - **9 notas actualizadas** (extensión, no reemplazo): [[Bienvenido]], [[SoyBluAI - Vision]], [[SoyBluAI - Agentes]], [[SoyBluAI - Gateway y Modelos]], [[SoyBluAI - Memoria compartida]], [[SoyBluAI - Skills y mini-apps]], [[SoyBluAI - Roadmap y estado]], [[SoyBluAI - Cumplimiento y Seguridad]] y esta misma bitácora.
  - **2 contradicciones directas detectadas y registradas sin resolver en silencio:** (1) "SOUP Lab" (desarrollar experimentalmente un modelo propio) vs. la decisión del 18-ago-2026 de descartar el homelab/entrenamiento desde cero — se propone lectura de reconciliación (SOUP = programa de fine-tuning ya en marcha) en [[SoyBluAI - Decisiones (ADRs)|ADR-001]], pendiente de confirmar; (2) "SoyBluAI Local" (Ollama/LM Studio/llama.cpp) vs. la decisión del 17-ago-2026 de descartar Ollama del gateway — conflicto real, sin resolución propuesta, ver [[SoyBluAI - Decisiones (ADRs)|ADR-002]].
  - **Decisión de alcance (ADR-003):** la nueva visión se incorpora como roadmap P0/P1/P2 (ver [[SoyBluAI - Roadmap y estado]]), no reemplaza el plan de 3 meses ya en curso (Mes 1 agosto → Mes 3 octubre, meta 500 usuarios de pago en 6 meses). Solo el Permission System por agente, Human-in-the-loop, Agent Builder básico y Memory 2.0 se marcan P0 dentro del roadmap ampliado, por ser prerrequisito de seguridad.
  - **No se reorganizó la estructura del vault** (se evaluó la estructura de carpetas por área propuesta en la visión nueva y se descartó por ahora: la estructura plana actual, con prefijo `SoyBluAI -`, sigue siendo adecuada para el tamaño del vault).
  - **Naming (versión inicial de esta entrada):** se detectó que la visión nueva usaba "SoyBluAI" mientras el vault usaba "Blu AI" / "BLU IA" — se registró como pendiente de confirmación de negocio (ADR-004, versión inicial).

- **Rebranding ejecutado: "Blu AI" / "BLU IA" → "SoyBluAI".** El mismo día, el equipo confirmó que el nombre oficial del proyecto es **SoyBluAI**, con alcance completo (marca, nombres de feature, nombres de archivo del vault). Se ejecutó sobre las 26 notas del vault (las 20 originales + las 6 nuevas de esta misma fecha):
  - Nombre de marca: "Blu AI" / "BLU IA" → **SoyBluAI** en todo el vault.
  - Nombres de feature con prefijo "Blu": **SoyBluAI Code**, **SoyBluAI Chat**, **SoyBluAI Light**, **SoyBluAI Flash**, **SoyBluAI Ultra**, **SoyBluAI Memory**, **SoyBluAI Connect**, **SoyBluAI Local**.
  - Archivos renombrados de `Blu AI - X.md` a `SoyBluAI - X.md` (con `Blu AI - Blu Chat.md` → `SoyBluAI - Chat.md` y `Blu AI - Blu Code.md` → `SoyBluAI - Code.md`, para no duplicar el prefijo), y todos los wikilinks internos actualizados.
  - Tag `blu` → `soybluia` en el frontmatter de todas las notas.
  - **Sin tocar:** los slugs de repositorio reales (`gpb-codes/blu-ai`, `blutechrobotics/Proyecto-BLU-IA`) y el comando CLI `npx blu-code` — son identificadores de infraestructura, no prosa de marca; renombrarlos en la documentación sin renombrar el repo/paquete real generaría enlaces y comandos incorrectos. Tampoco se reescribió el contenido factual de entradas históricas de esta bitácora (solo la mención de marca dentro de ellas), ni el wordmark en minúsculas `"blu ia"` de los assets de marca ya generados (29-jul-2026) — esos archivos siguen diciendo "blu ia" hasta que se regeneren.
  - Detalle completo en [[SoyBluAI - Decisiones (ADRs)|ADR-004]] (actualizado a Accepted).

## 24 de agosto de 2026 (2) — Auditoría de templates/notas + Brand Book

- **Recepción y revisión de `BLU_IA_Brand_Book_1.pdf`** (V1 · 2026, subido por el equipo el mismo día). Contiene paleta de color, tipografía (Inter/Sora), símbolo "Convergencia" y reglas de uso, tono/manifiesto — y define el wordmark oficial como **"bluia"** (minúsculas, sin espacio).
  - **Conflicto detectado:** el wordmark "bluia" del Brand Book contradice el rebranding a **SoyBluAI** ejecutado horas antes ese mismo día (ver entrada anterior, ADR-004). Se registró el conflicto y se preguntó al equipo en lugar de resolverlo en silencio.
  - **Confirmación del equipo:** *"SoyBluAI sigue siendo el nombre"*. El Brand Book se trata como **activo desactualizado** (necesita regenerar el wordmark), no como motivo para revertir el rebranding. Detalle completo en la nueva nota [[SoyBluAI - Marca]].
  - Color, tipografía, símbolo y reglas de uso del Brand Book **no dependen del nombre** y se adoptan sin cambios — ya coincidían con la paleta usada en `banner-viewer.html` y con una entrada previa de esta bitácora (29-jul-2026), así que no hay conflicto ahí.
- **Auditoría de templates y notas existentes** (a pedido de Gabriel, "mejora los templates y todas las notas, antes haz una auditoría"). Hallazgos y correcciones aplicadas:
  - **Nota de marca nueva:** [[SoyBluAI - Marca]] — no existía documentación central de identidad visual pese a que el Brand Book es directamente relevante.
  - **Bug en `Templates/SoyBluAI - Prompt IA.md`:** la ruta de la bóveda de contexto para el prompt de OPENCODE apuntaba a `C:\Users\gabri\OneDrive\Desktop\trabajo\blu ai` (carpeta obsoleta) — corregida a `C:\Users\gabri\OneDrive\Desktop\blu-ai` (carpeta real conectada).
  - **Inconsistencia en `fecha_limite`:** `Templates/SoyBluAI - Nota de proyecto.md` la dejaba vacía (`""`, completar a mano) mientras `Templates/SoyBluAI - Tarea.md` la autocompletaba a hoy+7 días — no siempre aplica. Se estandarizó a manual (`""`) en ambos templates, con nota explicando el cambio.
  - **Bug en la Dataview query de [[Bienvenido]]:** filtraba por `FROM #blu` (tag anterior al rebranding) — no devolvía resultados desde que el tag pasó a `#soybluia`. Corregido a `FROM #soybluia`.
  - **Frontmatter inconsistente:** 12 notas no tenían el campo `actualizacion` (`Setup del equipo - dispositivos`, esta bitácora, [[SoyBluAI - Chat]], [[SoyBluAI - Clientes ideales]], [[SoyBluAI - Code]], [[SoyBluAI - Datasets - Catalogo]], [[SoyBluAI - Datasets y Personalizacion]], [[SoyBluAI - Kanban]], [[SoyBluAI - Metricas semanales]], [[SoyBluAI - Planes y monetizacion]], [[SoyBluAI - Stack tecnologico]], [[SoyBluAI - Web y Extension Chrome]]) — se agregó `actualizacion: 24-ago-2026`. `README.md` se dejó sin frontmatter YAML a propósito: es un readme de repositorio, no una nota de tipo `modulo`/`negocio` consultada por Dataview.
  - **`fase` no ordenable:** 16 notas con campo `fase` usaban texto libre (9 valores distintos), rompiendo el `SORT fase ASC` de [[Bienvenido]]. Se agregó `fase_orden` (numérico: Mes 1→1, Mes 2→2, Meses 4-6→4, por-definir→99) y se actualizó la query para ordenar por ese campo.
  - **`estado` sin vocabulario controlado** (8 valores libres distintos encontrados: activo, pendiente, planificacion, etc.) — se documenta como pendiente de menor prioridad, no se migró a la fuerza para no romper vistas/Kanban existentes sin acuerdo del equipo.
- **Nada se reorganizó ni se borró** fuera de lo listado arriba; los 28 archivos con nombre antiguo (`Blu AI - X.md`, `Templates\BLU - X.md`) siguen pendientes de borrado manual en el dispositivo (esta sesión no tiene permiso de borrado remoto).

## 18 de agosto de 2026 (8)

- **Definición de las bases de los tiers propios** (a pedido de Gabriel). Se actualizó [[SoyBluAI - Gateway y Modelos]] y todas las notas cruzadas:
  - **SoyBluAI Light** → base **DeepSeek** (versión estándar).
  - **SoyBluAI Flash** → base **DeepSeek Pro**.
  - **SoyBluAI Ultra** → base **Kimi K3** (Moonshot AI), con la advertencia de seguridad vigente de [[SoyBluAI - Cumplimiento y Seguridad]] (solo tareas sin datos personales, excluido del modo Auto por defecto, DPA pendiente).
  - **Aviso en producto para SoyBluAI Ultra:** al intentar usarlo, SoyBluAI mostrará una advertencia de que no se comparten los datos de usuario con el modelo y que, si el usuario envía datos sensibles, la responsabilidad es exclusiva del propio usuario.
- **Adopción de patrones de multiagente tipo `opencodex`** (18-ago-2026): se revisó [lidge-jun/opencodex](https://github.com/lidge-jun/opencodex) y se decidió usar funcionalidades similares para el orquestamiento multiagente y el llamado a otros agentes — sub-agentes en cualquier modelo/tier, control de superficie v1/v2, *combos* con failover/round-robin y routing `proveedor/modelo`. Documentado en [[SoyBluAI - Agentes]] y enlazado desde [[SoyBluAI - Gateway y Modelos]].
- **Nota dedicada Web y Extensión Chrome** (18-ago-2026): la web (Next.js 15: landing, pricing, login, panel, SoyBluAI Code web) y la extensión Chrome MV3 (side panel: chat, proyectos, nota a memoria) estaban dispersas en el vault sin nota propia. Se creó [[SoyBluAI - Web y Extension Chrome]] y se enlazó en el mapa de [[Bienvenido]] y la tabla de módulos de [[SoyBluAI - Vision]].
  - Se reemplazó la referencia anterior a "fine-tuning de Qwen/Llama" por DeepSeek (Light/Flash) y Kimi K3 (Ultra) en Gateway, Cumplimiento, SoyBluAI Chat, Vision y Roadmap. La postura de seguridad sobre Kimi no cambia.
- **Descartado el homelab / entrenar modelo propio desde cero** (18-ago-2026): se borró la nota `SoyBluAI - Servidor Local (Homelab)` — entrenar un modelo propio desde cero es demasiado costoso. La personalización se hará vía **datasets JSONL** para fine-tuning de los tiers (sobre DeepSeek/Kimi K3), ya documentado en [[SoyBluAI - Datasets y Personalizacion]]. Coherente con [[SoyBluAI - Gateway y Modelos]] (fine-tuning, no entrenamiento desde cero).

## 17 de agosto de 2026 (7)

- **Revisión de coherencia de todo el vault** (a pedido de Gabriel, tras agregar [[SoyBluAI - Datasets y Personalizacion]]). Se leyeron todas las notas y se corrigieron:
  - **[[SoyBluAI - Roadmap y estado]]:** sección "Roadmap a 3 meses" estaba duplicada íntegra (copiada dos veces) — se dejó una sola copia. La fila "Datos" seguía marcando la migración a Cloudflare D1 como "⚠️ en revisión", desactualizada desde que se confirmó el 17-ago — corregida.
  - **[[SoyBluAI - Vision]]:** enlace a [[SoyBluAI - Kanban]] duplicado en la sección de Estado — se dejó uno. El diagrama de arquitectura seguía listando **Ollama** pese a la decisión de descartarlo (ver entrada (6) más abajo, que ya lo señalaba como pendiente) — se quitó del diagrama y se agregó nota aclarando que Kimi es visión de producto, no un adapter implementado.
  - **[[SoyBluAI - Chat]]:** la tabla del Model Router recomendaba "Ollama → modelo local" para ejecución local, contradiciendo la decisión de descartarlo, y presentaba a Kimi como si ya estuviera activo — corregida con una nota aclaratoria.
  - **[[Bienvenido]] (sección "Cómo usar esta bóveda"):** tenía un error de una revisión anterior — decía que la bóveda se sincroniza con `gpb-codes/Proyecto-BLU-IA`, pero ese es el repo del **código del producto** (donde se hizo la auditoría técnica). El repo real de esta bóveda de notas es `gpb-codes/blu-ai`, tal como ya decían correctamente [[README]] y [[Setup del equipo - dispositivos]] desde el principio. Corregido para distinguir ambos repos explícitamente.
  - Sin cambios necesarios en [[SoyBluAI - Cumplimiento y Seguridad]] (ya auditado el 17-ago, sigue consistente), [[SoyBluAI - Agentes]], [[SoyBluAI - Code]], [[SoyBluAI - Clientes ideales]], [[SoyBluAI - Metricas semanales]], [[SoyBluAI - Planes y monetizacion]], [[SoyBluAI - Skills y mini-apps]], [[README]] ni [[Setup del equipo - dispositivos]].

## 17 de agosto de 2026 (6)

- **Nueva nota: [[SoyBluAI - Datasets y Personalizacion]].** Documenta el sistema para juntar señales de personalización (preferencias, feedback, memoria) y ejemplos para el fine-tuning de los tiers propios (SoyBluAI Light/Flash/Ultra). Decisión de formato: **JSONL, no JSON** (append-only, streaming, corrupción acotada a una línea, formato nativo de las APIs de fine-tuning de OpenAI/Anthropic/Together/Fireworks). Incluye ejemplos de los cuatro tipos de evento (`preference_update`, `feedback`, `memory_entry`, `finetune_example`), estructura de carpetas propuesta (`packages/memory/datasets/events/` vs `finetune/`), y cruce con [[SoyBluAI - Cumplimiento y Seguridad]] (anonimización y retención, ambas pendientes de definir en detalle). Enlazada desde [[SoyBluAI - Vision]] y el mapa de notas de [[Bienvenido]].

## 17 de agosto de 2026 (5)

- **Ronda de decisiones cerrando huecos de [[SoyBluAI - Cumplimiento y Seguridad]] (sección 9).** Gabriel respondió una tanda de preguntas sobre las decisiones pendientes del equipo:
  - **Ollama:** descartado — no se implementa en el gateway (pendiente actualizar el diagrama de [[SoyBluAI - Vision]]).
  - **Kimi/Moonshot AI y proveedores de IA en China:** se limitan a tareas sin datos personales, nunca prompts con datos identificables de usuarios; sigue pendiente firmar DPA antes de implementar cualquier uso.
  - **Responsable/DPO de privacidad:** Ignacio, como punto de contacto ante AEPD (España), la futura Agencia chilena y la Secretaría Anticorrupción y Buen Gobierno (México).
  - **Datos del bot de WhatsApp descontinuado:** eliminación completa, sin migrar ni anonimizar — falta solo definir el plazo de ejecución.
  - **Proveedor de storage de archivos:** Cloudflare R2.
  - **Proveedor de email transaccional:** Postmark.
  - **Zero Data Retention / Bedrock EU con Anthropic:** se evalúa más adelante, fuera del alcance de V1.
  - Todo esto se refleja en el documento (secciones 0, 2, 3, 4, 5, 6 y 9); los DPAs de los proveedores recién decididos (R2, Postmark) siguen pendientes de firmar.

## 17 de agosto de 2026 (4)

- **Entidad legal definida.** Confirmado por Gabriel: SoyBluAI operará como **una única entidad, constituida en México** — no habrá entidades separadas por mercado (Chile/México/España). Se actualiza [[SoyBluAI - Cumplimiento y Seguridad]] (secciones 0, 8 y 9), cerrando parcialmente ese gap (falta aún razón social y fecha de constitución). Consecuencias que se documentan como acciones a ejecutar, no evaluaciones abiertas:
  - **España/UE:** al no haber establecimiento en la UE, SoyBluAI necesita designar un **representante en la UE (Art. 27 GDPR)**.
  - **Chile:** al no constituirse entidad ahí, no aplican las obligaciones de facturación electrónica ante el SII; SoyBluAI opera como responsable extranjero bajo el alcance extraterritorial de la Ley 21.719. Queda como gap sin resolver si esa ley exige representante local en Chile — no se pudo confirmar con las fuentes disponibles.
  - **México** pasa a ser la jurisdicción de origen de SoyBluAI — el mercado donde el cumplimiento es más directo.

## 17 de agosto de 2026 (3)

- **Auditoría de consistencia de [[SoyBluAI - Cumplimiento y Seguridad]].** Revisión completa del documento contra el resto del vault y verificación externa de las fechas legales citadas.
  - **Desactualización corregida:** el documento seguía tratando la migración a Cloudflare D1 + Vectorize como "en revisión" (una de dos opciones), cuando ya estaba confirmada desde antes ese mismo día (ver entrada de arriba y [[SoyBluAI - Stack tecnologico]]). Se actualizó en las secciones 0, 2, 4, 6 y 9: ahora es una decisión cerrada pendiente de implementar (el fork auditado seguía en Prisma/PostgreSQL), y el riesgo de residencia de datos por el modelo edge de D1 pasa de "medio, si se migra" a "alto, con fecha límite" (Ley 21.719 de Chile, 1-dic-2026). Se corrigió el mismo problema (más una frase duplicada) en [[SoyBluAI - Memoria compartida]].
  - **Precisión sobre proveedores de IA:** se aclaró que Kimi (Moonshot AI) y el hosting de fine-tunes vía Together AI/Fireworks aparecen en la visión de producto ([[SoyBluAI - Vision]], [[SoyBluAI - Memoria compartida]]) pero no están confirmados como implementados — el fork solo tiene adapters de Anthropic/Gemini/OpenAI/OpenRouter. Se agregó **Ollama** (mencionado en el diagrama de Vision.md) al registro de subencargados de la sección 4, marcado como gap: falta confirmar si corre autohospedado o vía un tercero.
  - **Verificación externa de fechas legales:** Ley 21.719 de Chile (1-dic-2026), disolución del INAI en México, EU AI Act Art. 50 (2-ago-2026), fallo *Latombe* del Tribunal General de la UE (sep-2025), y PCI-DSS v4.0.1 — todas confirmadas correctas contra fuentes externas, sin errores encontrados.

## 17 de agosto de 2026 (2)

- **Política de menores de edad — versión definitiva.** Se actualiza [[SoyBluAI - Cumplimiento y Seguridad]] (sección 7). Primero se propuso "acceso completo desde los 13, control parental ≤12", lo que entraba en conflicto con las bases legales de España (14 sin representante), Chile y México (18 sin representante). Se ajustó a un modelo de dos niveles: **18+ acceso pleno y autoservicio; 13-17 solo con cuenta supervisada por un adulto** (consentimiento verificable, sin BYOK/SoyBluAI Code/memoria compartida, pago a nombre del adulto); **menores de 13, no permitido**. Al exigir consentimiento del representante para todo el rango 13-17 en los tres mercados, la política queda por encima del mínimo legal en los tres — se cierra el conflicto anterior. Quedan pendientes: mecanismo real de verificación de edad, especificación de producto del flujo de consentimiento, y validación legal local antes de lanzarlo.

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
- Se suma **Pablo** al equipo como desarrollador frontend. Es amigo de Gabriel y trabajarán en conjunto. Condiciones: 2% de equity con vesting a 4 años y cliff de 1 año, más $150 USD/mes a partir de que SoyBluAI llegue a 1,000 usuarios (misma estructura de hito que Gabriel). Equity comprometido total: Gabriel 10%, Seguridad 5% (sin cerrar), Pablo 2%. Ignacio conserva 83%.

## 28 de julio de 2026

- **Decisión mayor: se elimina WhatsApp como canal.** Meta prohíbe desde el 15 de enero de 2026 que proveedores de IA distribuyan asistentes de propósito general vía la WhatsApp Business API. SoyBluAI entraba directo en la categoría prohibida. La reapertura de marzo aplica solo a Europa y Brasil, con tarifa por mensaje que rompe la economía del plan barato. Se lanza como **app + web**.
- **Precio sube de $5 a $10/mes.** A $10, 500 usuarios dan los $5,000/mes en vez de necesitar 1,000. El plan con créditos (SoyBluAI pone las APIs) queda en $30/mes.
- **Diferenciador confirmado: SoyBluAI Code.** El enrutamiento multi-modelo ya está comoditizado (OpenRouter, Poe, TypingMind, Aymo). Lo que nadie hace bien en español es controlar proyectos de código desde el celular. Ese es el filo.
- **Stack actualizado: Supabase → Cloudflare (D1 + Vectorize).** Cambia la base de datos de Postgres/Supabase a Cloudflare D1 (SQLite) para memoria/datos, con Cloudflare Vectorize para la memoria vectorial (D1 no trae pgvector). ⚠️ *Falta definir solución de auth (D1 no la incluye) y si el hosting también se mueve de Vercel a Cloudflare Workers/Pages para aprovechar la latencia de edge. Ver alerta en [[SoyBluAI - Stack tecnologico]].*

## 25 de julio de 2026

Reporte técnico completo de SoyBluAI. 12,273 mensajes procesados, 54 usuarios por DM, 13 grupos activos. Auditoría de seguridad con 133 intentos de jailbreak y cero fugas. Detección de prospectos desactivada por dudas legales.

---

Relacionado: [[Bienvenido]] · [[SoyBluAI - Roadmap y estado]]
