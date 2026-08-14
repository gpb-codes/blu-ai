---
tags:
  - blu
  - skills
  - mini-apps
estado: planificacion
fase: Meses 4-6
responsable: equipo
tipo: modulo
---

# Blu AI — Skills y mini-apps

> El sistema que hace a Blu **extensible**, el más interesante a largo plazo.

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

Ver también: [[Blu AI - Agentes]], [[Blu AI - Gateway y Modelos]].