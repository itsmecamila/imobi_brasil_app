import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/domain/models/property.dart';

PropertyService _instantService() => PropertyService(
  loadDelay: Duration.zero,
  saveDelay: Duration.zero,
  simulateError: false,
);

/// Loads normally but always fails to save.
class _FailingSaveService extends PropertyService {
  _FailingSaveService()
    : super(
        loadDelay: Duration.zero,
        saveDelay: Duration.zero,
        simulateError: false,
      );

  @override
  Future<void> saveProperty(Map<String, dynamic> json) async {
    throw Exception('Save failed');
  }
}

Property _withPrice(Property property, double price) =>
    Property.fromJson({...property.toJson(), 'preco': price});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PropertyRepository', () {
    test('carrega os 6 imóveis já traduzidos', () async {
      final repository = PropertyRepository(_instantService());
      expect(repository.hasLoaded, isFalse);

      await repository.load();

      expect(repository.hasLoaded, isTrue);
      expect(repository.properties.length, 6);
      expect(repository.properties.first.title, 'Apartamento Centro');
    });

    test('atualiza o imóvel e avisa os ouvintes', () async {
      final repository = PropertyRepository(_instantService());
      await repository.load();
      var notifications = 0;
      repository.addListener(() => notifications++);

      await repository.update(_withPrice(repository.findById(1)!, 2000));

      expect(repository.findById(1)!.price, 2000);
      expect(notifications, 1);
    });

    test('com erro ao salvar, a lista não muda', () async {
      final repository = PropertyRepository(_FailingSaveService());
      await repository.load();

      await expectLater(
        repository.update(_withPrice(repository.findById(1)!, 2000)),
        throwsException,
      );

      expect(repository.findById(1)!.price, 1800);
    });
  });
}
