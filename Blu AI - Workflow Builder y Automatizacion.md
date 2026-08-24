---
tags:
  - blu
  - workflows
  - automation
  - permisos
  - human-in-the-loop
estado: planificacion
fase: Meses 4-6
responsable: equipo
tipo: modulo
actualizacion: 24-ago-2026
---

# Blu AI — Workflow Builder, Automation Hub y Human-in-the-loop

> Nota nueva (24-ago-2026). El agente **Automation** ya estaba nombrado en [[Blu AI - Agentes]] ("workflows repetitivos") pero sin diseño propio — esta nota lo desarrolla. También formaliza dos cosas que antes solo existían de forma implícita: el **sistema de permisos por agente** y la **aprobación humana** para acciones sensibles.

## 1. Workflow Builder

🔵 Nuevo. Editor visual de workflows basado en nodos. Soporta conceptualmente:

Triggers · Agents · Models · Tools · Conditions · Variables · Loops · Branching · Webhooks · APIs · MCP · Cron · Eventos · Human approval

Ejemplo:

```
Trigger → Agent → AI Model → Tool → Condition → Agent → Approval → Action
```

Se apoya en piezas que ya existen o están en roadmap: Agentes ([[Blu AI - Agentes]], [[Blu AI - Agent Builder y Marketplace]]), Gateway ([[Blu AI - Gateway y Modelos]]), Skills/MCP ([[Blu AI - Conectores, MCP y Assets]]). No requiere un motor de ejecución aparte del gateway + agentes ya planeados, solo la capa visual de composición.

## 2. Automation Hub

Centraliza automatizaciones por tipo de disparador: Scheduled · Event based · Webhook · Email · API · File events · Agent triggered.

Ejemplo:

```
Cada lunes 08:00 → Research Agent → Generar informe → QA → Notion → Enviar correo
```

Esto es una instancia concreta de un Workflow (sección 1) con trigger de tipo Cron. El Automation Hub es la vista de "workflows guardados y programados", no un sistema distinto.

## 3. Human-in-the-loop

🔵 Nuevo, importante para cumplimiento. Todo workflow o agente que pueda ejecutar una acción sensible debe poder pedir aprobación humana:

```
Agent → Action → Approval Required → User → Approve / Reject → Continue
```

Aplicable a: Deploy · Eliminación de datos/recursos · Envío de emails · Cambios en bases de datos · Pagos · Acciones externas (APIs de terceros).

**Cruce con lo ya documentado:** [[Blu AI - Cumplimiento y Seguridad]] (sección 3) ya describe un flujo de eliminación de datos con confirmación, y (sección 6) exige MFA y revisión de accesos para acciones administrativas. Human-in-the-loop es la generalización de ese principio a **cualquier agente o workflow**, no solo a las eliminaciones de datos de usuario. Se recomienda que, cuando se implemente, el flujo de aprobación reutilice el mismo log de auditoría ya exigido en esa nota (sección 6), en vez de crear uno paralelo.

## 4. Permission System (por agente)

🔵 Nuevo a nivel de agente — **distinto** del sistema de permisos por proyecto que ya existe (owner/admin/editor/viewer, documentado en [[Blu AI - Planes y monetizacion]] y referenciado en [[Blu AI - Cumplimiento y Seguridad]] sección 6). Ese sistema sigue vigente sin cambios y sigue siendo el control de acceso entre **personas** dentro de un proyecto.

Lo nuevo es un permiso **independiente por agente**, granular por herramienta:

```
Agent
│
├── Files
│   ├── Read ✓
│   ├── Write ✓
│   └── Delete ✕
│
├── GitHub
│   ├── Read ✓
│   ├── Commit ✓
│   └── Delete ✕
│
└── Database
    ├── Read ✓
    ├── Write ✓
    └── Drop ✕
```

**Por qué hace falta además del permiso de proyecto:** el permiso de proyecto controla qué puede ver/editar una *persona*; el Permission System de agente controla qué puede *hacer* un agente que actúa en nombre de esa persona (relevante sobre todo para Blu Code, que ya declara en su propia nota que "nunca sube el contenido de los archivos salvo lo que el usuario pida" — [[Blu AI - Blu Code]] — este sistema formaliza esa promesa como configuración explícita en vez de comportamiento fijo). Debe integrarse con la sección 6 de [[Blu AI - Cumplimiento y Seguridad]] (gestión de acceso, MFA, auditoría) cuando se implemente — mismo estándar de seguridad, alcance distinto (agente vs. persona).

## 5. Prioridad

Permission System (por agente) y Human-in-the-loop son **P0** — son requisito de seguridad antes de dar a cualquier agente o workflow capacidad de acción real (deploy, borrado, pagos), no una mejora posterior. Workflow Builder/Automation Hub como producto visual son **P1**. Ver [[Blu AI - Roadmap y estado]].

---

Relacionado: [[Blu AI - Agentes]] · [[Blu AI - Agent Builder y Marketplace]] · [[Blu AI - Cumplimiento y Seguridad]] · [[Blu AI - Conectores, MCP y Assets]] · [[Blu AI - Studios y Mission Mode]] · [[Blu AI - Roadmap y estado]]
