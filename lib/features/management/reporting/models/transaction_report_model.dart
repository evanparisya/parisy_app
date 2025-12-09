// lib/features/management/reporting/models/transaction_report_model.dart
// Status Transaction: pending, paid, failed
// Status Payment: transfer, cash

// Merepresentasikan satu item dalam transaksi (dari detail_transactions)
class DetailTransactionModel {
  final int vegetableId;
  final String vegetableName; // Field tambahan untuk kemudahan display
  final int quantity;
  final double priceUnit;
  final double subtotal;

  DetailTransactionModel({
    required this.vegetableId,
    required this.vegetableName,
    required this.quantity,
    required this.priceUnit,
    required this.subtotal,
  });

  factory DetailTransactionModel.fromJson(Map<String, dynamic> json) {
    return DetailTransactionModel(
      vegetableId: json['vegetable_id'] ?? 0,
      vegetableName: json['vegetable_name'] ?? 'Produk Tidak Diketahui',
      quantity: json['quantity'] ?? 0,
      priceUnit: (json['price_unit'] ?? 0.0).toDouble(),
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
    );
  }
}

// Merepresentasikan satu transaksi penuh (dari transactions)
class TransactionReportModel {
  final int id;
  final String code;
  final int userId;
  final String userName; // Field tambahan dari join users
  final double priceTotal;
  final String statusTransaction; 
  final String statusPayment; 
  final String? notes;
  final DateTime createdAt;
  final List<DetailTransactionModel> details;

  TransactionReportModel({
    required this.id,
    required this.code,
    required this.userId,
    required this.userName,
    required this.priceTotal,
    required this.statusTransaction,
    required this.statusPayment,
    this.notes,
    required this.createdAt,
    required this.details,
  });

  factory TransactionReportModel.fromJson(Map<String, dynamic> json) {
    return TransactionReportModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? 'Warga',
      priceTotal: (json['price_total'] ?? 0.0).toDouble(),
      statusTransaction: json['status_transaction'] ?? 'pending',
      statusPayment: json['status_payment'] ?? 'transfer',
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      details: (json['details'] as List?)
              ?.map((d) => DetailTransactionModel.fromJson(d))
              .toList() ??
          [],
    );
  }
}