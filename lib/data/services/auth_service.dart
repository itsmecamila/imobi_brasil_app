import 'dart:convert';

import 'package:imobi_app/config/broker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simulated sign-in API. There is no backend: the fixed test credentials
/// from the brief are checked locally, with the same latency and simulated
/// failure as the listings API. The session is kept on the device, so
/// reopening the app does not ask for the login again.
class AuthService {
  AuthService({
    this.storage,
    this.simulateError = const bool.fromEnvironment('SIMULATE_ERROR'),
    this.delay = const Duration(seconds: 1),
  });

  /// Where the session is kept. Without it (tests), it lasts only while the
  /// app is open.
  final SharedPreferencesAsync? storage;
  final bool simulateError;
  final Duration delay;

  static const _email = 'corretor@imobibrasil.com.br';
  static const _password = 'imobi2026';
  static const _sessionKey = 'sessao';

  /// Returns the user's raw API data, or null when the credentials are wrong.
  /// Throws when the (simulated) request fails.
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    await Future<void>.delayed(delay);
    if (simulateError) throw Exception('Simulated network error');

    // E-mail addresses are case-insensitive in practice; passwords are not.
    final matches =
        email.trim().toLowerCase() == _email && password == _password;
    if (!matches) return null;
    final user = {'nome': BrokerContact.name, 'email': _email};
    await storage?.setString(_sessionKey, jsonEncode(user));
    return user;
  }

  /// The user of the last session still open on this device, if any.
  Future<Map<String, dynamic>?> savedSession() async {
    final saved = await storage?.getString(_sessionKey);
    return saved == null ? null : jsonDecode(saved) as Map<String, dynamic>;
  }

  /// Same latency as signing in. It never fails: the session is local, so
  /// leaving must always work, even with simulated errors on.
  Future<void> signOut() async {
    await Future<void>.delayed(delay);
    await storage?.remove(_sessionKey);
  }
}
