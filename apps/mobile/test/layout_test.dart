import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intelligence_chat/screens/chat_screen.dart';
import 'package:intelligence_chat/screens/profile_screen.dart';
import 'package:intelligence_chat/screens/settings_screen.dart';

import 'test_fonts.dart';

void main() {
  final sizes = <Size>[
    const Size(360, 800),
    const Size(390, 844),
    const Size(800, 600),
    const Size(1280, 800),
  ];

  for (final size in sizes) {
    testWidgets('Chat landing render at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester, const MaterialApp(home: ChatScreen()));

      expect(tester.takeException(), isNull);
    });

    testWidgets('Settings render at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(
        tester,
        const MaterialApp(home: SettingsScreen()),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('Profile render at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(
        tester,
        const MaterialApp(home: ProfileScreen()),
      );

      expect(tester.takeException(), isNull);
    });
  }
}