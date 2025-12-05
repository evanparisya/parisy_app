import 'dart:async';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/order_model.dart';

/// Order Service - REST API with Stream for real-time updates
/// Demonstrates: Async ⏳ + RestAPI 🌐 + Stream 🌊 + JSON 📄
class OrderService {
  final ApiClient apiClient;

  // Enable mock mode for testing (set to false when backend is ready)
  static const bool useMockOrders = true;

  OrderService({required this.apiClient});

  /// Get all orders
  /// Demonstrates: Async ⏳ + RestAPI 🌐 + JSON 📄
  Future<List<OrderModel>> getAllOrders() async {
    if (useMockOrders) {
      return _mockGetAllOrders();
    }
    return _apiGetAllOrders();
  }

  /// Mock get all orders
  Future<List<OrderModel>> _mockGetAllOrders() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    final mockOrders = [
      OrderModel(
        id: 'ORD-2025-001',
        userId: 'USER-001',
        totalPrice: 15000000.0,
        status: 'delivered',
        items: [
          OrderItemModel(
            id: 'ITEM-001',
            productId: 'PROD-001',
            productName: 'Laptop Gaming ASUS ROG',
            quantity: 1,
            productPrice: 15000000.0,
          ),
        ],
        address: 'Jl. Merdeka No. 123, Jakarta',
        phoneNumber: '081234567890',
        createdAt: DateTime.now().subtract(Duration(days: 10)),
      ),
      OrderModel(
        id: 'ORD-2025-002',
        userId: 'USER-001',
        totalPrice: 9200000.0,
        status: 'processing',
        items: [
          OrderItemModel(
            id: 'ITEM-002',
            productId: 'PROD-002',
            productName: 'Smartphone Flagship',
            quantity: 1,
            productPrice: 8999000.0,
          ),
        ],
        address: 'Jl. Sudirman No. 456, Jakarta',
        phoneNumber: '081234567890',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
    ];

    return mockOrders;
  }

  /// Real API get all orders
  Future<List<OrderModel>> _apiGetAllOrders() async {
    try {
      final response = await apiClient.dio.get('/orders');

      if (response.statusCode == 200) {
        List<OrderModel> orders = [];
        for (var order in response.data['orders'] ?? []) {
          orders.add(OrderModel.fromJson(order));
        }
        return orders;
      } else {
        throw Exception('Failed to fetch orders');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching orders: ${e.message}');
    }
  }

  /// Get single order by ID
  /// Demonstrates: Async ⏳ + RestAPI 🌐 + JSON 📄
  Future<OrderModel> getOrderById(String orderId) async {
    if (useMockOrders) {
      return _mockGetOrderById(orderId);
    }
    return _apiGetOrderById(orderId);
  }

  /// Mock get order by ID
  Future<OrderModel> _mockGetOrderById(String orderId) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    final mockOrders = {
      'ORD-2025-001': OrderModel(
        id: 'ORD-2025-001',
        userId: 'USER-001',
        totalPrice: 15000000.0,
        status: 'delivered',
        items: [
          OrderItemModel(
            id: 'ITEM-001',
            productId: 'PROD-001',
            productName: 'Laptop Gaming ASUS ROG',
            quantity: 1,
            productPrice: 15000000.0,
          ),
        ],
        address: 'Jl. Merdeka No. 123, Jakarta',
        phoneNumber: '081234567890',
        createdAt: DateTime.now().subtract(Duration(days: 10)),
      ),
      'ORD-2025-002': OrderModel(
        id: 'ORD-2025-002',
        userId: 'USER-001',
        totalPrice: 9200000.0,
        status: 'processing',
        items: [
          OrderItemModel(
            id: 'ITEM-002',
            productId: 'PROD-002',
            productName: 'Smartphone Flagship',
            quantity: 1,
            productPrice: 8999000.0,
          ),
        ],
        address: 'Jl. Sudirman No. 456, Jakarta',
        phoneNumber: '081234567890',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
    };

    return mockOrders[orderId] ?? (throw Exception('Order not found'));
  }

  /// Real API get order by ID
  Future<OrderModel> _apiGetOrderById(String orderId) async {
    try {
      final response = await apiClient.dio.get('/orders/$orderId');

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch order');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching order: ${e.message}');
    }
  }

  /// Stream order status updates - Real-time updates
  /// Demonstrates: Stream 🌊 + Async ⏳ + RestAPI 🌐 + JSON 📄
  ///
  /// Emits status updates every 2 seconds
  /// Example: Pending → Processing → Shipped → Delivered
  Stream<OrderStatusUpdate> streamOrderStatus(String orderId) {
    /// Create stream that polls API every 2 seconds
    /// Demonstrates: Stream 🌊
    return Stream.periodic(Duration(seconds: 2), (count) => count).asyncMap((
      _,
    ) async {
      /// Each tick: fetch latest status from API
      /// Demonstrates: Async ⏳ + RestAPI 🌐
      try {
        final response = await apiClient.dio.get('/orders/$orderId/status');

        if (response.statusCode == 200) {
          /// Parse JSON response to model
          /// Demonstrates: JSON 📄
          return OrderStatusUpdate.fromJson(response.data);
        } else {
          throw Exception('Failed to fetch status');
        }
      } on DioException catch (e) {
        throw Exception('Error fetching status: ${e.message}');
      }
    });
  }

  /// Cancel order
  /// Demonstrates: Async ⏳ + RestAPI 🌐
  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await apiClient.dio.post('/orders/$orderId/cancel');

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel order');
      }
    } on DioException catch (e) {
      throw Exception('Error canceling order: ${e.message}');
    }
  }
}
