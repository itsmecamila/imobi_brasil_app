import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/auth_repository.dart';
import 'package:imobi_app/data/services/auth_service.dart';
import 'package:imobi_app/ui/login/view_models/login_view_model.dart';

const _email = 'corretor@imobibrasil.com.br';
const _password = 'imobi2026';

(AuthRepository, LoginViewModel) _setup({bool simulateError = false}) {
  final repository = AuthRepository(
    AuthService(delay: Duration.zero, simulateError: simulateError),
  );
  return (repository, LoginViewModel(repository));
}

void main() {
  group('validação', () {
    test('e-mail obrigatório e com formato de e-mail', () {
      expect(LoginViewModel.validateEmail(' '), 'Informe o e-mail.');
      expect(
        LoginViewModel.validateEmail('corretor@imobibrasil'),
        'Informe um e-mail válido.',
      );
      expect(LoginViewModel.validateEmail(' $_email '), isNull);
    });

    test('senha obrigatória', () {
      expect(LoginViewModel.validatePassword(''), 'Informe a senha.');
      expect(LoginViewModel.validatePassword(_password), isNull);
    });
  });

  group('entrar', () {
    test('credenciais certas: entra, sem mensagem', () async {
      final (repository, viewModel) = _setup();
      final signingInStates = <bool>[];
      viewModel.addListener(() => signingInStates.add(viewModel.isSigningIn));

      final signedIn = await viewModel.signIn(_email, _password);

      expect(signedIn, isTrue);
      expect(repository.isSignedIn, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(signingInStates, [true, false]);
    });

    test('credenciais erradas: mensagem genérica', () async {
      final (repository, viewModel) = _setup();

      final signedIn = await viewModel.signIn(_email, 'errada');

      expect(signedIn, isFalse);
      expect(repository.isSignedIn, isFalse);
      expect(viewModel.errorMessage, 'E-mail ou senha incorretos.');
      expect(viewModel.isSigningIn, isFalse);
    });

    test('falha na chamada: mensagem para tentar de novo', () async {
      final (_, viewModel) = _setup(simulateError: true);

      await viewModel.signIn(_email, _password);

      expect(
        viewModel.errorMessage,
        'Não foi possível entrar agora. Tente de novo.',
      );
    });

    test('voltar a digitar apaga a mensagem antiga', () async {
      final (_, viewModel) = _setup();
      await viewModel.signIn(_email, 'errada');

      viewModel.clearError();

      expect(viewModel.errorMessage, isNull);
    });
  });
}
