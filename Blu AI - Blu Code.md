---
tags:
  - blu
  - code
  - cli
estado: pendiente
fase: Mes 2 - Producto
responsable: Gabriel
tipo: modulo
---

# Blu AI â€” Blu Code

> Pilar de la plataforma: una evoluciÃ³n del concepto OpenCode + Claude Code dentro de Blu.

## Dos modalidades

**Blu Code (Web)** â€” editor en el navegador:
- Editor Monaco + GitHub OAuth
- Editar cÃ³digo y commitear desde la web con GitHub conectado

**Blu Code Local (CLI/daemon)** â€” estilo Claude Code:
- Instalable con `npx blu-code`
- Herramientas locales en la mÃ¡quina del usuario: Read / Write / Edit / Bash / Grep / Glob
- Se conecta al backend en la nube (WS/HTTPS) â†’ **misma memoria, mismos agentes, mismo gateway**
- **Nunca sube el contenido de los archivos** al servidor salvo lo que el usuario pida compartir/commitear

## Alcance

```
Blu Code
â”‚
â”œâ”€â”€ Terminal
â”œâ”€â”€ VS Code
â”œâ”€â”€ JetBrains
â”œâ”€â”€ GitHub
â”œâ”€â”€ Git
â”œâ”€â”€ Debugger
â”œâ”€â”€ Tests
â”œâ”€â”€ Docker
â”œâ”€â”€ CI/CD
â”œâ”€â”€ Deploy
â””â”€â”€ Browser
```

## Privacidad

DiseÃ±o centrado en que el contenido local no sale de la mÃ¡quina salvo permiso explÃ­cito. Es un diferenciador de confianza frente a soluciones que suben todo a la nube.

Ver tambiÃ©n: [[Blu AI - Agentes]], [[Blu AI - Gateway y Modelos]].
