import 'package:flutter/material.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/ui_state_controller.dart';

/// Items de navegación del sidebar compartido.
enum AppSidebarItem {
  newChat,
  projects,
  memory,
  agenda,
  miniApps,
  settings,
  profile
}

/// Sidebar unificado: logo soybluia, "Nuevo chat", Recientes agrupados por
/// fecha con snippet, Memoria/Proyectos/Agenda/Mini-aplicaciones, cuenta fija
/// con avatar y Configuración. `selected` resalta la sección actual.
///
/// En pantallas anchas se puede colapsar a un rail de iconos (inspiración
/// Manus: recuperar espacio del área de trabajo). La preferencia se persiste
/// vía [UiStateController].
class AppSidebar extends StatelessWidget {
  final AppSidebarItem? selected;
  final ValueChanged<AppSidebarItem> onSelect;

  /// Al tocar una sesión de "Recientes" se abre su historial (SPEC §6).
  final ValueChanged<ChatSession>? onOpenSession;

  const AppSidebar({
    super.key,
    this.selected,
    required this.onSelect,
    this.onOpenSession,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UiStateController.instance,
      builder: (context, _) {
        final collapsed = UiStateController.instance.sidebarCollapsed;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: collapsed ? 72 : 280,
          decoration: BoxDecoration(
            color: ThemeScope.of(context).surfaceContainerLow,
            border: Border(
                right: BorderSide(
                    color: ThemeScope.of(context)
                        .outlineVariant
                        .withValues(alpha: 0.2))),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: collapsed ? 12 : 16),
              child: collapsed
                  ? _buildCollapsed(context)
                  : _buildExpanded(context),
            ),
          ),
        );
      },
    );
  }

  /// Columna completa (280px) con Recents, navegación y cuenta.
  Widget _buildExpanded(BuildContext context) {
    final selected = this.selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _BrandHeader(
          onToggleCollapse: () => UiStateController.instance
              .setSidebarCollapsed(true),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: _NewChatButton(
            onTap: () => onSelect(AppSidebarItem.newChat),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionLabel('Recientes'),
        Expanded(
          child: ListenableBuilder(
            listenable: SessionStore.instance,
            builder: (context, _) {
              return _buildRecentList(context, selected);
            },
          ),
        ),
        const SizedBox(height: 12),
        _UserCard(onTap: () => onSelect(AppSidebarItem.profile)),
        const SizedBox(height: 8),
        _SettingsButton(
          selected: selected == AppSidebarItem.settings,
          onTap: () => onSelect(AppSidebarItem.settings),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecentList(BuildContext context, AppSidebarItem? selected) {
    final sessions = SessionStore.instance.sessions;
    if (sessions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text('Sin conversaciones',
            style: kBodyMd.copyWith(color: BrandColors.gris)),
      );
    }
    final grouped = _groupByDate(sessions);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        for (final group in grouped) ...[
          if (group.label.isNotEmpty) _SectionLabel(group.label),
          for (final s in group.items)
            _SidebarLink(
              icon: s.icon,
              label: s.title,
              subtitle: s.messages.isEmpty
                  ? _relative(s.date)
                  : '${_relative(s.date)} · ${_snippet(s.messages.last.text)}',
              onTap: () {
                if (onOpenSession != null) {
                  onOpenSession!(s);
                } else {
                  onSelect(AppSidebarItem.newChat);
                }
              },
            ),
        ],
        const SizedBox(height: 8),
        const _SectionLabel('Mini-aplicaciones'),
        for (final app in MiniAppsStore.instance.apps)
          _SidebarLink(
            icon: app.icon,
            label: app.title,
            onTap: () => onSelect(AppSidebarItem.miniApps),
          ),
        const SizedBox(height: 8),
        _SidebarLink(
          icon: Icons.folder_outlined,
          label: 'Proyectos',
          onTap: () => onSelect(AppSidebarItem.projects),
          selected: selected == AppSidebarItem.projects,
        ),
        _SidebarLink(
          icon: Icons.menu_book_outlined,
          label: 'Memoria',
          onTap: () => onSelect(AppSidebarItem.memory),
          selected: selected == AppSidebarItem.memory,
        ),
        _AgendaLink(
          selected: selected == AppSidebarItem.agenda,
          onTap: () => onSelect(AppSidebarItem.agenda),
        ),
      ],
    );
  }

  /// Rail colapsado (72px): solo iconos con tooltips + avatar.
  Widget _buildCollapsed(BuildContext context) {
    final selected = this.selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        _CollapsedBrand(onTap: () => UiStateController.instance
            .setSidebarCollapsed(false)),
        const SizedBox(height: 20),
        _CollapsedIconNav(
          icon: Icons.add,
          label: 'Nuevo chat',
          onTap: () => onSelect(AppSidebarItem.newChat),
        ),
        const SizedBox(height: 12),
        _CollapsedIconNav(
          icon: Icons.folder_outlined,
          label: 'Proyectos',
          selected: selected == AppSidebarItem.projects,
          onTap: () => onSelect(AppSidebarItem.projects),
        ),
        _CollapsedIconNav(
          icon: Icons.menu_book_outlined,
          label: 'Memoria',
          selected: selected == AppSidebarItem.memory,
          onTap: () => onSelect(AppSidebarItem.memory),
        ),
        _CollapsedIconNav(
          icon: Icons.calendar_month_outlined,
          label: 'Agenda',
          selected: selected == AppSidebarItem.agenda,
          onTap: () => onSelect(AppSidebarItem.agenda),
        ),
        _CollapsedIconNav(
          icon: Icons.grid_view_outlined,
          label: 'Mini-aplicaciones',
          selected: selected == AppSidebarItem.miniApps,
          onTap: () => onSelect(AppSidebarItem.miniApps),
        ),
        const Spacer(),
        _CollapsedAvatar(onTap: () => onSelect(AppSidebarItem.profile)),
        const SizedBox(height: 12),
        _CollapsedIconNav(
          icon: Icons.settings_outlined,
          label: 'Configuración',
          selected: selected == AppSidebarItem.settings,
          onTap: () => onSelect(AppSidebarItem.settings),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  static List<({String label, List<ChatSession> items})> _groupByDate(
      List<ChatSession> sessions) {
    final order = ['Hoy', 'Ayer', 'Esta semana', 'Este mes', 'Anteriores'];
    final buckets = <String, List<ChatSession>>{
      for (final o in order) o: [],
    };
    for (final s in sessions) {
      buckets[_bucket(s.date)]!.add(s);
    }
    return [
      for (final o in order)
        if (buckets[o]!.isNotEmpty)
          (label: o, items: buckets[o]!),
    ];
  }

  static String _bucket(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff <= 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    if (diff < 7) return 'Esta semana';
    if (diff < 30) return 'Este mes';
    return 'Anteriores';
  }

  static String _relative(DateTime date) {
    final now = DateTime.now();
    final d = now.difference(date);
    if (d.inMinutes < 1) return 'ahora';
    if (d.inHours < 1) return 'hace ${d.inMinutes} min';
    if (d.inDays < 1) return 'hace ${d.inHours} h';
    if (d.inDays < 30) return 'hace ${d.inDays} d';
    return '${date.day}/${date.month}';
  }

  /// Vista previa del último mensaje, truncada para la lista de Recientes.
  static String _snippet(String text) {
    final compact = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 48) return compact;
    return '${compact.substring(0, 45)}…';
  }
}

class _BrandHeader extends StatelessWidget {
  final VoidCallback onToggleCollapse;

  const _BrandHeader({required this.onToggleCollapse});

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeScope.of(context).background == AppPalette.light.background;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Image.asset('assets/logos/mark-azul.png', width: 32, height: 32, filterQuality: FilterQuality.high),
          const SizedBox(width: 10),
          Expanded(
            child: Image.asset(
              isLight ? 'assets/logos/wordmark-oscuro.png' : 'assets/logos/wordmark-claro.png',
              height: 18,
              alignment: Alignment.centerLeft,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => Text('soybluia',
                  style: kHeadlineMd.copyWith(
                      color: ThemeScope.of(context).onSurface, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onToggleCollapse,
            tooltip: 'Colapsar barra lateral',
            icon: Icon(Icons.chevron_left,
                size: 18, color: ThemeScope.of(context).onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CollapsedBrand extends StatelessWidget {
  final VoidCallback onTap;

  const _CollapsedBrand({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Expandir barra lateral',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Image.asset('assets/logos/mark-azul.png', width: 40, height: 40, filterQuality: FilterQuality.high),
      ),
    );
  }
}

class _NewChatButton extends StatelessWidget {
  final VoidCallback onTap;

  const _NewChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ThemeScope.of(context).surfaceContainerHigh,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: ThemeScope.of(context).surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.add,
                  size: 18, color: ThemeScope.of(context).onSurface),
              const SizedBox(width: 8),
              Text('Nuevo chat',
                  style: kLabelMd.copyWith(
                      color: ThemeScope.of(context).onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(text.toUpperCase(),
          style: kLabelMd.copyWith(
              fontSize: 10,
              height: 1.2,
              letterSpacing: 0.8,
              color: ThemeScope.of(context)
                  .onSurfaceVariant
                  .withValues(alpha: 0.7))),
    );
  }
}

class _SidebarLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;

  /// Distintivo cobalto con contador (recordatorios pendientes, etc.).
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarLink({
    required this.icon,
    required this.label,
    this.subtitle,
    this.badge,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: selected ? c.surfaceContainerHigh : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: c.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Icon(icon,
                  size: 16,
                  color: selected
                      ? c.primary
                      : c.onSurfaceVariant.withValues(alpha: 0.7)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kBodyMd.copyWith(
                            fontSize: 13,
                            color: selected ? c.primary : c.onSurfaceVariant)),
                    if (subtitle != null)
                      Text(subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: kLabelMd.copyWith(
                              fontSize: 10, color: BrandColors.gris)),
                  ],
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: BrandColors.cobalt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(badge!,
                      style:
                          kLabelMd.copyWith(fontSize: 11, color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Enlace mínimo para el rail colapsado: icono centrado con tooltip.
class _CollapsedIconNav extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CollapsedIconNav({
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Material(
          color: selected ? c.surfaceContainerHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            hoverColor: c.surfaceContainerHigh,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon,
                  size: 20,
                  color: selected
                      ? c.primary
                      : c.onSurfaceVariant.withValues(alpha: 0.75)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Entrada de Agenda con distintivo cobalto de recordatorios pendientes.
class _AgendaLink extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _AgendaLink({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RemindersStore.instance,
      builder: (context, _) {
        final pending = RemindersStore.instance.pendingCount;
        return _SidebarLink(
          icon: Icons.calendar_month_outlined,
          label: 'Agenda',
          subtitle: pending > 0
              ? '$pending recordatorio${pending > 1 ? 's' : ''}'
              : null,
          badge: pending > 0 ? '$pending' : null,
          selected: selected,
          onTap: onTap,
        );
      },
    );
  }
}

/// Tarjeta de usuario con avatar de inicial, plan real y acceso al perfil.
class _UserCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _UserCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return ListenableBuilder(
      listenable: UserStore.instance,
      builder: (context, _) {
        final user = UserStore.instance;
        final plan = user.plan;
        final active = plan != UserPlan.gratis;
        final isGuest = !user.loggedIn;
        return Material(
          color: c.surfaceContainerHigh.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap ?? () {},
            borderRadius: BorderRadius.circular(8),
            hoverColor: c.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _Avatar(initial: isGuest ? '?' : _initial(user.name)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isGuest ? 'Invitado' : user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: kBodyMd.copyWith(
                                fontSize: 13, color: c.onSurface)),
                        const SizedBox(height: 2),
                        Text(isGuest ? 'Inicia sesión' : 'Plan ${plan.label}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: kLabelMd.copyWith(
                                fontSize: 11,
                                color: isGuest
                                    ? c.primary
                                    : (active
                                        ? BrandColors.cobalt
                                        : BrandColors.gris))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right,
                      size: 16, color: c.onSurfaceVariant),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CollapsedAvatar extends StatelessWidget {
  final VoidCallback onTap;

  const _CollapsedAvatar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserStore.instance,
      builder: (context, _) {
        final user = UserStore.instance;
        final isGuest = !user.loggedIn;
        return Tooltip(
          message: isGuest ? 'Perfil' : user.name,
          waitDuration: const Duration(milliseconds: 400),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: _Avatar(
              initial: isGuest ? '?' : _initial(user.name),
              size: 34,
            ),
          ),
        );
      },
    );
  }
}

/// Avatar circular cobalto con la inicial del nombre (SPEC §12: sin imágenes
/// remotas; se usa una inicial tipográfica).
class _Avatar extends StatelessWidget {
  final String initial;
  final double size;

  const _Avatar({required this.initial, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: BrandColors.cobalt,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(initial.toUpperCase(),
          style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.42,
              fontWeight: FontWeight.w600,
              fontFamily: 'Geist')),
    );
  }
}

String _initial(String name) =>
    name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

class _SettingsButton extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _SettingsButton({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? ThemeScope.of(context).surfaceContainerHigh
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: ThemeScope.of(context).surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(Icons.settings,
                  size: 20, color: ThemeScope.of(context).onSurfaceVariant),
              const SizedBox(width: 12),
              Text('Configuración',
                  style: kBodyMd.copyWith(
                      fontSize: 13,
                      color: ThemeScope.of(context).onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}