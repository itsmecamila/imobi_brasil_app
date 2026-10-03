import 'package:flutter/foundation.dart';
import 'package:imobi_app/data/services/auth_service.dart';
import 'package:imobi_app/domain/models/user.dart';

/// Source of truth for the session. The router listens to it to protect the
/// routes. The session lives only in memory: reopening the app asks for the
/// login again (no local persistence).
class AuthRepository extends ChangeNotifier {
  AuthRepository(this._service);

  final AuthService _service;
  User? _user;

  User? get user => _user;
  bool get isSignedIn => _user != null;

  /// Returns false for wrong credentials; throws when the request fails, so
  /// the screen can tell "check what you typed" from "try again later".
  Future<bool> signIn(String email, String password) async {
    final raw = await _service.signIn(email, password);
    if (raw == null) return false;
    _user = User.fromJson(raw);
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    notifyListeners();
  }
}
