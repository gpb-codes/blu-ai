import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_message.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'mini_app_card.dart';
import 'shared/markdown_text.dart';
import 'shared/shimmer.dart';
import 'suggestion_card_tile.dart';

/// Respuesta del asistente al estilo ChatGPT: sin tarjeta, con encabezado
/// (logo + nombre) sobre texto plano con markdown. Las acciones aparecen al
/// pasar el cursor en escritorio y siempre en táctil.
class AiBubble extends StatelessWidget {
  final String text;
  final List<SuggestionCard>? cards;
  final List<String>? citedNotes;
  final String? agentName;
  final IconData? agentIcon;
  final String? appTitle;
  final bool isStreaming;
  final VoidCallback? onStop;
  final ValueChanged<String>? onOpenNote;
  final ValueChanged<SuggestionCard>? onSuggestionTap;

  /// Sugerencias de continuación ("¿Qué quieres hacer ahora?") con
  /// Aceptar / Rechazar.
  final List<String> nextSteps;
  final ValueChanged<String>? onNextStep;

  const AiBubble({
    super.key,
    required this.text,
    this.cards,
    this.citedNotes,
    this.agentName,
    this.agentIcon,
    this.appTitle,
    this.isStreaming = false,
    this.onStop,
    this.onOpenNote,
    this.onSuggestionTap,
    this.nextSteps = const [],
    this.onNextStep,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final showName = agentName ?? 'soybluia';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: BrandColors.cobalt,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Icon(agentIcon ?? Icons.auto_awesome,
              size: 15, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(showName,
                          style: kBodyMd.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: c.onSurface)),
                    ),
                    if (agentName != null) ...[
                      const SizedBox(width: 8),
                      Text('agente',
                          style: kLabelMd.copyWith(
                              fontSize: 11, color: c.primary)),
                    ],
                  ],
                ),
              ),
              if (isStreaming && text.isEmpty)
                const _ThinkingIndicator()
              else
                MarkdownText(text: text),
              if (appTitle != null) ...[
                const SizedBox(height: 12),
                MiniAppCard(title: appTitle!),
              ],
              if (cards != null) ...[
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 480;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: cards!
                          .map((c) => SizedBox(
                                width: isNarrow
                                    ? constraints.maxWidth
                                    : (constraints.maxWidth - 16) / 2,
                                child: SuggestionCardTile(
                                  card: c,
                                  onTap: onSuggestionTap == null
                                      ? null
                                      : () => onSuggestionTap!(c),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
              if (!isStreaming &&
                  nextSteps.isNotEmpty &&
                  onNextStep != null) ...[
                const SizedBox(height: 16),
                _NextStepRow(
                  steps: nextSteps,
                  onTap: onNextStep!,
                ),
              ],
              if (citedNotes != null && citedNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final note in citedNotes!)
                      _CitedNoteChip(
                        title: note,
                        onTap: onOpenNote == null
                            ? null
                            : () => onOpenNote!(note),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 6),
              _HoverActions(
                text: text,
                isStreaming: isStreaming,
                onStop: onStop,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Acciones de la burbuja: valorar, copiar, voz y detener streaming.
/// En escritorio solo se muestran al pasar el cursor (estilo ChatGPT).
class _HoverActions extends StatefulWidget {
  final String text;
  final bool isStreaming;
  final VoidCallback? onStop;

  const _HoverActions({
    required this.text,
    required this.isStreaming,
    this.onStop,
  });

  @override
  State<_HoverActions> createState() => _HoverActionsState();
}

class _HoverActionsState extends State<_HoverActions> {
  bool? _feedback;
  bool _copied = false;
  bool _playing = false;
  double _speed = 1.0;
  bool _hovered = false;

  bool get _alwaysVisible {
    final platform = defaultTargetPlatform;
    final touch = platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS;
    return touch || MediaQuery.of(context).size.width < 480;
  }

  bool get _visible => _alwaysVisible || _hovered;

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: ThemeScope.of(context).surfaceContainerHigh,
        duration: const Duration(seconds: 1),
        content: Text(message,
            style: kBodyMd.copyWith(color: ThemeScope.of(context).onSurface)),
      ));
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    _toast('Respuesta copiada');
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    final active = c.primary;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: _visible ? 1 : 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              IconButton(
                icon: Icon(
                    _feedback == true ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 16),
                color: _feedback == true ? active : c.onSurfaceVariant,
                padding: const EdgeInsets.all(8),
                tooltip: 'Me gusta',
                onPressed: () =>
                    setState(() => _feedback = _feedback == true ? null : true),
              ),
              IconButton(
                icon: Icon(
                    _feedback == false
                        ? Icons.thumb_down
                        : Icons.thumb_down_outlined,
                    size: 16),
                color: _feedback == false ? active : c.onSurfaceVariant,
                padding: const EdgeInsets.all(8),
                tooltip: 'No me gusta',
                onPressed: () => setState(
                    () => _feedback = _feedback == false ? null : false),
              ),
              IconButton(
                icon: Icon(_copied ? Icons.check : Icons.content_copy_outlined,
                    size: 16),
                color: _copied ? active : c.onSurfaceVariant,
                padding: const EdgeInsets.all(8),
                tooltip: 'Copiar respuesta',
                onPressed: _copy,
              ),
              IconButton(
                icon: Icon(
                    _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 18),
                color: _playing ? active : c.onSurfaceVariant,
                padding: const EdgeInsets.all(8),
                tooltip: _playing ? 'Pausar' : 'Escuchar respuesta',
                onPressed: () => setState(() => _playing = !_playing),
              ),
              if (_playing)
                InkWell(
                  onTap: () =>
                      setState(() => _speed = _speed == 1.0 ? 1.5 : 1.0),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    child: Text('${_speed}x',
                        style: kLabelMd.copyWith(
                            fontSize: 11,
                            color: _speed == 1.5 ? active : c.onSurfaceVariant)),
                  ),
                ),
              if (widget.isStreaming && widget.onStop != null)
                IconButton(
                  icon: const Icon(Icons.stop_circle_outlined, size: 18),
                  color: c.error,
                  padding: const EdgeInsets.all(8),
                  tooltip: 'Detener generación',
                  onPressed: widget.onStop,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Estado "pensando" al inicio de una respuesta: fila de puntos + línea con
/// shimmer y pasos del agente, inspirado en el panel de actividad de Manus.
class _ThinkingIndicator extends StatelessWidget {
  const _ThinkingIndicator();

  static const _steps = [
    (icon: Icons.travel_explore, label: 'Relevando contexto'),
    (icon: Icons.route_outlined, label: 'Proponiendo plan'),
    (icon: Icons.sync_rounded, label: 'Iterando contigo'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const TypingDots(size: 6),
            const SizedBox(width: 10),
            Text('Pensando',
                style: kLabelMd.copyWith(
                    fontSize: 12, color: c.onSurfaceVariant)),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: const ShimmerBox(height: 10),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final step in _steps)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Icon(step.icon, size: 13, color: c.primary),
                    const SizedBox(width: 5),
                    Text(step.label,
                        style: kLabelMd.copyWith(
                            fontSize: 11, color: c.onSurfaceVariant)),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Sugerencias de continuación tras la respuesta: "¿Qué quieres hacer ahora?"
/// con fichas Aceptar / Rechazar al estilo Manus.
class _NextStepRow extends StatelessWidget {
  final List<String> steps;
  final ValueChanged<String> onTap;

  const _NextStepRow({required this.steps, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('¿Qué quieres hacer ahora?',
            style: kLabelMd.copyWith(
                fontSize: 12, color: c.onSurfaceVariant)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final step in steps)
              Material(
                color: c.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => onTap(step),
                  borderRadius: BorderRadius.circular(8),
                  hoverColor: c.surfaceContainerHighest,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                            step == steps.first
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            size: 14,
                            color: step == steps.first
                                ? c.success
                                : c.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(step,
                            style: kLabelMd.copyWith(
                                fontSize: 12, color: c.onSurface)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Ficha "Referencio [[Nota]]": citas de la memoria usadas por el agente.
class _CitedNoteChip extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _CitedNoteChip({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: c.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_outlined, size: 14, color: c.primary),
              const SizedBox(width: 6),
              Text('Referencio [[$title]]',
                  style: kLabelMd.copyWith(fontSize: 12, color: c.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}