import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Auth State enum
/// Demonstrates: State Management 🔄
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// Auth Controller - State Management with Provider + ChangeNotifier
/// Demonstrates: State Management 🔄 + Async ⏳ + RestAPI 🌐
class AuthController extends ChangeNotifier {
  final AuthService authService;

  // State variables
  /// Demonstrates: State Management 🔄
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
  /// Demonstrates: Async ⏳ + State Management 🔄 + RestAPI 🌐 + JSON 📄
  ///
  /// Flow:
  ///   1. Set state to loading, notify UI
  ///   2. Call async API (restAPI 🌐 via authService.login())
  ///   3. Parse JSON response with UserModel.fromJson()
  ///   4. Save token to api client
  ///   5. Update state to authenticated, notify UI
  Future<bool> login({required String email, required String password}) async {
    try {
      /// Demonstrates: State Management 🔄
      _state = AuthState.loading;
      notifyListeners(); // Notify UI: loading

      /// Demonstrates: Async ⏳ + RestAPI 🌐 + JSON 📄
      /// Calls: POST /auth/login with email & password
      final response = await authService.login(
        email: email,
        password: password,
      );

      _token = response.token;
      _currentUser = response.user;
      authService.apiClient.setToken(_token!);

      /// Demonstrates: State Management 🔄
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners(); // Notify UI: logged in

      return true;
    } catch (e) {
      /// Demonstrates: State Management 🔄 - error state
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners(); // Notify UI: error
      return false;
    }
  }

  /// Register user
  /// Demonstrates: Async ⏳ + State Management 🔄 + RestAPI 🌐 + JSON 📄
  ///
  /// Similar to login but with additional name parameter
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      /// Demonstrates: State Management 🔄
      _state = AuthState.loading;
      notifyListeners(); // Notify UI: loading

      /// Demonstrates: Async ⏳ + RestAPI 🌐 + JSON 📄
      /// Calls: POST /auth/register with email, password, name
      final response = await authService.register(
        email: email,
        password: password,
        name: name,
      );

      _token = response.token;
      _currentUser = response.user;
      authService.apiClient.setToken(_token!);

      /// Demonstrates: State Management 🔄
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners(); // Notify UI: registered & logged in

      return true;
    } catch (e) {
      /// Demonstrates: State Management 🔄 - error state
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners(); // Notify UI: error
      return false;
    }
  }

  /// Logout user
  /// Demonstrates: Async ⏳ + State Management 🔄 + RestAPI 🌐
  Future<void> logout() async {
    try {
      /// Demonstrates: State Management 🔄
      _state = AuthState.loading;
      notifyListeners(); // Notify UI: loading

      /// Demonstrates: Async ⏳ + RestAPI 🌐
      /// Calls: POST /auth/logout
      await authService.logout();

      _token = null;
      _currentUser = null;

      /// Demonstrates: State Management 🔄
      _state = AuthState.unauthenticated;
      _errorMessage = null;
      notifyListeners(); // Notify UI: logged out
    } catch (e) {
      /// Demonstrates: State Management 🔄 - error state
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners(); // Notify UI: error
    }
  }

  /// Verify and restore token
  /// Demonstrates: Async ⏳ + State Management 🔄 + RestAPI 🌐 + JSON 📄
  Future<void> verifyToken(String token) async {
    try {
      /// Demonstrates: State Management 🔄
      _state = AuthState.loading;
      notifyListeners(); // Notify UI: verifying

      authService.apiClient.setToken(token);
      _token = token;

      /// Demonstrates: Async ⏳ + RestAPI 🌐 + JSON 📄
      /// Calls: GET /auth/verify with token header
      final user = await authService.verifyToken();
      _currentUser = user;

      /// Demonstrates: State Management 🔄
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners(); // Notify UI: verified & restored
    } catch (e) {
      /// Demonstrates: State Management 🔄 - unauthenticated state
      _state = AuthState.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners(); // Notify UI: not authenticated
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
