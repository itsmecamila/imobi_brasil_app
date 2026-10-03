import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests draw text with a square placeholder font by default, so widths say
/// nothing about the real app. Layout tests load the app's Inter first.
Future<void> loadAppFonts(WidgetTester tester) async {
  await tester.runAsync(() async {
    final inter = FontLoader('Inter');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      inter.addFont(rootBundle.load('assets/fonts/Inter-$weight.ttf'));
    }
    await inter.load();
  });
}
