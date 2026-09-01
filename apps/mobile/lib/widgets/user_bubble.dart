import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Mensaje del usuario sin burbuja (estilo ChatGPT): texto plano alineado a
/// la derecha dentro de la columna centrada de conversación.
class UserBubble extends StatelessWidget {
  final String text;
  const UserBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: c.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Text(
            text,
            style: kBodyLg.copyWith(color: c.onSurface, height: 1.6),
          ),
        ),
      ),
    );
  }
}