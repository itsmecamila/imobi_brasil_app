import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/ui/core/themes/app_theme.dart';
import 'package:imobi_app/ui/property_list/view_models/property_list_view_model.dart';
import 'package:imobi_app/ui/property_list/widgets/property_list_screen.dart';
import 'package:provider/provider.dart';

Future<void> _pumpList(
  WidgetTester tester, {
  required double width,
  double textScale = 1,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  final repository = PropertyRepository(
    PropertyService(
      loadDelay: Duration.zero,
      saveDelay: Duration.zero,
      simulateError: false,
    ),
  );
  await tester.runAsync(repository.load);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: repository),
        ChangeNotifierProvider(
          create: (_) => PropertyListViewModel(repository),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const PropertyListScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('filtro por tipo', () {
    const scenarios = [
      (width: 360.0, textScale: 1.0),
      (width: 320.0, textScale: 1.0),
      (width: 360.0, textScale: 1.3),
    ];

    for (final (:width, :textScale) in scenarios) {
      testWidgets('"Aluguel" selecionado cabe numa linha '
          '(largura $width, fonte x$textScale)', (tester) async {
        await _pumpList(tester, width: width, textScale: textScale);

        await tester.tap(find.text('Aluguel'));
        await tester.pumpAndSettle();

        // One text line is ~20 high at 14sp; a wrapped label is ~2x that.
        final lineHeight = tester.getSize(find.text('Aluguel')).height;
        expect(lineHeight, lessThan(textScale * 28));
      });
    }
  });
}
