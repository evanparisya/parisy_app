import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthController extends ChangeNotifier {
  final AuthService authService;

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  UserModel? _currentUser;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _currentUser != null;

  AuthController({required this.authService}) {
    _checkAuthentication();
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(AuthState.error);
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _setState(AuthState.initial);
    }
  }

  // Check authentication on init
  Future<void> _checkAuthentication() async {
    final isLoggedIn = await authService.isLoggedIn();
    if (isLoggedIn) {
      await _loadUserFromPrefs();
      if (_currentUser != null) {
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } else {
      _setState(AuthState.unauthenticated);
    }
  }

  // Load user from SharedPreferences
  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        final userData = json.decode(userJson);
        _currentUser = UserModel.fromJson(userData);
      }
    } catch (e) {
      _currentUser = null;
    }
  }

  // Login
  Future<void> login({required String email, required String password}) async {
    _setState(AuthState.loading);
    _errorMessage = null;

    final result = await authService.login(email, password);

    if (result['success']) {
      // Load user data
      await _loadUserFromPrefs();
      _setState(AuthState.authenticated);
    } else {
      _setError(result['message'] ?? 'Login gagal');
    }
  }

  // Register
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);
    _errorMessage = null;

    final result = await authService.register(name, email, password);

    if (result['success']) {
      // After successful registration, return to initial state
      // User should login with their credentials
      _setState(AuthState.initial);
    } else {
      _setError(result['message'] ?? 'Registrasi gagal');
    }
  }

  // Logout
  Future<void> logout() async {
    await authService.logout();
    _currentUser = null;
    _setState(AuthState.unauthenticated);
  }

  // Check auth
  Future<bool> isLoggedIn() async {
    return await authService.isLoggedIn();
  }
}
