import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_theme.dart';
import 'package:imobi_app/ui/property_list/view_models/property_list_view_model.dart';
import 'package:imobi_app/ui/property_list/widgets/property_card.dart';
import 'package:provider/provider.dart';

import '../helpers/auth.dart';

Future<(PropertyRepository, GoRouter)> _pumpApp(WidgetTester tester) async {
  // Tall enough for the whole form to be built at once.
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final repository = PropertyRepository(
    PropertyService(
      loadDelay: Duration.zero,
      saveDelay: Duration.zero,
      simulateError: false,
    ),
  );
  await tester.runAsync(repository.load);
  final auth = await signedInAuth(tester);
  final router = createRouter(auth);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: repository),
        ChangeNotifierProvider(
          create: (_) => PropertyListViewModel(repository),
        ),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return (repository, router);
}

/// Fills the required fields of a rent listing and taps "Cadastrar".
Future<void> _fillAndCreate(WidgetTester tester) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), 'Casa Nova');
  await tester.enterText(fields.at(2), '150000');
  await tester.enterText(fields.at(3), 'Presidente Prudente');
  await tester.enterText(fields.at(4), 'Centro');
  await tester.enterText(fields.at(8), '70');
  await tester.tap(find.text('Selecione…'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Aluguel').last);
  await tester.pumpAndSettle();

  await tester.tap(find.text('Cadastrar'));
  await tester.pumpAndSettle();
}

String _firstCardTitle(WidgetTester tester) =>
    tester.widget<PropertyCard>(find.byType(PropertyCard).first).property.title;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('/property/new aberto pelo endereço: salvar volta à Lista', (
    tester,
  ) async {
    final (repository, router) = await _pumpApp(tester);

    router.go(Routes.newProperty);
    await tester.pumpAndSettle();
    // "new" is not read as a listing id.
    expect(find.text('Cadastrar imóvel'), findsOneWidget);

    await _fillAndCreate(tester);

    expect(find.text('Imóvel cadastrado'), findsOneWidget);
    expect(router.state.uri.path, Routes.home);
    expect(repository.properties.first.price, 1500);
    expect(_firstCardTitle(tester), 'Casa Nova');
  });

  testWidgets('pelo botão, com filtro que esconde o novo: limpa e avisa', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.enterText(find.byType(TextField), 'centro');
    await tester.tap(find.text('Venda'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adicionar imóvel'));
    await tester.pumpAndSettle();
    await _fillAndCreate(tester);

    expect(
      find.text('Imóvel cadastrado. Busca e filtro limpos para mostrá-lo.'),
      findsOneWidget,
    );
    expect(_firstCardTitle(tester), 'Casa Nova');
    final search = tester.widget<TextField>(find.byType(TextField));
    expect(search.controller!.text, isEmpty);
  });

  testWidgets('pelo botão, com busca que mostra o novo: mantém a busca', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.enterText(find.byType(TextField), 'casa');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adicionar imóvel'));
    await tester.pumpAndSettle();
    await _fillAndCreate(tester);

    expect(find.text('Imóvel cadastrado'), findsOneWidget);
    expect(_firstCardTitle(tester), 'Casa Nova');
    final search = tester.widget<TextField>(find.byType(TextField));
    expect(search.controller!.text, 'casa');
  });
}
