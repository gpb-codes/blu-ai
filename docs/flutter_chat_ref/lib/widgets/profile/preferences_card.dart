import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';

/// Fila de preferencia con icono, label, valor y chevron.
class PreferenceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const PreferenceRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: ThemeScope.of(context).onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: kBodyMd.copyWith(color: ThemeScope.of(context).onSurface)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kBodyMd.copyWith(
                        color: ThemeScope.of(context).onSurfaceVariant)),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 20, color: ThemeScope.of(context).outline),
            ],
          ),
        ),
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
        height: 1, color: ThemeScope.of(context).outlineVariant.withValues(alpha: 0.2));
  }
}

/// Sección "Preferences" (Perfil): preferencias editables con hoja inferior.
class PreferencesSection extends StatefulWidget {
  const PreferencesSection({super.key});

  @override
  State<PreferencesSection> createState() => _PreferencesSectionState();
}

class _PreferencesSectionState extends State<PreferencesSection> {
  String _language = 'Español';
  // SPEC §2: el modelo por defecto es Auto.
  String _defaultModel = 'Auto';
  String _timezone = 'America/Argentina/Buenos_Aires (UTC-3)';

  Future<void> _pickOption(
      BuildContext context, String title, List<String> options,
      String selected, ValueChanged<String> onSelected) async {
    final c = ThemeScope.of(context);
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: c.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title,
                  style: kHeadlineMd.copyWith(
                      color: c.onSurface, fontWeight: FontWeight.w600)),
            ),
            for (final option in options)
              InkWell(
                onTap: () => Navigator.of(sheetContext).pop(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(option,
                            style: kBodyMd.copyWith(color: c.onSurface)),
                      ),
                      if (option == selected)
                        const Icon(Icons.check_circle,
                            size: 20, color: BrandColors.cobalt),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (result != null) onSelected(result);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(icon: Icons.tune, title: 'Preferencias'),
          const SizedBox(height: 8),
          PreferenceRow(
            icon: Icons.language_outlined,
            label: 'Idioma',
            value: _language,
            onTap: () => _pickOption(context, 'Idioma', const ['Español', 'English'],
                _language, (v) => setState(() => _language = v)),
          ),
          const _SectionDivider(),
          PreferenceRow(
            icon: Icons.smart_toy_outlined,
            label: 'Modelo por defecto',
            value: _defaultModel,
            onTap: () => _pickOption(context, 'Modelo por defecto',
                const ['Auto', 'Blu Light', 'Blu Flash', 'Blu Ultra'],
                _defaultModel, (v) => setState(() => _defaultModel = v)),
          ),
          const _SectionDivider(),
          PreferenceRow(
            icon: Icons.schedule_outlined,
            label: 'Zona horaria',
            value: _timezone,
            onTap: () => _pickOption(context, 'Zona horaria',
                const [
                  'America/Argentina/Buenos_Aires (UTC-3)',
                  'America/Mexico_City (UTC-6)',
                  'Europe/Madrid (UTC+2)',
                ],
                _timezone, (v) => setState(() => _timezone = v)),
          ),
        ],
      ),
    );
  }
}