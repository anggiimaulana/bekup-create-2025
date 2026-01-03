import 'package:flutter/foundation.dart';
import '../models/story.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  String? _token;
  String? _userId;
  String? _userName;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // Check authentication status on app start
  Future<void> checkAuthStatus() async {
    _state = AuthState.loading;
    notifyListeners();

    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final userInfo = await _authService.getUserInfo();
      _token = userInfo['token'];
      _userId = userInfo['userId'];
      _userName = userInfo['userName'];
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.login(email, password);

    if (result['success']) {
      final LoginResult loginResult = result['loginResult'];
      await _authService.saveLoginSession(
        loginResult.token,
        loginResult.userId,
        loginResult.name,
      );

      _token = loginResult.token;
      _userId = loginResult.userId;
      _userName = loginResult.name;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register(String name, String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.register(name, email, password);

    if (result['success']) {
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _userId = null;
    _userName = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}
