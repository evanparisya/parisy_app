import 'package:flutter/material.dart';
import '../models/admin_user_model.dart';
import '../models/admin_product_model.dart';
import '../models/admin_transaction_model.dart';
import '../services/admin_service.dart';

enum AdminState { initial, loading, success, error }

class AdminController extends ChangeNotifier {
  final AdminService adminService;

  AdminState _state = AdminState.initial;
  String? _errorMessage;

  // Users/Residents
  List<AdminUserModel> _users = [];
  
  // Products
  List<AdminProductModel> _products = [];
  
  // Transactions
  List<AdminTransactionModel> _transactions = [];
  double _totalTransactions = 0;

  AdminController({required this.adminService});

  // Getters
  AdminState get state => _state;
  String? get errorMessage => _errorMessage;
  List<AdminUserModel> get users => _users;
  List<AdminProductModel> get products => _products;
  List<AdminTransactionModel> get transactions => _transactions;
  double get totalTransactions => _totalTransactions;

  // ==================== USERS MANAGEMENT ====================
  Future<void> loadUsers() async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      _users = await adminService.getAllUsers();

      _state = AdminState.success;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchUsers(String query) async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      if (query.isEmpty) {
        await loadUsers();
      } else {
        _users = await adminService.searchUsers(query);
        _state = AdminState.success;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addUser(AdminUserModel user) async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      await adminService.addUser(user);
      await loadUsers();

      return true;
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(AdminUserModel user) async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      await adminService.updateUser(user);
      await loadUsers();

      return true;
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      await adminService.deleteUser(userId);
      await loadUsers();

      return true;
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== PRODUCTS MANAGEMENT ====================
  Future<void> loadProducts() async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      _products = await adminService.getAllProducts();

      _state = AdminState.success;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      if (query.isEmpty) {
        await loadProducts();
      } else {
        _products = await adminService.searchProducts(query);
        _state = AdminState.success;
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> addProduct(AdminProductModel product) async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      await adminService.addProduct(product);
      await loadProducts();

      return true;
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(AdminProductModel product) async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      await adminService.updateProduct(product);
      await loadProducts();

      return true;
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      await adminService.deleteProduct(productId);
      await loadProducts();

      return true;
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== TRANSACTIONS MANAGEMENT ====================
  Future<void> loadTransactions() async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      _transactions = await adminService.getAllTransactions();
      _totalTransactions = await adminService.getTotalTransactionAmount();

      _state = AdminState.success;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> getUserTransactions(String userId) async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      _transactions = await adminService.getUserTransactions(userId);

      _state = AdminState.success;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> getTransactionsByType(String type) async {
    try {
      _state = AdminState.loading;
      notifyListeners();

      _transactions = await adminService.getTransactionsByType(type);

      _state = AdminState.success;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = AdminState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
