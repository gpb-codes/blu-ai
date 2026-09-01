import 'package:flutter/material.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/profile/danger_zone_card.dart';
import '../widgets/profile/personal_info_card.dart';
import '../widgets/profile/preferences_card.dart';
import '../widgets/profile/profile_hero_card.dart';
import '../widgets/profile/security_card.dart';
import '../widgets/shared/app_card.dart';
import '../widgets/top_app_bar.dart';
import 'agenda_screen.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'memory_screen.dart';
import 'mini_apps_screen.dart';
import 'projects_screen.dart';
import 'register_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _twoFactorEnabled = true;

  void _handleSelect(AppSidebarItem item) {
    switch (item) {
      case AppSidebarItem.settings:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
      case AppSidebarItem.projects:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ProjectsScreen()));
      case AppSidebarItem.memory:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MemoryScreen()));
      case AppSidebarItem.agenda:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AgendaScreen()));
      case AppSidebarItem.miniApps:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MiniAppsScreen()));
      case AppSidebarItem.newChat:
        Navigator.pop(context);
      case AppSidebarItem.profile:
        break;
    }
  }

  void _openSession(ChatSession session) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => ChatScreen(sessionId: session.id)));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;
    final c = ThemeScope.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: c.background,
      drawer: isWide
          ? null
          : AppSidebar(
              selected: AppSidebarItem.profile,
              onSelect: _handleSelect,
              onOpenSession: _openSession,
            ),
      body: Row(
        children: [
          if (isWide)
            AppSidebar(
              selected: AppSidebarItem.profile,
              onSelect: _handleSelect,
              onOpenSession: _openSession,
            ),
          Expanded(
            child: Column(
              children: [
                if (!isWide)
                  TopAppBar(
                    onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const PageHeader(
                              title: 'Perfil',
                              subtitle:
                                  'Gestiona tu cuenta, seguridad e información personal.',
                            ),
                            const SizedBox(height: 24),
                            const _AuthCard(),
                            const SizedBox(height: 24),
                            const ProfileHeroCard(),
                            const SizedBox(height: 24),
                            const PersonalInfoSection(),
                            const SizedBox(height: 24),
                            const PreferencesSection(),
                            const SizedBox(height: 24),
                            SecuritySection(
                              twoFactorEnabled: _twoFactorEnabled,
                              onTwoFactorChanged: (v) =>
                                  setState(() => _twoFactorEnabled = v),
                            ),
                            const SizedBox(height: 24),
                            const _SessionCard(),
                            const SizedBox(height: 24),
                            const DangerZoneSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de acceso: se muestra cuando el usuario no ha iniciado sesión y
/// ofrece Iniciar sesión / Crear cuenta (opcional, la app arranca en el chat).
class _AuthCard extends StatelessWidget {
  const _AuthCard();

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return ListenableBuilder(
      listenable: UserStore.instance,
      builder: (context, _) {
        if (UserStore.instance.loggedIn) return const SizedBox.shrink();
        return AppCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 560;
              final buttons = Row(
                children: [
                  _AuthButton(
                    label: 'Iniciar sesión',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _AuthButton(
                    label: 'Crear cuenta',
                    outline: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                  ),
                ],
              );
              final text = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estás como invitado',
                      style: kBodyMd.copyWith(
                          color: c.onSurface, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text('Inicia sesión para guardar tu plan y sincronizar.',
                      style: kLabelMd.copyWith(
                          fontSize: 12, color: BrandColors.gris)),
                ],
              );
              return Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: BrandColors.cobalt.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.login,
                        size: 18, color: BrandColors.cobalt),
                  ),
                  const SizedBox(width: 12),
                  if (wide) ...[
                    Expanded(child: text),
                    const SizedBox(width: 8),
                    buttons,
                  ] else
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          text,
                          const SizedBox(height: 10),
                          buttons,
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outline;

  const _AuthButton({
    required this.label,
    required this.onTap,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: outline ? Colors.transparent : BrandColors.cobalt,
            borderRadius: BorderRadius.circular(8),
            border: outline
                ? Border.all(color: c.outlineVariant)
                : null,
          ),
          child: Text(label,
              style: kLabelMd.copyWith(
                  color: outline ? c.onSurface : Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

/// Tarjeta de sesión: cierre de sesión con confirmación. Solo con sesión.
class _SessionCard extends StatelessWidget {
  const _SessionCard();

  Future<void> _confirmLogout(BuildContext context) async {
    final c = ThemeScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.surfaceContainerLow,
        title: Text('Cerrar sesión',
            style: kHeadlineMd.copyWith(color: c.onSurface)),
        content: Text(
          'Volverás al modo invitado. Tu plan y tus datos seguirán guardados.',
          style: kBodyMd.copyWith(color: c.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    UserStore.instance.setLoggedIn(false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: c.surfaceContainerHigh,
        content: Text('Sesión cerrada. Hasta pronto.',
            style: kBodyMd.copyWith(color: c.onSurface)),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return ListenableBuilder(
      listenable: UserStore.instance,
      builder: (context, _) {
        if (!UserStore.instance.loggedIn) return const SizedBox.shrink();
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                  icon: Icons.logout,
                  title: 'Sesión',
                  description: 'Cierra tu sesión en este dispositivo.'),
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _confirmLogout(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: c.surfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: c.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Text('Cerrar sesión',
                        style: kLabelMd.copyWith(
                            color: c.onSurface,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
