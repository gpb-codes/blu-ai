import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:blu_ia_app/screens/chat_screen.dart';
import 'package:blu_ia_app/screens/login_screen.dart';
import 'package:blu_ia_app/screens/profile_screen.dart';
import 'package:blu_ia_app/screens/settings_screen.dart';

import 'test_fonts.dart';

void main() {
  final sizes = <Size>[
    const Size(360, 800),
    const Size(390, 844),
    const Size(800, 600),
    const Size(1280, 800),
  ];

  for (final size in sizes) {
    testWidgets('Login render at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpThemed(tester, const LoginScreen());

      expect(tester.takeException(), isNull);
    });
    testWidgets('Chat landing render at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpThemed(tester, const ChatScreen());

      expect(tester.takeException(), isNull);
    });

    testWidgets('Settings render at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpThemed(tester, const SettingsScreen());

      expect(tester.takeException(), isNull);
    });

    testWidgets('Profile render at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpThemed(tester, const ProfileScreen());

      expect(tester.takeException(), isNull);
    });
  }
}