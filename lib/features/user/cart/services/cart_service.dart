// lib/features/user/cart/services/cart_service.dart
import 'package:dio/dio.dart';
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/features/user/orders/models/order_model.dart';
import 'package:parisy_app/features/user/transaction/models/transaction_model.dart';
import 'package:parisy_app/features/user/transaction/services/transaction_service.dart';
import '../models/cart_model.dart';

class CartService {
  final ApiClient apiClient;
  late final TransactionService _transactionService;

  CartService({required this.apiClient}) {
    _transactionService = TransactionService(apiClient: apiClient);
  }

  // Melakukan Checkout/Pembuatan Transaksi
  // Mengembalikan OrderModel yang dibuat
  Future<OrderModel> checkout({required CheckoutRequest request}) async {
    try {
      // Convert CheckoutRequest to CreateTransactionRequest
      final transactionRequest = CreateTransactionRequest(
        totalPrice: request.priceTotal,
        paymentMethod: request.statusPayment,
        notes: request.notes,
        items: request.items
            .map(
              (item) => TransactionItemRequest(
                vegetableId: item['vegetable_id'] as int,
                quantity: item['quantity'] as int,
                unitPrice: (item['price_unit'] as num).toDouble(),
              ),
            )
            .toList(),
      );

      // Create transaction using the transaction service
      final response = await _transactionService.createTransaction(
        request: transactionRequest,
      );

      if (response.success && response.transactionId != null) {
        // Fetch the created transaction detail to get full order info
        final transactionDetail = await _transactionService
            .getTransactionDetail(response.transactionId!);

        // Convert TransactionModel to OrderModel for compatibility
        return OrderModel(
          id: transactionDetail.id,
          code: transactionDetail.code,
          userId: transactionDetail.userId ?? request.userId,
          priceTotal: transactionDetail.totalPrice,
          statusTransaction: transactionDetail.transactionStatus,
          statusPayment: transactionDetail.paymentMethod,
          notes: transactionDetail.notes,
          createdAt: transactionDetail.createdAt ?? DateTime.now(),
          details: transactionDetail.items
              .map(
                (item) => OrderDetailModel.fromJson({
                  'vegetable_id': item.vegetableId,
                  'vegetable_name': 'Produk #${item.vegetableId}',
                  'quantity': item.quantity,
                  'price_unit': item.unitPrice,
                  'subtotal': item.subtotal,
                }),
              )
              .toList(),
        );
      } else {
        throw Exception(response.message);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Checkout gagal';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      throw Exception('Checkout error: $e');
    }
  }

  /// Get transaction service instance for direct access if needed
  TransactionService get transactionService => _transactionService;
}
