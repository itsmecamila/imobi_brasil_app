import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/property_repository.dart';
import 'package:imobi_app/data/services/property_service.dart';
import 'package:imobi_app/ui/property_detail/view_models/property_detail_view_model.dart';

PropertyRepository _repository() => PropertyRepository(
  PropertyService(
    loadDelay: Duration.zero,
    saveDelay: Duration.zero,
    simulateError: false,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PropertyDetailViewModel', () {
    test('fica "carregando" até o Repository carregar', () async {
      final repository = _repository();
      final viewModel = PropertyDetailViewModel(repository, 3);
      expect(viewModel.isLoading, isTrue);

      await repository.load();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.property?.title, 'Kitnet Universitária');
      expect(viewModel.isNotFound, isFalse);
    });

    test('marca "não encontrado" para um id que não existe', () async {
      final repository = _repository();
      await repository.load();

      final viewModel = PropertyDetailViewModel(repository, 999);

      expect(viewModel.isNotFound, isTrue);
      expect(viewModel.property, isNull);
    });

    test('abre WhatsApp, discador e e-mail com os links certos', () async {
      final repository = _repository();
      await repository.load();
      final opened = <Uri>[];
      final viewModel = PropertyDetailViewModel(
        repository,
        1,
        launcher: (uri) async {
          opened.add(uri);
          return true;
        },
      );

      await viewModel.openWhatsApp();
      await viewModel.call();
      await viewModel.sendEmail();

      expect(opened[0].host, 'wa.me');
      expect(opened[0].path, '/551800000000');
      expect(opened[0].queryParameters['text'], contains('Apartamento Centro'));
      expect(opened[1].toString(), 'tel:+551800000000');
      expect(opened[2].scheme, 'mailto');
      expect(opened[2].path, 'corretor@imobibrasil.com.br');
    });

    test('devolve falso quando o app de contato não abre', () async {
      final repository = _repository();
      await repository.load();
      final viewModel = PropertyDetailViewModel(
        repository,
        1,
        launcher: (uri) async => false,
      );

      expect(await viewModel.openWhatsApp(), isFalse);
    });
  });
}
