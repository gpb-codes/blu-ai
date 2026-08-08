import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';

/// Sección "Danger Zone" (Perfil): eliminación de cuenta.
class DangerZoneSection extends StatelessWidget {
  const DangerZoneSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      border: Border.all(color: AppColorsDark.error.withValues(alpha: 0.4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Danger Zone',
              style: kHeadlineMd.copyWith(color: AppColorsDark.error)),
          const SizedBox(height: 4),
          Text(
            'Permanently delete your account and all associated data.',
            style: kBodyMd.copyWith(color: AppColorsDark.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorsDark.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColorsDark.error.withValues(alpha: 0.5)),
            ),
            child: Text('Delete Account',
                style: kLabelMd.copyWith(color: AppColorsDark.error)),
          ),
        ],
      ),
    );
  }
}