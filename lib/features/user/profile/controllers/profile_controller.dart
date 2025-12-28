// lib/features/user/profile/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:parisy_app/features/auth/models/user_model.dart';
import 'package:parisy_app/features/auth/controllers/auth_controller.dart';

/// Profile Controller - Manage user profile state
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

  /// Update user profile (Partial update of UserModel)
  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    // In a real app, this would call an API via a ProfileService.
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_user != null) {
        // Simulasi update di AuthController untuk sinkronisasi state global
        final updatedUser = _user!.copyWith(name: name, phone: phone, address: address);
        
        // Memanggil AuthController untuk sinkronisasi state global
        // Asumsi: AuthController memiliki metode updateCurrentUser
        // (Anda harus menambahkan metode ini secara manual di AuthController jika belum ada)
        // authController.updateCurrentUser(updatedUser); 
        
        _user = updatedUser;
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