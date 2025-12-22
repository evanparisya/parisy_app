// lib/features/management/finance/controllers/finance_controller.dart
import 'package:flutter/material.dart';
import 'package:parisy_app/features/management/finance/models/cash_flow_model.dart';
import 'package:parisy_app/features/management/finance/models/financial_report_model.dart';
import 'package:parisy_app/features/management/finance/services/finance_service.dart';

enum FinanceState { initial, loading, loaded, error }

class FinanceController extends ChangeNotifier {
  final FinanceService service;

  FinanceState _state = FinanceState.initial;
  String? _errorMessage;
  FinancialReportModel? _summary;
  List<CashFlowEntry> _history = [];

  FinanceController({required this.service});

  FinanceState get state => _state;
  String? get errorMessage => _errorMessage;
  FinancialReportModel? get summary => _summary;
  List<CashFlowEntry> get history => _history;

  /// Get income entries
  List<CashFlowEntry> get incomeEntries =>
      _history.where((e) => e.type == 'IN').toList();

  /// Get expense entries
  List<CashFlowEntry> get expenseEntries =>
      _history.where((e) => e.type == 'OUT').toList();

  Future<void> loadFinanceData() async {
    try {
      _state = FinanceState.loading;
      notifyListeners();

      _summary = await service.getFinancialSummary();
      _history = await service.getCashFlowHistory();

      _state = FinanceState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = FinanceState.error;
      _errorMessage = _parseError(e);
    } finally {
      notifyListeners();
    }
  }

  /// Save (create or update) cash flow entry
  Future<bool> saveCashFlow(CashFlowEntry entry) async {
    try {
      _state = FinanceState.loading;
      notifyListeners();

      final success = await service.manageCashFlow(entry);
      if (success) {
        await loadFinanceData();
        return true;
      }
      return false;
    } catch (e) {
      _state = FinanceState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Create new cash flow entry
  Future<bool> createCashFlow(CashFlowEntry entry) async {
    try {
      _state = FinanceState.loading;
      _errorMessage = null;
      notifyListeners();

      final success = await service.createCashFlow(entry);
      if (success) {
        await loadFinanceData();
      }

      _state = FinanceState.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _state = FinanceState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Update existing cash flow entry
  Future<bool> updateCashFlow(CashFlowEntry entry) async {
    try {
      _state = FinanceState.loading;
      _errorMessage = null;
      notifyListeners();

      final success = await service.updateCashFlow(entry);
      if (success) {
        await loadFinanceData();
      }

      _state = FinanceState.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _state = FinanceState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  /// Delete cash flow entry
  Future<bool> deleteCashFlow(int id) async {
    try {
      _state = FinanceState.loading;
      _errorMessage = null;
      notifyListeners();

      final success = await service.deleteCashFlow(id);
      if (success) {
        _history.removeWhere((e) => e.id == id);
        // Reload to get updated summary
        await loadFinanceData();
      }

      _state = FinanceState.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _state = FinanceState.error;
      _errorMessage = _parseError(e);
      notifyListeners();
      return false;
    }
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
