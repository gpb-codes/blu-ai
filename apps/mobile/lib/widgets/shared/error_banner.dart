import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Banner de error global (SPEC §14): superficie adaptativa al tema, texto
/// onSurface (legible también en oscuro) y botón Reintentar cobalto.
class ErrorBanner extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const ErrorBanner({
    super.key,
    required this.message,
    this.actionLabel = 'Reintentar',
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      decoration: BoxDecoration(
        color: c.surfaceContainer,
        border: Border.all(color: c.outlineVariant.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: kBodyMd.copyWith(fontSize: 13, color: c.onSurface)),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: BrandColors.cobalt,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(actionLabel,
                    style: kLabelMd.copyWith(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
