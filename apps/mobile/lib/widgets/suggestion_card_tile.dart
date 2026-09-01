import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../theme/app_colors.dart';

class SuggestionCardTile extends StatelessWidget {
  final SuggestionCard card;
  final VoidCallback? onTap;
  const SuggestionCardTile({super.key, required this.card, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeScope.of(context).surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  ThemeScope.of(context).outlineVariant.withValues(alpha: 0.3)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.title,
                style: TextStyle(
                    color: ThemeScope.of(context).primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(card.subtitle,
                style: TextStyle(
                    fontSize: 12,
                    color: ThemeScope.of(context).onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
