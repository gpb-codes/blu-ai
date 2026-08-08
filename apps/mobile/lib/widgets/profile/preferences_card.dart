import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';

/// Fila de preferencia con icono, label, valor y chevron.
class PreferenceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const PreferenceRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColorsDark.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: kBodyMd.copyWith(color: AppColorsDark.onSurface)),
          ),
          Text(value,
              style: kBodyMd.copyWith(color: AppColorsDark.onSurfaceVariant)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20, color: AppColorsDark.outline),
        ],
      ),
    );
  }
}

/// Divider estándar de las secciones de perfil.
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1, color: AppColorsDark.outlineVariant.withValues(alpha: 0.2));
  }
}

/// Sección "Preferences" (Perfil).
class PreferencesSection extends StatelessWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(icon: Icons.tune, title: 'Preferences'),
          SizedBox(height: 8),
          PreferenceRow(
              icon: Icons.language_outlined, label: 'Language', value: 'Español'),
          _SectionDivider(),
          PreferenceRow(
              icon: Icons.smart_toy_outlined, label: 'Default model', value: 'GPT-4'),
          _SectionDivider(),
          PreferenceRow(
              icon: Icons.schedule_outlined, label: 'Timezone', value: 'UTC-3'),
        ],
      ),
    );
  }
}