import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intelligence_chat/main.dart';
import 'package:intelligence_chat/services/stores.dart';
import 'package:intelligence_chat/theme/theme_controller.dart';

import 'test_fonts.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ThemeController.instance.setThemeIndex(0);
    UserStore.instance.setConsentGiven(false);
    UserStore.instance.setLoggedIn(false);
  });

  testWidgets('Attachment sheet confirms the chosen file type',
      (WidgetTester tester) async {
    await pumpApp(tester, const IntelligenceApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Adjuntar'));
    await tester.pumpAndSettle();

    expect(find.text('Adjuntar'), findsOneWidget);
    expect(find.text('Archivo'), findsOneWidget);
    expect(find.text('Imagen'), findsOneWidget);
    expect(find.text('Dato'), findsOneWidget);

    await tester.tap(find.text('Imagen'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('"Imagen" adjuntado a la conversación'), findsOneWidget);
  });

  testWidgets('Help button opens the help center sheet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpApp(tester, const IntelligenceApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.text('Centro de ayuda'), findsOneWidget);
  });

  testWidgets('Invite dialog validates the email before adding a member',
      (WidgetTester tester) async {
    await pumpApp(tester, const IntelligenceApp());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Proyectos'));
    await tester.pumpAndSettle();
    expect(find.text('Proyectos'), findsWidgets);

    await tester.ensureVisible(find.text('Invitar').first);
    await tester.tap(find.text('Invitar').first);
    await tester.pumpAndSettle();
    expect(find.text('Invitar miembro'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'correo-invalido');
    await tester.tap(find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Invitar'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Ese correo no parece válido.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'nuevo@example.com');
    await tester.tap(find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text('Invitar'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Invitar miembro'), findsNothing);
  });

  testWidgets('Voice flow grants permission and transcribes into the input',
      (WidgetTester tester) async {
    await pumpApp(tester, const IntelligenceApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('soybluia quiere usar el micrófono'), findsOneWidget);

    await tester.tap(find.text('Permitir'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Escuchando…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.text('Transcripción lista'), findsOneWidget);

    await tester.tap(find.text('Enviar transcripción'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Escuchando…'), findsNothing);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, isNotEmpty);
  });
}