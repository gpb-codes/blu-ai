import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';

/// Sección "Notifications" (Settings): lista de toggles de preferencias.
class NotificationsSection extends StatelessWidget {
  final Map<String, bool> notifications;
  final void Function(String key, bool value) onChanged;

  const NotificationsSection({
    super.key,
    required this.notifications,
    required this.onChanged,
  });

  static const _descriptions = {
    'Novedades de producto':
        'Recibe noticias sobre nuevas funciones y modelos.',
    'Alertas de uso': 'Notifícate cuando te acerques a los límites de API.',
    'Marketing': 'Correos y ofertas promocionales.',
  };

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
              icon: Icons.notifications_outlined,
              title: 'Notificaciones',
              description: 'Elige qué actualizaciones quieres recibir.'),
          const SizedBox(height: 8),
          ...notifications.keys.map((key) {
            final isFirst = key == notifications.keys.first;
            return Container(
              padding: EdgeInsets.only(top: isFirst ? 12 : 16),
              decoration: BoxDecoration(
                border: isFirst
                    ? null
                    : Border(
                        top: BorderSide(
                            color: ThemeScope.of(context)
                                .outlineVariant
                                .withValues(alpha: 0.2))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(key,
                            style: kBodyMd.copyWith(
                                color: ThemeScope.of(context).onSurface,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(
                          _descriptions[key] ?? '',
                          style: kBodyMd.copyWith(
                              color: ThemeScope.of(context).onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: notifications[key]!,
                    onChanged: (v) => onChanged(key, v),
                    activeTrackColor: ThemeScope.of(context).primaryContainer,
                    trackColor: WidgetStatePropertyAll(
                        ThemeScope.of(context).surfaceVariant),
                    thumbColor: const WidgetStatePropertyAll(Colors.white),
                    inactiveThumbColor: Colors.white,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
