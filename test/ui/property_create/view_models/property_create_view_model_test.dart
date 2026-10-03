import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/ui/property_create/view_models/property_create_view_model.dart';
import 'package:imobi_app/ui/property_form/view_models/property_form.dart';

/// Loads normally; saving fails when [failSave] is true.
class _FakeService extends PropertyService {
  _FakeService({this.failSave = false})
    : super(
        loadDelay: Duration.zero,
        saveDelay: Duration.zero,
        simulateError: false,
      );

  final bool failSave;

  @override
  Future<void> saveProperty(Map<String, dynamic> json) async {
    if (failSave) throw Exception('Save failed');
  }
}

Future<(PropertyRepository, PropertyCreateViewModel)> _loaded({
  bool failSave = false,
}) async {
  final repository = PropertyRepository(_FakeService(failSave: failSave));
  await repository.load();
  return (repository, PropertyCreateViewModel(repository));
}

const _filled = PropertyForm(
  title: 'Casa Nova',
  description: '',
  type: PropertyType.sale,
  price: 'R\$ 350.000,00',
  city: 'Presidente Prudente',
  neighborhood: 'Centro',
  bedrooms: '3',
  bathrooms: '',
  parkingSpaces: '',
  area: '120',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fica carregando até o Repository ter os imóveis', () async {
    final repository = PropertyRepository(_FakeService());
    final viewModel = PropertyCreateViewModel(repository);
    expect(viewModel.isLoading, isTrue);

    await repository.load();

    expect(viewModel.isLoading, isFalse);
  });

  test('só pede confirmação ao sair se algo foi preenchido', () async {
    final (_, viewModel) = await _loaded();

    expect(viewModel.hasChanges(const PropertyForm.blank()), isFalse);
    expect(viewModel.hasChanges(_filled), isTrue);
  });

  group('salvar', () {
    test('cadastra no topo com o próximo id e foto provisória', () async {
      final (repository, viewModel) = await _loaded();

      final created = await viewModel.save(_filled);

      expect(created!.id, 7);
      expect(created.photoUrl, 'https://picsum.photos/seed/imovel-7/600/400');
      expect(created.price, 350000);
      expect(created.bathrooms, 0);
      expect(repository.properties.first.title, 'Casa Nova');
      expect(viewModel.isSaving, isFalse);
    });

    test('com erro, devolve null e a lista não muda', () async {
      final (repository, viewModel) = await _loaded(failSave: true);

      final created = await viewModel.save(_filled);

      expect(created, isNull);
      expect(repository.properties.length, 6);
      expect(viewModel.isSaving, isFalse);
    });
  });
}
