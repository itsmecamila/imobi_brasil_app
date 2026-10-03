import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_theme.dart';
import 'package:imobi_app/ui/core/ui/property_photo.dart';
import 'package:imobi_app/ui/property_list/view_models/property_list_view_model.dart';
import 'package:imobi_app/ui/property_list/widgets/property_card.dart';
import 'package:provider/provider.dart';

Finder _heroWithTag(int id) => find.byWidgetPredicate(
  (widget) => widget is Hero && widget.tag == propertyPhotoHeroTag(id),
);

Future<void> _pumpApp(WidgetTester tester) async {
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
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: createRouter(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Lista → Detalhe → foto em tela cheia → fechar', (tester) async {
    await _pumpApp(tester);

    // The card photo carries the shared Hero tag.
    expect(_heroWithTag(1), findsOneWidget);

    await tester.tap(find.byType(PropertyCard).first);
    await tester.pumpAndSettle();

    // Detail: the same tag lives on the detail photo, which opens the viewer.
    expect(_heroWithTag(1), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsNothing);

    await tester.tap(find.byType(PropertyPhoto));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(_heroWithTag(1), findsOneWidget);

    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsNothing);
    expect(find.text('Entrar em Contato'), findsOneWidget);
  });

  testWidgets('foto em tela cheia por link direto de imóvel inexistente', (
    tester,
  ) async {
    await _pumpApp(tester);
    final router = GoRouter.of(tester.element(find.byType(PropertyCard).first));

    router.go(Routes.propertyPhoto(999));
    await tester.pumpAndSettle();

    expect(find.text('Este imóvel não está mais disponível.'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsNothing);
  });
}
