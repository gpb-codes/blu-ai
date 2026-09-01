import 'package:flutter/material.dart';
import '../../services/stores.dart';
import '../../theme/app_colors.dart';
import '../app_sidebar.dart';
import '../top_app_bar.dart';

/// Shell con el sidebar compartido (escritorio) o drawer (móvil) + barra
/// superior con botón atrás, usado por las pantallas secundarias.
class SidebarShell extends StatefulWidget {
  final AppSidebarItem selected;
  final ValueChanged<AppSidebarItem> onSelect;
  final Widget child;

  /// Al tocar una sesión de "Recientes" se abre su historial completo.
  final void Function(ChatSession)? onOpenSession;

  const SidebarShell({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.child,
    this.onOpenSession,
  });

  @override
  State<SidebarShell> createState() => _SidebarShellState();
}

class _SidebarShellState extends State<SidebarShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _handleSelect(AppSidebarItem item) {
    Navigator.of(context).pop();
    widget.onSelect(item);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ThemeScope.of(context).background,
      drawer: isWide
          ? null
          : AppSidebar(
              selected: widget.selected,
              onSelect: _handleSelect,
              onOpenSession: widget.onOpenSession,
            ),
      body: Row(
        children: [
          if (isWide)
            AppSidebar(
                selected: widget.selected,
                onSelect: widget.onSelect,
                onOpenSession: widget.onOpenSession),
          Expanded(
            child: Column(
              children: [
                if (!isWide)
                  TopAppBar(
                    showBack: true,
                    onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}