// lib/features/management/finance/models/financial_report_model.dart
class FinancialReportModel {
  final double totalIncome; // Total dari transaksi completed
  final double totalPending; // Total dari transaksi pending
  final double totalCancelled; // Total dari transaksi cancelled
  final int totalTransactions; // Jumlah semua transaksi
  final int completedCount; // Jumlah transaksi completed
  final int pendingCount; // Jumlah transaksi pending
  final int cancelledCount; // Jumlah transaksi cancelled

  FinancialReportModel({
    required this.totalIncome,
    required this.totalPending,
    required this.totalCancelled,
    required this.totalTransactions,
    required this.completedCount,
    required this.pendingCount,
    required this.cancelledCount,
  });

  /// Net balance = total income (completed) - cancelled
  double get netBalance => totalIncome;

  /// Total expense untuk backward compatibility (cancelled transactions)
  double get totalExpense => totalCancelled;

  factory FinancialReportModel.fromJson(Map<String, dynamic> json) {
    return FinancialReportModel(
      totalIncome:
          double.tryParse(json['total_income']?.toString() ?? '0') ?? 0.0,
      totalPending:
          double.tryParse(json['total_pending']?.toString() ?? '0') ?? 0.0,
      totalCancelled:
          double.tryParse(json['total_cancelled']?.toString() ?? '0') ?? 0.0,
      totalTransactions: json['total_transactions'] ?? 0,
      completedCount: json['completed_count'] ?? 0,
      pendingCount: json['pending_count'] ?? 0,
      cancelledCount: json['cancelled_count'] ?? 0,
    );
  }
}
