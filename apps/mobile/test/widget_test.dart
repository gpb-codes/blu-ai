import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intelligence_chat/main.dart';

import 'test_fonts.dart';

void main() {
  testWidgets('Chat app renders landing smoke test', (WidgetTester tester) async {
    await pumpApp(tester, const IntelligenceApp());

    expect(find.text('soybluia'), findsOneWidget);
    expect(find.text('¿En qué trabajamos hoy?'), findsOneWidget);
    expect(find.text('Pregunta lo que quieras'), findsOneWidget);
    expect(find.text('Blu Light'), findsOneWidget);
  });

  testWidgets('Sending a message shows the conversation', (WidgetTester tester) async {
    await pumpApp(tester, const IntelligenceApp());

    await tester.enterText(find.byType(TextField), 'Hola');
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();

    expect(find.text('Hola'), findsOneWidget);
    expect(find.text('¿En qué trabajamos hoy?'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1700));
    expect(find.textContaining('Respuesta simulada'), findsOneWidget);
  });
}
