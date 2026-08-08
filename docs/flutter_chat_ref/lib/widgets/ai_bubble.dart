import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../theme/app_colors.dart';
import 'suggestion_card_tile.dart';

class AiBubble extends StatelessWidget {
  final String text;
  final List<SuggestionCard>? cards;
  const AiBubble({super.key, required this.text, this.cards});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColorsDark.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColorsDark.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.bolt, color: AppColorsDark.primary, size: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColorsDark.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColorsDark.outlineVariant.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text,
                        style: const TextStyle(fontSize: 16, height: 1.6, color: AppColorsDark.onSurface)),
                    if (cards != null) ...[
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 480;
                          return Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: cards!
                                .map((c) => SizedBox(
                                      width: isNarrow
                                          ? constraints.maxWidth
                                          : (constraints.maxWidth - 16) / 2,
                                      child: SuggestionCardTile(card: c),
                                    ))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(Icons.thumb_up_outlined, size: 16, color: AppColorsDark.onSurfaceVariant),
                    SizedBox(width: 16),
                    Icon(Icons.thumb_down_outlined, size: 16, color: AppColorsDark.onSurfaceVariant),
                    SizedBox(width: 16),
                    Icon(Icons.content_copy_outlined, size: 16, color: AppColorsDark.onSurfaceVariant),
                    SizedBox(width: 16),
                    Icon(Icons.refresh, size: 16, color: AppColorsDark.onSurfaceVariant),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
