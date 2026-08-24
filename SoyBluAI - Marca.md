---
tags:
  - soybluia
  - marca
  - branding
  - design
estado: activo
fase: N/A
fase_orden: 0
responsable: equipo
tipo: marca
actualizacion: 24-ago-2026
---

# SoyBluAI — Marca

> Nota nueva (24-ago-2026). Consolida el contenido de `BLU_IA_Brand_Book_1.pdf` (V1 · 2026, subido por el equipo) adaptado al nombre oficial **SoyBluAI** (ver [[SoyBluAI - Decisiones (ADRs)]], ADR-004). El Brand Book original usa el wordmark en minúsculas **"bluia"** — eso queda **desactualizado** y pendiente de rediseño; ver "Conflicto de wordmark" más abajo. El resto del sistema (color, tipografía, símbolo, tono) no depende del nombre y se adopta tal cual.

## Conflicto de wordmark (pendiente de diseño)

🔴 El Brand Book define el wordmark oficial como **"bluia"** (blu en negro suave/blanco + ia en cobalto, sin espacio, sin mayúsculas). Esto contradice el rebranding a **SoyBluAI** ejecutado el 24-ago-2026 (ADR-004). El equipo confirmó explícitamente el mismo día: *"SoyBluAI sigue siendo el nombre"* — el Brand Book se trata como **activo desactualizado**, no como motivo para revertir el nombre.

- **No resuelto todavía:** cómo se ve el wordmark de "SoyBluAI" (tratamiento tipográfico, si se abrevia visualmente, si conserva el patrón "texto neutro + fragmento en cobalto"). Es una decisión de diseño, no de documentación — no se improvisa acá.
- **Assets actuales** (mark-azul, mark-blanco, mark-negro, icono-transparente, icono-fondo-blanco, app-icon-claro/oscuro, favicon-16/32/48/64/192/512, wordmark-claro/oscuro/transparente, PNG+SVG) siguen usando "blu ia" / "bluia" — generados el 29-jul-2026 según [[SoyBluAI - Bitacora]]. Siguen siendo válidos como referencia de **color y forma del símbolo**; el texto del wordmark necesita regenerarse.
- **Siguiente paso:** el equipo de diseño define el wordmark "SoyBluAI" y regenera el set de archivos completo con el mismo manifiesto (ver "Archivos" abajo).

## Símbolo — "Convergencia"

Tres trazos asimétricos que convergen en un núcleo sólido. Reglas de uso:

- Tamaño mínimo: 24px. Se mantiene legible hasta 16px.
- Espacio de resguardo mínimo = ancho de un trazo.
- No estirar ni distorsionar.
- No rotar el símbolo ni separar el símbolo del nombre.
- No usar colores fuera de la paleta.
- No usar sombras, degradados ni efectos 3D.
- Evitar clichés de IA en cualquier variante futura: sin foco/bombilla, sin cerebro, sin circuitos, sin robot.

## Paleta de color

| Nombre | Hex | Uso |
|---|---|---|
| Cobalto | `#0A34F5` | Color primario de marca |
| Azul claro | `#3D6BFF` | Sobre fondo oscuro |
| Negro suave | `#0B0F1A` | Texto / fondo oscuro |
| Gris | `#8E8E93` | Texto secundario |
| Gris fondo | `#F2F4F8` | Superficies claras |

**Nota de coherencia:** estos valores ya coinciden con una entrada previa de [[SoyBluAI - Bitacora]] (29-jul-2026) y con `banner-viewer.html` (`--accent: #3d6bff` en su CSS) — no hay conflicto de paleta, solo de wordmark. `banner-viewer.html` es una herramienta HTML del vault (no una nota `.md`), su `<title>` sigue diciendo "Blu Code" — queda fuera del rebranding de notas ejecutado el 24-ago-2026 y pendiente si se decide actualizar herramientas HTML sueltas.

## Tipografía

- **Titular:** Inter (alternativa: Sora), Bold, −2% tracking.
- **Subtítulo:** Inter, Semibold, tracking 0.
- **Cuerpo:** Inter, Regular, tracking 0.
- **Etiqueta:** Inter, Bold, 8pt, +240% tracking, mayúsculas.

## Tono / manifiesto

> "Claude, Gemini, GPT. Todos entran. Uno solo responde." — [Nombre] no es otro chat de IA, es el orquestador que decide qué modelo responde.

Tagline original: *"Muchos modelos. Una sola mente."* Sigue vigente conceptualmente (multi-modelo + Model Router, ver [[SoyBluAI - Vision]]); si se usa en materiales nuevos, evaluar si menciona el wordmark literal (pendiente hasta resolver el conflicto de arriba).

## Reglas de uso (heredadas del Brand Book)

- Espacio de resguardo mínimo = ancho de un trazo del símbolo.
- No estirar/distorsionar el logo.
- No usar colores fuera de paleta.
- No usar sombras, degradados ni efectos 3D.
- No rotar el símbolo ni separar símbolo y nombre.

## Archivos (manifiesto de assets, pendiente de regeneración del wordmark)

mark-azul · mark-azul-claro · mark-blanco · mark-negro · icono-transparente · icono-fondo-blanco · app-icon-claro · app-icon-oscuro · favicon-16/32/48/64/192/512 · wordmark-claro · wordmark-oscuro · wordmark-transparente — formatos PNG + SVG.

---

Relacionado: [[SoyBluAI - Vision]] · [[SoyBluAI - Decisiones (ADRs)]] · [[SoyBluAI - Bitacora]]
