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
  OrderModel? _selectedOrder;
  String? _errorMessage;

  OrderController({required this.orderService, required this.authController});

  // Getters
  OrderState get state => _state;
  List<OrderModel> get orderHistory => _orderHistory;
  OrderModel? get selectedOrder => _selectedOrder;
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

      _orderHistory = await orderService.getOrderHistory(userId);

      _state = OrderState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = OrderState.error;
      _errorMessage = _parseError(e);
    } finally {
      notifyListeners();
    }
  }

  /// Get order detail by ID
  Future<OrderModel?> getOrderDetail(int orderId) async {
    try {
      _state = OrderState.loading;
      _errorMessage = null;
      notifyListeners();

      _selectedOrder = await orderService.getOrderDetail(orderId);
      _state = OrderState.loaded;
      notifyListeners();
      return _selectedOrder;
    } catch (e) {
      _state = OrderState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return null;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus({
    required int orderId,
    String? transactionStatus,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      _state = OrderState.loading;
      _errorMessage = null;
      notifyListeners();

      final success = await orderService.updateOrderStatus(
        orderId: orderId,
        transactionStatus: transactionStatus,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      if (success) {
        // Reload order history after update
        await loadOrderHistory();
      }

      _state = OrderState.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _state = OrderState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Delete an order
  Future<bool> deleteOrder(int orderId) async {
    try {
      _state = OrderState.loading;
      _errorMessage = null;
      notifyListeners();

      final success = await orderService.deleteOrder(orderId);

      if (success) {
        // Remove from local list
        _orderHistory.removeWhere((o) => o.id == orderId);
        if (_selectedOrder?.id == orderId) {
          _selectedOrder = null;
        }
      }

      _state = OrderState.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _state = OrderState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Clear selected order
  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Parse error message
  String _parseError(dynamic e) {
    final errorStr = e.toString();
    if (errorStr.contains('Exception: ')) {
      return errorStr.substring(errorStr.indexOf('Exception: ') + 11);
    }
    return errorStr;
  }
}
