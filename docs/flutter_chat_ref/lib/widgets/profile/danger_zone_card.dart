import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';

/// Sección "Danger Zone" (Perfil): eliminación de cuenta con confirmación.
class DangerZoneSection extends StatelessWidget {
  const DangerZoneSection({super.key});

  Future<void> _confirmDelete(BuildContext context) async {
    final c = ThemeScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.surfaceContainerLow,
        title: Text('Eliminar cuenta',
            style: kHeadlineMd.copyWith(color: c.onSurface)),
        content: Text(
          'Esto eliminará permanentemente tu cuenta y todos los datos '
          'asociados. Esta acción no se puede deshacer.',
          style: kBodyMd.copyWith(color: c.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Eliminar',
                style: kBodyMd.copyWith(color: c.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: c.surfaceContainerHigh,
        content: Text('Cuenta eliminada (simulado).',
            style: kBodyMd.copyWith(color: c.onSurface)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return AppCard(
      border: Border.all(color: c.error.withValues(alpha: 0.4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Zona de peligro',
              style: kHeadlineMd.copyWith(color: c.error)),
          const SizedBox(height: 4),
          Text(
            'Elimina permanentemente tu cuenta y todos los datos asociados.',
            style: kBodyMd.copyWith(color: c.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _confirmDelete(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: c.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: c.error.withValues(alpha: 0.5)),
                ),
                child: Text('Eliminar cuenta',
                    style: kLabelMd.copyWith(color: c.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}