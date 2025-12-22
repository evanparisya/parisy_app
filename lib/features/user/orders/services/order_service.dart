// lib/features/user/orders/services/order_service.dart
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/features/user/orders/models/order_model.dart';
import 'package:parisy_app/features/user/transaction/models/transaction_model.dart';
import 'package:parisy_app/features/user/transaction/services/transaction_service.dart';

class OrderService {
  final ApiClient apiClient;
  late final TransactionService _transactionService;

  OrderService({required this.apiClient}) {
    _transactionService = TransactionService(apiClient: apiClient);
  }

  /// Get order/transaction history for logged in user
  /// Uses the transaction service to fetch from /transaction/history
  Future<List<OrderModel>> getOrderHistory(int userId) async {
    try {
      // Fetch transactions from the backend
      final transactions = await _transactionService.getTransactionHistory();

      // Convert TransactionModel list to OrderModel list
      return transactions.map((txn) => _convertToOrderModel(txn)).toList();
    } catch (e) {
      throw Exception('Error fetching order history: $e');
    }
  }

  /// Get order/transaction detail by ID
  Future<OrderModel> getOrderDetail(int orderId) async {
    try {
      final transaction = await _transactionService.getTransactionDetail(
        orderId,
      );
      return _convertToOrderModel(transaction);
    } catch (e) {
      throw Exception('Error fetching order detail: $e');
    }
  }

  /// Update order/transaction status
  Future<bool> updateOrderStatus({
    required int orderId,
    String? transactionStatus,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final request = UpdateTransactionRequest(
        transactionStatus: transactionStatus,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      return await _transactionService.updateTransaction(
        transactionId: orderId,
        request: request,
      );
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  /// Delete an order/transaction
  Future<bool> deleteOrder(int orderId) async {
    try {
      return await _transactionService.deleteTransaction(orderId);
    } catch (e) {
      throw Exception('Error deleting order: $e');
    }
  }

  /// Helper method to convert TransactionModel to OrderModel
  OrderModel _convertToOrderModel(TransactionModel txn) {
    return OrderModel(
      id: txn.id,
      code: txn.code,
      userId: txn.userId ?? 0,
      priceTotal: txn.totalPrice,
      statusTransaction: txn.transactionStatus,
      statusPayment: txn.paymentMethod,
      notes: txn.notes,
      createdAt: txn.createdAt ?? DateTime.now(),
      details: txn.items
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
  }

  /// Get transaction service instance for direct access if needed
  TransactionService get transactionService => _transactionService;
}
