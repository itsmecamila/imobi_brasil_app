import 'package:flutter/foundation.dart';
import 'package:imobi_app/data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._repository);

  final AuthRepository _repository;
  bool _isSigningIn = false;
  String? _errorMessage;

  bool get isSigningIn => _isSigningIn;

  /// Result of the last attempt, shown below the button.
  String? get errorMessage => _errorMessage;

  /// Typing again makes the old attempt's message stale.
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Returns whether it signed in. The router takes the user to the list on
  /// its own, because it listens to the session.
  Future<bool> signIn(String email, String password) async {
    _isSigningIn = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final signedIn = await _repository.signIn(email, password);
      // Generic on purpose: saying which field is wrong would reveal which
      // e-mails have an account (OWASP authentication guidance).
      if (!signedIn) _errorMessage = 'E-mail ou senha incorretos.';
      return signedIn;
    } catch (_) {
      _errorMessage = 'Não foi possível entrar agora. Tente de novo.';
      return false;
    } finally {
      _isSigningIn = false;
      notifyListeners();
    }
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe o e-mail.';
    return _emailShape.hasMatch(email) ? null : 'Informe um e-mail válido.';
  }

  static String? validatePassword(String? value) =>
      (value == null || value.isEmpty) ? 'Informe a senha.' : null;
}

/// Only the shape (something@domain.ext), to catch typos before the request;
/// whether the address exists is the server's job.
final _emailShape = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
