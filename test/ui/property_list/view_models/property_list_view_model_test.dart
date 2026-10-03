import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/domain/models/property.dart';
import 'package:imobi_app/ui/property_list/view_models/property_list_view_model.dart';

PropertyRepository _repository({bool simulateError = false}) =>
    PropertyRepository(
      PropertyService(
        loadDelay: Duration.zero,
        saveDelay: Duration.zero,
        simulateError: simulateError,
      ),
    );

Future<PropertyListViewModel> _loadedViewModel() async {
  final viewModel = PropertyListViewModel(_repository());
  await viewModel.load();
  return viewModel;
}

List<String> _titles(PropertyListViewModel viewModel) =>
    viewModel.visibleProperties.map((property) => property.title).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PropertyListViewModel', () {
    test('carrega os imóveis e desliga o "carregando"', () async {
      final viewModel = PropertyListViewModel(_repository());
      final loadingStates = <bool>[];
      viewModel.addListener(() => loadingStates.add(viewModel.isLoading));

      await viewModel.load();

      // The repository also notifies mid-load, so check only the edges.
      expect(loadingStates.first, isTrue);
      expect(loadingStates.last, isFalse);
      expect(viewModel.hasError, isFalse);
      expect(viewModel.visibleProperties.length, 6);
    });

    test('marca erro quando o carregamento falha', () async {
      final viewModel = PropertyListViewModel(_repository(simulateError: true));

      await viewModel.load();

      expect(viewModel.hasError, isTrue);
      expect(viewModel.isLoading, isFalse);
    });

    test('filtro Aluguel mostra só os imóveis de aluguel', () async {
      final viewModel = await _loadedViewModel();

      viewModel.selectFilter(PropertyFilter.rent);

      expect(viewModel.visibleProperties.length, 3);
      expect(
        viewModel.visibleProperties.every(
          (property) => property.type == PropertyType.rent,
        ),
        isTrue,
      );
    });

    test('busca ignora maiúsculas e acentos', () async {
      final viewModel = await _loadedViewModel();

      viewModel.search('  UNIVERSITARIA ');

      expect(_titles(viewModel), ['Kitnet Universitária']);
    });

    test('busca também pela cidade', () async {
      final viewModel = await _loadedViewModel();

      viewModel.search('prudente');

      expect(viewModel.visibleProperties.length, 6);
    });

    test('filtro e busca juntos podem não ter resultado', () async {
      final viewModel = await _loadedViewModel();

      viewModel
        ..selectFilter(PropertyFilter.sale)
        ..search('centro');

      expect(viewModel.visibleProperties, isEmpty);
      expect(viewModel.hasNoProperties, isFalse);
    });

    test('avisa a tela quando o Repository atualiza um imóvel', () async {
      final repository = _repository();
      final viewModel = PropertyListViewModel(repository);
      await viewModel.load();
      var notifications = 0;
      viewModel.addListener(() => notifications++);

      final edited = Property.fromJson({
        ...repository.findById(1)!.toJson(),
        'titulo': 'Apartamento Centro Reformado',
      });
      await repository.update(edited);

      expect(notifications, 1);
      expect(_titles(viewModel).first, 'Apartamento Centro Reformado');
    });
  });

  group('PropertyListViewModel.reveal', () {
    test('imóvel escondido pela busca ou filtro: limpa os dois', () async {
      final viewModel = await _loadedViewModel();
      final rent = viewModel.visibleProperties.firstWhere(
        (property) => property.type == PropertyType.rent,
      );
      viewModel
        ..selectFilter(PropertyFilter.sale)
        ..search('centro');

      final cleared = viewModel.reveal(rent);

      expect(cleared, isTrue);
      expect(viewModel.query, isEmpty);
      expect(viewModel.filter, PropertyFilter.all);
    });

    test('imóvel já visível: mantém busca e filtro', () async {
      final viewModel = await _loadedViewModel();
      viewModel
        ..selectFilter(PropertyFilter.rent)
        ..search('centro');

      final cleared = viewModel.reveal(viewModel.visibleProperties.first);

      expect(cleared, isFalse);
      expect(viewModel.query, 'centro');
      expect(viewModel.filter, PropertyFilter.rent);
    });
  });

  group('PropertyListViewModel.restoreSample', () {
    test('volta aos dados de exemplo e mostra todos', () async {
      final repository = _repository();
      final viewModel = PropertyListViewModel(repository);
      await viewModel.load();
      await repository.update(
        Property.fromJson({
          ...repository.findById(1)!.toJson(),
          'titulo': 'Editado',
        }),
      );
      viewModel
        ..selectFilter(PropertyFilter.sale)
        ..search('editado');

      final restored = await viewModel.restoreSample();

      expect(restored, isTrue);
      expect(repository.findById(1)!.title, 'Apartamento Centro');
      expect(viewModel.query, isEmpty);
      expect(viewModel.filter, PropertyFilter.all);
      expect(viewModel.visibleProperties.length, 6);
      expect(viewModel.isLoading, isFalse);
    });

    test('com erro, os imóveis atuais continuam', () async {
      final repository = PropertyRepository(_FailingResetService());
      final viewModel = PropertyListViewModel(repository);
      await viewModel.load();
      viewModel.search('kitnet');

      final restored = await viewModel.restoreSample();

      expect(restored, isFalse);
      expect(viewModel.hasError, isFalse);
      expect(viewModel.query, 'kitnet');
      expect(viewModel.visibleProperties.length, 1);
    });
  });
}

/// Loads normally but cannot restore the sample data.
class _FailingResetService extends PropertyService {
  _FailingResetService()
    : super(
        loadDelay: Duration.zero,
        saveDelay: Duration.zero,
        simulateError: false,
      );

  @override
  Future<void> resetToSample() async => throw Exception('Reset failed');
}
