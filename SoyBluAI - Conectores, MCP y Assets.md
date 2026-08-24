---
tags:
  - soybluia
  - conectores
  - mcp
  - assets
  - integraciones
estado: planificacion
fase: Meses 4-6
fase_orden: 4
responsable: equipo
tipo: modulo
actualizacion: 24-ago-2026
---

# SoyBluAI — Connect, MCP Marketplace y Asset Library

> Nota nueva (24-ago-2026). Extiende la sección "Plugins" de [[SoyBluAI - Skills y mini-apps]] (que ya nombraba Slack, Notion, Discord, Jira) y el sistema MCP base mencionado en [[Bienvenido]] ("Base del sistema MCP — 9 herramientas ✅"). No reemplaza esas notas: las organiza bajo la marca SoyBluAI Connect y agrega lo que faltaba (Asset Library, MCP Marketplace como ecosistema).

## 1. SoyBluAI Connect

🟡 Existente parcial → requiere actualización. Ya documentado como "Plugins" en [[SoyBluAI - Skills y mini-apps]] (Slack, Notion, Discord, Jira, etc.) y como sistema MCP base (9 herramientas, ✅ funcional según [[Bienvenido]]). La nueva visión pide ampliar el catálogo (GitHub, Notion, Google Drive, Discord, Slack, WhatsApp*, Databases, APIs, MCP, Webhooks) y un flujo explícito por integración:

```
Connect → Permissions → Tools → Agents → Memory
```

\* Nota de coherencia: WhatsApp como **canal de distribución** del producto está descontinuado (bitácora 28-jul-2026, prohibición de Meta). Esto no impide una integración de WhatsApp como **conector de salida** (ej. un workflow que envía un mensaje de WhatsApp vía Business API a un número ya vinculado, distinto de operar un bot de propósito general). Se documenta la distinción para no reabrir por error una decisión ya cerrada.

GitHub ya está integrado en el producto de forma nativa (OAuth, SoyBluAI Code — [[SoyBluAI - Code]]), no como "conector" genérico — se mantiene así, SoyBluAI Connect no lo duplica.

## 2. MCP Marketplace

🟡 Existente (base) → 🔵 ampliación nueva. Hoy existe una base del sistema MCP con 9 herramientas ([[Bienvenido]], sección "Lo que ya está construido"). La nueva visión pide tratarlo como **ecosistema extensible**: instalar MCP, configurar, autenticar, definir permisos, habilitar herramientas por agente (reutiliza el Permission System de [[SoyBluAI - Workflow Builder y Automatizacion]], no crea uno nuevo). Se documenta como ⚪ **ROADMAP P2** — la base de 9 herramientas ya construida sigue siendo la prioridad de corto plazo; el marketplace (catálogo instalable, autenticación por conector) es evolución posterior.

## 3. Asset Library

🔵 Nuevo. Biblioteca central de: Images, Videos, Audio, Documents, Code, Designs, Presentations, Generated Files. Cada asset asociable a Usuario, Proyecto, Agente, Workflow, Fecha, Modelo.

**Relación con lo existente:** hoy los archivos generados (imágenes FLUX, mini-apps) van a storage S3-compatible / **Cloudflare R2** ([[SoyBluAI - Stack tecnologico]], [[SoyBluAI - Cumplimiento y Seguridad]] sección 4). Asset Library es la capa de **catálogo y metadatos** sobre ese mismo storage ya decidido — no requiere un proveedor de storage nuevo ni migrar el que ya se eligió (R2). Debe heredar las mismas reglas de retención/eliminación ya definidas en [[SoyBluAI - Cumplimiento y Seguridad]] (sección 3).

## 4. Prioridad

SoyBluAI Connect (ampliar catálogo de Plugins ya existente) es **P1**. MCP Marketplace y Asset Library son **P2** — no bloquean el lanzamiento V1. Ver [[SoyBluAI - Roadmap y estado]].

---

Relacionado: [[SoyBluAI - Skills y mini-apps]] · [[SoyBluAI - Code]] · [[SoyBluAI - Cumplimiento y Seguridad]] · [[SoyBluAI - Stack tecnologico]] · [[SoyBluAI - Workflow Builder y Automatizacion]] · [[SoyBluAI - Agent Builder y Marketplace]]
