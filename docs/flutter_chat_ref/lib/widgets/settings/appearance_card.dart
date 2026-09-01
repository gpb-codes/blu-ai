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
    (Icons.dark_mode_outlined, 'Modo oscuro'),
    (Icons.light_mode_outlined, 'Modo blanco'),
    (Icons.desktop_windows_outlined, 'Sistema'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              icon: Icons.palette_outlined,
              title: 'Apariencia',
              description: 'Personaliza el tema de la interfaz.'),
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
                          ? c.surfaceVariant.withValues(alpha: 0.3)
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
                                  ? c.primary
                                  : c.outlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(_options[i].$1,
                                  size: 20,
                                  color: selected
                                      ? c.primary
                                      : c.onSurfaceVariant),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(_options[i].$2,
                                    style: kBodyMd.copyWith(
                                        color: selected
                                            ? c.onSurface
                                            : c.onSurfaceVariant)),
                              ),
                              Radio<int>(
                                value: i,
                                activeColor: c.primaryContainer,
                                fillColor: WidgetStatePropertyAll(
                                    selected
                                        ? c.primaryContainer
                                        : c.outlineVariant),
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