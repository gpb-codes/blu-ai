import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';
import 'preferences_card.dart';

/// Sección "Security" (Perfil).
class SecuritySection extends StatelessWidget {
  final bool twoFactorEnabled;
  final ValueChanged<bool> onTwoFactorChanged;

  const SecuritySection({
    super.key,
    required this.twoFactorEnabled,
    required this.onTwoFactorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              icon: Icons.security_outlined, title: 'Security'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorsDark.surfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColorsDark.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: Text('Change Password',
                style: kLabelMd.copyWith(color: AppColorsDark.onSurface)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.verified_user_outlined,
                  size: 20, color: AppColorsDark.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Two-factor authentication',
                        style: kBodyMd.copyWith(color: AppColorsDark.onSurface)),
                    const SizedBox(height: 2),
                    Text('Extra layer of security for your account',
                        style: kBodyMd.copyWith(color: AppColorsDark.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(
                value: twoFactorEnabled,
                onChanged: onTwoFactorChanged,
                activeTrackColor: AppColorsDark.primaryContainer,
                trackColor: const WidgetStatePropertyAll(AppColorsDark.surfaceVariant),
                thumbColor: const WidgetStatePropertyAll(Colors.white),
                inactiveThumbColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const PreferenceRow(
              icon: Icons.devices_outlined, label: 'Active sessions', value: '2 devices'),
        ],
      ),
    );
  }
}