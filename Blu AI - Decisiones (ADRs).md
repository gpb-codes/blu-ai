---
tags:
  - blu
  - adr
  - decisiones
tipo: decision
estado: activo
responsable: equipo
actualizacion: 24-ago-2026
---

# Blu AI — Decisiones de arquitectura (ADRs)

> Registro de decisiones arquitectónicas relevantes, formato ADR. Se crea esta nota (24-ago-2026) al integrar la visión de evolución de Blu hacia un "AI Work Operating System" con la documentación existente del vault. Decisiones de negocio/legal previas ya vivían distribuidas en [[Blu AI - Bitacora]] — esta nota es específica para decisiones de **arquitectura de producto** derivadas de esa integración.

## ADR-001 — SOUP como programa de fine-tuning, no entrenamiento desde cero

### Context
La nueva visión pide un "SOUP Lab" para desarrollar experimentalmente un modelo propio. El 18-ago-2026 el equipo descartó explícitamente entrenar un modelo desde cero (homelab), optando por fine-tuning de DeepSeek/Kimi K3 para los tiers Blu Light/Flash/Ultra ([[Blu AI - Bitacora]]).

### Decision
SOUP se define como el **nombre del programa de I+D de fine-tuning** que ya está en marcha (tiers Light/Flash/Ultra), no como reapertura del entrenamiento desde cero. "SOUP Lab" es la infraestructura de experimentación (datasets, evaluación, checkpoints) sobre ese mismo programa. Ver desarrollo completo en [[Blu AI - SOUP y AI Core]].

### Alternatives
(a) Tratar SOUP como un modelo nuevo entrenado desde cero → reabriría la decisión del 18-ago sin justificación nueva, contradice el argumento de costo ya usado para descartar el homelab. (b) No usar el nombre SOUP y mantener solo "tiers propios" → pierde la narrativa de producto de la nueva visión sin necesidad, ya que el contenido técnico es compatible.

### Consequences
Se puede avanzar con SOUP Lab (datasets + fine-tuning + evaluación) sin reabrir la decisión de costo del homelab. Requiere que el equipo confirme explícitamente esta lectura antes de comunicar "SOUP" externamente, para no generar expectativa de un modelo entrenado desde cero.

### Status
**Proposed** — pendiente de confirmación explícita por Gabriel/equipo.

---

## ADR-002 — BLU Local (Ollama/LM Studio/llama.cpp): revertir el descarte o mantenerlo

### Context
El 17-ago-2026 el equipo descartó Ollama del gateway ("no se implementa"), decisión ratificada el 18-ago-2026 y ya reflejada en [[Blu AI - Vision]] (diagrama), [[Blu AI - Cumplimiento y Seguridad]] (secciones 4, 5, 9) y [[Blu AI - Blu Chat]]. La nueva visión pide "BLU Local" con Ollama, LM Studio y llama.cpp como pilar de la arquitectura (Cloud AI + Local AI + SOUP).

### Decision
**No se toma una decisión aquí.** Se documenta el conflicto explícitamente (ver [[Blu AI - SOUP y AI Core]], sección 3) y se deja pendiente para que el equipo elija entre revertir el descarte (reabrir Ollama/LM Studio/llama.cpp bajo el paraguas BLU Local) o mantenerlo descartado y tratar BLU Local como roadmap indefinido.

### Alternatives
(a) Revertir: justificable por la promesa de privacidad ya existente en [[Blu AI - Blu Code]] ("el contenido local no sale de la máquina"), que es coherente con ejecución local de modelos. (b) Mantener el descarte: la razón original no está documentada en detalle (solo "descartado", sin justificación de costo/complejidad explícita como en el caso del homelab) — el equipo debería registrar el motivo si decide mantenerlo, para que quede trazable.

### Consequences
Mientras no haya decisión, BLU Local no entra al roadmap activo. Cualquier mención a Ollama en materiales de producto o marketing debe esperar esta resolución.

### Status
**Proposed** — bloqueada, requiere decisión explícita del equipo (recomendado: Gabriel, dueño técnico del gateway).

---

## ADR-003 — Alcance del "AI Work Operating System" frente a la capacidad real del equipo

### Context
El vault documenta un equipo de 3 personas (Gabriel: backend/gateway; Pablo: frontend, 2% equity; Ignacio: coordinación/negocio, 83%) con meta de lanzar V1 y cobrar en 3 meses (Mes 3 = octubre 2026) y llegar a 500 usuarios de pago en 6 meses ([[Blu AI - Roadmap y estado]], [[Blu AI - Metricas semanales]]). La nueva visión describe una plataforma de alcance mucho mayor: Studios (5), Agent Builder, Workflow Builder, Mission Mode, Marketplaces (Agent + MCP), SOUP Lab, AI Control Center, App Builder, Design Agent, Asset Library, BLU Connect ampliado — sin equipo adicional documentado para construirlo.

### Decision
La nueva visión se incorpora como **dirección de producto a mediano/largo plazo (roadmap P1/P2, y parte de P0 solo donde es prerrequisito de seguridad)**, no como reemplazo del plan de 3 meses ya en curso. El roadmap actualizado ([[Blu AI - Roadmap y estado]]) prioriza: (1) lo que ya estaba en marcha para V1 (auth, BYOK, memoria RAG, Blu Code, Stripe); (2) lo nuevo que es prerrequisito de seguridad para cualquier agente con capacidad de acción (Permission System por agente, Human-in-the-loop, Agent Builder básico); (3) todo lo demás (Studios, Mission Mode, Marketplaces, Creative/Research Studio, App Builder, AI Control Center) como P1/P2, explícitamente no bloqueante para el lanzamiento de octubre.

### Alternatives
(a) Adoptar todo el alcance nuevo de inmediato → riesgo alto de no lanzar en Mes 3 con un equipo de 3 personas. (b) Ignorar la nueva visión y seguir solo el plan de 3 meses → pierde la dirección estratégica de largo plazo que el usuario pidió incorporar. Se eligió una vía intermedia: incorporar la visión como arquitectura de referencia y roadmap, sin comprometer el plan de corto plazo ya en ejecución.

### Consequences
El equipo debe tratar los documentos nuevos (Studios, Agent Builder, Workflow Builder, SOUP, Conectores/MCP/Assets) como **arquitectura de referencia para cuando llegue esa fase**, no como backlog inmediato. Se recomienda revisar esta priorización en el cierre de Mes 1 (31-ago-2026, ya programado en [[Blu AI - Kanban]]).

### Status
**Accepted** — refleja la instrucción explícita de "no asumir que se debe implementar inmediatamente" dada en la visión original.

---

## ADR-004 — Nombre del proyecto: "Blu AI" (vault) vs. "SoyBluAI" (nueva visión)

### Context
Todo el vault usa consistentemente "Blu AI" / "BLU" / "BLU IA" como nombre del producto (marca ya definida en la bitácora del 29-jul-2026: paleta, ícono, wordmark "blu ia"). El prompt de la nueva visión usa "SoyBluAI" en todo momento.

### Decision
Se trata "SoyBluAI" como el mismo proyecto que "Blu AI", sin renombrar ninguna nota ni el manual de marca ya generado. No se asume que sea un rebranding — es una decisión de negocio que el equipo (Ignacio, dueño de marca/negocio) debe confirmar explícitamente si de verdad hay intención de cambiar el nombre público.

### Alternatives
Renombrar todo el vault a "SoyBluAI" ahora → riesgo de trabajo innecesario si "SoyBluAI" era solo la forma de referirse al proyecto en este prompt, no una decisión de rebranding real.

### Consequences
Ninguna nota se renombra. Si el equipo confirma un rebranding real, se abre una tarea aparte (fuera del alcance de esta integración) para actualizar manual de marca, dominios y menciones.

### Status
**Proposed** — sin acción, pendiente de confirmación de negocio.

---

Relacionado: [[Blu AI - SOUP y AI Core]] · [[Blu AI - Roadmap y estado]] · [[Blu AI - Bitacora]] · [[Blu AI - Vision]]
