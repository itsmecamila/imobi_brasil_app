import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/services/auth_service.dart';

AuthService _service({bool simulateError = false}) =>
    AuthService(delay: Duration.zero, simulateError: simulateError);

void main() {
  group('AuthService.signIn', () {
    test('credenciais do enunciado devolvem o usuário, sem traduzir', () async {
      final raw = await _service().signIn(
        'corretor@imobibrasil.com.br',
        'imobi2026',
      );

      expect(raw, {
        'nome': 'Corretor ImobiBrasil',
        'email': 'corretor@imobibrasil.com.br',
      });
    });

    test('e-mail ignora maiúsculas e espaços; senha não', () async {
      final service = _service();

      expect(
        await service.signIn('  Corretor@ImobiBrasil.com.br ', 'imobi2026'),
        isNotNull,
      );
      expect(
        await service.signIn('corretor@imobibrasil.com.br', 'IMOBI2026'),
        isNull,
      );
    });

    test('credenciais erradas devolvem null', () async {
      expect(await _service().signIn('outro@email.com', 'imobi2026'), isNull);
    });

    test('com erro simulado, a chamada falha', () async {
      await expectLater(
        _service(simulateError: true)
            .signIn('corretor@imobibrasil.com.br', 'imobi2026'),
        throwsException,
      );
    });
  });
}
