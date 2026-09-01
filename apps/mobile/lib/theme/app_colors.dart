import 'package:flutter/material.dart';

/// Paleta oficial soybluia — ACTUALIZADA 2026-09: fondo #020A17, accent #023CF7.
class BrandColors {
  /// Accent: azul eléctrico #023CF7 (botones, selección, logo).
  static const cobalt = Color(0xFF023CF7);
  static const accent = Color(0xFF023CF7);

  /// Fondo: azul noche profundo #020A17.
  static const fondo = Color(0xFF020A17);
  static const negroSuave = Color(0xFF020A17);

  /// Secondary: azul grisáceo #1B2A4F (sidebar, cards).
  static const secondary = Color(0xFF1B2A4F);
  static const grisFondo = Color(0xFF1B2A4F);

  /// Texto: gris muy claro #DEE1E7.
  static const textClaro = Color(0xFFDEE1E7);
  static const grisClaro = Color(0xFFDEE1E7);

  /// Muted: gris #9A9CA3 (secundario, hints).
  static const gris = Color(0xFF9A9CA3);
  static const muted = Color(0xFF9A9CA3);

  /// Blanco puro #FFFFFF.
  static const blanco = Color(0xFFFFFFFF);
  static const crema = Color(0xFFFFFFFF);

  /// Legacy alias para compatibilidad.
  static const azulClaro = Color(0xFF3D6BFF);
  static const terracota = Color(0xFF023CF7);
}

/// Paleta de colores activa para una apariencia (oscura o clara).
class AppPalette {
  final Color background;
  final Color surface;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceVariant;
  final Color surfaceBright;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outlineVariant;
  final Color outline;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color inversePrimary;
  final Color error;
  final Color errorContainer;

  /// Cuarto nivel de texto/metadatos (tipo `--text-disable` de Manus).
  final Color textQuaternary;

  /// Superficie elevada por encima del contenedor alto (modales, paneles
  /// flotantes, tiles activos). Estilo `--fill-white`/`--background-gray-secondary`.
  final Color elevatedOverlay;

  /// Estados de función con tinte 12% (patrón `--function-success-tsp`).
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceVariant,
    required this.surfaceBright,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outlineVariant,
    required this.outline,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.inversePrimary,
    required this.error,
    required this.errorContainer,
    required this.textQuaternary,
    required this.elevatedOverlay,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
  });

  /// Tema noche BLU: fondo #020A17, secondary #1B2A4F, accent #023CF7, text #DEE1E7.
  static const dark = AppPalette(
    background: Color(0xFF020A17),
    surface: Color(0xFF020A17),
    surfaceContainerLow: Color(0xFF0A1930),
    surfaceContainer: Color(0xFF1B2A4F),
    surfaceContainerHigh: Color(0xFF24365F),
    surfaceContainerHighest: Color(0xFF2E426E),
    surfaceVariant: Color(0xFF1B2A4F),
    surfaceBright: Color(0xFF24365F),
    onSurface: Color(0xFFDEE1E7),
    onSurfaceVariant: Color(0xFF9A9CA3),
    outlineVariant: Color(0xFF2A3A5E),
    outline: Color(0xFF3A4A6E),
    primary: Color(0xFF023CF7),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF023CF7),
    onPrimaryContainer: Color(0xFFDEE1E7),
    secondaryContainer: Color(0xFF1B2A4F),
    onSecondaryContainer: Color(0xFF9A9CA3),
    tertiary: Color(0xFF9A9CA3),
    inversePrimary: Color(0xFF023CF7),
    error: Color(0xFFFFB4AB),
    errorContainer: Color(0xFF93000A),
    textQuaternary: Color(0xFF6B7280),
    elevatedOverlay: Color(0xFF1B2A4F),
    success: Color(0xFF10A37F),
    successContainer: Color(0x1F10A37F),
    warning: Color(0xFFFFBF36),
    warningContainer: Color(0x1FFFBF36),
  );

  /// Tema claro: blanco #FFFFFF con accent #023CF7 — espejo del noche.
  static const light = AppPalette(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF1F5FF),
    surfaceContainer: Color(0xFFE8ECFF),
    surfaceContainerHigh: Color(0xFFD9E0FF),
    surfaceContainerHighest: Color(0xFFCBD6FF),
    surfaceVariant: Color(0xFFE8ECFF),
    surfaceBright: Color(0xFFFFFFFF),
    onSurface: Color(0xFF020A17),
    onSurfaceVariant: Color(0xFF64748B),
    outlineVariant: Color(0xFFCBD6FF),
    outline: Color(0xFF94A3B8),
    primary: Color(0xFF023CF7),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF023CF7),
    onPrimaryContainer: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE0E7FF),
    onSecondaryContainer: Color(0xFF001A97),
    tertiary: Color(0xFF475569),
    inversePrimary: Color(0xFF023CF7),
    error: Color(0xFFDC2626),
    errorContainer: Color(0xFFFEE2E2),
    textQuaternary: Color(0xFF9A9CA3),
    elevatedOverlay: Color(0xFFFFFFFF),
    success: Color(0xFF10A37F),
    successContainer: Color(0x1A10A37F),
    warning: Color(0xFFD97706),
    warningContainer: Color(0x1AD97706),
  );
}

/// Paleta vigente del tema, propagada por InheritedWidget para que todos los
/// widgets se repinten al cambiar la apariencia. Usar `ThemeScope.of(context)`.
class ThemeScope extends InheritedWidget {
  final AppPalette palette;

  const ThemeScope({super.key, required this.palette, required super.child});

  static AppPalette of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ThemeScope>()!.palette;

  @override
  bool updateShouldNotify(ThemeScope oldWidget) => oldWidget.palette != palette;
}

/// Gradientes de la marca basados en la paleta activa. Siguen el lenguaje
/// visual de Manus: shimmer de texto "thinking" y brillo sutil de tarjetas
/// de herramienta usada (`--background-tool-used`).
class AppGradients {
  const AppGradients._();

  /// Barrido con brillo que recorre los niveles de superficie. Ideal para el
  /// shimmer de estados "pensando" y para skeletons de carga.
  static LinearGradient shimmer(AppPalette p) {
    final base = p.surfaceContainerLow;
    final highlight = p.surfaceContainerHighest;
    return LinearGradient(
      colors: [base, highlight, base],
      stops: const [0.0, 0.45, 1.0],
    );
  }

  /// Brillo sutil de borde→borde para tarjetas con actividad/evidencia.
  static LinearGradient toolSheen(AppPalette p) {
    final transparent = p.surfaceContainerLow.withValues(alpha: 0.0);
    final sheen = p.onSurface.withValues(alpha: 0.06);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [transparent, sheen, transparent],
      stops: const [0.06, 0.5, 0.94],
    );
  }
}

/// Jerarquía de sombras suaves en negros translúcidos (equivalente a
/// `--shadows-drop-1..4` de Manus: 4 niveles con alpha creciente).
class AppShadows {
  const AppShadows._();

  /// Ligera: elementos en reposo sobre la superficie base.
  static const List<BoxShadow> s = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 1),
    ),
  ];

  /// Media: tarjetas y inputs destacados.
  static const List<BoxShadow> m = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Alta: menús desplegables, hojas y modales.
  static const List<BoxShadow> l = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 28,
      offset: Offset(0, 8),
    ),
  ];

  /// Muy alta: overlays y paneles flotantes.
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
  ];
}
