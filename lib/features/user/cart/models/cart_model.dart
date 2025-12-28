// lib/features/user/cart/models/cart_model.dart

import 'package:parisy_app/features/user/cart/models/cart_item_model.dart';

/// Cart Model - Represents the entire shopping cart
class CartModel {
  List<CartItemModel> items = [];

  // Calculate total amount
  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);
  
  // Get count of unique items
  int get itemUniqueCount => items.length;

  // Constructor
  CartModel({List<CartItemModel>? items}) : items = items ?? [];
}

/// Checkout Request - Model for the API request payload
class CheckoutRequest {
  final int userId;
  final double priceTotal;
  final String statusPayment;
  final String? notes;
  final List<Map<String, dynamic>> items; // List of detail_transaction JSON

  CheckoutRequest({
    required this.userId,
    required this.priceTotal,
    required this.statusPayment,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'price_total': priceTotal,
      'status_payment': statusPayment,
      'notes': notes,
      'items': items,
    };
  }
}