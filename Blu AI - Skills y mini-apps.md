---
tags:
  - blu
  - skills
  - mini-apps
estado: planificacion
fase: Meses 4-6
responsable: equipo
tipo: modulo
actualizacion: 24-ago-2026
---

# Blu AI — Skills y mini-apps

> El sistema que hace a Blu **extensible**, el más interesante a largo plazo.
>
> **Actualización 24-ago-2026:** la sección "Plugins" de abajo se amplía y organiza bajo la marca **BLU Connect**, y el sistema MCP base (9 herramientas, ya ✅ en [[Bienvenido]]) se documenta como base de un futuro **MCP Marketplace** — ver detalle en la nota nueva [[Blu AI - Conectores, MCP y Assets]], que extiende esta sección sin reemplazarla.

## Mini-apps (base del sistema)

Proyectos interactivos generados dentro del chat:
- calendario, checklist, tracker
- guardados en la barra lateral
- personalizables

Son el **embrión del futuro sistema de Skills**.

## Sistema de Skills

En lugar de programar cada integración dentro del núcleo:

```
Blu
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

Esto permite que Blu sea extensible por la comunidad y por el usuario, sin tocar el núcleo.

Ver también: [[Blu AI - Agentes]], [[Blu AI - Gateway y Modelos]], [[Blu AI - Conectores, MCP y Assets]] (BLU Connect, MCP Marketplace, Asset Library — nuevo 24-ago-2026).