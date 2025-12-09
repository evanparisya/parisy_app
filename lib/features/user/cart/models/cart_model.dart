// lib/features/user/cart/models/cart_item_model.dart

/// Cart Item Model - Represents one vegetable item in the cart
class CartItemModel {
  final int productId;
  final String name;
  final double price; // price_unit in DBML context
  int quantity;
  
  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  // Calculate subtotal
  double get subtotal => price * quantity;

  // Converts to the structure needed for detail_transactions
  Map<String, dynamic> toDetailTransactionJson() {
    return {
      'vegetable_id': productId,
      'quantity': quantity,
      'price_unit': price,
      'subtotal': subtotal,
    };
  }
}