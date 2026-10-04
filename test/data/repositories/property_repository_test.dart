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

  @override
  Future<void> createProperty(Map<String, dynamic> json) async {
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

  group('PropertyRepository.add', () {
    test('o próximo id é o maior id + 1', () async {
      final repository = PropertyRepository(_instantService());
      expect(repository.nextId, 1);

      await repository.load();

      expect(repository.nextId, 7);
    });

    test('cadastra no topo e avisa os ouvintes', () async {
      final repository = PropertyRepository(_instantService());
      await repository.load();
      var notifications = 0;
      repository.addListener(() => notifications++);
      final created = Property.fromJson({
        ...repository.findById(1)!.toJson(),
        'id': repository.nextId,
        'titulo': 'Casa Nova',
      });

      await repository.add(created);

      expect(repository.properties.first.title, 'Casa Nova');
      expect(repository.properties.length, 7);
      expect(repository.nextId, 8);
      expect(notifications, 1);
    });

    test('com erro ao cadastrar, a lista não muda', () async {
      final repository = PropertyRepository(_FailingSaveService());
      await repository.load();
      final created = Property.fromJson({
        ...repository.findById(1)!.toJson(),
        'id': repository.nextId,
      });

      await expectLater(repository.add(created), throwsException);

      expect(repository.properties.length, 6);
    });
  });

  group('PropertyRepository: estado do carregamento', () {
    test('falhou: loadFailed; tentar de novo com sucesso limpa', () async {
      final service = _FlakyService(failures: 1);
      final repository = PropertyRepository(service);

      await expectLater(repository.load(), throwsException);
      expect(repository.loadFailed, isTrue);
      expect(repository.isLoading, isFalse);

      await repository.load();

      expect(repository.loadFailed, isFalse);
      expect(repository.hasLoaded, isTrue);
    });

    test('duas cargas ao mesmo tempo viram uma só requisição', () async {
      final service = _FlakyService(failures: 0);
      final repository = PropertyRepository(service);

      await Future.wait([repository.load(), repository.load()]);

      expect(service.fetches, 1);
    });

    test('restaurar depois de uma carga que falhou mostra os dados', () async {
      final repository = PropertyRepository(_FlakyService(failures: 99));
      await expectLater(repository.load(), throwsException);

      await repository.resetToSample();

      expect(repository.loadFailed, isFalse);
      expect(repository.hasLoaded, isTrue);
      expect(repository.properties.length, 6);
    });
  });
}

/// Fails the first [failures] fetches, then works; counts the fetches.
class _FlakyService extends PropertyService {
  _FlakyService({required int failures})
    : _failuresLeft = failures,
      super(
        loadDelay: Duration.zero,
        saveDelay: Duration.zero,
        simulateError: false,
      );

  int _failuresLeft;
  int fetches = 0;

  @override
  Future<List<Map<String, dynamic>>> fetchProperties() async {
    fetches++;
    if (_failuresLeft > 0) {
      _failuresLeft--;
      throw Exception('Load failed');
    }
    return super.fetchProperties();
  }
}
