import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'model_selector.dart';

class BottomInputArea extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String model;
  final ValueChanged<String> onModelChanged;

  const BottomInputArea({
    super.key,
    required this.controller,
    required this.onSend,
    required this.model,
    required this.onModelChanged,
  });

  @override
  State<BottomInputArea> createState() => _BottomInputAreaState();
}

class _BottomInputAreaState extends State<BottomInputArea> {
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColorsDark.background,
        border: Border(
            top: BorderSide(
                color: AppColorsDark.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              _buildInputRow(constraints.maxWidth),
              if (_dropdownOpen)
                Positioned(
                  right: 8,
                  bottom: constraints.maxHeight + 8,
                  child: ModelDropdown(
                    selected: widget.model,
                    onSelected: _selectModel,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputRow(double width) {
    final narrow = width < 420;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColorsDark.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColorsDark.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const IconButton(
            icon: Icon(Icons.add, size: 20, color: AppColorsDark.onSurfaceVariant),
            onPressed: null,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: widget.controller,
              minLines: 1,
              maxLines: 6,
              style:
                  kBodyMd.copyWith(fontSize: 15, color: AppColorsDark.onSurface),
              decoration: const InputDecoration(
                hintText: 'Pregunta lo que quieras',
                hintStyle:
                    TextStyle(color: AppColorsDark.onSurfaceVariant, fontSize: 15),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 4),
          ModelPill(
            label: widget.model,
            onTap: () => setState(() => _dropdownOpen = !_dropdownOpen),
          ),
          if (!narrow) ...[
            const SizedBox(width: 4),
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
  }
}
