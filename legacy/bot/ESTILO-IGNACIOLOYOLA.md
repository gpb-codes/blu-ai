# Estilo IgnacioLoyola — Manual de marca visual

Sistema de diseño de la marca IgnacioLoyola (ignacioloyola.vercel.app). Todo material
visual que genere Blu — gráficas, boards, diagramas, paso a paso, iconos, logos,
mockups — sigue ESTE manual. Inspirado en el minimalismo premium de los grandes
sistemas de diseño (claridad, deferencia, jerarquía), pero es NUESTRO estilo.

---

## 1. Filosofía (3 reglas madre)

1. **Claridad**: el contenido manda. Si un adorno no comunica, se quita.
2. **Aire**: el espacio en blanco ES el diseño. Ante la duda, más margen, menos cosas.
3. **Una sola voz de color**: un neutro cálido de fondo, tinta casi negra, y UN azul
   que carga toda la acción/acento. Los demás colores solo aparecen cuando los datos
   los necesitan.

Prohibido: degradados decorativos, sombras duras, bordes gruesos, clipart,
emojis en diseños, más de 2 fuentes, más de 1 acento por pieza (salvo datos categóricos).

---

## 2. Color (tokens)

### Neutros
| Token       | Hex       | Uso |
|-------------|-----------|-----|
| `surface`   | `#f5f5f7` | Fondo de toda pieza (gris perla, nunca blanco puro) |
| `card`      | `#ffffff` | Tarjetas/paneles sobre surface |
| `ink`       | `#1d1d1f` | Titulares y texto principal (casi negro, nunca #000) |
| `ink-2`     | `#6e6e73` | Texto secundario, subtítulos, captions |
| `muted`     | `#8a8a8e` | Etiquetas de ejes, hints, metadatos |
| `hairline`  | `#e5e5ea` | Líneas divisorias y grid (1px, sutilísimas) |
| `baseline`  | `#d2d2d7` | Bordes de inputs/tarjetas cuando se necesiten |

### Acento y semánticos
| Token       | Hex       | Uso |
|-------------|-----------|-----|
| `accent`    | `#0071e3` | EL azul de la marca. Links, botones, barra única, paso activo |
| `success`   | `#34c759` | Positivo, completado, crecimiento |
| `warning`   | `#ff9f0a` | Atención, pendiente |
| `danger`    | `#ff453a` | Negativo, error, caída |
| `purple`    | `#5e5ce6` | 5.º categórico |
| `pink`      | `#ff375f` | 6.º categórico |

### Orden categórico (series de datos distintas)
`#0071e3 → #34c759 → #ff9f0a → #5e5ce6 → #ff453a → #ff375f`
Una sola métrica = SOLO `accent`. Nunca arcoíris porque sí.

### Modo oscuro (solo si se pide)
surface `#161617` · card `#1d1d1f` · ink `#f5f5f7` · ink-2 `#a1a1a6` · hairline `#424245`

---

## 3. Tipografía

**Fuente**: system-ui — en Windows: `"Segoe UI Variable", "Segoe UI", -apple-system, sans-serif`.
Nunca serifas ni fuentes display de fantasía (excepción: logos de otras marcas, p.ej. Corven usa Cormorant Garamond).

### Escala (px, para piezas de ~1600px de ancho)
| Rol           | Tamaño | Peso | Extra |
|---------------|--------|------|-------|
| Display/Hero  | 56     | 700  | letter-spacing -0.02em, line-height 1.07 |
| Título pieza  | 38     | 700  | letter-spacing -0.015em |
| Título sección| 28     | 600  | |
| Subtítulo     | 21     | 500  | color ink-2 |
| Cuerpo        | 17     | 400  | line-height 1.5 — piso de legibilidad |
| Caption/label | 13     | 500  | color muted, puede ir UPPERCASE con letter-spacing 0.06em |
| Dato numérico | 24-40  | 600  | los números protagonistas van GRANDES |

Reglas: títulos con tracking negativo (apretados = premium). Jerarquía por
tamaño+peso+color, nunca por subrayados ni cajas. Texto alineado a la izquierda
(números en tablas: a la derecha).

---

## 4. Espaciado y geometría

- **Grid de 8px** (sub-múltiplos de 4px). Todo margen/padding es múltiplo de 8.
- Padding exterior de una pieza: mínimo 48px. Entre secciones: 40-64px.
- **Radios**: tarjetas 18px · botones/pills 980px (full) · barras de gráfica ~9px · chips 12px.
- **Sombras**: casi nunca. Si una tarjeta necesita separarse: `0 4px 24px rgba(0,0,0,.06)` máximo.
  Preferir contraste de superficie (card blanco sobre surface gris) en vez de sombra.
- **Líneas**: 1px `hairline`. Nunca bordes de 2px+ ni dobles marcos.

---

## 5. Reglas por tipo de pieza

### 5.1 Gráficas (blu-graf.py — ya implementado)
- bar / hbar / line con esquinas redondeadas, valores rotulados en `ink` semibold,
  grid horizontal hairline, sin ejes dibujados (spines invisibles).
- line lleva relleno degradado sutil (accent al 12%) bajo la curva.
- Título 19pt bold izquierda + subtítulo gris. Fondo `surface`.

### 5.2 Boards / tableros (kanban, estados, resúmenes)
- Fondo `surface`, columnas como tarjetas `card` radio 18px, padding 24px.
- Header de columna: caption UPPERCASE `muted` + contador en chip.
- Items: tarjetas blancas con hairline, título 17px/600, meta 13px `ink-2`.
- Estado con un punto de color semántico (● 8px), no fondos chillones.

### 5.3 Paso a paso / procesos
- Vertical u horizontal. Cada paso: círculo numerado 40px (fondo `accent`, número
  blanco 600) o check `success` si está completado; conectados por línea hairline de 2px.
- Paso activo: círculo `accent` + título `ink`. Pasos futuros: círculo `card` con
  borde `baseline`, texto `muted`.
- Título del paso 21px/600, descripción 15px `ink-2` máx 2 líneas.

### 5.4 Iconos SVG
- Estilo línea (stroke), grosor 1.8-2px, `stroke-linecap="round"`, `stroke-linejoin="round"`,
  esquinas redondeadas, grid de 24x24. Un solo color (`ink` o `accent`).
- Sin rellenos sólidos salvo detalles mínimos. Ópticamente alineados al texto.
- Nada de iconos 3D, ni multicolor, ni emoji-style.

### 5.5 Logos
- Wordmark primero: tipografía system-ui 700 con tracking -0.03em, o monograma
  geométrico simple dentro de un contenedor radio 18-22px.
- Máximo 2 colores (normalmente `ink` + `accent`). Debe funcionar en 1 color.
- Presentar siempre sobre `surface` con aire generoso (clear space = altura de 1 letra).

### 5.6 Tablas / comparativas
- Sin bordes verticales. Filas separadas por hairline. Header caption UPPERCASE `muted`.
- Números a la derecha, resaltado del "ganador" con `accent` o chip suave
  (`accent` al 10% de fondo, texto `accent`).

### 5.7 Mockups / estructuras de pantalla
- Frame del dispositivo minimal: rectángulo radio 40px `ink` con pantalla `card`.
- Contenido interno sigue todos los tokens de arriba.

---

## 6. Cómo se genera (pipeline de Blu)

1. **Gráficas de datos** → `blu-graf.py` (JSON en `blu-graf-input.json` → `blu-chart.png`).
2. **Todo lo demás** (boards, pasos, iconos, logos, tablas, mockups) → escribir HTML
   auto-contenido en `blu-diseno-input.html` usando estos tokens (hay plantilla base
   con las variables CSS en la sección 7) y correr `blu-diseno.js` → `blu-diseno.png`.
3. Verificar SIEMPRE el PNG con Read antes de mandarlo. Si algo se ve apretado,
   desalineado o fuera de marca, corregir y regenerar. Máximo 2 iteraciones.

## 7. Plantilla base HTML (copiar como punto de partida)

```html
<!doctype html><html><head><meta charset="utf-8"><style>
  :root{
    --surface:#f5f5f7; --card:#fff; --ink:#1d1d1f; --ink2:#6e6e73;
    --muted:#8a8a8e; --hairline:#e5e5ea; --baseline:#d2d2d7;
    --accent:#0071e3; --success:#34c759; --warning:#ff9f0a; --danger:#ff453a;
  }
  *{margin:0;padding:0;box-sizing:border-box}
  body{width:1600px;background:var(--surface);color:var(--ink);
       font-family:"Segoe UI Variable","Segoe UI",-apple-system,sans-serif;
       -webkit-font-smoothing:antialiased;padding:64px}
  h1{font-size:38px;font-weight:700;letter-spacing:-.015em}
  .sub{font-size:21px;font-weight:500;color:var(--ink2);margin-top:6px}
  .card{background:var(--card);border-radius:18px;padding:24px}
  .caption{font-size:13px;font-weight:600;color:var(--muted);
           text-transform:uppercase;letter-spacing:.06em}
</style></head><body>
  <!-- contenido -->
</body></html>
```

`blu-diseno.js` recorta al alto real del contenido y exporta a 2x. El `width` del
body define el ancho de la pieza (1600px default; 1080px para formato cuadrado social).
