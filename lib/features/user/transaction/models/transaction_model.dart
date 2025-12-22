// lib/features/user/transaction/models/transaction_model.dart

/// Transaction Detail Model - Represents one item in the transaction
class TransactionDetailModel {
  final int vegetableId;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  TransactionDetailModel({
    required this.vegetableId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailModel(
      vegetableId: json['vegetable_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitPrice: double.tryParse(json['unit_price']?.toString() ?? '0') ?? 0.0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vegetable_id': vegetableId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }
}

/// Transaction Model - Represents a complete transaction
class TransactionModel {
  final int id;
  final String code;
  final int? userId;
  final double totalPrice;
  final String paymentMethod;
  final String transactionStatus;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<TransactionDetailModel> items;

  TransactionModel({
    required this.id,
    required this.code,
    this.userId,
    required this.totalPrice,
    required this.paymentMethod,
    required this.transactionStatus,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['transaction_id'] ?? json['id'] ?? 0,
      code: json['code'] ?? 'TRX-000',
      userId: json['user_id'],
      totalPrice:
          double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['payment_method'] ?? 'transfer',
      transactionStatus: json['transaction_status'] ?? 'pending',
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      items:
          (json['items'] as List?)
              ?.map((item) => TransactionDetailModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': id,
      'code': code,
      'user_id': userId,
      'total_price': totalPrice.toString(),
      'payment_method': paymentMethod,
      'transaction_status': transactionStatus,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  /// Get status display text in Indonesian
  String get statusDisplayText {
    switch (transactionStatus.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'paid':
        return 'Dibayar';
      case 'processing':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'failed':
        return 'Gagal';
      default:
        return transactionStatus;
    }
  }

  /// Check if transaction is pending
  bool get isPending => transactionStatus.toLowerCase() == 'pending';

  /// Check if transaction is completed
  bool get isCompleted => transactionStatus.toLowerCase() == 'completed';

  /// Check if transaction is cancelled or failed
  bool get isCancelledOrFailed =>
      transactionStatus.toLowerCase() == 'cancelled' ||
      transactionStatus.toLowerCase() == 'failed';
}

/// Create Transaction Request - Request body for creating a new transaction
class CreateTransactionRequest {
  final double totalPrice;
  final String paymentMethod;
  final String? notes;
  final List<TransactionItemRequest> items;

  CreateTransactionRequest({
    required this.totalPrice,
    this.paymentMethod = 'transfer',
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// Transaction Item Request - Item data for creating a transaction
class TransactionItemRequest {
  final int vegetableId;
  final int quantity;
  final double unitPrice;

  TransactionItemRequest({
    required this.vegetableId,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'vegetable_id': vegetableId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}

/// Update Transaction Request - Request body for updating a transaction
class UpdateTransactionRequest {
  final String? transactionStatus;
  final String? paymentMethod;
  final String? notes;

  UpdateTransactionRequest({
    this.transactionStatus,
    this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (transactionStatus != null) {
      data['transaction_status'] = transactionStatus;
    }
    if (paymentMethod != null) {
      data['payment_method'] = paymentMethod;
    }
    if (notes != null) {
      data['notes'] = notes;
    }
    return data;
  }
}

/// Create Transaction Response - Response from creating a transaction
class CreateTransactionResponse {
  final String message;
  final int? transactionId;
  final bool success;

  CreateTransactionResponse({
    required this.message,
    this.transactionId,
    required this.success,
  });

  factory CreateTransactionResponse.fromJson(
    Map<String, dynamic> json,
    int statusCode,
  ) {
    return CreateTransactionResponse(
      message: json['message'] ?? 'Unknown response',
      transactionId: json['transaction_id'],
      success: statusCode == 201 || statusCode == 200,
    );
  }
}
