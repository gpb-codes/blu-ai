import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

/// Controla la apariencia global (oscuro / blanco / sistema).
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const _prefsKey = 'themeIndex';

  /// 0 = oscuro, 1 = blanco (por defecto), 2 = sistema.
  int themeIndex = 1;

  ThemeMode get mode => switch (themeIndex) {
        0 => ThemeMode.dark,
        1 => ThemeMode.light,
        _ => ThemeMode.system,
      };

  /// Restaura la preferencia guardada (SharedPreferences).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getInt(_prefsKey);
      if (saved != null) themeIndex = saved;
    } catch (_) {
      // Sin persistencia (p. ej. tests): se usa el valor por defecto.
    }
  }

  void setThemeIndex(int index) {
    if (index == themeIndex) return;
    themeIndex = index;
    notifyListeners();
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(_prefsKey, index))
        .catchError((_) => false);
  }

  /// Paleta activa que debe exponer [ThemeScope].
  AppPalette resolvePalette() {
    if (themeIndex == 1) return AppPalette.light;
    if (themeIndex == 2) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.light ? AppPalette.light : AppPalette.dark;
    }
    return AppPalette.dark;
  }
}