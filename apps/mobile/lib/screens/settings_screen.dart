import 'package:flutter/material.dart';
import '../services/stores.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/settings/account_card.dart';
import '../widgets/settings/api_keys_card.dart';
import '../widgets/settings/appearance_card.dart';
import '../widgets/settings/notifications_card.dart';
import '../widgets/shared/app_card.dart';
import '../widgets/top_app_bar.dart';
import 'plans_screen.dart';
import 'profile_screen.dart';
import 'projects_screen.dart';
import 'memory_screen.dart';
import 'agenda_screen.dart';
import 'chat_screen.dart';
import 'mini_apps_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late int _themeIndex = ThemeController.instance.themeIndex;
  final Map<String, bool> _notifications = {
    'Novedades de producto': true,
    'Alertas de uso': true,
    'Marketing': false,
  };

  void _openSession(ChatSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(sessionId: session.id)),
    );
  }

  void _handleSelect(AppSidebarItem item) {
    switch (item) {
      case AppSidebarItem.profile:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
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
      case AppSidebarItem.settings:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ThemeScope.of(context).background,
      drawer: isWide
          ? null
          : AppSidebar(
              selected: AppSidebarItem.settings,
              onSelect: _handleSelect,
              onOpenSession: _openSession,
            ),
      body: Row(
        children: [
          if (isWide)
            AppSidebar(
              selected: AppSidebarItem.settings,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            const PageHeader(
                              title: 'Configuración',
                              subtitle:
                                  'Gestiona tu cuenta, preferencias e integraciones de API.',
                            ),
                            const SizedBox(height: 24),
                            const SettingsAccountCard(),
                            const SizedBox(height: 24),
                            const _PlanSection(),
                            const SizedBox(height: 24),
                            _AppearanceAndKeysGrid(
                              themeIndex: _themeIndex,
                              onThemeChanged: (i) {
                                ThemeController.instance.setThemeIndex(i);
                                setState(() => _themeIndex = i);
                              },
                            ),
                            const SizedBox(height: 24),
                            NotificationsSection(
                              notifications: _notifications,
                              onChanged: (k, v) =>
                                  setState(() => _notifications[k] = v),
                            ),
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

/// Tarjeta del plan real en Configuración > Cuenta (SPEC §10): muestra el
/// plan del usuario y abre la pantalla de planes con "Mejorar plan".
class _PlanSection extends StatelessWidget {
  const _PlanSection();

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return ListenableBuilder(
      listenable: UserStore.instance,
      builder: (context, _) {
        final user = UserStore.instance;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Plan',
                      description:
                          'Tu plan actual y las opciones disponibles.'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: user.plan == UserPlan.gratis
                              ? BrandColors.gris.withValues(alpha: 0.4)
                              : BrandColors.cobalt,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('Plan ${user.plan.label}',
                            style: kLabelMd.copyWith(
                                fontSize: 12,
                                color: user.plan == UserPlan.gratis
                                    ? c.onSurfaceVariant
                                    : Colors.white)),
                      ),
                      const Spacer(),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const PlansScreen()),
                          ),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: BrandColors.cobalt,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Mejorar plan',
                                style: kLabelMd.copyWith(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                      user.plan == UserPlan.gratis
                          ? 'Acceso limitado. Mejorando desbloqueas todos los modelos y la memoria completa.'
                          : user.plan == UserPlan.byok
                              ? 'Traes tus propias claves de API y usas todos los modelos.'
                              : 'Créditos por consumo con tope suave por modelo.',
                      style: kBodyMd.copyWith(
                          fontSize: 13, color: c.onSurfaceVariant)),
                ],
              ),
            ),
            if (user.plan == UserPlan.creditos) ...[
              const SizedBox(height: 16),
              BalanceBar(user: user),
            ],
          ],
        );
      },
    );
  }
}

/// Grid 5/7 de Apariencia + API Keys en escritorio, apilado en móvil.
class _AppearanceAndKeysGrid extends StatelessWidget {
  final int themeIndex;
  final ValueChanged<int> onThemeChanged;

  const _AppearanceAndKeysGrid({
    required this.themeIndex,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 768;
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: AppearanceSection(
                      themeIndex: themeIndex,
                      onThemeChanged: onThemeChanged,
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(flex: 7, child: ApiKeysSection()),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppearanceSection(
                    themeIndex: themeIndex,
                    onThemeChanged: onThemeChanged,
                  ),
                  const SizedBox(height: 24),
                  const ApiKeysSection(),
                ],
              );
      },
    );
  }
}
