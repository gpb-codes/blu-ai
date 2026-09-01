import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'landing_input_card.dart';
import 'model_selector.dart';
import 'shared/attachment_sheet.dart';
import 'voice_button.dart';

/// Área de entrada flotante (estilo ChatGPT): caja redondeada con sombra,
/// botón de enviar que aparece al escribir y se vuelve detener durante el
/// streaming, pills de modelo debajo del campo y nota legal.
class BottomInputArea extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onStop;
  final bool isStreaming;
  final String model;
  final ValueChanged<String> onModelChanged;
  final String agent;
  final ValueChanged<String> onAgentChanged;

  const BottomInputArea({
    super.key,
    required this.controller,
    required this.onSend,
    this.onStop,
    this.isStreaming = false,
    required this.model,
    required this.onModelChanged,
    required this.agent,
    required this.onAgentChanged,
  });

  @override
  State<BottomInputArea> createState() => _BottomInputAreaState();
}

class _BottomInputAreaState extends State<BottomInputArea> {
  bool _dropdownOpen = false;

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: ThemeScope.of(context).background,
        border: Border(
            top: BorderSide(
                color: ThemeScope.of(context)
                    .outlineVariant
                    .withValues(alpha: 0.2))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 768),
              child: _buildComposer(),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'soybluia puede cometer errores. Revisa la información importante.',
              textAlign: TextAlign.center,
              style: kBodyXs.copyWith(
                  color: ThemeScope.of(context).textQuaternary),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    final c = ThemeScope.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: c.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
            border:
                Border.all(color: c.outlineVariant.withValues(alpha: 0.25)),
            boxShadow: AppShadows.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.add,
                        size: 20, color: c.onSurfaceVariant),
                    onPressed: () => showAttachmentSheet(context),
                    tooltip: 'Adjuntar',
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      minLines: 1,
                      maxLines: 6,
                      style: kBodyMd.copyWith(
                          fontSize: 16, color: c.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Pregunta lo que quieras',
                        hintStyle: TextStyle(
                            color: c.onSurfaceVariant, fontSize: 16),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (MediaQuery.of(context).size.width >= 480) ...[
                    VoiceButton(
                      onTranscribed: (text) => widget.controller.text = text,
                    ),
                    const SizedBox(width: 4),
                  ],
                  ChatSendButton(
                    onTap: _send,
                    onStop: widget.onStop,
                    isStreaming: widget.isStreaming,
                    active: _hasText,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AgentPill(
                        label: widget.agent,
                        onTap: () => setState(
                            () => _dropdownOpen = !_dropdownOpen),
                      ),
                      ModelPill(
                        label: widget.model,
                        active: widget.model == kAutoModel,
                        onTap: () => setState(
                            () => _dropdownOpen = !_dropdownOpen),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_dropdownOpen)
          Positioned(
            right: 16,
            bottom: 88,
            child: ModelDropdown(
              selected: widget.model,
              agent: widget.agent,
              onSelected: _selectModel,
              onAgentChanged: _selectAgent,
            ),
          ),
      ],
    );
  }
}