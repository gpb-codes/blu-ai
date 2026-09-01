import 'package:flutter/material.dart';
import '../../services/stores.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';

/// Tarjeta hero del perfil: avatar, nombre, badges, botón edit y estadísticas.
/// Reacciona al estado de sesión: como invitado muestra un perfil genérico.
class ProfileHeroCard extends StatelessWidget {
  const ProfileHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return ListenableBuilder(
      listenable: UserStore.instance,
      builder: (context, _) {
        final user = UserStore.instance;
        final guest = !user.loggedIn;
        final initials = guest
            ? '?'
            : user.name.trim().isEmpty
                ? '?'
                : user.name.trim()[0].toUpperCase();
        return AppCard(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 560;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color:
                                  guest ? c.surfaceVariant : c.primaryContainer,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: c.primary.withValues(alpha: 0.4),
                                  width: 2),
                            ),
                            alignment: Alignment.center,
                            child: guest
                                ? Icon(Icons.person_outline,
                                    size: 32, color: c.onSurfaceVariant)
                                : Text(initials,
                                    style: kHeadlineLg.copyWith(
                                        color: guest
                                            ? c.onSurfaceVariant
                                            : Colors.white)),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(guest ? 'Invitado' : user.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: kHeadlineMd.copyWith(
                                        color: c.onSurface)),
                                const SizedBox(height: 4),
                                Text(
                                    guest
                                        ? 'Inicia sesión para guardar tu plan y datos.'
                                        : user.email,
                                    overflow: TextOverflow.ellipsis,
                                    style: kBodyMd.copyWith(
                                        color: c.onSurfaceVariant)),
                                if (!guest) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: user.plan == UserPlan.gratis
                                              ? c.surfaceVariant
                                              : BrandColors.cobalt
                                                  .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text('Plan ${user.plan.label}',
                                            style: kLabelMd.copyWith(
                                                color:
                                                    user.plan == UserPlan.gratis
                                                        ? c.onSurface
                                                        : BrandColors.cobalt)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: c.primaryContainer
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text('Member',
                                            style: kLabelMd.copyWith(
                                                color: c.primary)),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (wide && !guest) ...[
                            const SizedBox(width: 16),
                            const _EditProfileButton(),
                          ],
                        ],
                      ),
                      if (!wide && !guest)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: _EditProfileButton(),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                  height: 1, color: c.outlineVariant.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: _StatItem(
                          label: 'Mensajes', value: guest ? '—' : '1,284')),
                  Expanded(
                      child: _StatItem(
                          label: 'Tokens usados', value: guest ? '—' : '2.4M')),
                  Expanded(
                      child: _StatItem(
                          label: 'Modelos', value: guest ? '—' : '3')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => EditProfileDialog.show(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: c.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Text('Editar perfil',
              style: kLabelMd.copyWith(color: c.onSurface)),
        ),
      ),
    );
  }
}

/// Diálogo de edición de perfil (nombre y correo) que escribe en UserStore.
class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const EditProfileDialog(),
    );
  }

  @override
  State<EditProfileDialog> createState() => EditProfileDialogState();
}

class EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _name =
      TextEditingController(text: UserStore.instance.name);
  late final TextEditingController _email =
      TextEditingController(text: UserStore.instance.email);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return AlertDialog(
      backgroundColor: c.surfaceContainerLow,
      title: Text('Editar perfil',
          style: kHeadlineMd.copyWith(color: c.onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            style: kBodyMd.copyWith(color: c.onSurface),
            decoration: InputDecoration(
              labelText: 'Nombre completo',
              labelStyle: kLabelMd.copyWith(color: c.onSurfaceVariant),
              filled: true,
              fillColor: c.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: c.outlineVariant),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            style: kBodyMd.copyWith(color: c.onSurface),
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              labelStyle: kLabelMd.copyWith(color: c.onSurfaceVariant),
              filled: true,
              fillColor: c.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: c.outlineVariant),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            UserStore.instance.setProfile(name: _name.text, email: _email.text);
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
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
                color: ThemeScope.of(context).onSurface,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(label,
            style: kLabelMd.copyWith(
                color: ThemeScope.of(context).onSurfaceVariant)),
      ],
    );
  }
}
