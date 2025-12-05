/// Cart Item Model - JSON parsing
/// Demonstrates: JSON ✅
class CartItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  /// Calculate subtotal
  double get subtotal => price * quantity;

  /// JSON → Dart Object
  /// Demonstrates: JSON deserialization ✅
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }

  /// Dart Object → JSON
  /// Demonstrates: JSON serialization ✅
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  @override
  String toString() =>
      'CartItem($name x$quantity = Rp ${subtotal.toStringAsFixed(0)})';
}

/// Checkout Request - For API call
/// Demonstrates: JSON + State Management
class CheckoutRequest {
  final List<CartItem> items;
  final String address;
  final String phone;
  final String notes;

  CheckoutRequest({
    required this.items,
    required this.address,
    required this.phone,
    this.notes = '',
  });

  /// Calculate total price
  double get totalPrice => items.fold(0, (sum, item) => sum + item.subtotal);

  /// Dart Object → JSON
  /// Demonstrates: JSON serialization for API request ✅
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'address': address,
      'phone': phone,
      'notes': notes,
      'total_price': totalPrice,
    };
  }
}

/// Checkout Response - From API
/// Demonstrates: JSON parsing
class CheckoutResponse {
  final String orderId;
  final String status;
  final DateTime createdAt;

  CheckoutResponse({
    required this.orderId,
    required this.status,
    required this.createdAt,
  });

  /// JSON → Dart Object
  /// Demonstrates: JSON deserialization ✅
  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      orderId: json['order_id'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
