import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';

/// Sección "Appearance" (Settings): opciones de tema Dark / Light / System.
class AppearanceSection extends StatelessWidget {
  final int themeIndex;
  final ValueChanged<int> onThemeChanged;

  const AppearanceSection({
    super.key,
    required this.themeIndex,
    required this.onThemeChanged,
  });

  static const _options = [
    (Icons.dark_mode_outlined, 'Dark Mode'),
    (Icons.light_mode_outlined, 'Light Mode'),
    (Icons.desktop_windows_outlined, 'System'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              description: 'Customize the UI theme.'),
          const SizedBox(height: 16),
          RadioGroup<int>(
            groupValue: themeIndex,
            onChanged: (v) {
              if (v != null) onThemeChanged(v);
            },
            child: Column(
              children: [
                ...List.generate(_options.length, (i) {
                  final selected = i == themeIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: selected
                          ? AppColorsDark.surfaceVariant.withValues(alpha: 0.3)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => onThemeChanged(i),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected
                                  ? AppColorsDark.primary
                                  : AppColorsDark.outlineVariant
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(_options[i].$1,
                                  size: 20,
                                  color: selected
                                      ? AppColorsDark.primary
                                      : AppColorsDark.onSurfaceVariant),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(_options[i].$2,
                                    style: kBodyMd.copyWith(
                                        color: selected
                                            ? AppColorsDark.onSurface
                                            : AppColorsDark.onSurfaceVariant)),
                              ),
                              Radio<int>(
                                value: i,
                                activeColor: AppColorsDark.primaryContainer,
                                fillColor: WidgetStatePropertyAll(
                                    selected
                                        ? AppColorsDark.primaryContainer
                                        : AppColorsDark.outlineVariant),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}