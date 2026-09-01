import 'package:flutter/material.dart';

/// Brand Book oficial SoyBluia — fuente de verdad.
class BrandColors {
  /// Cobalto #0A34F5 — primary, CTA, logo.
  static const cobalt = Color(0xFF0A34F5);
  static const accent = Color(0xFF0A34F5);

  /// Negro suave #0B0F1A — dark background.
  static const fondo = Color(0xFF0B0F1A);
  static const negroSuave = Color(0xFF0B0F1A);

  /// Azul claro #3D6BFF — interactive.
  static const azulClaro = Color(0xFF3D6BFF);

  /// Gris #8E8E93 — secondary text.
  static const gris = Color(0xFF8E8E93);
  static const muted = Color(0xFF8E8E93);

  /// Gris claro #F2F4F8 — light background.
  static const grisFondo = Color(0xFFF2F4F8);
  static const grisClaro = Color(0xFFF2F4F8);

  /// Blanco / Texto claro
  static const blanco = Color(0xFFFFFFFF);
  static const textClaro = Color(0xFFF7F8FA);
  static const crema = Color(0xFFF7F8FA);
  static const terracota = Color(0xFF0A34F5);
  static const secondary = Color(0xFF8E8E93);
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

  /// Dark: #0B0F1A / #111625 / #171D2D / #242B3D — Brand Book §10.
  static const dark = AppPalette(
    background: Color(0xFF0B0F1A),
    surface: Color(0xFF111625),
    surfaceContainerLow: Color(0xFF111625),
    surfaceContainer: Color(0xFF171D2D),
    surfaceContainerHigh: Color(0xFF1E2535),
    surfaceContainerHighest: Color(0xFF242B3D),
    surfaceVariant: Color(0xFF171D2D),
    surfaceBright: Color(0xFF242B3D),
    onSurface: Color(0xFFF7F8FA),
    onSurfaceVariant: Color(0xFF8E8E93),
    outlineVariant: Color(0xFF242B3D),
    outline: Color(0xFF3A4A6E),
    primary: Color(0xFF0A34F5),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF0A34F5),
    onPrimaryContainer: Color(0xFFF7F8FA),
    secondaryContainer: Color(0xFF111625),
    onSecondaryContainer: Color(0xFF8E8E93),
    tertiary: Color(0xFF8E8E93),
    inversePrimary: Color(0xFF3D6BFF),
    error: Color(0xFFFFB4AB),
    errorContainer: Color(0xFF93000A),
    textQuaternary: Color(0xFF6B7280),
    elevatedOverlay: Color(0xFF171D2D),
    success: Color(0xFF10A37F),
    successContainer: Color(0x1F10A37F),
    warning: Color(0xFFFFBF36),
    warningContainer: Color(0x1FFFBF36),
  );

  /// Light: #F2F4F8 / #FFFFFF / #F8F9FB / #E2E5EB — Brand Book §11.
  static const light = AppPalette(
    background: Color(0xFFF2F4F8),
    surface: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF8F9FB),
    surfaceContainer: Color(0xFFEFF2F6),
    surfaceContainerHigh: Color(0xFFE2E5EB),
    surfaceContainerHighest: Color(0xFFD9DDE3),
    surfaceVariant: Color(0xFFEFF2F6),
    surfaceBright: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0B0F1A),
    onSurfaceVariant: Color(0xFF8E8E93),
    outlineVariant: Color(0xFFE2E5EB),
    outline: Color(0xFFCBD6FF),
    primary: Color(0xFF0A34F5),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF0A34F5),
    onPrimaryContainer: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE0E7FF),
    onSecondaryContainer: Color(0xFF001A97),
    tertiary: Color(0xFF475569),
    inversePrimary: Color(0xFF3D6BFF),
    error: Color(0xFFDC2626),
    errorContainer: Color(0xFFFEE2E2),
    textQuaternary: Color(0xFF8E8E93),
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
