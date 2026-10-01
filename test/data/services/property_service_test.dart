import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/services/property_service.dart';

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
}
