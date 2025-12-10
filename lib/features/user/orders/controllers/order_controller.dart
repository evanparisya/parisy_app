// lib/features/user/orders/controllers/order_controller.dart
import 'package:flutter/material.dart';
import 'package:parisy_app/features/auth/controllers/auth_controller.dart';
import 'package:parisy_app/features/user/orders/models/order_model.dart';
import 'package:parisy_app/features/user/orders/services/order_service.dart';

enum OrderState { initial, loading, loaded, error }

class OrderController extends ChangeNotifier {
  final OrderService orderService;
  final AuthController authController;

  OrderState _state = OrderState.initial;
  List<OrderModel> _orderHistory = [];
  String? _errorMessage;

  OrderController({required this.orderService, required this.authController});

  // Getters
  OrderState get state => _state;
  List<OrderModel> get orderHistory => _orderHistory;
  String? get errorMessage => _errorMessage;

  /// Load user's order history
  Future<void> loadOrderHistory() async {
    // Perbaikan Null Safety untuk akses ID
    final userId = authController.currentUser?.id; 
    if (userId == null) {
      _state = OrderState.error;
      _errorMessage = 'User ID tidak ditemukan. Harap login ulang.';
      notifyListeners();
      return;
    }

    try {
      _state = OrderState.loading;
      notifyListeners();
      
      _orderHistory = await orderService.getOrderHistory(userId); // Menggunakan userId yang sudah dicheck

      _state = OrderState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = OrderState.error;
      _errorMessage = e.toString().contains('Exception: ') ? e.toString().substring(11) : e.toString();
    } finally {
      notifyListeners();
    }
  }
}