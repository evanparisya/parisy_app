import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';

/// Profile Controller - Manage user profile state
/// Demonstrates: State Management 🔄
class ProfileController extends ChangeNotifier {
  final AuthController authController;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileController({required this.authController}) {
    _loadUserProfile();
  }

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load user profile
  Future<void> _loadUserProfile() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get current user from AuthController
      _user = authController.currentUser;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_user != null) {
        _user = _user!.copyWith(name: name, phone: phone, address: address);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await authController.logout();
    _user = null;
    notifyListeners();
  }
}
