// lib/features/user/transaction/controllers/transaction_controller.dart
import 'package:flutter/material.dart';
import 'package:parisy_app/features/user/transaction/models/transaction_model.dart';
import 'package:parisy_app/features/user/transaction/services/transaction_service.dart';

enum TransactionState { initial, loading, loaded, error }

class TransactionController extends ChangeNotifier {
  final TransactionService transactionService;

  TransactionState _state = TransactionState.initial;
  List<TransactionModel> _transactions = [];
  TransactionModel? _selectedTransaction;
  String? _errorMessage;

  TransactionController({required this.transactionService});

  // Getters
  TransactionState get state => _state;
  List<TransactionModel> get transactions => _transactions;
  TransactionModel? get selectedTransaction => _selectedTransaction;
  String? get errorMessage => _errorMessage;

  /// Load transaction history
  Future<void> loadTransactionHistory() async {
    try {
      _state = TransactionState.loading;
      _errorMessage = null;
      notifyListeners();

      _transactions = await transactionService.getTransactionHistory();
      _state = TransactionState.loaded;
    } catch (e) {
      _state = TransactionState.error;
      _errorMessage = _parseError(e);
    } finally {
      notifyListeners();
    }
  }

  /// Get transaction detail by ID
  Future<TransactionModel?> getTransactionDetail(int transactionId) async {
    try {
      _state = TransactionState.loading;
      _errorMessage = null;
      notifyListeners();

      _selectedTransaction = await transactionService.getTransactionDetail(
        transactionId,
      );
      _state = TransactionState.loaded;
      notifyListeners();
      return _selectedTransaction;
    } catch (e) {
      _state = TransactionState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return null;
    }
  }

  /// Create a new transaction
  Future<CreateTransactionResponse?> createTransaction({
    required double totalPrice,
    String paymentMethod = 'transfer',
    String? notes,
    required List<TransactionItemRequest> items,
  }) async {
    try {
      _state = TransactionState.loading;
      _errorMessage = null;
      notifyListeners();

      final request = CreateTransactionRequest(
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
        notes: notes,
        items: items,
      );

      final response = await transactionService.createTransaction(
        request: request,
      );

      if (response.success) {
        // Reload transaction history after creating new transaction
        await loadTransactionHistory();
      }

      _state = TransactionState.loaded;
      notifyListeners();
      return response;
    } catch (e) {
      _state = TransactionState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return null;
    }
  }

  /// Update transaction status
  Future<bool> updateTransactionStatus({
    required int transactionId,
    String? transactionStatus,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      _state = TransactionState.loading;
      _errorMessage = null;
      notifyListeners();

      final request = UpdateTransactionRequest(
        transactionStatus: transactionStatus,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      final success = await transactionService.updateTransaction(
        transactionId: transactionId,
        request: request,
      );

      if (success) {
        // Reload transaction history after update
        await loadTransactionHistory();
      }

      _state = TransactionState.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _state = TransactionState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Delete a transaction
  Future<bool> deleteTransaction(int transactionId) async {
    try {
      _state = TransactionState.loading;
      _errorMessage = null;
      notifyListeners();

      final success = await transactionService.deleteTransaction(transactionId);

      if (success) {
        // Remove from local list
        _transactions.removeWhere((t) => t.id == transactionId);
        if (_selectedTransaction?.id == transactionId) {
          _selectedTransaction = null;
        }
      }

      _state = TransactionState.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _state = TransactionState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Filter transactions by status
  List<TransactionModel> filterByStatus(String status) {
    return _transactions
        .where((t) => t.transactionStatus.toLowerCase() == status.toLowerCase())
        .toList();
  }

  /// Get pending transactions
  List<TransactionModel> get pendingTransactions => filterByStatus('pending');

  /// Get completed transactions
  List<TransactionModel> get completedTransactions =>
      filterByStatus('completed');

  /// Get paid transactions
  List<TransactionModel> get paidTransactions => filterByStatus('paid');

  /// Clear selected transaction
  void clearSelectedTransaction() {
    _selectedTransaction = null;
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
