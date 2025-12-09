// lib/features/management/finance/models/cash_flow_model.dart
class CashFlowEntry {
  final int id;
  final String description;
  final double amount;
  final String type; // 'IN' (Pemasukan) atau 'OUT' (Pengeluaran)
  final DateTime date;
  final String sourceOrDestination;

  CashFlowEntry({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.sourceOrDestination,
  });

  factory CashFlowEntry.fromJson(Map<String, dynamic> json) {
    return CashFlowEntry(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      type: json['type'] ?? 'IN',
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      sourceOrDestination: json['source_or_destination'] ?? 'N/A',
    );
  }
}