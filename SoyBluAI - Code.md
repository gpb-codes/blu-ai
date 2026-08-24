---
tags:
  - soybluia
  - code
  - cli
estado: pendiente
fase: Mes 2 - Producto
responsable: Gabriel
tipo: modulo
---

# SoyBluAI — Code

> Pilar de la plataforma: una evolución del concepto OpenCode + Claude Code dentro de SoyBluAI.

## Dos modalidades

**SoyBluAI Code (Web)** — editor en el navegador:
- Editor Monaco + GitHub OAuth
- Editar código y commitear desde la web con GitHub conectado

**SoyBluAI Code Local (CLI/daemon)** — estilo Claude Code:
- Instalable con `npx blu-code`
- Herramientas locales en la máquina del usuario: Read / Write / Edit / Bash / Grep / Glob
- Se conecta al backend en la nube (WS/HTTPS) → **misma memoria, mismos agentes, mismo gateway**
- **Nunca sube el contenido de los archivos** al servidor salvo lo que el usuario pida compartir/commitear

## Alcance

```
SoyBluAI Code
│
├── Terminal
├── VS Code
├── JetBrains
├── GitHub
├── Git
├── Debugger
├── Tests
├── Docker
├── CI/CD
├── Deploy
└── Browser
```

## Privacidad

Diseño centrado en que el contenido local no sale de la máquina salvo permiso explícito. Es un diferenciador de confianza frente a soluciones que suben todo a la nube.

Ver también: [[SoyBluAI - Agentes]], [[SoyBluAI - Gateway y Modelos]].