// lib/features/management/finance/models/financial_report_model.dart
class FinancialReportModel {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final int totalTransactions;

  FinancialReportModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.totalTransactions,
  });

  factory FinancialReportModel.fromJson(Map<String, dynamic> json) {
    return FinancialReportModel(
      totalIncome: (json['total_income'] ?? 0.0).toDouble(),
      totalExpense: (json['total_expense'] ?? 0.0).toDouble(),
      netBalance: (json['net_balance'] ?? 0.0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
    );
  }
}