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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            text,
            textAlign: TextAlign.end,
            style: kBodyLg.copyWith(
              color: ThemeScope.of(context).onSurface,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}