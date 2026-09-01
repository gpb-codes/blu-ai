import 'package:flutter/material.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/shared/app_card.dart';
import '../widgets/shared/sidebar_shell.dart';
import 'agenda_screen.dart';
import 'chat_screen.dart';
import 'memory_screen.dart';
import 'mini_apps_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

/// Pantalla de proyectos colaborativos (SPEC §3): tarjetas con rol,
/// crear/editar/invitar/eliminar y gestión de miembros.
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SidebarShell(
      selected: AppSidebarItem.projects,
      onSelect: (item) => _switchSidebar(context, item, _openScreen),
      onOpenSession: (s) => _openScreen(context, ChatScreen(sessionId: s.id)),
      child: ListenableBuilder(
        listenable: ProjectsStore.instance,
        builder: (context, _) {
          final projects = ProjectsStore.instance.projects;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(
                          child: PageHeader(
                            title: 'Proyectos',
                            subtitle:
                                'Colabora con permisos y memoria compartida por proyecto.',
                          ),
                        ),
                        const SizedBox(width: 12),
                        _CreateProjectButton(
                            onTap: () => _showCreateDialog(context)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (projects.isEmpty)
                      _EmptyState(
                        icon: Icons.folder_open_outlined,
                        title: 'Sin proyectos todavía',
                        action: 'Crear proyecto',
                        onAction: () => _showCreateDialog(context),
                      )
                    else
                      for (final p in projects) ...[
                        _ProjectCard(
                          project: p,
                          onOpen: () => _showDetail(context, p),
                          onEdit: () => _showRenameDialog(context, p),
                          onInvite: () => _showInviteDialog(context, p),
                          onRemove: () => _confirmRemove(context, p),
                        ),
                        const SizedBox(height: 16),
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

  void _switchSidebar(BuildContext context, AppSidebarItem item,
      void Function(BuildContext, Widget) open) {
    switch (item) {
      case AppSidebarItem.newChat:
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
            (r) => false);
      case AppSidebarItem.projects:
        break;
      case AppSidebarItem.memory:
        open(context, const MemoryScreen());
      case AppSidebarItem.agenda:
        open(context, const AgendaScreen());
      case AppSidebarItem.miniApps:
        open(context, const MiniAppsScreen());
      case AppSidebarItem.settings:
        open(context, const SettingsScreen());
      case AppSidebarItem.profile:
        open(context, const ProfileScreen());
    }
  }

  void _showCreateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _CreateProjectDialog(
        onCreated: (name) {
          ProjectsStore.instance.create(name);
          _snack(context, 'Proyecto "$name" creado');
        },
      ),
    );
  }

  void _showRenameDialog(BuildContext context, Project p) {
    showDialog<void>(
      context: context,
      builder: (_) => _CreateProjectDialog(
        initialName: p.name,
        submitLabel: 'Guardar',
        onCreated: (name) {
          ProjectsStore.instance.rename(p.id, name);
          _snack(context, 'Proyecto renombrado');
        },
      ),
    );
  }

  void _showInviteDialog(BuildContext context, Project p) {
    showDialog<void>(
      context: context,
      builder: (_) => _InviteDialog(
        onInvite: (email, role) {
          ProjectsStore.instance.invite(p.id, email, role);
          _snack(context, '$email invitado como ${role.label}');
        },
      ),
    );
  }

  void _showDetail(BuildContext context, Project p) {
    showDialog<void>(
      context: context,
      builder: (_) => _ProjectDetailDialog(project: p),
    );
  }

  void _confirmRemove(BuildContext context, Project p) {
    final canDelete =
        p.role == ProjectRole.propietario || p.role == ProjectRole.admin;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ThemeScope.of(context).surfaceContainerLow,
        title: Text(canDelete ? 'Eliminar proyecto' : 'Salir del proyecto',
            style:
                kHeadlineMd.copyWith(color: ThemeScope.of(context).onSurface)),
        content: Text(
            canDelete
                ? '¿Eliminar "${p.name}" y todos sus datos? Esta acción no se puede deshacer.'
                : '¿Salir de "${p.name}"? Dejarás de ver su contenido.',
            style: kBodyMd.copyWith(
                color: ThemeScope.of(context).onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ProjectsStore.instance.remove(p.id);
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Color(0xFFBA1A1A))),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: ThemeScope.of(context).surfaceContainerHigh,
        content: Text(text,
            style: kBodyMd.copyWith(color: ThemeScope.of(context).onSurface)),
      ));
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onInvite;
  final VoidCallback onRemove;

  const _ProjectCard({
    required this.project,
    required this.onOpen,
    required this.onEdit,
    required this.onInvite,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: BrandColors.cobalt.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.folder_outlined,
                    size: 20, color: BrandColors.cobalt),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name,
                        style: kHeadlineMd.copyWith(
                            color: c.onSurface, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                        '${project.slug} · creado el '
                        '${project.createdAt.day}/${project.createdAt.month}/${project.createdAt.year}',
                        style: kLabelMd.copyWith(
                            fontSize: 12, color: BrandColors.gris)),
                  ],
                ),
              ),
              _RoleChip(role: project.role),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CardAction(
                icon: Icons.open_in_new,
                label: 'Abrir',
                onTap: onOpen,
                primary: true,
              ),
              _CardAction(
                  icon: Icons.edit_outlined, label: 'Editar', onTap: onEdit),
              _CardAction(
                  icon: Icons.person_add_alt,
                  label: 'Invitar',
                  onTap: onInvite),
              _CardAction(
                icon: project.role == ProjectRole.propietario ||
                        project.role == ProjectRole.admin
                    ? Icons.delete_outline
                    : Icons.logout,
                label: project.role == ProjectRole.propietario ||
                        project.role == ProjectRole.admin
                    ? 'Eliminar'
                    : 'Salir',
                onTap: onRemove,
                danger: project.role == ProjectRole.propietario,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final ProjectRole role;
  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: BrandColors.cobalt.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(role.icon, size: 12, color: BrandColors.cobalt),
          const SizedBox(width: 4),
          Text(role.label,
              style:
                  kLabelMd.copyWith(fontSize: 10, color: BrandColors.cobalt)),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool danger;

  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final color = danger
        ? const Color(0xFFBA1A1A)
        : primary
            ? BrandColors.cobalt
            : c.onSurfaceVariant;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: c.surfaceContainerHigh,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: (primary || danger)
                ? color.withValues(alpha: 0.1)
                : c.surfaceContainerHigh.withValues(alpha: 0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label, style: kLabelMd.copyWith(fontSize: 12, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateProjectButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateProjectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: BrandColors.cobalt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text('Crear proyecto',
                  style: kLabelMd.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateProjectDialog extends StatefulWidget {
  final ValueChanged<String> onCreated;
  final String? initialName;
  final String submitLabel;

  const _CreateProjectDialog({
    required this.onCreated,
    this.initialName,
    this.submitLabel = 'Crear',
  });

  @override
  State<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName ?? '');
  String? _error;

  String get _slug => _name.text
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  bool get _slugTaken =>
      ProjectsStore.instance.projects.any((p) => p.slug == _slug);

  void _submit() {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'El nombre es obligatorio.');
      return;
    }
    if (_slug.isEmpty || _slugTaken) {
      setState(() => _error = 'El slug "$_slug" ya existe. Usa otro nombre.');
      return;
    }
    Navigator.of(context).pop();
    widget.onCreated(_name.text.trim());
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return AlertDialog(
      backgroundColor: c.surfaceContainerLow,
      title: Text(
          widget.initialName == null ? 'Crear proyecto' : 'Editar proyecto',
          style: kHeadlineMd.copyWith(color: c.onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: kBodyMd.copyWith(color: c.onSurface),
            decoration: InputDecoration(
              labelText: 'Nombre',
              labelStyle: kLabelMd.copyWith(color: c.onSurfaceVariant),
              filled: true,
              fillColor: c.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: c.outlineVariant),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('slug: $_slug',
              style: kCodeSm.copyWith(color: BrandColors.gris)),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 14, color: Color(0xFFFF6B5E)),
                const SizedBox(width: 6),
                Text(_error!,
                    style: kLabelMd.copyWith(
                        fontSize: 12, color: const Color(0xFFFF6B5E))),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _submit, child: Text(widget.submitLabel)),
      ],
    );
  }
}

class _InviteDialog extends StatefulWidget {
  final void Function(String email, ProjectRole role) onInvite;

  const _InviteDialog({required this.onInvite});

  @override
  State<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<_InviteDialog> {
  final _email = TextEditingController();
  ProjectRole _role = ProjectRole.editor;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Escribe el correo de la persona a invitar.');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _error = 'Ese correo no parece válido.');
      return;
    }
    Navigator.of(context).pop();
    widget.onInvite(email, _role);
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return AlertDialog(
      backgroundColor: c.surfaceContainerLow,
      title: Text('Invitar miembro',
          style: kHeadlineMd.copyWith(color: c.onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            style: kBodyMd.copyWith(color: c.onSurface),
            decoration: InputDecoration(
              labelText: 'Correo',
              labelStyle: kLabelMd.copyWith(color: c.onSurfaceVariant),
              filled: true,
              fillColor: c.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: c.outlineVariant),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(_error!,
                style: kBodyMd.copyWith(
                    fontSize: 12, color: const Color(0xFFFF6B5E))),
            const SizedBox(height: 16),
          ],
          DropdownButtonFormField<ProjectRole>(
            initialValue: _role,
            dropdownColor: c.surfaceContainerLow,
            items: ProjectRole.values
                .map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.label,
                        style: kBodyMd.copyWith(color: c.onSurface))))
                .toList(),
            onChanged: (v) => setState(() => _role = v ?? _role),
            style: kBodyMd.copyWith(color: c.onSurface),
            decoration: InputDecoration(
              labelText: 'Rol',
              labelStyle: kLabelMd.copyWith(color: c.onSurfaceVariant),
              filled: true,
              fillColor: c.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: c.outlineVariant),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Invitar'),
        ),
      ],
    );
  }
}

class _ProjectDetailDialog extends StatelessWidget {
  final Project project;

  const _ProjectDetailDialog({required this.project});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final canManage = project.role == ProjectRole.propietario ||
        project.role == ProjectRole.admin;
    return AlertDialog(
      backgroundColor: c.surfaceContainerLow,
      title:
          Text(project.name, style: kHeadlineMd.copyWith(color: c.onSurface)),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Acceso: ${project.role.label}',
                style: kLabelMd.copyWith(color: BrandColors.cobalt)),
            const SizedBox(height: 12),
            Text('Miembros (${project.members.length})',
                style: kLabelMd.copyWith(
                    color: c.onSurfaceVariant, letterSpacing: 0.4)),
            const SizedBox(height: 8),
            for (final m in project.members)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(m.role.icon, size: 14, color: BrandColors.gris),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(m.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: kBodyMd.copyWith(
                              fontSize: 13, color: c.onSurface)),
                    ),
                    Text(m.role.label,
                        style: kLabelMd.copyWith(
                            fontSize: 11, color: BrandColors.gris)),
                    if (canManage && m.role != ProjectRole.propietario) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          ProjectsStore.instance
                              .removeMember(project.id, m.email);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close,
                            size: 15, color: Color(0xFFFF6B5E)),
                        padding: const EdgeInsets.all(8),
                        constraints:
                            const BoxConstraints(minWidth: 38, minHeight: 38),
                        tooltip: 'Quitar miembro',
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text('El editor escribe, el visualizador solo lee.',
                style:
                    kLabelMd.copyWith(fontSize: 11, color: BrandColors.gris)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String action;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 40, color: BrandColors.gris),
          const SizedBox(height: 12),
          Text(title, style: kBodyMd.copyWith(color: c.onSurfaceVariant)),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: BrandColors.cobalt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Text(action, style: kLabelMd.copyWith(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
