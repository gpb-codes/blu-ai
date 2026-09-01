import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blu_ia_app/screens/agenda_screen.dart';
import 'package:blu_ia_app/screens/chat_screen.dart';
import 'package:blu_ia_app/screens/login_screen.dart';
import 'package:blu_ia_app/screens/memory_screen.dart';
import 'package:blu_ia_app/screens/mini_apps_screen.dart';
import 'package:blu_ia_app/screens/plans_screen.dart';
import 'package:blu_ia_app/screens/profile_screen.dart';
import 'package:blu_ia_app/screens/projects_screen.dart';
import 'package:blu_ia_app/screens/register_screen.dart';
import 'package:blu_ia_app/screens/settings_screen.dart';
import 'package:blu_ia_app/theme/app_colors.dart';

import 'test_fonts.dart';

final _screens = <(String, Widget)>[
  ('Chat', const ChatScreen()),
  ('Login', const LoginScreen()),
  ('Register', const RegisterScreen()),
  ('Settings', const SettingsScreen()),
  ('Profile', const ProfileScreen()),
  ('Projects', const ProjectsScreen()),
  ('Agenda', const AgendaScreen()),
  ('Memory', const MemoryScreen()),
  ('MiniApps', const MiniAppsScreen()),
  ('Plans', const PlansScreen()),
];

void main() {
  Future<void> pumpAt(
    WidgetTester tester,
    Widget home,
    AppPalette palette,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await pumpApp(
      tester,
      ThemeScope(
        palette: palette,
        child: MaterialApp(home: home),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final (name, screen) in _screens) {
    for (final palette in [AppPalette.light, AppPalette.dark]) {
      for (final size in [const Size(390, 844), const Size(1280, 800)]) {
        testWidgets(
          '$name render ${palette == AppPalette.dark ? 'dark' : 'light'} '
          '${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
            await pumpAt(tester, screen, palette, size);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}