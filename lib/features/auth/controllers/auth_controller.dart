// lib/features/auth/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Auth State enum
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Auth Controller - State Management
class AuthController extends ChangeNotifier {
  final AuthService authService;

  AuthState _state = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  String? _token;

  AuthController({required this.authService});

  // Getters
  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get token => _token;
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Login user
  Future<bool> login({required String email, required String password}) async {
    try {
      _state = AuthState.loading;
      notifyListeners();

      final response = await authService.login(
        email: email,
        password: password,
      );

      _token = response.token;
      _currentUser = response.user;
      authService.apiClient.setToken(_token!);

      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().contains('Exception: ') ? e.toString().substring(11) : e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Register user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _state = AuthState.loading;
      notifyListeners();

      final response = await authService.register(
        email: email,
        password: password,
        name: name,
      );

      _token = response.token;
      _currentUser = response.user;
      authService.apiClient.setToken(_token!);

      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();

      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().contains('Exception: ') ? e.toString().substring(11) : e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _state = AuthState.loading;
      notifyListeners();

      await authService.logout();

      _token = null;
      _currentUser = null;

      _state = AuthState.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Verify and restore token
  Future<void> verifyToken(String token) async {
    try {
      _state = AuthState.loading;
      notifyListeners();

      authService.apiClient.setToken(token);
      _token = token;

      final user = await authService.verifyToken();
      _currentUser = user;

      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = AuthState.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}