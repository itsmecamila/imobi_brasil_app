import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/ui/core/themes/app_theme.dart';
import 'package:imobi_app/ui/property_list/view_models/property_list_view_model.dart';
import 'package:imobi_app/ui/property_list/widgets/property_card.dart';
import 'package:imobi_app/ui/property_list/widgets/property_list_screen.dart';
import 'package:imobi_app/ui/property_list/widgets/property_list_skeleton.dart';
import 'package:provider/provider.dart';

import '../../../helpers/auth.dart';
import '../../../helpers/fonts.dart';

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
  final auth = await signedInAuth(tester);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
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
      (width: 360.0, textScale: 1.5),
    ];

    for (final (:width, :textScale) in scenarios) {
      testWidgets('"Aluguel" selecionado aparece inteiro, em Inter '
          '(largura $width, fonte x$textScale)', (tester) async {
        await loadAppFonts(tester);
        await _pumpList(tester, width: width, textScale: textScale);

        await tester.tap(find.text('Aluguel'));
        await tester.pumpAndSettle();

        final label = tester.renderObject<RenderParagraph>(
          find.text('Aluguel'),
        );
        // The brand font, not the system one (which differs per phone).
        expect(label.text.style?.fontFamily, 'Inter');
        // Not cut: the whole word is laid out…
        expect(
          label.size.width,
          greaterThanOrEqualTo(label.getMaxIntrinsicWidth(double.infinity)),
        );
        // …and, as drawn (shrunk if needed), it stays inside the filter
        // without running into the next segment.
        final drawn = tester.getRect(find.text('Aluguel'));
        final filter = tester.getRect(
          find.byType(SegmentedButton<PropertyFilter>),
        );
        expect(drawn.right, lessThanOrEqualTo(filter.right));
        expect(
          drawn.left,
          greaterThanOrEqualTo(tester.getRect(find.text('Venda')).right),
        );
      });
    }
  });

  group('cabeçalho', () {
    for (final textScale in [1.3, 1.5, 2.0]) {
      testWidgets('acompanha a fonte do sistema e não invade a lista '
          '(fonte x$textScale)', (tester) async {
        await loadAppFonts(tester);
        await _pumpList(tester, width: 360);
        double heightOf(Finder finder) => tester.getSize(finder).height;
        final normalTitle = heightOf(find.text('Imóveis'));
        final normalSearch = heightOf(find.byType(TextField));

        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        await tester.pumpAndSettle();

        // Grows with the system font, like the rest of the app.
        expect(heightOf(find.text('Imóveis')), greaterThan(normalTitle));
        expect(heightOf(find.byType(TextField)), greaterThan(normalSearch));
        // And everything still fits above the first card.
        expect(tester.takeException(), isNull);
        expect(
          tester.getRect(find.byType(PropertyCard).first).top,
          greaterThanOrEqualTo(
            tester.getRect(find.byType(SegmentedButton<PropertyFilter>)).bottom,
          ),
        );
      });
    }

    testWidgets('some ao descer e volta ao subir (quick return)', (
      tester,
    ) async {
      await _pumpList(tester, width: 360);
      final list = find.byType(CustomScrollView);

      await tester.drag(list, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Sair').hitTestable(), findsNothing);

      await tester.drag(list, const Offset(0, 100));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Sair').hitTestable(), findsOneWidget);
    });
  });

  group('botão "Adicionar imóvel"', () {
    testWidgets('aparece com os imóveis carregados', (tester) async {
      await _pumpList(tester, width: 360);

      expect(find.text('Adicionar imóvel'), findsOneWidget);
    });

    testWidgets('não aparece quando o carregamento falha', (tester) async {
      final viewModel = PropertyListViewModel(
        PropertyRepository(
          PropertyService(
            loadDelay: Duration.zero,
            saveDelay: Duration.zero,
            simulateError: true,
          ),
        ),
      );
      await tester.runAsync(viewModel.load);
      final auth = await signedInAuth(tester);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider.value(value: viewModel),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const PropertyListScreen(),
          ),
        ),
      );

      expect(find.text('Atualizar'), findsOneWidget);
      expect(find.text('Adicionar imóvel'), findsNothing);
    });
  });

  group('carregando (esqueleto)', () {
    /// The list as it opens: loading has started and takes [loadDelay].
    Future<PropertyListViewModel> pumpLoading(WidgetTester tester) async {
      final viewModel = PropertyListViewModel(
        PropertyRepository(
          PropertyService(
            loadDelay: const Duration(seconds: 2),
            simulateError: false,
          ),
        ),
      );
      final auth = await signedInAuth(tester);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider.value(value: viewModel),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const PropertyListScreen(),
          ),
        ),
      );
      viewModel.load();
      await tester.pump();
      return viewModel;
    }

    testWidgets('mostra os cards-esqueleto com brilho e some com os dados', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpLoading(tester);

      expect(find.byType(PropertyListSkeleton), findsOneWidget);
      expect(find.byType(ShaderMask), findsNWidgets(3));
      expect(find.bySemanticsLabel('Carregando imóveis…'), findsOneWidget);

      // Ends the simulated delay, then lets the asset be read for real.
      await tester.pump(const Duration(seconds: 2));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump();

      expect(find.byType(PropertyListSkeleton), findsNothing);
      expect(find.byType(PropertyCard), findsWidgets);
      semantics.dispose();
    });

    testWidgets('com "remover animações" do sistema, os blocos ficam parados', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await pumpLoading(tester);

      expect(find.byType(PropertyListSkeleton), findsOneWidget);
      expect(find.byType(ShaderMask), findsNothing);

      await tester.pump(const Duration(seconds: 2));
    });
  });
}
