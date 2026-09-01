import 'package:flutter/material.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/shared/app_card.dart';
import '../widgets/shared/sidebar_shell.dart';
import '../widgets/shared/shimmer.dart';
import 'agenda_screen.dart';
import 'chat_screen.dart';
import 'memory_screen.dart';
import 'profile_screen.dart';
import 'projects_screen.dart';
import 'settings_screen.dart';

/// Mini-aplicaciones guardadas (SPEC §7): se listan en el panel lateral, se
/// abren a pantalla completa y se pueden editar.
class MiniAppsScreen extends StatelessWidget {
  const MiniAppsScreen({super.key});

  void _switch(BuildContext context, AppSidebarItem item) {
    switch (item) {
      case AppSidebarItem.newChat:
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
            (r) => false);
      case AppSidebarItem.miniApps:
        break;
      case AppSidebarItem.projects:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProjectsScreen()));
      case AppSidebarItem.memory:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MemoryScreen()));
      case AppSidebarItem.agenda:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const AgendaScreen()));
      case AppSidebarItem.settings:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
      case AppSidebarItem.profile:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SidebarShell(
      selected: AppSidebarItem.miniApps,
      onSelect: (item) => _switch(context, item),
      onOpenSession: (s) => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ChatScreen(sessionId: s.id))),
      child: ListenableBuilder(
        listenable: MiniAppsStore.instance,
        builder: (context, _) {
          final apps = MiniAppsStore.instance.apps;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const PageHeader(
                      title: 'Mini-aplicaciones',
                      subtitle:
                          'Herramientas generadas en el chat y guardadas aquí.',
                    ),
                    const SizedBox(height: 24),
                    if (apps.isEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Aún no guardaste mini-aplicaciones.',
                              style:
                                  kBodyMd.copyWith(color: BrandColors.gris)),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ChatScreen()),
                            ),
                            icon: const Icon(Icons.auto_awesome, size: 16),
                            style: FilledButton.styleFrom(
                              backgroundColor: BrandColors.cobalt,
                              foregroundColor: Colors.white,
                            ),
                            label: const Text('Crear una en el chat'),
                          ),
                        ],
                      )
                    else
                      for (final app in apps) ...[
                        _MiniAppRow(
                          app: app,
                          onOpen: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  MiniAppViewer(app: app),
                            ),
                          ),
                          onEdit: () => showMiniAppRenameDialog(context, app),
                        ),
                        const SizedBox(height: 12),
                      ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

  /// Diálogo para renombrar una mini-aplicación; "Guardar" aplica el texto
  /// escrito en el campo (no el título viejo).
  Future<void> showMiniAppRenameDialog(BuildContext context, MiniApp app) {
  final controller = TextEditingController(text: app.title);
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: ThemeScope.of(dialogContext).surfaceContainerLow,
      title: Text('Editar mini-aplicación',
          style: kHeadlineMd.copyWith(
              color: ThemeScope.of(dialogContext).onSurface)),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: kBodyMd.copyWith(color: ThemeScope.of(dialogContext).onSurface),
        decoration: InputDecoration(
          labelText: 'Nombre',
          labelStyle:
              kLabelMd.copyWith(color: ThemeScope.of(dialogContext).onSurfaceVariant),
          filled: true,
          fillColor: ThemeScope.of(dialogContext).surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: ThemeScope.of(dialogContext).outlineVariant),
          ),
        ),
        onSubmitted: (v) => _applyRename(dialogContext, app, controller, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () =>
              _applyRename(dialogContext, app, controller, controller.text),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

void _applyRename(
    BuildContext context, MiniApp app, TextEditingController controller, String raw) {
  final name = raw.trim();
  if (name.isNotEmpty) MiniAppsStore.instance.rename(app.id, name);
  Navigator.of(context).pop();
}

class _MiniAppRow extends StatelessWidget {
  final MiniApp app;
  final VoidCallback onOpen;
  final VoidCallback onEdit;

  const _MiniAppRow({
    required this.app,
    required this.onOpen,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return AppCard(
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        hoverColor: c.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: BrandColors.cobalt.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(app.icon, size: 20, color: BrandColors.cobalt),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.title,
                        style: kBodyMd.copyWith(
                            color: c.onSurface, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(
                        app.edited ? 'Versión editada' : 'Generada en el chat',
                        style: kLabelMd.copyWith(
                            fontSize: 11, color: BrandColors.gris)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    size: 18, color: c.onSurfaceVariant),
                onPressed: onEdit,
                tooltip: 'Editar',
              ),
              const Icon(Icons.chevron_right, color: BrandColors.gris),
            ],
          ),
        ),
      ),
    );
  }
}

/// Visor a pantalla completa de una mini-aplicación (marco incrustado).
class MiniAppViewer extends StatelessWidget {
  /// Vínculo a la mini-app guardada; cuando viene del chat ([app] nulo) se
  /// muestran [title]/[icon] tal cual y la edición queda deshabilitada.
  final MiniApp? app;
  final String? title;
  final IconData? icon;

  const MiniAppViewer({super.key, this.app, this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final live = app == null ? null : MiniAppsStore.instance.byId(app!.id);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            ListenableBuilder(
              listenable: MiniAppsStore.instance,
              builder: (context, _) {
                final current =
                    live ?? MiniAppsStore.instance.byId(app?.id ?? '');
                final title = current?.title ?? this.title ?? '';
                final icon = current?.icon ?? this.icon ?? Icons.widgets_outlined;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: BrandColors.cobalt.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Icon(icon, size: 16, color: BrandColors.cobalt),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: kHeadlineMd.copyWith(
                                color: c.onSurface, fontWeight: FontWeight.w600)),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            size: 18,
                            color: app == null ? c.outlineVariant : c.onSurfaceVariant),
                        onPressed: app == null
                            ? null
                            : () => showMiniAppRenameDialog(context, app!),
                        tooltip: 'Editar',
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: BoxDecoration(
                  color: c.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: c.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: _AppFrame(icon: icon ?? Icons.widgets_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estructura de carga mientras se descarga el paquete (SPEC §7), luego el
/// marco con el contenido de la mini-aplicación.
class _AppFrame extends StatefulWidget {
  final IconData icon;

  const _AppFrame({required this.icon});

  @override
  State<_AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends State<_AppFrame> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skeleton con brillo animado mientras se descarga el paquete.
            ShimmerBox(height: 14, radius: 4, width: 180),
            SizedBox(height: 10),
            ShimmerBox(height: 10, radius: 4, width: 140),
            SizedBox(height: 24),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 48, color: BrandColors.cobalt),
          const SizedBox(height: 16),
          Text('Mini-aplicación generada',
              style: kHeadlineMd.copyWith(color: c.onSurface)),
          const SizedBox(height: 8),
          Text('El marco incrustado (WebView) se cargará aquí.',
              style: kBodyMd.copyWith(color: BrandColors.gris)),
        ],
      ),
    );
  }
}