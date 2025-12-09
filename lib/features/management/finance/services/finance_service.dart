// lib/features/management/finance/services/finance_service.dart
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/features/management/finance/models/cash_flow_model.dart';
import 'package:parisy_app/features/management/finance/models/financial_report_model.dart';

class FinanceService {
  final ApiClient apiClient;

  static const bool useMock = true;

  FinanceService({required this.apiClient});

  Future<FinancialReportModel> getFinancialSummary() async {
    if (useMock) {
      await Future.delayed(Duration(milliseconds: 500));
      return FinancialReportModel(
        totalIncome: 12500000.0,
        totalExpense: 3000000.0,
        netBalance: 9500000.0,
        totalTransactions: 45,
      );
    }
    throw UnimplementedError('API get financial summary belum diimplementasi');
  }

  Future<List<CashFlowEntry>> getCashFlowHistory() async {
    if (useMock) {
      await Future.delayed(Duration(seconds: 1));
      return [
        CashFlowEntry(id: 1, description: 'Pemasukan - Penjualan Jan', amount: 5000000, type: 'IN', date: DateTime(2025, 1, 30), sourceOrDestination: 'Marketplace'),
        CashFlowEntry(id: 2, description: 'Pengeluaran - Gaji Karyawan', amount: 2000000, type: 'OUT', date: DateTime(2025, 1, 31), sourceOrDestination: 'Kas Umum'),
        CashFlowEntry(id: 3, description: 'Pemasukan - Penjualan Feb', amount: 7500000, type: 'IN', date: DateTime(2025, 2, 28), sourceOrDestination: 'Marketplace'),
        CashFlowEntry(id: 4, description: 'Pengeluaran - Pembelian Alat', amount: 1000000, type: 'OUT', date: DateTime(2025, 2, 20), sourceOrDestination: 'Vendor A'),
      ];
    }
    throw UnimplementedError('API get cash flow history belum diimplementasi');
  }

  Future<bool> manageCashFlow(CashFlowEntry entry) async {
    if (useMock) {
      await Future.delayed(Duration(seconds: 1));
      return true;
    }
    throw UnimplementedError();
  }
}