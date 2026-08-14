---
tags:
  - blu
  - agentes
estado: planificacion
fase: Meses 4-6
responsable: equipo
tipo: modulo
---

# Blu AI â€” Agentes

> Blu no es un simple chatbot: es una plataforma de agentes que ejecutan tareas de extremo a extremo.

## Agentes definidos

| Agente | FunciÃ³n |
|--------|---------|
| **Plan** | Descomponer y planificar tareas |
| **Build** | Construir/implementar cambios |
| **Cowork** | ColaboraciÃ³n en tiempo real |
| **Research** | InvestigaciÃ³n y recopilaciÃ³n |
| **QA** | Pruebas y verificaciÃ³n |
| **Automation** | Workflows repetitivos |
| **Knowledge** | GestiÃ³n del conocimiento/memoria |

## Ejemplo tipo agente de desarrollo

> "Corrige el error de autenticaciÃ³n del registro."

Blu (vÃ­a [[Blu AI - Blu Code]]):

1. inspecciona el repositorio
2. localiza el error
3. analiza logs
4. modifica cÃ³digo
5. ejecuta tests
6. inicia la app y la prueba
7. corrige errores adicionales
8. crea commit y abre PR

Eso ya es un **agente de desarrollo**, no un chatbot.

## Contexto

Cada agente comparte la misma memoria y el mismo gateway ([[Blu AI - Memoria compartida]], [[Blu AI - Gateway y Modelos]]). Los proyectos pueden tener varios usuarios, cada uno con su agente/sesiÃ³n.
