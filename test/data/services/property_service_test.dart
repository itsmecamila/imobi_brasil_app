import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  // Needed to read assets (rootBundle) outside a running app.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PropertyService.fetchProperties', () {
    test('busca os 6 imóveis do asset, sem traduzir', () async {
      final service = PropertyService(
        loadDelay: Duration.zero,
        simulateError: false,
      );

      final raw = await service.fetchProperties();

      expect(raw.length, 6);
      expect(raw.first['titulo'], 'Apartamento Centro');
    });

    test('lança erro quando o erro simulado está ligado', () async {
      final service = PropertyService(
        loadDelay: Duration.zero,
        simulateError: true,
      );

      expect(service.fetchProperties(), throwsException);
    });
  });

  group('persistência no aparelho', () {
    // In-memory storage in place of the device's, as in the package's own
    // example tests.
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    PropertyService service() => PropertyService(
      storage: SharedPreferencesAsync(),
      loadDelay: Duration.zero,
      saveDelay: Duration.zero,
      simulateError: false,
    );

    test('a edição continua lá ao "reabrir o app"', () async {
      final first = (await service().fetchProperties()).first;
      await service().saveProperty({...first, 'preco': 2000.0});

      // A brand-new service, as after closing and opening the app.
      final reopened = await service().fetchProperties();

      expect(reopened.first['preco'], 2000.0);
      expect(reopened.length, 6);
    });

    test('o imóvel cadastrado continua lá, no topo', () async {
      final sample = (await service().fetchProperties()).first;
      await service().createProperty({...sample, 'id': 7, 'titulo': 'Nova'});

      final reopened = await service().fetchProperties();

      expect(reopened.length, 7);
      expect(reopened.first['titulo'], 'Nova');
    });

    test('restaurar volta aos dados de exemplo', () async {
      final sample = (await service().fetchProperties()).first;
      await service().createProperty({...sample, 'id': 7});

      await service().resetToSample();

      expect((await service().fetchProperties()).length, 6);
    });

    test('com erro ao salvar, nada é guardado', () async {
      final first = (await service().fetchProperties()).first;
      final failing = PropertyService(
        storage: SharedPreferencesAsync(),
        saveDelay: Duration.zero,
        simulateError: true,
      );

      await expectLater(
        failing.saveProperty({...first, 'preco': 2000.0}),
        throwsException,
      );

      expect((await service().fetchProperties()).first['preco'], 1800.0);
    });
  });
}
