import 'package:imobi_app/config/broker.dart';

/// Simulated sign-in API. There is no backend: the fixed test credentials
/// from the brief are checked locally, with the same latency and simulated
/// failure as the listings API.
class AuthService {
  AuthService({
    this.simulateError = const bool.fromEnvironment('SIMULATE_ERROR'),
    this.delay = const Duration(seconds: 1),
  });

  final bool simulateError;
  final Duration delay;

  static const _email = 'corretor@imobibrasil.com.br';
  static const _password = 'imobi2026';

  /// Returns the user's raw API data, or null when the credentials are wrong.
  /// Throws when the (simulated) request fails.
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    await Future<void>.delayed(delay);
    if (simulateError) throw Exception('Simulated network error');

    // E-mail addresses are case-insensitive in practice; passwords are not.
    final matches =
        email.trim().toLowerCase() == _email && password == _password;
    if (!matches) return null;
    return {'nome': BrokerContact.name, 'email': _email};
  }
}
