import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

/// Order State enum
/// Demonstrates: State Management 🔄
enum OrderState { initial, loading, loaded, error }

/// Order Controller - State Management with Stream subscription
/// Demonstrates: State Management 🔄 + Stream 🌊 + Async ⏳
class OrderController extends ChangeNotifier {
  final OrderService orderService;

  // State variables
  /// Demonstrates: State Management 🔄
  OrderState _state = OrderState.initial;
  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  String? _errorMessage;
  bool _isLoadingOrderStatus = false;

  // Stream subscription for real-time order status
  /// Demonstrates: Stream 🌊
  StreamSubscription<OrderStatusUpdate>? _statusSubscription;

  // Current order status being listened to
  Map<String, OrderStatusUpdate> _orderStatusMap = {};

  OrderController({required this.orderService});

  // Getters
  OrderState get state => _state;
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  String? get errorMessage => _errorMessage;
  bool get isLoadingOrderStatus => _isLoadingOrderStatus;

  /// Get current status for specific order
  OrderStatusUpdate? getOrderStatus(String orderId) {
    return _orderStatusMap[orderId];
  }

  // --- Utility Methods for UI (NEW) ---

  /// Get color based on status string
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Color(AppColors.statusDelivered);
      case 'shipped':
        return Color(AppColors.statusShipped);
      case 'processing':
        return Color(AppColors.statusProcessing);
      case 'pending':
        return Color(AppColors.statusPending);
      case 'cancelled':
        return Color(AppColors.statusCancelled);
      default:
        return Color(AppColors.primaryBlack);
    }
  }

  /// Get Indonesian label based on status string
  String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'TERKIRIM';
      case 'shipped':
      case 'shipping': // Assuming 'shipping' or 'shipped' maps to the same label
        return 'DIKIRIM';
      case 'processing':
        return 'DIPROSES';
      case 'pending':
        return 'MENUNGGU';
      case 'cancelled':
        return 'DIBATALKAN';
      default:
        return 'TIDAK DIKETAHUI';
    }
  }

  // --- End of Utility Methods for UI ---

  /// Load all orders
  /// Demonstrates: Async ⏳ + State Management 🔄
  Future<void> loadOrders() async {
    try {
      _state = OrderState.loading;
      notifyListeners(); // Notify UI: loading

      final orders = await orderService.getAllOrders();
      _orders = orders;
      _state = OrderState.loaded;
      _errorMessage = null;
      notifyListeners(); // Notify UI: data loaded
    } catch (e) {
      _state = OrderState.error;
      _errorMessage = e.toString();
      notifyListeners(); // Notify UI: error
    }
  }

  /// Get order detail
  /// Demonstrates: Async ⏳ + State Management 🔄
  Future<void> getOrderDetail(String orderId) async {
    try {
      _state = OrderState.loading;
      notifyListeners(); // Notify UI: loading

      final order = await orderService.getOrderById(orderId);
      _selectedOrder = order;
      _state = OrderState.loaded;
      _errorMessage = null;
      notifyListeners(); // Notify UI: data loaded
    } catch (e) {
      _state = OrderState.error;
      _errorMessage = e.toString();
      notifyListeners(); // Notify UI: error
    }
  }

  /// Listen to order status updates
  /// Demonstrates: Stream 🌊 + Async ⏳ + State Management 🔄
  void listenToOrderStatus(String orderId) {
    /// Cancel previous subscription if exists
    _statusSubscription?.cancel();

    try {
      // NOTE: We don't set _isLoadingOrderStatus = true here, as the initial 
      // load of OrderDetailScreen might rely on orderController.state == OrderState.loading.
      // We rely on the stream listener below to set it to false on the first data event.

      /// Subscribe to stream
      /// Demonstrates: Stream 🌊 + Async ⏳
      _statusSubscription = orderService
          .streamOrderStatus(orderId)
          .listen(
            (statusUpdate) {
              /// Stream emits new status
              /// Demonstrates: Stream 🌊 receiving data
              _orderStatusMap[orderId] = statusUpdate;
              _isLoadingOrderStatus = false; // Set to false when we get data
              notifyListeners(); // Notify UI: status updated

              print('Order $orderId status: ${statusUpdate.status}');
            },
            onError: (error) {
              /// Handle stream error
              _errorMessage = error.toString();
              _isLoadingOrderStatus = false; // Set to false on error
              notifyListeners(); // Notify UI: error
            },
          );
      
      // Set loading state *after* the stream starts, so the UI can show a loader 
      // while the first stream event is awaited.
      _isLoadingOrderStatus = true;
      notifyListeners();

    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingOrderStatus = false;
      notifyListeners();
    }
  }

  /// Cancel order
  /// Demonstrates: Async ⏳ + State Management 🔄
  Future<bool> cancelOrder(String orderId) async {
    try {
      // Set a generic loading state for the operation
      _isLoadingOrderStatus = true;
      notifyListeners(); // Notify UI: canceling

      await orderService.cancelOrder(orderId);
      
      // Manually update the map since the real-time stream might take a second to catch up
      _orderStatusMap[orderId] = OrderStatusUpdate(
        orderId: orderId,
        status: 'cancelled',
        timestamp: DateTime.now(),
      );
      
      _isLoadingOrderStatus = false;
      notifyListeners(); // Notify UI: cancelled

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingOrderStatus = false;
      notifyListeners(); // Notify UI: error
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    /// Important: Cancel stream subscription on dispose
    /// Demonstrates: Stream cleanup 🌊
    _statusSubscription?.cancel();
    super.dispose();
  }
}