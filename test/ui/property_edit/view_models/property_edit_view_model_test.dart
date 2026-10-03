import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/ui/property_edit/view_models/property_edit_view_model.dart';
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

Future<PropertyEditViewModel> _viewModel({bool failSave = false}) async {
  final repository = PropertyRepository(_FakeService(failSave: failSave));
  await repository.load();
  return PropertyEditViewModel(repository, 2);
}

/// The draft of listing 2 ("Casa Jardim Bongiovani") with some fields changed.
PropertyForm _form(
  PropertyEditViewModel viewModel, {
  String? price,
  String? bedrooms,
  String? area,
}) {
  final draft = PropertyForm.fromProperty(viewModel.original!);
  return PropertyForm(
    title: draft.title,
    description: draft.description,
    type: draft.type,
    price: price ?? draft.price,
    city: draft.city,
    neighborhood: draft.neighborhood,
    bedrooms: bedrooms ?? draft.bedrooms,
    bathrooms: draft.bathrooms,
    parkingSpaces: draft.parkingSpaces,
    area: area ?? draft.area,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('rascunho', () {
    test('converte os textos do formulário num imóvel', () async {
      final viewModel = await _viewModel();

      final property = viewModel.toProperty(
        _form(viewModel, price: 'R\$ 1.800,50', bedrooms: '', area: '65,5'),
      );

      expect(property.price, 1800.5);
      expect(property.bedrooms, 0);
      expect(property.area, 65.5);
      expect(property.type, PropertyType.sale);
    });

    test('sem mudanças ao abrir; com mudanças depois de editar', () async {
      final viewModel = await _viewModel();

      expect(viewModel.hasChanges(_form(viewModel)), isFalse);
      expect(viewModel.hasChanges(_form(viewModel, bedrooms: '4')), isTrue);
    });
  });

  group('salvar', () {
    test('com sucesso atualiza o imóvel', () async {
      final viewModel = await _viewModel();

      final saved = await viewModel.save(_form(viewModel, bedrooms: '4'));

      expect(saved, isTrue);
      expect(viewModel.original!.bedrooms, 4);
      expect(viewModel.isSaving, isFalse);
    });

    test('com erro devolve falso e o imóvel continua o original', () async {
      final viewModel = await _viewModel(failSave: true);

      final saved = await viewModel.save(_form(viewModel, bedrooms: '4'));

      expect(saved, isFalse);
      expect(viewModel.original!.bedrooms, 3);
      expect(viewModel.isSaving, isFalse);
    });
  });
}
