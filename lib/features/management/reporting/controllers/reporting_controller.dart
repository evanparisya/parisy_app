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

  ReportingController({required this.service});

  ReportingState get state => _state;
  String? get errorMessage => _errorMessage;
  List<TransactionReportModel> get transactionHistory => _transactionHistory;
  List<ProductReportModel> get productHistory => _productHistory;

  Future<void> loadTransactionHistory() async {
    try {
      _state = ReportingState.loading;
      notifyListeners();
      _transactionHistory = await service.getTransactionHistory();
      _state = ReportingState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = ReportingState.error;
      _errorMessage = e.toString();
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
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}