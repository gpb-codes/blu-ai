import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';

/// Tarjeta hero del perfil: avatar, nombre, badges, botón edit y estadísticas.
class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 560;
              return Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColorsDark.surfaceVariant,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColorsDark.primary.withValues(alpha: 0.4),
                          width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text('IL',
                        style:
                            kHeadlineLg.copyWith(color: AppColorsDark.onSurface)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ignacio Loyola',
                            overflow: TextOverflow.ellipsis,
                            style: kHeadlineMd.copyWith(
                                color: AppColorsDark.onSurface)),
                        const SizedBox(height: 4),
                        Text('ignacio@example.com',
                            overflow: TextOverflow.ellipsis,
                            style: kBodyMd.copyWith(
                                color: AppColorsDark.onSurfaceVariant)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColorsDark.surfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Plan: BYOK',
                                  style: kLabelMd.copyWith(
                                      color: AppColorsDark.onSurface)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColorsDark.primaryContainer
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Member',
                                  style: kLabelMd.copyWith(
                                      color: AppColorsDark.primary)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (wide) ...[
                    const SizedBox(width: 16),
                    const _EditProfileButton(),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: AppColorsDark.outlineVariant.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _StatItem(label: 'Messages', value: '1,284')),
              Expanded(child: _StatItem(label: 'Tokens used', value: '2.4M')),
              Expanded(child: _StatItem(label: 'Models', value: '3')),
            ],
          ),
        ],
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: kHeadlineMd.copyWith(
                color: AppColorsDark.onSurface, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(label, style: kLabelMd.copyWith(color: AppColorsDark.onSurfaceVariant)),
      ],
    );
  }
}