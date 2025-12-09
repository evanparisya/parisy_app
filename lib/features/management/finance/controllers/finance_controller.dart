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
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

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
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}