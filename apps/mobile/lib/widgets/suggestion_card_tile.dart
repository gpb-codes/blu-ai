import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../theme/app_colors.dart';

class SuggestionCardTile extends StatelessWidget {
  final SuggestionCard card;
  const SuggestionCardTile({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColorsDark.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColorsDark.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.title,
                style: const TextStyle(
                    color: AppColorsDark.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(card.subtitle,
                style: const TextStyle(
                    fontSize: 12, color: AppColorsDark.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
