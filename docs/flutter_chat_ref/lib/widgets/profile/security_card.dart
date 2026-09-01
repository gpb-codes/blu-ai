import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';
import 'preferences_card.dart';

/// Sección "Seguridad" (Perfil): contraseña, 2FA y sesiones activas.
class SecuritySection extends StatelessWidget {
  final bool twoFactorEnabled;
  final ValueChanged<bool> onTwoFactorChanged;

  const SecuritySection({
    super.key,
    required this.twoFactorEnabled,
    required this.onTwoFactorChanged,
  });

  void _notReady(BuildContext context) {
    final c = ThemeScope.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: c.surfaceContainerHigh,
        content: Text('Esta opción estará disponible pronto.',
            style: kBodyMd.copyWith(color: c.onSurface)),
      ));
  }

  Future<void> _showDevices(BuildContext context) async {
    final c = ThemeScope.of(context);
    await showModalBottomSheet<void>(
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
              child: Text('Sesiones activas',
                  style: kHeadlineMd.copyWith(
                      color: c.onSurface, fontWeight: FontWeight.w600)),
            ),
            const _DeviceRow(device: 'Chrome · Buenos Aires', last: 'Ahora'),
            const _DeviceRow(device: 'MacBook · Buenos Aires', last: 'Hace 2 h'),            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              icon: Icons.security_outlined, title: 'Seguridad'),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _notReady(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: c.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: c.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Text('Cambiar contraseña',
                    style: kLabelMd.copyWith(color: c.onSurface)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.verified_user_outlined,
                  size: 20, color: c.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Autenticación de dos factores',
                        style: kBodyMd.copyWith(color: c.onSurface)),
                    const SizedBox(height: 2),
                    Text('Capa extra de seguridad para tu cuenta',
                        style: kBodyMd.copyWith(color: c.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(
                value: twoFactorEnabled,
                onChanged: onTwoFactorChanged,
                activeTrackColor: c.primaryContainer,
                trackColor:
                    WidgetStatePropertyAll(c.surfaceVariant),
                thumbColor: const WidgetStatePropertyAll(Colors.white),
                inactiveThumbColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 12),
          PreferenceRow(
            icon: Icons.devices_outlined,
            label: 'Sesiones activas',
            value: '2 dispositivos',
            onTap: () => _showDevices(context),
          ),
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final String device;
  final String last;

  const _DeviceRow({required this.device, required this.last});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.devices, size: 20, color: c.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(device,
                style: kBodyMd.copyWith(color: c.onSurface)),
          ),
          Text(last, style: kLabelMd.copyWith(color: c.onSurfaceVariant)),
        ],
      ),
    );
  }
}