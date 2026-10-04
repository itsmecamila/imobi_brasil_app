import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/auth_repository.dart';
import 'package:imobi_app/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

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

  group('sessão guardada no aparelho', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    AuthRepository withStorage() => AuthRepository(
      AuthService(
        storage: SharedPreferencesAsync(),
        delay: Duration.zero,
        simulateError: false,
      ),
    );

    test('ao "reabrir o app", continua logado', () async {
      await withStorage().signIn('corretor@imobibrasil.com.br', 'imobi2026');

      final reopened = withStorage();
      await reopened.restoreSession();

      expect(reopened.isSignedIn, isTrue);
      expect(reopened.user!.name, 'Corretor ImobiBrasil');
    });

    test('depois de sair, reabrir pede o login', () async {
      final repository = withStorage();
      await repository.signIn('corretor@imobibrasil.com.br', 'imobi2026');
      await repository.signOut();

      final reopened = withStorage();
      await reopened.restoreSession();

      expect(reopened.isSignedIn, isFalse);
    });

    test('sessão guardada ilegível: pede o login e é apagada', () async {
      for (final damaged in ['não é JSON', '{"outro": 1}', '[1, 2]']) {
        await SharedPreferencesAsync().setString('sessao', damaged);

        final reopened = withStorage();
        await reopened.restoreSession();

        expect(reopened.isSignedIn, isFalse, reason: damaged);
        expect(await SharedPreferencesAsync().getString('sessao'), isNull);
      }
    });

    test('credencial errada não guarda sessão', () async {
      await withStorage().signIn('corretor@imobibrasil.com.br', 'errada');

      final reopened = withStorage();
      await reopened.restoreSession();

      expect(reopened.isSignedIn, isFalse);
    });
  });
}
