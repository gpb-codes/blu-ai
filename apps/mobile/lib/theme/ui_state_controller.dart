import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias de interfaz independientes de la apariencia (colapso del
/// sidebar, tamaños, etc.). Persistidas en SharedPreferences.
class UiStateController extends ChangeNotifier {
  UiStateController._();

  static final UiStateController instance = UiStateController._();

  static const _collapseKey = 'sidebarCollapsed';

  /// Barras del sidebar se colapsan a un rail de iconos en escritorio.
  bool sidebarCollapsed = false;

  /// Restaura las preferencias guardadas.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_collapseKey);
      if (saved != null) sidebarCollapsed = saved;
    } catch (_) {
      // Sin persistencia (tests): valor por defecto.
    }
  }

  void setSidebarCollapsed(bool v) {
    if (v == sidebarCollapsed) return;
    sidebarCollapsed = v;
    notifyListeners();
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool(_collapseKey, v))
        .catchError((_) => false);
  }
}