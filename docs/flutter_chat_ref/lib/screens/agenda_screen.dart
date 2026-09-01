import 'package:flutter/material.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/shared/app_card.dart';
import '../widgets/shared/sidebar_shell.dart';
import 'chat_screen.dart';
import 'memory_screen.dart';
import 'mini_apps_screen.dart';
import 'profile_screen.dart';
import 'projects_screen.dart';
import 'settings_screen.dart';

/// Agenda y recordatorios (SPEC §9): modal crear/editar/eliminar, distintivo
/// de pendientes y confirmaciones de calendario.
class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  void _switch(BuildContext context, AppSidebarItem item) {
    switch (item) {
      case AppSidebarItem.newChat:
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
            (r) => false);
      case AppSidebarItem.agenda:
        break;
      case AppSidebarItem.projects:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProjectsScreen()));
      case AppSidebarItem.memory:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MemoryScreen()));
      case AppSidebarItem.miniApps:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MiniAppsScreen()));
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
      selected: AppSidebarItem.agenda,
      onSelect: (item) => _switch(context, item),
      onOpenSession: (s) => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ChatScreen(sessionId: s.id))),
      child: ListenableBuilder(
        listenable: RemindersStore.instance,
        builder: (context, _) {
          final reminders = RemindersStore.instance.reminders;
          return Stack(
            children: [
              SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const PageHeader(
                          title: 'Agenda',
                          subtitle:
                              'Recordatorios y confirmaciones de calendario.',
                        ),
                        const SizedBox(height: 24),
                        _ConfirmationCard(),
                        const SizedBox(height: 24),
                        Text('Recordatorios (${reminders.length})',
                            style: kLabelMd.copyWith(
                                color: ThemeScope.of(context).onSurfaceVariant,
                                letterSpacing: 0.4)),
                        const SizedBox(height: 12),
                        if (reminders.isEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sin recordatorios pendientes.',
                                  style: kBodyMd.copyWith(
                                      color: BrandColors.gris)),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () => _showReminderDialog(context),
                                icon: const Icon(Icons.alarm_add, size: 16),
                                style: FilledButton.styleFrom(
                                  backgroundColor: BrandColors.cobalt,
                                  foregroundColor: Colors.white,
                                ),
                                label: const Text('Crear recordatorio'),
                              ),
                            ],
                          )
                        else
                          for (final r in reminders) ...[
                            _ReminderCard(
                              reminder: r,
                              onDelete: () {
                                RemindersStore.instance.remove(r.id);
                              },
                              onEdit: () =>
                                  _showReminderDialog(context, existing: r),
                            ),
                            const SizedBox(height: 12),
                          ],
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 24,
                bottom: 24,
                child: FloatingActionButton(
                  onPressed: () => _showReminderDialog(context),
                  backgroundColor: BrandColors.cobalt,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReminderDialog(BuildContext context, {Reminder? existing}) {
    showDialog<void>(
      context: context,
      builder: (_) => ReminderDialog(
        existing: existing,
        onSave: (text, at, tz) {
          if (existing == null) {
            RemindersStore.instance.add(text, at, tz);
          } else {
            RemindersStore.instance.update(existing.id, text, at, tz);
          }
        },
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ReminderCard({
    required this.reminder,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final now = DateTime.now();
    final isToday = reminder.at.year == now.year &&
        reminder.at.month == now.month &&
        reminder.at.day == now.day;
    final overdue = reminder.at.isBefore(now);
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: overdue
                  ? c.warningContainer
                  : BrandColors.cobalt.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
                overdue ? Icons.schedule_send : Icons.notifications_none,
                size: 18,
                color: overdue ? c.warning : BrandColors.cobalt),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(reminder.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: kBodyMd.copyWith(
                              color: c.onSurface, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 8),
                    _ReminderStatusBadge(
                      overdue: overdue,
                      isToday: isToday,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                    '${reminder.at.day}/${reminder.at.month}/${reminder.at.year} '
                    '${reminder.at.hour.toString().padLeft(2, '0')}:'
                    '${reminder.at.minute.toString().padLeft(2, '0')} '
                    '(${reminder.timezone})',
                    style: kLabelMd.copyWith(
                        fontSize: 12,
                        color: overdue ? c.warning : BrandColors.gris)),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon:
                Icon(Icons.edit_outlined, size: 18, color: c.onSurfaceVariant),
            padding: const EdgeInsets.all(10),
            tooltip: 'Editar recordatorio',
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, size: 18, color: c.error),
            padding: const EdgeInsets.all(10),
            tooltip: 'Eliminar recordatorio',
          ),
        ],
      ),
    );
  }
}

/// Distintivo de estado del recordatorio con tinte al 12% (patrón Manus:
/// vencido = warning, hoy = marca, en agenda = éxito).
class _ReminderStatusBadge extends StatelessWidget {
  final bool overdue;
  final bool isToday;

  const _ReminderStatusBadge({
    required this.overdue,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final (label, fg, bg) = overdue
        ? ('Vencido', c.warning, c.warningContainer)
        : isToday
            ? ('Hoy', BrandColors.cobalt, BrandColors.cobalt.withValues(alpha: 0.12))
            : ('En agenda', c.success, c.successContainer);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: kLabelMd.copyWith(fontSize: 10, color: fg)),
    );
  }
}

/// Tarjeta de confirmación de agenda (Google Calendar): Confirmar / Rechazar;
/// cada acción deja un estado propio visible (SPEC §9).
enum _Decision { confirmed, rejected }

class _ConfirmationCard extends StatefulWidget {
  @override
  State<_ConfirmationCard> createState() => _ConfirmationCardState();
}

class _ConfirmationCardState extends State<_ConfirmationCard> {
  _Decision? _decision;

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    if (_decision != null) {
      final confirmed = _decision == _Decision.confirmed;
      return AppCard(
        child: Row(
          children: [
            Icon(
              confirmed ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 18,
              color: confirmed ? BrandColors.cobalt : const Color(0xFFFF5A4E),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  confirmed
                      ? 'Confirmaste "Revisión del roadmap"'
                      : 'Rechazaste "Revisión del roadmap"',
                  style: kBodyMd.copyWith(
                      color: c.onSurface, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
    }
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.event_available,
                size: 18, color: BrandColors.cobalt),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Confirmación de agenda',
                    style: kBodyMd.copyWith(
                        color: c.onSurface, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('"Revisión del roadmap" · mañana 11:00',
                    style: kLabelMd.copyWith(
                        fontSize: 12, color: c.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ConfirmButton(
            label: 'Confirmar',
            onTap: () => setState(() => _decision = _Decision.confirmed),
          ),
          const SizedBox(width: 8),
          _ConfirmButton(
            label: 'Rechazar',
            outline: true,
            onTap: () => setState(() => _decision = _Decision.rejected),
          ),
        ],
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outline;

  const _ConfirmButton({
    required this.label,
    required this.onTap,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: outline ? Colors.transparent : BrandColors.cobalt,
            borderRadius: BorderRadius.circular(8),
            border: outline
                ? Border.all(color: ThemeScope.of(context).outlineVariant)
                : null,
          ),
          child: Text(label,
              style: kLabelMd.copyWith(
                  color: outline
                      ? ThemeScope.of(context).onSurface
                      : Colors.white)),
        ),
      ),
    );
  }
}

class ReminderDialog extends StatefulWidget {
  final void Function(String text, DateTime at, String timezone) onSave;

  /// Si se pasa, el diálogo edita el recordatorio existente (SPEC §9).
  final Reminder? existing;

  const ReminderDialog({super.key, required this.onSave, this.existing});

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  late final TextEditingController _text =
      TextEditingController(text: widget.existing?.text ?? '');
  late DateTime _date =
      widget.existing?.at ?? DateTime.now().add(const Duration(days: 1));
  late TimeOfDay _time = widget.existing == null
      ? const TimeOfDay(hour: 9, minute: 0)
      : TimeOfDay(
          hour: widget.existing!.at.hour, minute: widget.existing!.at.minute);
  late String _timezone =
      widget.existing?.timezone ?? 'America/Argentina/Buenos_Aires';

  static const _zones = [
    'America/Argentina/Buenos_Aires',
    'America/Mexico_City',
    'America/Bogota',
    'America/Santiago',
    'America/Sao_Paulo',
    'Europe/Madrid',
    'UTC',
  ];

  Future<void> _pickTimezone() async {
    final c = ThemeScope.of(context);
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: c.surfaceContainerLow,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text('Zona horaria',
                  style: kHeadlineMd.copyWith(
                      color: ThemeScope.of(sheetContext).onSurface,
                      fontWeight: FontWeight.w600)),
            ),
            for (final zone in _zones)
              ListTile(
                title: Text(zone,
                    style: kBodyMd.copyWith(
                        color: ThemeScope.of(sheetContext).onSurface)),
                trailing: zone == _timezone
                    ? const Icon(Icons.check,
                        size: 18, color: BrandColors.cobalt)
                    : null,
                onTap: () => Navigator.of(sheetContext).pop(zone),
              ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) {
      setState(() => _timezone = picked);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return AlertDialog(
      backgroundColor: c.surfaceContainerLow,
      title: Text(
          widget.existing == null
              ? 'Nuevo recordatorio'
              : 'Editar recordatorio',
          style: kHeadlineMd.copyWith(color: c.onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _text,
            autofocus: true,
            style: kBodyMd.copyWith(color: c.onSurface),
            decoration: InputDecoration(
              labelText: 'Recordarme',
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _date = picked);
                    }
                  },
                  label: Text('${_date.day}/${_date.month}/${_date.year}',
                      style:
                          kBodyMd.copyWith(fontSize: 13, color: c.onSurface)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.access_time, size: 16),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _time,
                    );
                    if (picked != null) {
                      setState(() => _time = picked);
                    }
                  },
                  label: Text(
                      '${_time.hour.toString().padLeft(2, '0')}:'
                      '${_time.minute.toString().padLeft(2, '0')}',
                      style:
                          kBodyMd.copyWith(fontSize: 13, color: c.onSurface)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.public, size: 16),
              onPressed: _pickTimezone,
              label: Text('Zona horaria: $_timezone',
                  style: kBodyMd.copyWith(fontSize: 12, color: c.onSurface)),
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
          onPressed: () {
            if (_text.text.trim().isEmpty) return;
            Navigator.of(context).pop();
            widget.onSave(
              _text.text.trim(),
              DateTime(
                  _date.year, _date.month, _date.day, _time.hour, _time.minute),
              _timezone,
            );
          },
          child: Text(widget.existing == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}
