---
tags:
  - soybluia
  - skills
  - mini-apps
estado: planificacion
fase: Meses 4-6
fase_orden: 4
responsable: equipo
tipo: modulo
actualizacion: 24-ago-2026
---

# SoyBluAI — Skills y mini-apps

> El sistema que hace a SoyBluAI **extensible**, el más interesante a largo plazo.
>
> **Actualización 24-ago-2026:** la sección "Plugins" de abajo se amplía y organiza bajo la marca **SoyBluAI Connect**, y el sistema MCP base (9 herramientas, ya ✅ en [[Bienvenido]]) se documenta como base de un futuro **MCP Marketplace** — ver detalle en la nota nueva [[SoyBluAI - Conectores, MCP y Assets]], que extiende esta sección sin reemplazarla.

## Mini-apps (base del sistema)

Proyectos interactivos generados dentro del chat:
- calendario, checklist, tracker
- guardados en la barra lateral
- personalizables

Son el **embrión del futuro sistema de Skills**.

## Sistema de Skills

En lugar de programar cada integración dentro del núcleo:

```
SoyBluAI
│
├── Skills
│   ├── coding
│   ├── browser
│   ├── excel
│   ├── powerpoint
│   ├── word
│   ├── email
│   ├── github
│   ├── docker
│   ├── databases
│   ├── research
│   ├── design
│   └── automation
│
└── Plugins
    ├── Slack
    ├── Notion
    ├── Discord
    ├── Jira
    └── etc.
```

Esto permite que SoyBluAI sea extensible por la comunidad y por el usuario, sin tocar el núcleo.

Ver también: [[SoyBluAI - Agentes]], [[SoyBluAI - Gateway y Modelos]], [[SoyBluAI - Conectores, MCP y Assets]] (SoyBluAI Connect, MCP Marketplace, Asset Library — nuevo 24-ago-2026).