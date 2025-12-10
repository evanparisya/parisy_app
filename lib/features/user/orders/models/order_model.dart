// lib/features/user/orders/models/order_model.dart

// Merepresentasikan satu item dalam pesanan (dari detail_transactions)
class OrderDetailModel {
  final int vegetableId;
  final String vegetableName; // Nama barang ditambahkan untuk display
  final int quantity;
  final double priceUnit;
  final double subtotal;

  OrderDetailModel({
    required this.vegetableId,
    required this.vegetableName,
    required this.quantity,
    required this.priceUnit,
    required this.subtotal,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      vegetableId: json['vegetable_id'] ?? 0,
      vegetableName: json['vegetable_name'] ?? 'Produk Tidak Diketahui',
      quantity: json['quantity'] ?? 0,
      priceUnit: (json['price_unit'] as num? ?? 0.0).toDouble(),
      subtotal: (json['subtotal'] as num? ?? 0.0).toDouble(),
    );
  }
}

// Merepresentasikan satu pesanan penuh (dari transactions)
class OrderModel {
  final int id;
  final String code;
  final int userId;
  final double priceTotal;
  final String statusTransaction; // pending, paid, failed
  final String statusPayment; // transfer, cash
  final String? notes;
  final DateTime createdAt;
  final List<OrderDetailModel> details;

  OrderModel({
    required this.id,
    required this.code,
    required this.userId,
    required this.priceTotal,
    required this.statusTransaction,
    required this.statusPayment,
    this.notes,
    required this.createdAt,
    required this.details,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? 'TRX-000',
      userId: json['user_id'] ?? 0,
      priceTotal: (json['price_total'] as num? ?? 0.0).toDouble(),
      statusTransaction: json['status_transaction'] ?? 'pending',
      statusPayment: json['status_payment'] ?? 'transfer',
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      details: (json['details'] as List?)
              ?.map((d) => OrderDetailModel.fromJson(d))
              .toList() ??
          [],
    );
  }
}