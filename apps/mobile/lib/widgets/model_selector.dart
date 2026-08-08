import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

const kBluModels = ['Blu Light', 'Blu Flash', 'Blu Ultra'];

class OtherModel {
  final String name;
  final IconData icon;
  final Color color;

  const OtherModel({required this.name, required this.icon, required this.color});
}

const kOtherModels = [
  OtherModel(name: 'Claude', icon: Icons.flare, color: Color(0xFFFB923C)),
  OtherModel(name: 'ChatGPT', icon: Icons.donut_large, color: Color(0xFF34D399)),
  OtherModel(name: 'Gemini', icon: Icons.auto_awesome, color: Color(0xFF60A5FA)),
];

/// Pill del selector de modelo (Blu Light / expand_more) que abre el dropdown.
class ModelPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const ModelPill({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        hoverColor: AppColorsDark.surfaceBright,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColorsDark.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border:
                Border.all(color: AppColorsDark.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: kBodyMd.copyWith(
                      fontSize: 13, color: AppColorsDark.onSurface)),
              const SizedBox(width: 2),
              const Icon(Icons.expand_more,
                  size: 16, color: AppColorsDark.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}

/// Panel del dropdown de modelos (OTROS MODELOS + SOYBLUIA).
class ModelDropdown extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const ModelDropdown({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: AppColorsDark.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColorsDark.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DropdownLabel('OTROS MODELOS'),
                for (final m in kOtherModels)
                  _DropdownButton(
                    onTap: () => onSelected(m.name),
                    child: Row(
                      children: [
                        Icon(m.icon, size: 16, color: m.color),
                        const SizedBox(width: 12),
                        Text(m.name,
                            style: kBodyMd.copyWith(
                                fontSize: 14, color: AppColorsDark.onSurface)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
              height: 1,
              color: AppColorsDark.outlineVariant.withValues(alpha: 0.2)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DropdownLabel('SOYBLUIA'),
                for (final name in kBluModels)
                  _DropdownButton(
                    onTap: () => onSelected(name),
                    selected: selected == name,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(name,
                              style: kBodyMd.copyWith(
                                  fontSize: 14,
                                  color: selected == name
                                      ? Colors.white
                                      : AppColorsDark.onSurfaceVariant)),
                        ),
                        if (selected == name)
                          const Icon(Icons.check, size: 18, color: Colors.white),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownLabel extends StatelessWidget {
  final String text;

  const _DropdownLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(text,
          style: kLabelMd.copyWith(
              fontSize: 10,
              height: 1.2,
              letterSpacing: 0.6,
              color: AppColorsDark.onSurfaceVariant)),
    );
  }
}

class _DropdownButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool selected;
  final Widget child;

  const _DropdownButton({
    required this.onTap,
    this.selected = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColorsDark.surfaceContainerHigh,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColorsDark.inversePrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Botón circular de enviar (arrow_upward, fondo primaryContainer).
class ChatSendButton extends StatelessWidget {
  final VoidCallback onTap;

  const ChatSendButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColorsDark.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x330A34F5),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_upward, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}
