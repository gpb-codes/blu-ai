import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/profile/danger_zone_card.dart';
import '../widgets/profile/personal_info_card.dart';
import '../widgets/profile/preferences_card.dart';
import '../widgets/profile/profile_hero_card.dart';
import '../widgets/profile/security_card.dart';
import '../widgets/shared/app_card.dart';
import '../widgets/top_app_bar.dart';

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
      case AppSidebarItem.newChat:
        Navigator.pop(context);
      case AppSidebarItem.profile:
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
              selected: AppSidebarItem.profile,
              onSelect: _handleSelect,
            ),
      body: Row(
        children: [
          if (isWide)
            AppSidebar(
              selected: AppSidebarItem.profile,
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
                              title: 'Profile',
                              subtitle:
                                  'Manage your account, security, and personal information.',
                            ),
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
