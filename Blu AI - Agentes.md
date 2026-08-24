---
tags:
  - blu
  - agentes
estado: planificacion
fase: Meses 4-6
responsable: equipo
tipo: modulo
actualizacion: 24-ago-2026
---

# Blu AI — Agentes

> Blu no es un simple chatbot: es una plataforma de agentes que ejecutan tareas de extremo a extremo.
>
> **Actualización 24-ago-2026:** los 7 agentes de abajo pasan a entenderse como **agentes de sistema preconfigurados** — el punto de partida por defecto. Para crear agentes propios (nombre, avatar, modelo, permisos, herramientas, etc.) ver la nota nueva [[Blu AI - Agent Builder y Marketplace]], que extiende esta nota sin reemplazarla.

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

## Multiagente y llamado a otros agentes

Inspirado en proyectos tipo [`opencodex`](https://github.com/lidge-jun/opencodex) (proxy universal de proveedores para Codex/Claude Code), Blu adoptará funcionalidades similares para orquestar varios agentes y delegar trabajo entre ellos:

- **Sub-agentes en cualquier modelo:** un agente principal (p. ej. Plan o Build) puede invocar sub-agentes especializados que corren sobre distintos modelos/tiers del [[Blu AI - Gateway y Modelos]] (Blu Light/Flash/Ultra o proveedores externos), exponiéndolos en el selector de sub-agentes.
- **Control de superficie multiagente (v1/v2):** gestión de qué agentes/sub-agentes quedan visibles y enrutables en cada sesión, con cadenas de fallback si el modelo objetivo falla.
- **Combos de agentes/modelo:** un id virtual de agente con failover o round-robin ponderado entre proveedores (similar a los *combos* de opencodex), para no depender de un solo modelo.
- **Routing `proveedor/modelo`:** direccionar una subtarea a `deepseek/pro` o `kimi-k3/ultra` según su naturaleza, reutilizando el gateway existente.

Esto mantiene la arquitectura actual (memoria compartida + gateway) y añade una capa de orquestación agente-a-agente por encima del modo Auto. Ver también [[Blu AI - Gateway y Modelos]] (routing y combos) y [[Blu AI - Skills y mini-apps]].

---

Relacionado (nuevo, 24-ago-2026): [[Blu AI - Agent Builder y Marketplace]] · [[Blu AI - Workflow Builder y Automatizacion]] (Permission System por agente) · [[Blu AI - Studios y Mission Mode]] (Agent Studio, Mission Mode)