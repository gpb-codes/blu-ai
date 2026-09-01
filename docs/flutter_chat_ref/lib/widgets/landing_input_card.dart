import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../screens/agenda_screen.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'model_selector.dart';
import 'shared/attachment_sheet.dart';
import 'voice_button.dart';

/// Estado vacío del chat estilo claude.ai: chispa terracota, saludo serif,
/// composer cálido y chips de sugerencia en fila debajo.
class LandingInputCard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String model;
  final ValueChanged<String> onModelChanged;
  final String agent;
  final ValueChanged<String> onAgentChanged;
  final Project? project;
  final ValueChanged<Project?> onProjectChanged;

  /// Al tocar una sugerencia de ejemplo se envía su instrucción.
  final ValueChanged<SuggestionCard>? onSuggestionTap;

  const LandingInputCard({
    super.key,
    required this.controller,
    required this.onSend,
    required this.model,
    required this.onModelChanged,
    required this.agent,
    required this.onAgentChanged,
    required this.project,
    required this.onProjectChanged,
    this.onSuggestionTap,
  });

  @override
  State<LandingInputCard> createState() => _LandingInputCardState();
}

class _LandingInputCardState extends State<LandingInputCard> {
  bool _dropdownOpen = false;
  String? _reminderText;

  bool get _hasText => widget.controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
  }

  void _send() {
    setState(() => _dropdownOpen = false);
    widget.onSend();
  }

  void _selectModel(String model) {
    setState(() => _dropdownOpen = false);
    widget.onModelChanged(model);
  }

  void _selectAgent(String agent) {
    setState(() => _dropdownOpen = false);
    widget.onAgentChanged(agent);
  }

  Future<void> _pickProject() async {
    final picked = await showModalBottomSheet<Project>(
      context: context,
      backgroundColor: ThemeScope.of(context).surfaceContainerLow,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _ProjectSheet(
        projects: ProjectsStore.instance.projects,
        current: widget.project?.id,
      ),
    );
    if (picked != null) widget.onProjectChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListenableBuilder(
          listenable: UserStore.instance,
          builder: (context, _) {
            final user = UserStore.instance;
            final greeting = user.loggedIn
                ? 'Hola, ${user.name.split(' ').first}.'
                : 'Hola.';
            return Column(
              children: [
                const Icon(Icons.auto_awesome,
                    size: 22, color: BrandColors.terracota),
                const SizedBox(height: 12),
                Text(greeting,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 36,
                        height: 1.15,
                        letterSpacing: -0.5,
                        color: ThemeScope.of(context).onSurface)),
                const SizedBox(height: 6),
                Text('¿En qué trabajamos hoy?',
                    textAlign: TextAlign.center,
                    style: kBodyMd.copyWith(
                        color: ThemeScope.of(context).onSurfaceVariant)),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 672),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ThemeScope.of(context).surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: ThemeScope.of(context)
                                    .outlineVariant
                                    .withValues(alpha: 0.45)),
                            boxShadow: AppShadows.s,
                          ),
                          child: Column(
                            children: [
                              _ProjectRow(
                                project: widget.project,
                                onPick: _pickProject,
                                onRemove: () => widget.onProjectChanged(null),
                              ),
                              Container(
                                  height: 1,
                                  color: ThemeScope.of(context)
                                      .outlineVariant
                                      .withValues(alpha: 0.2)),
                              _ReminderRow(
                                reminderText: _reminderText,
                                onTap: () => _showReminderDialog(context),
                              ),
                              Container(
                                  height: 1,
                                  color: ThemeScope.of(context)
                                      .outlineVariant
                                      .withValues(alpha: 0.2)),
                              _buildInputRow(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_dropdownOpen)
                      Positioned(
                        right: 24,
                        top: constraints.maxHeight + 8,
                        child: ModelDropdown(
                          selected: widget.model,
                          agent: widget.agent,
                          onSelected: _selectModel,
                          onAgentChanged: _selectAgent,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 672),
                  child: _SuggestionChips(onTap: widget.onSuggestionTap),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showReminderDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => ReminderDialog(
        onSave: (text, at, tz) {
          RemindersStore.instance.add(text, at, tz);
          setState(() => _reminderText = text);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              backgroundColor: ThemeScope.of(context).surfaceContainerHigh,
              content: Text('Recordatorio creado: "$text"',
                  style: kBodyMd.copyWith(
                      color: ThemeScope.of(context).onSurface)),
            ));
        },
      ),
    );
  }

  Widget _buildInputRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 480;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add,
                        size: 20,
                        color: ThemeScope.of(context).onSurfaceVariant),
                    onPressed: () => showAttachmentSheet(context),
                    tooltip: 'Adjuntar',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      style: kBodyMd.copyWith(
                          fontSize: 15,
                          color: ThemeScope.of(context).onSurface),
                      decoration: InputDecoration(
                        hintText: 'Pregunta lo que quieras',
                        hintStyle: TextStyle(
                            color: ThemeScope.of(context).onSurfaceVariant,
                            fontSize: 15),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!narrow) ...[
                    AgentPill(
                      label: widget.agent,
                      onTap: () =>
                          setState(() => _dropdownOpen = !_dropdownOpen),
                    ),
                    const SizedBox(width: 8),
                  ],
                  ModelPill(
                    label: widget.model,
                    active: widget.model == kAutoModel,
                    onTap: () => setState(() => _dropdownOpen = !_dropdownOpen),
                  ),
                  if (!narrow) ...[
                    const SizedBox(width: 8),
                    VoiceButton(
                      onTranscribed: (text) => widget.controller.text = text,
                    ),
                  ],
                  const SizedBox(width: 4),
                  ChatSendButton(
                    onTap: _send,
                    active: _hasText,
                    background: ThemeScope.of(context).onSurface,
                  ),
                ],
              ),
              if (narrow) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    AgentPill(
                      label: widget.agent,
                      onTap: () =>
                          setState(() => _dropdownOpen = !_dropdownOpen),
                    ),
                    const Spacer(),
                    VoiceButton(
                      onTranscribed: (text) => widget.controller.text = text,
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Chips de sugerencia estilo claude.ai: píldoras delineadas en fila.
class _SuggestionChips extends StatelessWidget {
  final ValueChanged<SuggestionCard>? onTap;

  const _SuggestionChips({this.onTap});

  static const _suggestions = [
    SuggestionCard(
        'Plan de lanzamiento', 'Crea un plan de lanzamiento para mi producto'),
    SuggestionCard(
        'Ideas de contenido', 'Propón ideas de contenido para mi marca'),
    SuggestionCard(
        'Resumen de documento', 'Resume el documento que te adjunto'),
    SuggestionCard(
        'Análisis de datos', 'Analiza estos datos y dame conclusiones'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final card in _suggestions)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap == null ? null : () => onTap!(card),
              borderRadius: BorderRadius.circular(999),
              hoverColor: c.surfaceContainer,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: c.outlineVariant.withValues(alpha: 0.6)),
                ),
                child: Text(card.title,
                    style: kBodyMd.copyWith(fontSize: 13, color: c.onSurface)),
              ),
            ),
          ),
      ],
    );
  }
}

/// Píldora del agente activo (SPEC §5).
class AgentPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AgentPill({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        hoverColor: c.surfaceBright,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: c.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: c.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline, size: 14, color: c.onSurfaceVariant),
              const SizedBox(width: 4),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kBodyMd.copyWith(fontSize: 12, color: c.onSurface)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila "Agregar a un proyecto": abre el selector; con proyecto activo muestra
/// nombre, rol (con icono) y "x" para desvincular (SPEC §3).
class _ProjectRow extends StatelessWidget {
  final Project? project;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ProjectRow({
    required this.project,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPick,
        hoverColor: c.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(project == null ? Icons.add_box : Icons.folder_outlined,
                  size: 20,
                  color: project == null
                      ? c.onSurfaceVariant
                      : BrandColors.cobalt),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                    project == null
                        ? 'Agregar a un proyecto'
                        : '${project!.name} · ${project!.role.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kBodyMd.copyWith(
                        fontSize: 14,
                        color:
                            project == null ? c.onSurfaceVariant : c.onSurface,
                        fontWeight: project == null ? null : FontWeight.w500)),
              ),
              if (project != null) ...[
                Icon(project!.role.icon, size: 16, color: BrandColors.cobalt),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child:
                        Icon(Icons.close, size: 16, color: c.onSurfaceVariant),
                  ),
                ),
              ] else
                Icon(Icons.expand_more, size: 18, color: c.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila "Recordarme" (SPEC §9): abre el modal de recordatorio del chat.
class _ReminderRow extends StatelessWidget {
  final String? reminderText;
  final VoidCallback onTap;

  const _ReminderRow({required this.reminderText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final has = reminderText != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: c.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.alarm_add_outlined,
                  size: 20,
                  color: has ? BrandColors.cobalt : c.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(has ? 'Recordaré: $reminderText' : 'Recordarme',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kBodyMd.copyWith(
                        fontSize: 14,
                        color: has ? c.onSurface : c.onSurfaceVariant,
                        fontWeight: has ? FontWeight.w500 : null)),
              ),
              const Icon(Icons.add, size: 16, color: BrandColors.cobalt),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selector de proyectos (hoja inferior; en escritorio, reutilizada la misma
/// hoja con ancho limitado).
class _ProjectSheet extends StatelessWidget {
  final List<Project> projects;
  final String? current;

  const _ProjectSheet({required this.projects, required this.current});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agregar a un proyecto',
                  style: kHeadlineMd.copyWith(
                      color: c.onSurface, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('La conversación usará la memoria compartida.',
                  style: kBodyMd.copyWith(color: c.onSurfaceVariant)),
              const SizedBox(height: 12),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final p in projects)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: p.id == current
                              ? c.surfaceContainerHigh
                              : c.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(p),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Icon(Icons.folder_outlined,
                                      size: 18, color: BrandColors.cobalt),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name,
                                            style: kBodyMd.copyWith(
                                                color: c.onSurface,
                                                fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 2),
                                        Text(p.slug,
                                            style: kLabelMd.copyWith(
                                                fontSize: 11,
                                                color: BrandColors.gris)),
                                      ],
                                    ),
                                  ),
                                  Icon(p.role.icon,
                                      size: 14, color: BrandColors.cobalt),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
