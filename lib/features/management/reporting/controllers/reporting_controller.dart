// lib/features/management/reporting/controllers/reporting_controller.dart
import 'package:flutter/material.dart';
import 'package:parisy_app/features/management/reporting/models/product_report_model.dart';
import 'package:parisy_app/features/management/reporting/models/transaction_report_model.dart';
import 'package:parisy_app/features/management/reporting/services/reporting_service.dart';

enum ReportingState { initial, loading, loaded, error }

class ReportingController extends ChangeNotifier {
  final ReportingService service;

  ReportingState _state = ReportingState.initial;
  String? _errorMessage;
  List<TransactionReportModel> _transactionHistory = [];
  List<ProductReportModel> _productHistory = [];
  TransactionReportModel? _selectedTransaction;

  ReportingController({required this.service});

  ReportingState get state => _state;
  String? get errorMessage => _errorMessage;
  List<TransactionReportModel> get transactionHistory => _transactionHistory;
  List<ProductReportModel> get productHistory => _productHistory;
  TransactionReportModel? get selectedTransaction => _selectedTransaction;

  Future<void> loadTransactionHistory() async {
    try {
      _state = ReportingState.loading;
      notifyListeners();
      _transactionHistory = await service.getTransactionHistory();
      _state = ReportingState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = ReportingState.error;
      _errorMessage = _parseError(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadProductHistory() async {
    try {
      _state = ReportingState.loading;
      notifyListeners();
      _productHistory = await service.getProductHistory();
      _state = ReportingState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = ReportingState.error;
      _errorMessage = _parseError(e);
    } finally {
      notifyListeners();
    }
  }

  /// Get transaction detail by ID
  Future<TransactionReportModel?> getTransactionDetail(
    int transactionId,
  ) async {
    try {
      _state = ReportingState.loading;
      _errorMessage = null;
      notifyListeners();

      _selectedTransaction = await service.getTransactionDetail(transactionId);
      _state = ReportingState.loaded;
      notifyListeners();
      return _selectedTransaction;
    } catch (e) {
      _state = ReportingState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return null;
    }
  }

  /// Update transaction status (Admin/Sekretaris)
  Future<bool> updateTransactionStatus({
    required int transactionId,
    String? transactionStatus,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      _state = ReportingState.loading;
      _errorMessage = null;
      notifyListeners();

      final success = await service.updateTransactionStatus(
        transactionId: transactionId,
        transactionStatus: transactionStatus,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      if (success) {
        // Reload transaction history after update
        await loadTransactionHistory();
      }

      _state = ReportingState.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _state = ReportingState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Delete a transaction (Admin/Sekretaris)
  Future<bool> deleteTransaction(int transactionId) async {
    try {
      _state = ReportingState.loading;
      _errorMessage = null;
      notifyListeners();

      final success = await service.deleteTransaction(transactionId);

      if (success) {
        // Remove from local list
        _transactionHistory.removeWhere((t) => t.id == transactionId);
        if (_selectedTransaction?.id == transactionId) {
          _selectedTransaction = null;
        }
      }

      _state = ReportingState.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _state = ReportingState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Filter transactions by status
  List<TransactionReportModel> filterByStatus(String status) {
    return _transactionHistory
        .where((t) => t.statusTransaction.toLowerCase() == status.toLowerCase())
        .toList();
  }

  /// Get pending transactions
  List<TransactionReportModel> get pendingTransactions =>
      filterByStatus('pending');

  /// Get paid transactions
  List<TransactionReportModel> get paidTransactions => filterByStatus('paid');

  /// Clear selected transaction
  void clearSelectedTransaction() {
    _selectedTransaction = null;
    notifyListeners();
  }

  /// Clear error
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
