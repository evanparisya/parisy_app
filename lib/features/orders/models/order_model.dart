class OrderModel {
  final String id;
  final String userId;
  final String status; // pending, processing, shipped, delivered
  final double totalPrice;
  final String address;
  final String phoneNumber;
  final String? notes;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalPrice,
    required this.address,
    required this.phoneNumber,
    this.notes,
    required this.items,
    required this.createdAt,
    this.deliveredAt,
  });

  // JSON to Model
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      status: json['status'] ?? 'pending',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      notes: json['notes'],
      items: json['items'] != null
          ? List<OrderItemModel>.from(
              (json['items'] as List).map((x) => OrderItemModel.fromJson(x)),
            )
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
    );
  }

  // Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'total_price': totalPrice,
      'address': address,
      'phone_number': phoneNumber,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'OrderModel(id: $id, status: $status)';
}

class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final double productPrice;
  final int quantity;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
  });

  // JSON to Model
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productPrice: (json['product_price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  // Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'quantity': quantity,
    };
  }
}

class OrderStatusUpdate {
  final String orderId;
  final String status;
  final DateTime timestamp;

  OrderStatusUpdate({
    required this.orderId,
    required this.status,
    required this.timestamp,
  });

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdate(
      orderId: json['order_id'] ?? '',
      status: json['status'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}
