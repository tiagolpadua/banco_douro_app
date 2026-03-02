import 'package:banco_douro_app/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  bool _isLoggedIn = false;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  Future<void> init() async {
    _isLoggedIn = await _authService.isLoggedIn();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;

    try {
      await _authService.login(email, password);
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }

  void clearError() {
    if (_error == null) {
      return;
    }

    _error = null;
    notifyListeners();
  }
}
