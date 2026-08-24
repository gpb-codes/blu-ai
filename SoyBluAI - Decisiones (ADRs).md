---
tags:
  - soybluia
  - adr
  - decisiones
tipo: decision
estado: activo
responsable: equipo
actualizacion: 24-ago-2026
---

# SoyBluAI — Decisiones de arquitectura (ADRs)

> Registro de decisiones arquitectónicas relevantes, formato ADR. Se crea esta nota (24-ago-2026) al integrar la visión de evolución de SoyBluAI hacia un "AI Work Operating System" con la documentación existente del vault. Decisiones de negocio/legal previas ya vivían distribuidas en [[SoyBluAI - Bitacora]] — esta nota es específica para decisiones de **arquitectura de producto** derivadas de esa integración.

## ADR-001 — SOUP como programa de fine-tuning, no entrenamiento desde cero

### Context
La nueva visión pide un "SOUP Lab" para desarrollar experimentalmente un modelo propio. El 18-ago-2026 el equipo descartó explícitamente entrenar un modelo desde cero (homelab), optando por fine-tuning de DeepSeek/Kimi K3 para los tiers SoyBluAI Light/Flash/Ultra ([[SoyBluAI - Bitacora]]).

### Decision
SOUP se define como el **nombre del programa de I+D de fine-tuning** que ya está en marcha (tiers Light/Flash/Ultra), no como reapertura del entrenamiento desde cero. "SOUP Lab" es la infraestructura de experimentación (datasets, evaluación, checkpoints) sobre ese mismo programa. Ver desarrollo completo en [[SoyBluAI - SOUP y AI Core]].

### Alternatives
(a) Tratar SOUP como un modelo nuevo entrenado desde cero → reabriría la decisión del 18-ago sin justificación nueva, contradice el argumento de costo ya usado para descartar el homelab. (b) No usar el nombre SOUP y mantener solo "tiers propios" → pierde la narrativa de producto de la nueva visión sin necesidad, ya que el contenido técnico es compatible.

### Consequences
Se puede avanzar con SOUP Lab (datasets + fine-tuning + evaluación) sin reabrir la decisión de costo del homelab. Requiere que el equipo confirme explícitamente esta lectura antes de comunicar "SOUP" externamente, para no generar expectativa de un modelo entrenado desde cero.

### Status
**Proposed** — pendiente de confirmación explícita por Gabriel/equipo.

---

## ADR-002 — SoyBluAI Local (Ollama/LM Studio/llama.cpp): revertir el descarte o mantenerlo

### Context
El 17-ago-2026 el equipo descartó Ollama del gateway ("no se implementa"), decisión ratificada el 18-ago-2026 y ya reflejada en [[SoyBluAI - Vision]] (diagrama), [[SoyBluAI - Cumplimiento y Seguridad]] (secciones 4, 5, 9) y [[SoyBluAI - Chat]]. La nueva visión pide "SoyBluAI Local" con Ollama, LM Studio y llama.cpp como pilar de la arquitectura (Cloud AI + Local AI + SOUP).

### Decision
**No se toma una decisión aquí.** Se documenta el conflicto explícitamente (ver [[SoyBluAI - SOUP y AI Core]], sección 3) y se deja pendiente para que el equipo elija entre revertir el descarte (reabrir Ollama/LM Studio/llama.cpp bajo el paraguas SoyBluAI Local) o mantenerlo descartado y tratar SoyBluAI Local como roadmap indefinido.

### Alternatives
(a) Revertir: justificable por la promesa de privacidad ya existente en [[SoyBluAI - Code]] ("el contenido local no sale de la máquina"), que es coherente con ejecución local de modelos. (b) Mantener el descarte: la razón original no está documentada en detalle (solo "descartado", sin justificación de costo/complejidad explícita como en el caso del homelab) — el equipo debería registrar el motivo si decide mantenerlo, para que quede trazable.

### Consequences
Mientras no haya decisión, SoyBluAI Local no entra al roadmap activo. Cualquier mención a Ollama en materiales de producto o marketing debe esperar esta resolución.

### Status
**Proposed** — bloqueada, requiere decisión explícita del equipo (recomendado: Gabriel, dueño técnico del gateway).

---

## ADR-003 — Alcance del "AI Work Operating System" frente a la capacidad real del equipo

### Context
El vault documenta un equipo de 3 personas (Gabriel: backend/gateway; Pablo: frontend, 2% equity; Ignacio: coordinación/negocio, 83%) con meta de lanzar V1 y cobrar en 3 meses (Mes 3 = octubre 2026) y llegar a 500 usuarios de pago en 6 meses ([[SoyBluAI - Roadmap y estado]], [[SoyBluAI - Metricas semanales]]). La nueva visión describe una plataforma de alcance mucho mayor: Studios (5), Agent Builder, Workflow Builder, Mission Mode, Marketplaces (Agent + MCP), SOUP Lab, AI Control Center, App Builder, Design Agent, Asset Library, SoyBluAI Connect ampliado — sin equipo adicional documentado para construirlo.

### Decision
La nueva visión se incorpora como **dirección de producto a mediano/largo plazo (roadmap P1/P2, y parte de P0 solo donde es prerrequisito de seguridad)**, no como reemplazo del plan de 3 meses ya en curso. El roadmap actualizado ([[SoyBluAI - Roadmap y estado]]) prioriza: (1) lo que ya estaba en marcha para V1 (auth, BYOK, memoria RAG, SoyBluAI Code, Stripe); (2) lo nuevo que es prerrequisito de seguridad para cualquier agente con capacidad de acción (Permission System por agente, Human-in-the-loop, Agent Builder básico); (3) todo lo demás (Studios, Mission Mode, Marketplaces, Creative/Research Studio, App Builder, AI Control Center) como P1/P2, explícitamente no bloqueante para el lanzamiento de octubre.

### Alternatives
(a) Adoptar todo el alcance nuevo de inmediato → riesgo alto de no lanzar en Mes 3 con un equipo de 3 personas. (b) Ignorar la nueva visión y seguir solo el plan de 3 meses → pierde la dirección estratégica de largo plazo que el usuario pidió incorporar. Se eligió una vía intermedia: incorporar la visión como arquitectura de referencia y roadmap, sin comprometer el plan de corto plazo ya en ejecución.

### Consequences
El equipo debe tratar los documentos nuevos (Studios, Agent Builder, Workflow Builder, SOUP, Conectores/MCP/Assets) como **arquitectura de referencia para cuando llegue esa fase**, no como backlog inmediato. Se recomienda revisar esta priorización en el cierre de Mes 1 (31-ago-2026, ya programado en [[SoyBluAI - Kanban]]).

### Status
**Accepted** — refleja la instrucción explícita de "no asumir que se debe implementar inmediatamente" dada en la visión original.

---

## ADR-004 — Rebranding: "Blu AI" / "BLU IA" → "SoyBluAI"

### Context
Al integrar la visión del AI Work Operating System (24-ago-2026) se detectó que el vault usaba consistentemente "Blu AI" / "BLU IA" mientras que el prompt de la nueva visión usaba "SoyBluAI" en todo momento. La primera versión de esta ADR lo dejó como pendiente de confirmación de negocio, sin renombrar nada. **Ese mismo día**, el equipo confirmó explícitamente: *"el proyecto completo se llama SoyBluAI, así que si hay diferencias de compatibilidad en nombres cambialos por SoyBluAI"* — con alcance completo (nombre de marca, nombres de feature con prefijo "Blu" y nombres de archivo del vault).

### Decision
Se ejecuta el rebranding completo: "Blu AI" / "BLU IA" → **SoyBluAI** como nombre de marca; los nombres de feature con prefijo "Blu" pasan a usar el prefijo completo (**SoyBluAI Code**, **SoyBluAI Chat**, **SoyBluAI Light/Flash/Ultra**, **SoyBluAI Memory**, **SoyBluAI Connect**, **SoyBluAI Local**); y los nombres de archivo del vault pasan de `Blu AI - X.md` a `SoyBluAI - X.md` (con dos excepciones para evitar redundancia: `Blu AI - Blu Chat.md` → `SoyBluAI - Chat.md` y `Blu AI - Blu Code.md` → `SoyBluAI - Code.md`, en vez de `SoyBluAI - SoyBluAI Chat.md`). Los wikilinks internos se actualizaron en todo el vault para apuntar a los nuevos nombres. Se agregaron `Blu AI` y `BLU IA` como **aliases** en [[SoyBluAI - Vision]] para que los wikilinks/búsquedas con el nombre anterior sigan resolviendo.

### Alternatives
(a) Renombrar solo el nombre de marca, dejando los nombres de feature (Blu Code, Blu Chat, etc.) sin cambiar, por ser sub-marcas distintas del nombre de proyecto → descartada, el equipo pidió explícitamente el alcance completo. (b) Renombrar todo excepto los archivos, para no tocar wikilinks/historial de Git → descartada por la misma razón.

### Consequences
- **No se tocaron identificadores de infraestructura real**: los slugs de repositorio (`gpb-codes/blu-ai`, `blutechrobotics/Proyecto-BLU-IA`, `gpb-codes/Proyecto-BLU-IA`) y el comando CLI `npx blu-code` se dejaron **sin cambiar** — son identificadores externos reales (GitHub, npm), no prosa de marca; renombrarlos en la documentación sin renombrar la infraestructura real generaría documentación incorrecta. Si el equipo decide renombrar también el repo/paquete, es una tarea de infraestructura aparte.
- **No se reescribió el contenido factual de entradas históricas de la bitácora** (fechas, decisiones, cifras) — solo se actualizó la mención de marca dentro de ellas, igual que en el resto del vault, para mantener el vault internamente consistente sin alterar qué se decidió ni cuándo.
- El wordmark en minúsculas `"blu ia"` mencionado en la entrada histórica del 29-jul-2026 (manual de marca) se dejó **sin tocar** — es un registro histórico de un asset ya generado (PDF, ícono, favicon) que sigue diciendo "blu ia" hasta que alguien regenere esos archivos con el nuevo nombre. Queda como pendiente operativo, no de documentación.
- Los 4 ADRs de esta nota (incluida esta) y las 15 notas tocadas en la integración del 24-ago quedaron con el nombre nuevo de forma consistente.

### Status
**Accepted** — ejecutado el 24-ago-2026.

---

## ADR-005 — Wordmark del Brand Book ("bluia") frente al nombre "SoyBluAI"

### Context
Horas después de ejecutarse ADR-004, el equipo subió `BLU_IA_Brand_Book_1.pdf` (V1 · 2026) para pedir una mejora de templates y notas. El Brand Book define el wordmark oficial como **"bluia"** (minúsculas, sin espacio) — contradiciendo directamente el rebranding a SoyBluAI recién aceptado. En vez de asumir cuál de los dos documentos prevalecía, se registró el conflicto y se preguntó explícitamente al equipo.

### Decision
El equipo confirmó: *"SoyBluAI sigue siendo el nombre"*. Se decide: (1) el rebranding de ADR-004 **no se revierte**; (2) el Brand Book se trata como **activo de diseño desactualizado** — válido para paleta de color, tipografía, símbolo "Convergencia" y reglas de uso (no dependen del nombre), pero su wordmark textual queda pendiente de rediseño bajo "SoyBluAI"; (3) se documenta lo reutilizable en la nueva nota [[SoyBluAI - Marca]], dejando explícito qué queda pendiente de diseño (no de documentación).

### Alternatives
(a) Revertir el rebranding de ADR-004 y adoptar "bluia" como nombre oficial, por venir de un documento de marca formal → descartada, el equipo confirmó explícitamente lo contrario. (b) Ignorar el Brand Book hasta que alguien lo actualice manualmente → descartada: el color/tipografía/símbolo sí son reutilizables hoy, no tiene sentido dejarlos sin documentar por el conflicto de un solo campo (el wordmark).

### Consequences
- Color (`#0A34F5`, `#3D6BFF`, `#0B0F1A`, `#8E8E93`, `#F2F4F8`), tipografía (Inter/Sora) y reglas de uso del símbolo quedan adoptados en [[SoyBluAI - Marca]] sin cambios respecto al Brand Book.
- El wordmark visual de "SoyBluAI" (tratamiento tipográfico del nombre) queda como **tarea de diseño pendiente**, no resuelta en esta sesión de documentación.
- Los assets ya generados (29-jul-2026: mark-azul, wordmark-claro/oscuro, favicons, etc.) siguen usando el texto "blu ia"/"bluia" hasta que se regeneren — mismo tratamiento que ya establecía ADR-004 para esos archivos.

### Status
**Accepted** — confirmado el 24-ago-2026. Queda un ítem operativo abierto (rediseño del wordmark), no un ítem de decisión.

---

Relacionado: [[SoyBluAI - SOUP y AI Core]] · [[SoyBluAI - Roadmap y estado]] · [[SoyBluAI - Bitacora]] · [[SoyBluAI - Vision]] · [[SoyBluAI - Marca]]
