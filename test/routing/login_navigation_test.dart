import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:imobi_app/data/repositories/auth_repository.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_theme.dart';
import 'package:imobi_app/ui/login/widgets/login_screen.dart';
import 'package:imobi_app/ui/property_list/view_models/property_list_view_model.dart';
import 'package:imobi_app/ui/property_list/widgets/property_list_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/auth.dart';

Future<GoRouter> _pumpApp(WidgetTester tester, AuthRepository auth) async {
  final repository = PropertyRepository(
    PropertyService(
      loadDelay: Duration.zero,
      saveDelay: Duration.zero,
      simulateError: false,
    ),
  );
  await tester.runAsync(repository.load);
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
  return router;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sem login, o app abre no Login', (tester) async {
    await _pumpApp(tester, instantAuth());

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(PropertyListScreen), findsNothing);
  });

  testWidgets('sem login, um link direto também cai no Login', (tester) async {
    final router = await _pumpApp(tester, instantAuth());

    router.go(Routes.editProperty(1));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.login);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('entrar leva à Lista com o nome na barra; sair volta ao Login', (
    tester,
  ) async {
    final router = await _pumpApp(tester, instantAuth());

    await tester.enterText(
      find.byType(TextField).at(0),
      'corretor@imobibrasil.com.br',
    );
    await tester.enterText(find.byType(TextField).at(1), 'imobi2026');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.home);
    expect(find.text('Corretor ImobiBrasil'), findsOneWidget);
    // The login leaves the history: back on the list exits the app.
    expect(router.canPop(), isFalse);

    // Asks first: "Cancelar" keeps the session.
    await tester.tap(find.byTooltip('Sair'));
    await tester.pumpAndSettle();
    expect(find.text('Sair da conta?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.home);

    await tester.tap(find.byTooltip('Sair'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sair'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.login);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('já logado, abrir /login leva à Lista', (tester) async {
    final router = await _pumpApp(tester, await signedInAuth(tester));

    router.go(Routes.login);
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.home);
  });
}
