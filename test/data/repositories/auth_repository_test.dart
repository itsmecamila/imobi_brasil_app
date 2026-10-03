import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/auth_repository.dart';
import 'package:imobi_app/data/services/auth_service.dart';

AuthRepository _repository({bool simulateError = false}) => AuthRepository(
  AuthService(delay: Duration.zero, simulateError: simulateError),
);

void main() {
  group('AuthRepository', () {
    test('começa sem ninguém logado', () {
      expect(_repository().isSignedIn, isFalse);
    });

    test('entra com as credenciais certas e avisa os ouvintes', () async {
      final repository = _repository();
      var notifications = 0;
      repository.addListener(() => notifications++);

      final signedIn = await repository.signIn(
        'corretor@imobibrasil.com.br',
        'imobi2026',
      );

      expect(signedIn, isTrue);
      expect(repository.isSignedIn, isTrue);
      expect(repository.user!.name, 'Corretor ImobiBrasil');
      expect(notifications, 1);
    });

    test('credenciais erradas: devolve false e continua deslogado', () async {
      final repository = _repository();

      final signedIn = await repository.signIn(
        'corretor@imobibrasil.com.br',
        'errada',
      );

      expect(signedIn, isFalse);
      expect(repository.isSignedIn, isFalse);
    });

    test('falha na chamada: lança erro e continua deslogado', () async {
      final repository = _repository(simulateError: true);

      await expectLater(
        repository.signIn('corretor@imobibrasil.com.br', 'imobi2026'),
        throwsException,
      );
      expect(repository.isSignedIn, isFalse);
    });

    test('sair limpa o usuário e avisa os ouvintes', () async {
      final repository = _repository();
      await repository.signIn('corretor@imobibrasil.com.br', 'imobi2026');
      var notifications = 0;
      repository.addListener(() => notifications++);

      await repository.signOut();

      expect(repository.isSignedIn, isFalse);
      expect(repository.user, isNull);
      expect(notifications, 1);
    });
  });
}
