import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';

/// Tarjeta de cuenta (Settings): avatar, nombre, email, plan y botón
/// "Edit Profile".
class SettingsAccountCard extends StatelessWidget {
  const SettingsAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 560;
          return Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColorsDark.surfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColorsDark.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      alignment: Alignment.center,
                      child: Text('IL',
                          style: kHeadlineMd.copyWith(color: AppColorsDark.onSurface)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ignacio Loyola',
                              style:
                                  kHeadlineMd.copyWith(color: AppColorsDark.onSurface)),
                          const SizedBox(height: 4),
                          Text('ignacio@example.com',
                              style:
                                  kBodyMd.copyWith(color: AppColorsDark.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColorsDark.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('Plan: BYOK',
                                style:
                                    kLabelMd.copyWith(color: AppColorsDark.onSurface)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (wide) const _EditProfileButton(),
            ],
          );
        },
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColorsDark.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppColorsDark.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Text('Edit Profile',
          style: kLabelMd.copyWith(color: AppColorsDark.onSurface)),
    );
  }
}