import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      _user = await _authService.getProfile();
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );

    if (result['success']) {
      _user = result['user'];
      _isLoggedIn = true;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    if (result['success']) {
      _user = result['user'];
      _isLoggedIn = true;
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _user = null;
    _isLoggedIn = false;

    _isLoading = false;
    notifyListeners();
  }
}
