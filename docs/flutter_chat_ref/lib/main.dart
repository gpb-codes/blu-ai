import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'theme/app_colors.dart';
import 'theme/theme_controller.dart';
import 'theme/ui_state_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.instance.load();
  await UiStateController.instance.load();
  runApp(const IntelligenceApp());
}

ThemeData _buildTheme(AppPalette p, Brightness brightness) => ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: p.background,
      fontFamily: 'Inter',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.windows: _AppPageTransitionsBuilder(),
          TargetPlatform.android: _AppPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: _AppPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: p.primary,
        onPrimary: p.onPrimary,
        primaryContainer: p.primaryContainer,
        onPrimaryContainer: p.onPrimaryContainer,
        secondary: p.secondaryContainer,
        onSecondary: p.onPrimaryContainer,
        secondaryContainer: p.secondaryContainer,
        onSecondaryContainer: p.onSecondaryContainer,
        tertiary: p.tertiary,
        surface: p.surface,
        onSurface: p.onSurface,
        error: p.error,
        onError: Colors.white,
        errorContainer: p.errorContainer,
        onErrorContainer: p.onSurfaceVariant,
        outline: p.outline,
        outlineVariant: p.outlineVariant,
        surfaceContainerLow: p.surfaceContainerLow,
        surfaceContainer: p.surfaceContainer,
        surfaceContainerHigh: p.surfaceContainerHigh,
        surfaceContainerHighest: p.surfaceContainerHighest,
        inversePrimary: p.inversePrimary,
      ),
    );

/// Transición de página fade + deslizamiento sutil, consistente con el
/// lenguaje minimalista de la app (inspiración Manus: sin rebotes llamativos).
class _AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const _AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.02, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class IntelligenceApp extends StatelessWidget {
  const IntelligenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final controller = ThemeController.instance;
        return ThemeScope(
          palette: controller.resolvePalette(),
          child: MaterialApp(
            title: 'soybluia',
            debugShowCheckedModeBanner: false,
            theme: _buildTheme(AppPalette.light, Brightness.light),
            darkTheme: _buildTheme(AppPalette.dark, Brightness.dark),
            themeMode: controller.mode,
            home: const ChatScreen(),
          ),
        );
      },
    );
  }
}
