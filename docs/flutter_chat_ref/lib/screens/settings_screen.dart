import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/settings/account_card.dart';
import '../widgets/settings/api_keys_card.dart';
import '../widgets/settings/appearance_card.dart';
import '../widgets/settings/notifications_card.dart';
import '../widgets/shared/app_card.dart';
import '../widgets/top_app_bar.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _themeIndex = 0; // 0 = Dark, 1 = Light, 2 = System
  final Map<String, bool> _notifications = {
    'Product Updates': true,
    'Usage Alerts': true,
    'Marketing': false,
  };

  void _handleSelect(AppSidebarItem item) {
    switch (item) {
      case AppSidebarItem.profile:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
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
      backgroundColor: AppColorsDark.background,
      drawer: isWide
          ? null
          : AppSidebar(
              selected: AppSidebarItem.settings,
              onSelect: _handleSelect,
            ),
      body: Row(
        children: [
          if (isWide)
            AppSidebar(
              selected: AppSidebarItem.settings,
              onSelect: _handleSelect,
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
                              title: 'Settings',
                              subtitle:
                                  'Manage your account, preferences, and API integrations.',
                            ),
                            const SizedBox(height: 24),
                            const SettingsAccountCard(),
                            const SizedBox(height: 24),
                            _AppearanceAndKeysGrid(
                              themeIndex: _themeIndex,
                              onThemeChanged: (i) => setState(() => _themeIndex = i),
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
