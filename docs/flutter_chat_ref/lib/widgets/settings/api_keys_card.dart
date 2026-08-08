import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';

/// Sección "API Keys" (Settings): lista de proveedores con acciones
/// editar/eliminar que se muestran al pasar el mouse.
class ApiKeysSection extends StatelessWidget {
  const ApiKeysSection({super.key});

  static const _keys = [
    (Icons.smart_toy_outlined, 'OpenAI', 'sk-proj-...8a2b'),
    (Icons.auto_awesome, 'Anthropic', 'sk-ant-...f93d'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: SectionHeader(
                    icon: Icons.key_outlined,
                    title: 'API Keys',
                    description:
                        'Manage your external provider keys for custom models.'),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColorsDark.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('Add Key', style: kLabelMd.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._keys.map((k) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _KeyRow(icon: k.$1, provider: k.$2, maskedKey: k.$3),
              )),
        ],
      ),
    );
  }
}

class _KeyRow extends StatefulWidget {
  final IconData icon;
  final String provider;
  final String maskedKey;

  const _KeyRow({
    required this.icon,
    required this.provider,
    required this.maskedKey,
  });

  @override
  State<_KeyRow> createState() => _KeyRowState();
}

class _KeyRowState extends State<_KeyRow> {
  bool _hovered = false;

  // setState diferido a post-frame: evita la aserción recursiva del
  // MouseTracker (`mouse_tracker.dart` / `object.dart`) en Flutter web.
  void _setHovered(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _hovered = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColorsDark.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: AppColorsDark.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColorsDark.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(widget.icon,
                  size: 18, color: AppColorsDark.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.provider,
                      style: kBodyMd.copyWith(
                          color: AppColorsDark.onSurface,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(widget.maskedKey,
                      style:
                          kCodeSm.copyWith(color: AppColorsDark.onSurfaceVariant)),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: _hovered ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: const Row(
                children: [
                  _IconAction(
                      icon: Icons.edit_outlined,
                      color: AppColorsDark.onSurfaceVariant,
                      hoverColor: AppColorsDark.onSurface),
                  SizedBox(width: 4),
                  _IconAction(
                      icon: Icons.delete_outline,
                      color: AppColorsDark.error,
                      hoverColor: AppColorsDark.errorContainer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color hoverColor;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.hoverColor,
  });

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hovered = false;

  void _setHovered(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _hovered = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColorsDark.surfaceVariant
                : AppColorsDark.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(widget.icon,
              size: 18, color: _hovered ? widget.hoverColor : widget.color),
        ),
      ),
    );
  }
}