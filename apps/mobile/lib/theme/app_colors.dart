import 'package:flutter/material.dart';

/// Paleta oficial soybluia (SPEC-DISENO-FALTANTE §1).
class BrandColors {
  /// Marca principal: botones primarios, enlaces, foco, selección, logotipo.
  static const cobalt = Color(0xFF0A34F5);

  /// Acentos sobre fondos oscuros: texto primario, iconos activos, distintivos.
  static const azulClaro = Color(0xFF3D6BFF);

  /// Texto principal y fondos oscuros.
  static const negroSuave = Color(0xFF0B0F1A);

  /// Texto secundario, pistas, metadatos, iconos inactivos.
  static const gris = Color(0xFF8E8E93);

  /// Superficies claras: tarjetas, campos, paneles, hover.
  static const grisFondo = Color(0xFFF2F4F8);

  /// Crema cálido del fondo claro (inspiración claude.ai).
  static const crema = Color(0xFFF5F4EE);

  /// Acento terracota para detalles de marca (chispa del saludo, etc.).
  static const terracota = Color(0xFFD97757);
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

  /// Tema oscuro (predeterminado): fondo #0B0F1A, superficies #131722/#1A1F2E/
  /// #222839, texto #EDEFF6, primario #3D6BFF, botones primarios #0A34F5.
  static const dark = AppPalette(
    background: BrandColors.negroSuave,
    surface: BrandColors.negroSuave,
    surfaceContainerLow: Color(0xFF131722),
    surfaceContainer: Color(0xFF1A1F2E),
    surfaceContainerHigh: Color(0xFF222839),
    surfaceContainerHighest: Color(0xFF2A3040),
    surfaceVariant: Color(0xFF222839),
    surfaceBright: Color(0xFF2A3040),
    onSurface: Color(0xFFEDEFF6),
    onSurfaceVariant: BrandColors.gris,
    outlineVariant: Color(0xFF2E3444),
    outline: Color(0xFF8E8FA3),
    primary: BrandColors.azulClaro,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: BrandColors.cobalt,
    onPrimaryContainer: Color(0xFFEDEFF6),
    secondaryContainer: Color(0xFF131722),
    onSecondaryContainer: BrandColors.gris,
    tertiary: BrandColors.gris,
    inversePrimary: BrandColors.cobalt,
    error: Color(0xFFFFB4AB),
    errorContainer: Color(0xFF93000A),
    textQuaternary: Color(0xFF5F5F68),
    elevatedOverlay: Color(0xFF313747),
    success: Color(0xFF5EB92D),
    successContainer: Color(0x1F5EB92D),
    warning: Color(0xFFFFBF36),
    warningContainer: Color(0x1FFFBF36),
  );

  /// Tema claro: fondo crema cálido (claude.ai), superficies cálidas,
  /// texto #0B0F1A, primario #0A34F5.
  static const light = AppPalette(
    background: BrandColors.crema,
    surface: Color(0xFFFAF9F5),
    surfaceContainerLow: Color(0xFFF0EEE6),
    surfaceContainer: Color(0xFFEAE7DC),
    surfaceContainerHigh: Color(0xFFE3E0D4),
    surfaceContainerHighest: Color(0xFFDDD9CC),
    surfaceVariant: Color(0xFFEAE7DC),
    surfaceBright: Color(0xFFFFFFFF),
    onSurface: BrandColors.negroSuave,
    onSurfaceVariant: BrandColors.gris,
    outlineVariant: Color(0xFFDEDACC),
    outline: BrandColors.gris,
    primary: BrandColors.cobalt,
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: BrandColors.cobalt,
    onPrimaryContainer: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE0E7FF),
    onSecondaryContainer: Color(0xFF001A97),
    tertiary: Color(0xFF46464B),
    inversePrimary: BrandColors.cobalt,
    error: Color(0xFFBA1A1A),
    errorContainer: Color(0xFFFFDAD6),
    textQuaternary: Color(0xFF90939C),
    elevatedOverlay: Color(0xFFF3F3F3),
    success: Color(0xFF2E7D32),
    successContainer: Color(0x1A2E7D32),
    warning: Color(0xFFB26A00),
    warningContainer: Color(0x1AB26A00),
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
