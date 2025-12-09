// lib/features/user/orders/services/order_service.dart
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/features/user/orders/models/order_model.dart'; // Path diperiksa
import 'package:parisy_app/core/constants/app_constants.dart'; // Perlu diimpor untuk subRoleWarga

class OrderService {
  final ApiClient apiClient;
  static const bool useMock = true;

  OrderService({required this.apiClient});

  // --- MOCK DATA ---
  static List<OrderModel> _mockOrders = [
    OrderModel(
      id: 1, code: 'TRX-001', userId: 6, priceTotal: 45000.0,
      statusTransaction: 'paid', statusPayment: 'transfer', createdAt: DateTime(2025, 12, 5, 10, 30),
      details: [
        OrderDetailModel(vegetableId: 101, vegetableName: 'Bayam Merah Organik', quantity: 3, priceUnit: 15000, subtotal: 45000),
      ],
    ),
    OrderModel(
      id: 2, code: 'TRX-002', userId: 6, priceTotal: 22000.0,
      statusTransaction: 'pending', statusPayment: 'cash', createdAt: DateTime(2025, 12, 6, 11, 0),
      details: [
        OrderDetailModel(vegetableId: 102, vegetableName: 'Wortel Jumbo', quantity: 1, priceUnit: 22000, subtotal: 22000),
      ],
    ),
    OrderModel(
      id: 3, code: 'TRX-003', userId: 6, priceTotal: 18000.0,
      statusTransaction: 'failed', statusPayment: 'transfer', createdAt: DateTime(2025, 12, 7, 15, 45),
      details: [
        OrderDetailModel(vegetableId: 103, vegetableName: 'Tomat Cherry Manis', quantity: 1, priceUnit: 18000, subtotal: 18000),
      ],
    ),
  ];
  // --- END MOCK DATA ---
  
  // Mengambil riwayat pesanan berdasarkan ID user yang login
  Future<List<OrderModel>> getOrderHistory(int userId) async {
    if (useMock) {
      await Future.delayed(Duration(seconds: 1));
      // Menggunakan userId yang dilewatkan
      return List.from(_mockOrders.where((o) => o.userId == userId).toList().reversed); 
    }
    
    // Real API call
    try {
      // Endpoint diasumsikan /user/orders?user_id=...
      final response = await apiClient.dio.get('/user/orders', queryParameters: {'user_id': userId});
      
      if (response.statusCode == 200) {
        final List data = response.data['orders'] ?? [];
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil riwayat pesanan: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching order history: $e');
    }
  }
}// lib/features/user/orders/services/order_service.dart
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/features/user/orders/models/order_model.dart'; // Path diperiksa
import 'package:parisy_app/core/constants/app_constants.dart'; // Perlu diimpor untuk subRoleWarga

class OrderService {
  final ApiClient apiClient;
  static const bool useMock = true;

  OrderService({required this.apiClient});

  // --- MOCK DATA ---
  static List<OrderModel> _mockOrders = [
    OrderModel(
      id: 1, code: 'TRX-001', userId: 6, priceTotal: 45000.0,
      statusTransaction: 'paid', statusPayment: 'transfer', createdAt: DateTime(2025, 12, 5, 10, 30),
      details: [
        OrderDetailModel(vegetableId: 101, vegetableName: 'Bayam Merah Organik', quantity: 3, priceUnit: 15000, subtotal: 45000),
      ],
    ),
    OrderModel(
      id: 2, code: 'TRX-002', userId: 6, priceTotal: 22000.0,
      statusTransaction: 'pending', statusPayment: 'cash', createdAt: DateTime(2025, 12, 6, 11, 0),
      details: [
        OrderDetailModel(vegetableId: 102, vegetableName: 'Wortel Jumbo', quantity: 1, priceUnit: 22000, subtotal: 22000),
      ],
    ),
    OrderModel(
      id: 3, code: 'TRX-003', userId: 6, priceTotal: 18000.0,
      statusTransaction: 'failed', statusPayment: 'transfer', createdAt: DateTime(2025, 12, 7, 15, 45),
      details: [
        OrderDetailModel(vegetableId: 103, vegetableName: 'Tomat Cherry Manis', quantity: 1, priceUnit: 18000, subtotal: 18000),
      ],
    ),
  ];
  // --- END MOCK DATA ---
  
  // Mengambil riwayat pesanan berdasarkan ID user yang login
  Future<List<OrderModel>> getOrderHistory(int userId) async {
    if (useMock) {
      await Future.delayed(Duration(seconds: 1));
      // Menggunakan userId yang dilewatkan
      return List.from(_mockOrders.where((o) => o.userId == userId).toList().reversed); 
    }
    
    // Real API call
    try {
      // Endpoint diasumsikan /user/orders?user_id=...
      final response = await apiClient.dio.get('/user/orders', queryParameters: {'user_id': userId});
      
      if (response.statusCode == 200) {
        final List data = response.data['orders'] ?? [];
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil riwayat pesanan: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Error fetching order history: $e');
    }
  }
}