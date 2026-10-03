import 'package:flutter_test/flutter_test.dart';
import 'package:imobi_app/data/repositories/auth_repository.dart';
import 'package:imobi_app/data/services/auth_service.dart';

AuthRepository instantAuth() =>
    AuthRepository(AuthService(delay: Duration.zero, simulateError: false));

/// Screens behind the login need a session to be tested.
Future<AuthRepository> signedInAuth(WidgetTester tester) async {
  final auth = instantAuth();
  await tester.runAsync(
    () => auth.signIn('corretor@imobibrasil.com.br', 'imobi2026'),
  );
  return auth;
}
