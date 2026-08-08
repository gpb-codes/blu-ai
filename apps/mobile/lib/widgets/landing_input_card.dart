import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'model_selector.dart';

/// Estado vacío del chat: título "¿En qué trabajamos hoy?" + tarjeta con
/// "Agregar a un proyecto", input, selector de modelo y botón de enviar.
class LandingInputCard extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String model;
  final ValueChanged<String> onModelChanged;

  const LandingInputCard({
    super.key,
    required this.controller,
    required this.onSend,
    required this.model,
    required this.onModelChanged,
  });

  @override
  State<LandingInputCard> createState() => _LandingInputCardState();
}

class _LandingInputCardState extends State<LandingInputCard> {
  bool _dropdownOpen = false;

  void _send() {
    setState(() => _dropdownOpen = false);
    widget.onSend();
  }

  void _selectModel(String model) {
    setState(() => _dropdownOpen = false);
    widget.onModelChanged(model);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('¿En qué trabajamos hoy?',
            textAlign: TextAlign.center,
            style: kHeadlineLg.copyWith(color: AppColorsDark.onSurface)),
        const SizedBox(height: 40),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 672),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColorsDark.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColorsDark.outlineVariant
                                .withValues(alpha: 0.3)),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 24,
                              offset: Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        children: [
                          const _AddToProjectRow(),
                          Container(
                              height: 1,
                              color: AppColorsDark.outlineVariant
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
                      onSelected: _selectModel,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildInputRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 420;
        return Container(
          color: AppColorsDark.surfaceContainer,
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
          child: Row(
            children: [
              const Icon(Icons.add,
                  size: 20, color: AppColorsDark.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  style: kBodyMd.copyWith(
                      fontSize: 15, color: AppColorsDark.onSurface),
                  decoration: const InputDecoration(
                    hintText: 'Pregunta lo que quieras',
                    hintStyle: TextStyle(
                        color: AppColorsDark.onSurfaceVariant, fontSize: 15),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              ModelPill(
                label: widget.model,
                onTap: () => setState(() => _dropdownOpen = !_dropdownOpen),
              ),
              if (!narrow) ...[
                const SizedBox(width: 8),
                const IconButton(
                  icon: Icon(Icons.mic_none,
                      size: 20, color: AppColorsDark.onSurfaceVariant),
                  onPressed: null,
                ),
              ],
              const SizedBox(width: 4),
              ChatSendButton(onTap: _send),
            ],
          ),
        );
      },
    );
  }
}

class _AddToProjectRow extends StatelessWidget {
  const _AddToProjectRow();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        hoverColor: AppColorsDark.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.add_box,
                  size: 20, color: AppColorsDark.onSurfaceVariant),
              const SizedBox(width: 12),
              Text('Agregar a un proyecto',
                  style: kBodyMd.copyWith(
                      fontSize: 14, color: AppColorsDark.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
