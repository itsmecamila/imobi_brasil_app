import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/routing/router.dart';
import 'package:imobi_app/ui/core/themes/app_theme.dart';
import 'package:imobi_app/ui/property_list/view_models/property_list_view_model.dart';
import 'package:provider/provider.dart';

import '../helpers/auth.dart';

/// Offline until [online] is set.
class _SwitchableService extends PropertyService {
  _SwitchableService()
    : super(
        loadDelay: Duration.zero,
        saveDelay: Duration.zero,
        simulateError: false,
      );

  bool online = false;

  @override
  Future<List<Map<String, dynamic>>> fetchProperties() async {
    if (!online) throw Exception('Offline');
    return super.fetchProperties();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Opened straight from a link (web) while the listings fail to load: each
  // screen shows the error with "Atualizar" instead of loading forever.
  for (final (path, title) in [
    (Routes.property(1), 'Imóvel'),
    (Routes.editProperty(1), 'Editar imóvel'),
    (Routes.propertyPhoto(1), 'Foto'),
    (Routes.newProperty, 'Cadastrar imóvel'),
  ]) {
    testWidgets('$path sem conexão: erro com Atualizar, que resolve', (
      tester,
    ) async {
      final service = _SwitchableService();
      final repository = PropertyRepository(service);
      await tester.runAsync(() => repository.load().catchError((_) {}));
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
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      router.go(path);
      await tester.pumpAndSettle();

      expect(find.text(title), findsOneWidget);
      expect(
        find.text('Não foi possível carregar os imóveis agora.'),
        findsOneWidget,
      );

      service.online = true;
      await tester.tap(find.text('Atualizar'));
      // A spinner shows while it reloads (an endless animation), and the asset
      // is read outside the test clock: move both forward step by step.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
      }
      await tester.pump();

      expect(
        find.text('Não foi possível carregar os imóveis agora.'),
        findsNothing,
      );
    });
  }
}
