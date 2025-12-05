class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final double productPrice;
  final String productImage;
  int quantity;
  final DateTime addedAt;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.quantity,
    required this.addedAt,
  });

  // Calculate subtotal
  double get subtotal => productPrice * quantity;

  // JSON to Model
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productPrice: (json['product_price'] ?? 0).toDouble(),
      productImage: json['product_image'] ?? '',
      quantity: json['quantity'] ?? 1,
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'])
          : DateTime.now(),
    );
  }

  // Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'product_image': productImage,
      'quantity': quantity,
      'added_at': addedAt.toIso8601String(),
    };
  }

  // Copy with
  CartItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    double? productPrice,
    String? productImage,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productImage: productImage ?? this.productImage,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  String toString() =>
      'CartItemModel(id: $id, productName: $productName, quantity: $quantity)';
}

class CheckoutRequest {
  final List<CartItemModel> items;
  final double totalPrice;
  final String address;
  final String phoneNumber;
  final String notes;

  CheckoutRequest({
    required this.items,
    required this.totalPrice,
    required this.address,
    required this.phoneNumber,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'total_price': totalPrice,
      'address': address,
      'phone_number': phoneNumber,
      'notes': notes,
    };
  }
}

class CheckoutResponse {
  final String orderId;
  final String status;
  final double totalPrice;
  final DateTime createdAt;

  CheckoutResponse({
    required this.orderId,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      orderId: json['order_id'] ?? '',
      status: json['status'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
