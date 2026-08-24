# Bóveda SoyBluAI (blu-ai)

Bóveda de **Obsidian** del proyecto **SoyBluAI** — agente de IA multi-modelo con app web, código, memoria compartida y agentes. Documentación de producto, arquitectura, negocio y operación para todo el equipo (desarrollo, coordinación, marketing).

> Nombre oficial del proyecto: **SoyBluAI** (confirmado 24-ago-2026, ver [[SoyBluAI - Decisiones (ADRs)|ADR-004]]). Si encontrás "Blu AI" o "BLU IA" en algún lugar es una mención histórica o un asset de marca pendiente de actualizar — no un nombre alternativo vigente.

## Cómo empezar

1. Instala [Obsidian](https://obsidian.md).
2. Pide acceso a Gabriel (repo privado) y clona: `gh repo clone gpb-codes/blu-ai` (o GitHub Desktop / Working Copy / Termux).
3. Abre la carpeta como bóveda en Obsidian. Los complementos se instalan solos (Git sincroniza en background cada 10/30 min).

Guía paso a paso por dispositivo: [[Setup del equipo - dispositivos]].

## Punto de entrada

- [[Bienvenido]] — contexto del proyecto para el equipo, qué está construido y qué falta (empezar por acá).
- [[SoyBluAI - Vision]] — índice técnico: todos los módulos, arquitectura, estado.
- [[SoyBluAI - Roadmap y estado]] — qué se está construyendo y en qué orden (P0/P1/P2).
- [[SoyBluAI - Decisiones (ADRs)]] — decisiones de arquitectura registradas (formato ADR), incluye contradicciones detectadas y cómo se resolvieron.

## Contenido por área

**Producto / técnico**
[[SoyBluAI - Vision]] · [[SoyBluAI - Chat]] · [[SoyBluAI - Code]] · [[SoyBluAI - Web y Extension Chrome]] · [[SoyBluAI - Gateway y Modelos]] · [[SoyBluAI - Memoria compartida]] · [[SoyBluAI - Agentes]] · [[SoyBluAI - Skills y mini-apps]] · [[SoyBluAI - Datasets y Personalizacion]] · [[SoyBluAI - Datasets - Catalogo]] · [[SoyBluAI - Stack tecnologico]] · [[SoyBluAI - Cumplimiento y Seguridad]]

**Evolución del producto (AI Work Operating System, 24-ago-2026)**
[[SoyBluAI - Studios y Mission Mode]] · [[SoyBluAI - Agent Builder y Marketplace]] · [[SoyBluAI - Workflow Builder y Automatizacion]] · [[SoyBluAI - SOUP y AI Core]] · [[SoyBluAI - Conectores, MCP y Assets]]

**Marca**
[[SoyBluAI - Marca]] — paleta, tipografía, símbolo y reglas de uso (ver también `Templates/SoyBluAI - Activo de marca.md`).

**Negocio y operación**
[[SoyBluAI - Clientes ideales]] · [[SoyBluAI - Metricas semanales]] · [[SoyBluAI - Planes y monetizacion]] · [[SoyBluAI - Bitacora]]

**Tareas**
[[SoyBluAI - Tareas]] (backlog, 20 tareas, fuente Notion) · [[SoyBluAI - Kanban]] (tablero del sprint)

## Templates (`Templates/`)

Insertar con `Ctrl/Cmd + P` → *Templater: Insert template*:

- `SoyBluAI - Nota de proyecto` — nota de proyecto/módulo nuevo.
- `SoyBluAI - Tarea` — tarea individual.
- `SoyBluAI - Prompt IA` — prompt listo para Claude u opencode con el contexto del proyecto.
- `SoyBluAI - Activo de marca` — registrar un asset de marca nuevo (logo, banner, post, ícono) y chequear que cumple las reglas de [[SoyBluAI - Marca]].
- `Diaria` — nota diaria (Periodic Notes).

## Sincronización

- Auto commit cada 10 min · push/pull cada 30 min · pull al abrir Obsidian (plugin **Git**).
- Repo privado `gpb-codes/blu-ai` · rama `main` · merge automático.
- Para forzar una sincronización inmediata sin esperar el auto-commit: `Ctrl/Cmd + P` → *Git: Commit and push* (o el ícono de Git en la barra lateral).

## Complementos incluidos

Git · Local REST API (MCP, solo local) · Calendar · Kanban · Tasks · Projects · Periodic Notes · Templater · Dataview · MD Formatter

## Convención de nombres

- Notas de proyecto: prefijo `SoyBluAI - ` en la raíz de la bóveda.
- Templates: prefijo `SoyBluAI - ` dentro de `Templates/` (excepto `Diaria`, sin prefijo por convención de Periodic Notes).
- Tag principal en frontmatter: `soybluia`.
