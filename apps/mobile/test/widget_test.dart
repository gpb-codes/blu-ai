import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intelligence_chat/main.dart';
import 'package:intelligence_chat/services/stores.dart';
import 'package:intelligence_chat/theme/app_colors.dart';
import 'package:intelligence_chat/theme/theme_controller.dart';
import 'package:intelligence_chat/widgets/user_bubble.dart';

import 'test_fonts.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ThemeController.instance.setThemeIndex(0);
    UserStore.instance.setConsentGiven(false);
    UserStore.instance.setLoggedIn(false);
  });

  testWidgets('App starts on the main page', (WidgetTester tester) async {
    await pumpApp(tester, const IntelligenceApp());

    expect(find.text('¿En qué trabajamos hoy?'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsNothing);
    expect(find.text('Invitado'), findsOneWidget);
  });

  testWidgets('Chat streams from the main page', (WidgetTester tester) async {
    await pumpApp(tester, const IntelligenceApp());

    await tester.enterText(find.byType(TextField), 'Hola');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();

    expect(find.text('Hola'), findsWidgets);

    // Streaming: texto incremental hasta la respuesta completa.
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.textContaining('Ya puse a trabajar'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    expect(find.textContaining('ajustamos el enfoque'), findsOneWidget);
    expect(find.byIcon(Icons.stop_circle_outlined), findsNothing);
  });

  testWidgets('Register shows consent and enters the chat',
      (WidgetTester tester) async {
    await pumpApp(tester, const IntelligenceApp());

    await tester.tap(find.text('Invitado'));
    await tester.pumpAndSettle();
    await tester.tap(
        find.text('Crear cuenta').hitTestable().first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Ignacio Loyola');
    await tester.enterText(find.byType(TextField).at(1), 'ignacio@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'secret123');
    await tester.enterText(find.byType(TextField).at(3), 'secret123');
    await tester.ensureVisible(find.text('Crear cuenta'));
    await tester.tap(find.text('Crear cuenta').hitTestable().first);
    await tester.pumpAndSettle();

    // Primera sesión: consentimiento obligatorio para continuar (SPEC §11).
    expect(find.text('Un último paso'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byType(Checkbox).at(i));
    }
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aceptar y continuar'));
    await tester.pumpAndSettle();

    expect(UserStore.instance.loggedIn, isTrue);
    expect(find.text('¿En qué trabajamos hoy?'), findsOneWidget);
  });

  testWidgets('Appearance switches to light mode', (WidgetTester tester) async {
    await pumpApp(tester, const IntelligenceApp());

    await tester.tap(find.text('Invitado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar sesión').hitTestable().first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'ignacio@example.com');
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.ensureVisible(find.text('Iniciar sesión'));
    await tester.tap(find.text('Iniciar sesión').hitTestable().first);
    await tester.pumpAndSettle();
    // Consentimiento (usuario nuevo por defecto).
    if (find.text('Un último paso').evaluate().isNotEmpty) {
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byType(Checkbox).at(i));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar y continuar'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Configuración'));
    await tester.pumpAndSettle();
    expect(find.text('Apariencia'), findsOneWidget);

    await tester.ensureVisible(find.text('Modo blanco'));
    await tester.tap(find.text('Modo blanco'));
    await tester.pumpAndSettle();

    final palette = ThemeScope.of(tester.element(find.text('Apariencia')));
    expect(palette, same(AppPalette.light));
  });

  testWidgets('Profile logout returns to guest mode',
      (WidgetTester tester) async {
    await pumpApp(tester, const IntelligenceApp());

    // Invitado: el perfil no muestra datos de sesión.
    await tester.tap(find.text('Invitado'));
    await tester.pumpAndSettle();
    expect(find.text('Estás como invitado'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsNothing);
    expect(find.text('Información personal'), findsNothing);

    // Iniciar sesión desde el perfil.
    await tester.tap(find.text('Iniciar sesión').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'ignacio@example.com');
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.ensureVisible(find.text('Iniciar sesión'));
    await tester.tap(find.text('Iniciar sesión').hitTestable().first);
    await tester.pumpAndSettle();
    if (find.text('Un último paso').evaluate().isNotEmpty) {
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byType(Checkbox).at(i));
      }
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aceptar y continuar'));
      await tester.pumpAndSettle();
    }

    // Con sesión: nombre real y cierre de sesión.
    await tester.tap(find.text('Ignacio Loyola').first);
    await tester.pumpAndSettle();
    expect(find.text('Ignacio Loyola'), findsWidgets);
    expect(find.text('Información personal'), findsOneWidget);
    await tester.ensureVisible(find.text('Cerrar sesión'));
    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar sesión').hitTestable().last);
    await tester.pumpAndSettle();

    expect(UserStore.instance.loggedIn, isFalse);
    expect(find.text('Estás como invitado'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsNothing);
  });

  testWidgets('Editing a mini-app saves the typed name',
      (WidgetTester tester) async {
    await pumpApp(tester, const IntelligenceApp());
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).first, const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendario editorial'));
    await tester.pumpAndSettle();

    expect(find.text('Calendario editorial'), findsWidgets);
    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Calendario 2026');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Calendario 2026'), findsWidgets);
    expect(MiniAppsStore.instance.byId('a1')?.title, 'Calendario 2026');

    // Deja la semilla limpia para el resto de ejecuciones.
    MiniAppsStore.instance.rename('a1', 'Calendario editorial');
  });

  testWidgets('Suggestion card sends its instruction as a message',
      (WidgetTester tester) async {
    await pumpApp(tester, const IntelligenceApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hola');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump(const Duration(milliseconds: 2500));

    expect(find.text('Ejemplo de lógica'), findsOneWidget);
    await tester.ensureVisible(find.text('Ejemplo de lógica'));
    await tester.tap(find.text('Ejemplo de lógica'));
    await tester.pump();

    // La sugerencia entra como mensaje del usuario.
    expect(
      find.descendant(
        of: find.byType(UserBubble),
        matching: find.text('Crea un algoritmo de ordenación recursivo.'),
      ),
      findsOneWidget,
    );

    // El streaming termina y deja la segunda respuesta completa.
    await tester.pumpAndSettle();
    expect(find.text('Crea un algoritmo de ordenación recursivo.'),
        findsWidgets);
    expect(find.byIcon(Icons.stop_circle_outlined), findsNothing);
  });
}