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

  // Filter state
  String? _statusFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;

  FinanceController({required this.service});

  FinanceState get state => _state;
  String? get errorMessage => _errorMessage;
  FinancialReportModel? get summary => _summary;
  List<CashFlowEntry> get history => _history;

  // Filter getters
  String? get statusFilter => _statusFilter;
  DateTime? get startDateFilter => _startDateFilter;
  DateTime? get endDateFilter => _endDateFilter;

  /// Get completed transactions (income)
  List<CashFlowEntry> get incomeEntries =>
      _history.where((e) => e.status == 'completed').toList();

  /// Get cancelled transactions
  List<CashFlowEntry> get cancelledEntries =>
      _history.where((e) => e.status == 'cancelled').toList();

  /// Get pending transactions
  List<CashFlowEntry> get pendingEntries =>
      _history.where((e) => e.status == 'pending').toList();

  /// Load finance data (summary and history)
  Future<void> loadFinanceData() async {
    try {
      _state = FinanceState.loading;
      notifyListeners();

      _summary = await service.getFinancialSummary();
      _history = await service.getCashFlowHistory(
        status: _statusFilter,
        startDate: _startDateFilter,
        endDate: _endDateFilter,
      );

      _state = FinanceState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = FinanceState.error;
      _errorMessage = _parseError(e);
    } finally {
      notifyListeners();
    }
  }

  /// Load history with filters
  Future<void> loadHistoryWithFilters({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _statusFilter = status;
    _startDateFilter = startDate;
    _endDateFilter = endDate;

    try {
      _state = FinanceState.loading;
      notifyListeners();

      _history = await service.getCashFlowHistory(
        status: status,
        startDate: startDate,
        endDate: endDate,
      );

      _state = FinanceState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = FinanceState.error;
      _errorMessage = _parseError(e);
    } finally {
      notifyListeners();
    }
  }

  /// Clear filters and reload
  Future<void> clearFilters() async {
    _statusFilter = null;
    _startDateFilter = null;
    _endDateFilter = null;
    await loadFinanceData();
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
