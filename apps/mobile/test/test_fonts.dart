import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carga las fuentes reales (Inter/Geist) para que los tests usen métricas
/// reales de texto en lugar de la fuente Ahem (que exagera el ancho de cada
/// carácter y provoca falsos overflows).
Future<void> loadTestFonts() async {
  const assets = [
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-Bold.ttf',
    'assets/fonts/Geist.ttf',
  ];
  for (final asset in assets) {
    final bytes = await rootBundle.load(asset);
    final family = asset.contains('Inter') ? 'Inter' : 'Geist';
    final loader = FontLoader(family)..addFont(Future.value(bytes));
    await loader.load();
  }
}

/// Pinta un widget dentro de un MaterialApp con fuentes reales cargadas.
Future<void> pumpApp(WidgetTester tester, Widget child) async {
  await loadTestFonts();
  await tester.pumpWidget(child);
}
