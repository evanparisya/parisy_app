// lib/features/management/finance/models/cash_flow_model.dart
/// Model untuk riwayat transaksi dari /finance/history
/// Sesuai dengan response backend yang mengembalikan data transaksi
class CashFlowEntry {
  final int id;
  final String code;
  final int userId;
  final double amount; // total_price dari backend
  final String paymentMethod; // payment_method
  final String status; // transaction_status
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CashFlowEntry({
    required this.id,
    required this.code,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Helper untuk mendapatkan description untuk display
  String get description => 'Transaksi $code';

  /// Helper untuk mendapatkan type (IN/OUT) berdasarkan status
  String get type => status == 'completed'
      ? 'IN'
      : (status == 'cancelled' ? 'OUT' : 'PENDING');

  /// Helper untuk backward compatibility
  DateTime get date => createdAt;
  String get sourceOrDestination => paymentMethod;

  factory CashFlowEntry.fromJson(Map<String, dynamic> json) {
    return CashFlowEntry(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      userId: json['user_id'] ?? 0,
      amount: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['payment_method'] ?? 'transfer',
      status: json['transaction_status'] ?? 'pending',
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
}
