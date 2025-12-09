// lib/features/user/cart/services/cart_service.dart
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/features/user/orders/models/order_model.dart';
import '../models/cart_model.dart';

class CartService {
  final ApiClient apiClient;
  static const bool useMock = true;

  CartService({required this.apiClient});

  // Melakukan Checkout/Pembuatan Transaksi
  // Mengembalikan OrderModel yang dibuat
  Future<OrderModel> checkout({
    required CheckoutRequest request,
  }) async {
    if (useMock) {
      await Future.delayed(Duration(seconds: 2));
      // Simulate success and return a mock OrderModel (matching DBML transactions)
      return OrderModel(
        id: DateTime.now().millisecondsSinceEpoch,
        code: 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        userId: request.userId,
        priceTotal: request.priceTotal,
        statusTransaction: 'pending', 
        statusPayment: request.statusPayment,
        notes: request.notes,
        createdAt: DateTime.now(),
        // Detail transaksi disimulasikan dari request item
        details: request.items.map((item) => OrderDetailModel.fromJson({
          'vegetable_id': item['vegetable_id'],
          'vegetable_name': 'Mock Sayur ${item['vegetable_id']}',
          'quantity': item['quantity'],
          'price_unit': item['price_unit'],
          'subtotal': item['subtotal'],
        })).toList(),
      );
    }
    
    // Real API call
    try {
      final response = await apiClient.dio.post(
        '/transactions/checkout',
        data: request.toJson(),
      );
      
      if (response.statusCode == 201) {
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception('Checkout failed: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('Checkout error: $e');
    }
  }
}