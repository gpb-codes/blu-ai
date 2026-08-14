---
tags:
  - blu
  - agentes
---

# Blu AI — Agentes

> Blu no es un simple chatbot: es una plataforma de agentes que ejecutan tareas de extremo a extremo.

## Agentes definidos

| Agente | Función |
|--------|---------|
| **Plan** | Descomponer y planificar tareas |
| **Build** | Construir/implementar cambios |
| **Cowork** | Colaboración en tiempo real |
| **Research** | Investigación y recopilación |
| **QA** | Pruebas y verificación |
| **Automation** | Workflows repetitivos |
| **Knowledge** | Gestión del conocimiento/memoria |

## Ejemplo tipo agente de desarrollo

> "Corrige el error de autenticación del registro."

Blu (vía [[Blu AI - Blu Code]]):

1. inspecciona el repositorio
2. localiza el error
3. analiza logs
4. modifica código
5. ejecuta tests
6. inicia la app y la prueba
7. corrige errores adicionales
8. crea commit y abre PR

Eso ya es un **agente de desarrollo**, no un chatbot.

## Contexto

Cada agente comparte la misma memoria y el mismo gateway ([[Blu AI - Memoria compartida]], [[Blu AI - Gateway y Modelos]]). Los proyectos pueden tener varios usuarios, cada uno con su agente/sesión.