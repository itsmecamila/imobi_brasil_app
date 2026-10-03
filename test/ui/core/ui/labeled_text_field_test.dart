import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/ui/core/themes/app_theme.dart';
import 'package:imobi_app/ui/core/ui/labeled_text_field.dart';

import '../../../helpers/fonts.dart';

void main() {
  testWidgets('mensagem de erro: ícone centralizado com o texto', (
    tester,
  ) async {
    await loadAppFonts(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: ErrorLine(message: 'Informe o título.')),
      ),
    );

    final icon = tester.getRect(find.byIcon(Icons.error_outline));
    final text = tester.getRect(find.text('Informe o título.'));
    expect(icon.center.dy, closeTo(text.center.dy, 0.5));
  });
}
