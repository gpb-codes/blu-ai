---
tags:
  - blu
  - soup
  - ai-core
  - modelos
  - conflicto
estado: conflicto-a-resolver
fase: por-definir
responsable: Gabriel
tipo: modulo
actualizacion: 24-ago-2026
---

# Blu AI — SOUP y AI Core

> Nota nueva (24-ago-2026). Contiene **dos contradicciones directas** con decisiones ya cerradas en el vault ([[Blu AI - Bitacora]], 17 y 18-ago-2026). Se documentan explícitamente en vez de resolverse en silencio, como exige el protocolo de auditoría. Ver también [[Blu AI - Decisiones (ADRs)|ADR-001 y ADR-002]].

## 1. AI Core — encuadre (sin conflicto)

La nueva visión pide que el gateway de modelos se presente como **AI Core**, con SOUP integrado dentro (no como producto aparte):

```
AI CORE
│
├── SOUP
├── GPT
├── Claude
├── Gemini
├── Kimi
└── Local Models
```

Esto es compatible con lo ya construido: [[Blu AI - Gateway y Modelos]] ya es, en la práctica, un AI Core — gateway multi-proveedor con adapters (Anthropic/Gemini/OpenAI/OpenRouter) + tiers propios (Blu Light/Flash/Ultra). 🟡 Clasificación: **existente, requiere renombrar/reencuadrar**, no reconstruir. Se actualizó [[Blu AI - Gateway y Modelos]] para reflejar el encuadre AI Core y ampliar los criterios del Model Router (calidad, velocidad, precio, context window, capabilities, tool support, disponibilidad, privacidad, cost limits).

## 2. 🔴 CONFLICTO 1 — SOUP Lab vs. "se descarta entrenar modelo propio desde cero"

**Lo que dice el vault (vigente, 18-ago-2026):** la bitácora registra explícitamente: *"Descartado el homelab / entrenar modelo propio desde cero (18-ago-2026): se borró la nota `Blu AI - Servidor Local (Homelab)` — entrenar un modelo propio desde cero es demasiado costoso. La personalización se hará vía datasets JSONL para fine-tuning de los tiers (sobre DeepSeek/Kimi K3)."* Los tiers propios de Blu (Light/Flash/Ultra) son **fine-tunes sobre modelos open-source existentes** (DeepSeek, Kimi K3), no modelos entrenados desde cero — ver [[Blu AI - Gateway y Modelos]] y [[Blu AI - Datasets y Personalizacion]].

**Lo que pide la nueva visión:** un "SOUP LAB" con Experiments, Datasets, Training, Fine-tuning, Evaluation, Checkpoints, Models, con el objetivo explícito de *"desarrollar experimentalmente un modelo propio que posteriormente pueda convertirse en el modelo oficial de SoyBluAI"*.

**Análisis:** no es necesariamente la misma decisión que se descartó. Lo descartado fue entrenar **desde cero** (homelab, sin partir de un modelo base). Lo que ya está en marcha — fine-tuning de DeepSeek/Kimi K3 para los tiers Light/Flash/Ultra — es, de hecho, la primera fase de un "SOUP Lab" bien entendido: Datasets (ya documentado en [[Blu AI - Datasets y Personalizacion]] y [[Blu AI - Datasets - Catalogo]]) + Fine-tuning (ya en roadmap) + Evaluation/Checkpoints (no documentado todavía). El riesgo es de **naming y expectativa**: si "SOUP" se entiende como "vamos a entrenar un modelo desde cero", contradice la decisión del 18-ago; si se entiende como "el programa de I+D de fine-tuning que ya existe, con nombre e infraestructura de experimentación formal", es una extensión coherente.

**Decisión propuesta (a confirmar por el equipo, ver ADR-001):** SOUP = el nombre del programa de I+D detrás de los tiers Blu Light/Flash/Ultra — fine-tuning sobre modelos open-source, **no** entrenamiento desde cero. "SOUP Lab" es la infraestructura de experimentación (datasets, evaluación, checkpoints) para ese programa, ya parcialmente documentada en [[Blu AI - Datasets y Personalizacion]]. Se documenta explícitamente como **iniciativa de I+D que evoluciona por fases**, no como un modelo terminado — tal como pide la nueva visión. Con esta lectura, **no hay contradicción real** con el 18-ago-2026, siempre que el equipo confirme que "modelo propio" no implica volver a evaluar entrenamiento desde cero.

## 3. 🔴 CONFLICTO 2 — BLU Local vs. "Ollama descartado"

**Lo que dice el vault (vigente, 17-ago-2026):** *"Ollama: descartado — no se implementa en el gateway"* (bitácora 17-ago-2026, ratificado 18-ago-2026, reflejado en [[Blu AI - Cumplimiento y Seguridad]] sección 4/5/9 y ya quitado del diagrama de [[Blu AI - Vision]]).

**Lo que pide la nueva visión:** "BLU Local" — integrar Ollama, LM Studio, llama.cpp, archivos y herramientas locales, combinable con Cloud AI + SOUP.

**Esto es una contradicción directa, no de matiz.** No se resuelve en esta nota. Se registra como decisión pendiente para el equipo (ver ADR-002): o bien (a) se revierte la decisión del 17-ago-2026 y se reabre Ollama/LM Studio/llama.cpp como parte de BLU Local, con la justificación de que la nueva visión de "AI Work Operating System" lo requiere para el pilar de código/desarrollo local (coherente con la promesa de privacidad de [[Blu AI - Blu Code]], que ya dice "el contenido local no sale de la máquina"); o bien (b) se mantiene el descarte y BLU Local se posterga indefinidamente como ⚪ **ROADMAP**, dejando claro que hoy no se va a implementar. **No se marca ninguna de las dos opciones como decidida** — queda para que el equipo (Gabriel) lo resuelva explícitamente.

## 4. Clasificación mientras no se resuelva el conflicto

- **SOUP (como nombre del programa de fine-tuning ya existente):** 🟡 existente, requiere renombrar/formalizar — no bloquea nada, se puede aplicar de inmediato sin esperar el ADR.
- **SOUP Lab (infraestructura de experimentación — evaluation, checkpoints):** 🟣 **EXPERIMENTAL** — no documentar como funcionalidad oficial hasta tener el ADR-001 confirmado.
- **BLU Local (Ollama/LM Studio/llama.cpp):** 🔴 **CONFLICTO**, sin resolver — no se agrega al roadmap activo hasta el ADR-002.

## 5. Model Router — ampliación (sin conflicto)

El Model Router ya existe (modo Auto, [[Blu AI - Blu Chat]] y [[Blu AI - Gateway y Modelos]]) y ya considera tarea (charla/código/investigación/agente) y calidad/velocidad/costo. La nueva visión pide ampliar los criterios: **calidad, velocidad, precio, context window, capabilities, tool support, disponibilidad, privacidad, cost limits.** 🟡 Existente, requiere actualización — se agregó como ampliación de criterios en [[Blu AI - Gateway y Modelos]], sin tocar la arquitectura de adapters ya implementada (78/78 tests pasando).

---

Relacionado: [[Blu AI - Gateway y Modelos]] · [[Blu AI - Datasets y Personalizacion]] · [[Blu AI - Cumplimiento y Seguridad]] · [[Blu AI - Bitacora]] · [[Blu AI - Decisiones (ADRs)]] · [[Blu AI - Vision]]
