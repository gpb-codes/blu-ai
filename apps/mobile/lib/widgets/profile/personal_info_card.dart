import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';

/// Fila etiqueta/valor usada en las secciones de perfil.
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: kBodyMd.copyWith(color: AppColorsDark.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: kBodyMd.copyWith(
                    color: AppColorsDark.onSurface, fontWeight: FontWeight.w500)),
          ),
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

/// Sección "Personal Info" (Perfil).
class PersonalInfoSection extends StatelessWidget {
  const PersonalInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
              icon: Icons.person_outline, title: 'Personal Info'),
          SizedBox(height: 8),
          InfoRow(label: 'Full name', value: 'Ignacio Loyola'),
          _SectionDivider(),
          InfoRow(label: 'Email', value: 'ignacio@example.com'),
          _SectionDivider(),
          InfoRow(label: 'Username', value: '@soybluia'),
          _SectionDivider(),
          InfoRow(
              label: 'Bio', value: 'Building intelligent assistants for everyone.'),
        ],
      ),
    );
  }
}