# blu-graf.py — generador de graficas premium para Blu (estilo IgnacioLoyola)
# Manual de marca: ESTILO-IGNACIOLOYOLA.md (misma carpeta)
# Uso:
#   python blu-graf.py "{\"type\":\"bar\",\"title\":\"Ventas\",\"subtitle\":\"Ene-Abr 2026\",
#                        \"labels\":[\"Ene\",\"Feb\",\"Mar\",\"Abr\"],\"values\":[10,15,8,19],
#                        \"unit\":\"$\"}"
# type: bar | hbar | line   (default bar)
# Devuelve por stdout la ruta del PNG generado.
import sys, json, os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.font_manager as fm
from matplotlib.patches import FancyBboxPatch
from matplotlib.ticker import FuncFormatter
from matplotlib.path import Path
from matplotlib.patches import PathPatch

OUT = r"C:\Users\MSI\.claude\scripts\blu-chart.png"

# ---- Paleta validada (dataviz, modo claro) --------------------------------
SURFACE   = "#f5f5f7"   # fondo tipo apple.com (gris muy claro, no blanco puro)
CARD      = "#ffffff"   # tarjeta interior (si se usara)
INK       = "#1d1d1f"   # tinta primaria (titulo) — negro Apple
INK_2     = "#6e6e73"   # tinta secundaria (subtitulo, valores) — gris Apple
MUTED     = "#8a8a8e"   # ejes / etiquetas
GRID      = "#e5e5ea"   # lineas de reja (hairline, muy sutil)
BASELINE  = "#d2d2d7"   # linea base
SERIES = ["#0071e3", "#34c759", "#ff9f0a", "#30d158",
          "#5e5ce6", "#ff453a", "#ff375f", "#ff6482"]  # paleta system-ui Apple

# Fuente tipo Apple/system-ui: en Windows usamos Segoe UI si existe
for _f in ["SF Pro Display", "SF Pro Text", "Segoe UI Variable", "Segoe UI", "Helvetica Neue", "Arial"]:
    if any(_f.lower() in f.name.lower() for f in fm.fontManager.ttflist):
        plt.rcParams["font.family"] = _f
        break
plt.rcParams["axes.unicode_minus"] = False


def _fmt_num(unit):
    def f(x, _pos=None):
        if abs(x) >= 1000:
            s = f"{x/1000:.1f}k".replace(".0k", "k")
        else:
            s = f"{x:.0f}" if float(x).is_integer() else f"{x:.1f}"
        return f"{unit}{s}" if unit and unit != "$" else (f"${s}" if unit == "$" else s)
    return f


def _style(ax):
    ax.set_facecolor(SURFACE)
    for s in ["top", "right", "left", "bottom"]:
        ax.spines[s].set_visible(False)
    ax.tick_params(colors=MUTED, length=0, labelsize=11, pad=8)
    for lbl in ax.get_xticklabels() + ax.get_yticklabels():
        lbl.set_color(MUTED)
        lbl.set_fontweight("500")


def _px_per_data(ax):
    """Pixeles por unidad de dato en x e y, segun los limites ya fijados."""
    p0 = ax.transData.transform((0, 0))
    px = ax.transData.transform((1, 0))
    py = ax.transData.transform((0, 1))
    return abs(px[0] - p0[0]), abs(py[1] - p0[1])


def _rounded_bar_v(ax, cx, w, y0, y1, color, radius_px=16, zorder=3):
    """Barra vertical con esquinas superiores redondeadas (radio en pixeles reales)."""
    px_x, px_y = _px_per_data(ax)
    rx = min(radius_px / px_x, w / 2) if px_x else 0
    ry = min(radius_px / px_y, abs(y1 - y0)) if px_y else 0
    x0, x1 = cx - w / 2, cx + w / 2
    if ry <= 0:
        ax.add_patch(plt.Rectangle((x0, y0), w, y1 - y0, facecolor=color,
                                    linewidth=0, zorder=zorder))
        return
    verts = [(x0, y0), (x0, y1 - ry), (x0, y1), (x0 + rx, y1),
             (x1 - rx, y1), (x1, y1), (x1, y1 - ry), (x1, y0), (x0, y0)]
    codes = [Path.MOVETO, Path.LINETO, Path.CURVE3, Path.CURVE3,
             Path.LINETO, Path.CURVE3, Path.CURVE3, Path.LINETO, Path.CLOSEPOLY]
    ax.add_patch(PathPatch(Path(verts, codes), facecolor=color, linewidth=0, zorder=zorder))


def _rounded_bar_h(ax, cy, h, x0, x1, color, radius_px=16, zorder=3):
    """Barra horizontal con esquinas derechas redondeadas (radio en pixeles reales)."""
    px_x, px_y = _px_per_data(ax)
    rx = min(radius_px / px_x, abs(x1 - x0)) if px_x else 0
    ry = min(radius_px / px_y, h / 2) if px_y else 0
    y0, y1 = cy - h / 2, cy + h / 2
    if rx <= 0:
        ax.add_patch(plt.Rectangle((x0, y0), x1 - x0, h, facecolor=color,
                                    linewidth=0, zorder=zorder))
        return
    verts = [(x0, y0), (x1 - rx, y0), (x1, y0), (x1, y0 + ry),
             (x1, y1 - ry), (x1, y1), (x1 - rx, y1), (x0, y1), (x0, y0)]
    codes = [Path.MOVETO, Path.LINETO, Path.CURVE3, Path.CURVE3,
             Path.LINETO, Path.CURVE3, Path.CURVE3, Path.LINETO, Path.CLOSEPOLY]
    ax.add_patch(PathPatch(Path(verts, codes), facecolor=color, linewidth=0, zorder=zorder))


def make(spec):
    ctype = spec.get("type", "bar").lower()
    title = spec.get("title", "")
    subtitle = spec.get("subtitle", "")
    labels = [str(x) for x in spec.get("labels", [])]
    values = [float(x) for x in spec.get("values", [])]
    unit = spec.get("unit", "")
    n = len(values)
    if spec.get("palette") == "categorical" and ctype != "line":
        colors = [SERIES[i % len(SERIES)] for i in range(n)]
    else:
        colors = [SERIES[0]] * n

    fig, ax = plt.subplots(figsize=(8.6, 4.8), dpi=180)
    fig.patch.set_facecolor(SURFACE)
    # Layout fijo ANTES de dibujar: si se ajusta despues (tight_layout), la
    # posicion de los ejes cambia y el radio de las barras (calculado en
    # pixeles reales) queda mal escalado en el PNG final.
    fig.subplots_adjust(left=0.085, right=0.97, top=0.76, bottom=0.13)

    if ctype == "line":
        xs = np.arange(n)
        ys = np.array(values)
        # area con degradado bajo la curva, estilo Apple Health/Stocks
        line_color = SERIES[0]
        ax.plot(xs, ys, color=line_color, linewidth=3, zorder=4,
                solid_capstyle="round", solid_joinstyle="round")
        ax.fill_between(xs, ys, ys.min() - (ys.max() - ys.min() or 1) * 0.15,
                         color=line_color, alpha=0.12, zorder=2, linewidth=0)
        ax.scatter(xs, ys, s=54, color=CARD, zorder=5, edgecolors=line_color, linewidths=2.4)
        ax.set_xticks(xs); ax.set_xticklabels(labels)
        ax.grid(axis="y", color=GRID, linewidth=1.0, zorder=0)
        for x, y in zip(xs, ys):
            ax.annotate(_fmt_num(unit)(y), (x, y), textcoords="offset points",
                        xytext=(0, 14), ha="center", fontsize=11,
                        color=INK, fontweight="600")
        ax.margins(x=0.08, y=0.28)

    elif ctype == "hbar":
        ypos = np.arange(n)
        vmax = max(values) if values else 1
        ax.set_ylim(-0.6, n - 0.4)
        ax.set_yticks(list(ypos)); ax.set_yticklabels(labels)
        ax.invert_yaxis()
        ax.set_xlim(0, vmax * 1.22)
        fig.canvas.draw()  # fija transData para que el radio en pixeles sea exacto
        for i, (v, c) in enumerate(zip(values, colors)):
            _rounded_bar_h(ax, i, 0.58, 0, v, c, zorder=3)
        ax.grid(axis="x", color=GRID, linewidth=1.0, zorder=0)
        for i, v in enumerate(values):
            ax.annotate(_fmt_num(unit)(v), (v, i), textcoords="offset points",
                        xytext=(10, 0), va="center", ha="left", fontsize=11,
                        color=INK, fontweight="600")

    else:  # bar
        xpos = np.arange(n)
        vmax = max(values) if values else 1
        ax.set_xlim(-0.6, n - 0.4)
        ax.set_xticks(list(xpos)); ax.set_xticklabels(labels)
        ax.set_ylim(0, vmax * 1.22)
        fig.canvas.draw()  # fija transData para que el radio en pixeles sea exacto
        for i, (v, c) in enumerate(zip(values, colors)):
            _rounded_bar_v(ax, i, 0.56, 0, v, c, zorder=3)
        ax.grid(axis="y", color=GRID, linewidth=1.0, zorder=0)
        for i, v in enumerate(values):
            ax.annotate(_fmt_num(unit)(v), (i, v), textcoords="offset points",
                        xytext=(0, 10), ha="center", fontsize=11,
                        color=INK, fontweight="600")

    ax.set_axisbelow(True)
    _style(ax)
    if unit:
        fmt = FuncFormatter(_fmt_num(unit))
        (ax.yaxis if ctype != "hbar" else ax.xaxis).set_major_formatter(fmt)

    # Titulo y subtitulo alineados a la izquierda (jerarquia tipografica Apple)
    if title:
        fig.suptitle(title, x=0.03, y=0.97, ha="left", fontsize=19,
                     fontweight="700", color=INK)
    if subtitle:
        fig.text(0.03, 0.885, subtitle, ha="left", fontsize=12,
                  color=INK_2, fontweight="500")

    fig.savefig(OUT, facecolor=SURFACE, bbox_inches="tight", pad_inches=0.35)
    plt.close(fig)
    return OUT


INPUT = r"C:\Users\MSI\.claude\scripts\blu-graf-input.json"

if __name__ == "__main__":
    raw = None
    if len(sys.argv) > 1:
        a = sys.argv[1]
        if a.strip().startswith("{"):
            raw = a
        elif os.path.exists(a):
            with open(a, encoding="utf-8") as fh:
                raw = fh.read()
    if raw is None and os.path.exists(INPUT):
        with open(INPUT, encoding="utf-8") as fh:
            raw = fh.read()
    if not raw:
        print("ERROR: no hay datos. Escribe el JSON en blu-graf-input.json"); sys.exit(1)
    try:
        spec = json.loads(raw)
    except Exception as e:
        print("ERROR parseando JSON:", e); sys.exit(1)
    try:
        print(make(spec))
    except Exception as e:
        print("ERROR generando grafica:", e); sys.exit(1)
