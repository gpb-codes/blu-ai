---
tags:
  - soybluia
  - agentes
  - agent-builder
  - marketplace
estado: planificacion
fase: Meses 4-6
fase_orden: 4
responsable: equipo
tipo: modulo
actualizacion: 24-ago-2026
---

# SoyBluAI — Agent Builder y Agent Marketplace

> Nota nueva (24-ago-2026). Extiende [[SoyBluAI - Agentes]] — **no la reemplaza**. [[SoyBluAI - Agentes]] sigue siendo la nota de referencia para los 7 agentes de sistema (Plan, Build, Cowork, Research, QA, Automation, Knowledge) y la orquestación multiagente tipo `opencodex`. Esta nota cubre lo que faltaba: cómo un usuario crea **su propio agente** personalizado, y la visión (a futuro) de compartirlos.

## 1. Por qué es una nota separada y no un reemplazo

[[SoyBluAI - Agentes]] describe agentes **predefinidos por SoyBluAI** que ejecutan tareas de extremo a extremo, y la capa de orquestación multiagente (sub-agentes, combos, routing `proveedor/modelo`). Eso sigue vigente sin cambios. Lo que aporta la nueva visión es un **constructor** para que el usuario configure agentes propios (no solo use los 7 de sistema) — funcionalidad que no estaba documentada. Se clasifica 🔵 **NUEVO**.

## 2. Agent Builder — configuración

Un agente creado por el usuario se configura con:

- Nombre y avatar
- Modelo (cualquiera del gateway — ver [[SoyBluAI - Gateway y Modelos]]: tiers SoyBluAI Light/Flash/Ultra o proveedores externos)
- System Prompt y personalidad
- Memoria (qué parte de [[SoyBluAI - Memoria compartida]] puede leer/escribir)
- Herramientas y MCP (ver [[SoyBluAI - Conectores, MCP y Assets]])
- Permisos (ver sección 4 y el Permission System en [[SoyBluAI - Workflow Builder y Automatizacion]])
- Knowledge Base (documentos/fuentes propias del agente)
- Workflow asociado (opcional — ver [[SoyBluAI - Workflow Builder y Automatizacion]])
- Límites y presupuesto (tope de gasto/tokens, reutiliza el sistema de créditos de [[SoyBluAI - Planes y monetizacion]])

## 3. Arquitectura conceptual

```
Agent
├── Brain        → modelo + system prompt + personalidad (Gateway y Modelos)
├── Memory       → memoria propia del agente sobre Memoria compartida (Memory 2.0)
├── Tools        → Skills + MCP (Conectores, MCP y Assets)
├── Knowledge    → Knowledge Base propia (Memory 2.0 / Research Studio)
├── Permissions  → Permission System (Workflow Builder y Automatizacion)
└── Workflows    → Workflow Builder
```

Esto reutiliza toda la infraestructura ya construida o en roadmap (gateway, memoria, skills/MCP, permisos, workflows) — el Agent Builder no introduce un runtime nuevo, es la capa de configuración sobre lo que ya existe.

## 4. Relación con los agentes de sistema

Los 7 agentes de [[SoyBluAI - Agentes]] (Plan, Build, Cowork, Research, QA, Automation, Knowledge) pasan a ser, bajo esta arquitectura, **agentes de sistema preconfigurados** — el punto de partida que SoyBluAI ofrece por defecto. Un usuario puede clonarlos y personalizarlos vía Agent Builder, o crear agentes nuevos desde cero. No hay contradicción: es una generalización del modelo ya documentado.

## 5. Agent Marketplace (roadmap, no inmediato)

Posibilidad futura de compartir agentes: privados, compartidos (dentro de un proyecto/equipo), públicos, comerciales. Se documenta explícitamente como ⚪ **ROADMAP P2** — no se asume que deba implementarse de inmediato. Depende de: Agent Builder funcionando, Permission System maduro, y una política de moderación/seguridad para agentes públicos (a definir junto con [[SoyBluAI - Cumplimiento y Seguridad]] cuando llegue el momento).

## 6. Prioridad

Agent Builder (creación y configuración básica) es **P0** en el roadmap ampliado — es la base de Mission Mode, Studios y Workflow Builder. Agent Marketplace es **P2**. Ver [[SoyBluAI - Roadmap y estado]].

---

Relacionado: [[SoyBluAI - Agentes]] · [[SoyBluAI - Gateway y Modelos]] · [[SoyBluAI - Memoria compartida]] · [[SoyBluAI - Workflow Builder y Automatizacion]] · [[SoyBluAI - Conectores, MCP y Assets]] · [[SoyBluAI - Studios y Mission Mode]]
