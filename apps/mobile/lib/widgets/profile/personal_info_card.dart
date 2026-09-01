import 'package:flutter/material.dart';
import '../../services/stores.dart';
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
                style: kBodyMd.copyWith(color: ThemeScope.of(context).onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: kBodyMd.copyWith(
                    color: ThemeScope.of(context).onSurface, fontWeight: FontWeight.w500)),
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
        height: 1, color: ThemeScope.of(context).outlineVariant.withValues(alpha: 0.2));
  }
}

/// Sección "Personal Info" (Perfil). Solo se muestra con sesión iniciada.
class PersonalInfoSection extends StatelessWidget {
  const PersonalInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserStore.instance,
      builder: (context, _) {
        final user = UserStore.instance;
        if (!user.loggedIn) return const SizedBox.shrink();
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                  icon: Icons.person_outline, title: 'Información personal'),
              const SizedBox(height: 8),
              InfoRow(label: 'Nombre completo', value: user.name),
              const _SectionDivider(),
              InfoRow(label: 'Correo', value: user.email),
              const _SectionDivider(),
              const InfoRow(label: 'Usuario', value: '@soybluia'),
              const _SectionDivider(),
              const InfoRow(
                  label: 'Biografía',
                  value: 'Construyendo asistentes inteligentes para todos.'),
            ],
          ),
        );
      },
    );
  }
}