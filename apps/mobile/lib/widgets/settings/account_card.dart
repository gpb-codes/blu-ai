import 'package:flutter/material.dart';
import '../../services/stores.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';
import '../profile/profile_hero_card.dart';

/// Tarjeta de cuenta (Settings): avatar, nombre, email, plan y botón
/// "Editar perfil". Reacciona al estado de sesión del usuario.
class SettingsAccountCard extends StatelessWidget {
  const SettingsAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return ListenableBuilder(
      listenable: UserStore.instance,
      builder: (context, _) {
        final user = UserStore.instance;
        final guest = !user.loggedIn;
        return AppCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 560;
              return Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: guest
                                ? c.surfaceVariant
                                : c.primaryContainer,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: c.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          alignment: Alignment.center,
                          child: guest
                              ? Icon(Icons.person_outline,
                                  size: 28, color: c.onSurfaceVariant)
                              : Text(
                                  user.name.trim().isEmpty
                                      ? '?'
                                      : user.name.trim()[0].toUpperCase(),
                                  style: kHeadlineMd.copyWith(
                                      color: guest
                                          ? c.onSurfaceVariant
                                          : Colors.white)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(guest ? 'Invitado' : user.name,
                                  style: kHeadlineMd.copyWith(
                                      color: c.onSurface)),
                              const SizedBox(height: 4),
                              Text(
                                  guest
                                      ? 'Inicia sesión desde tu perfil para sincronizar.'
                                      : user.email,
                                  style: kBodyMd.copyWith(
                                      color: c.onSurfaceVariant)),
                              if (!guest) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: user.plan == UserPlan.gratis
                                        ? c.surfaceVariant
                                        : BrandColors.cobalt.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('Plan ${user.plan.label}',
                                      style: kLabelMd.copyWith(
                                          color: user.plan == UserPlan.gratis
                                              ? c.onSurface
                                              : BrandColors.cobalt)),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (wide && !guest) const _EditProfileButton(),
                ],
              );
            },
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeScope.of(context).surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: ThemeScope.of(context).outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () => EditProfileDialog.show(context),
        borderRadius: BorderRadius.circular(8),
        child: Text('Editar perfil',
            style: kLabelMd.copyWith(color: ThemeScope.of(context).onSurface)),
      ),
    );
  }
}