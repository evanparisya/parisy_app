import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../models/cart_model.dart';

/// Cart Service - REST API for checkout
/// Demonstrates: Async ⏳ + RestAPI 🌐 + JSON 📄
class CartService {
  final ApiClient apiClient;
  
  // Enable mock mode for testing (set to false when backend is ready)
  static const bool useMockCart = true;

  CartService({required this.apiClient});

  /// Checkout cart items
  /// Demonstrates: Async ⏳ + RestAPI 🌐 + JSON 📄
  ///
  /// API Call:
  ///   POST /cart/checkout
  ///   Body: CheckoutRequest.toJson()
  Future<CheckoutResponse> checkout(CheckoutRequest request) async {
    if (useMockCart) {
      return _mockCheckout(request);
    }
    return _apiCheckout(request);
  }

  /// Mock checkout
  Future<CheckoutResponse> _mockCheckout(CheckoutRequest request) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    // Generate mock order ID
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    return CheckoutResponse(
      orderId: orderId,
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  /// Real API checkout
  Future<CheckoutResponse> _apiCheckout(CheckoutRequest request) async {
    try {
      /// Demonstrates: JSON serialization ✅
      final response = await apiClient.dio.post(
        '/cart/checkout',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        /// Demonstrates: JSON deserialization ✅
        return CheckoutResponse.fromJson(response.data);
      } else {
        throw Exception('Checkout failed');
      }
    } on DioException catch (e) {
      throw Exception('Error during checkout: ${e.message}');
    }
  }
}
