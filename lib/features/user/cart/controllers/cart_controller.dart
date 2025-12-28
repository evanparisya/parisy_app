// lib/features/user/cart/controllers/cart_controller.dart
import 'package:flutter/material.dart';
import 'package:parisy_app/features/auth/controllers/auth_controller.dart';
import 'package:parisy_app/features/user/orders/models/order_model.dart'; // Jalur sudah diperiksa
import 'package:parisy_app/features/user/cart/models/cart_item_model.dart'; // Import eksplisit untuk CartItemModel
import 'package:parisy_app/features/user/cart/models/cart_model.dart'; // Import eksplisit untuk CartModel dan CheckoutRequest
import 'package:parisy_app/features/user/cart/services/cart_service.dart';

class CartController extends ChangeNotifier {
  final CartService cartService;
  final AuthController authController;

  // Menggunakan nama kelas yang diimpor secara eksplisit
  CartModel _cart = CartModel();
  bool _isLoading = false;
  String? _errorMessage;

  CartController({required this.cartService, required this.authController});

  // Getters
  CartModel get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get itemCount => _cart.itemUniqueCount; 
  double get totalAmount => _cart.total;

  /// Add item to cart or increase quantity
  void addItem({
    required int productId,
    required String name,
    required double price,
    int quantity = 1,
  }) {
    final existingItemIndex = _cart.items.indexWhere((item) => item.productId == productId);
    
    if (existingItemIndex != -1) {
      _cart.items[existingItemIndex].quantity += quantity;
    } else {
      // Menggunakan CartItemModel yang diimpor secara eksplisit
      _cart.items.add(
        CartItemModel(
          productId: productId,
          name: name,
          price: price,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }
  
  /// Update specific item quantity
  void updateQuantity(int productId, int quantity) {
    final itemIndex = _cart.items.indexWhere((item) => item.productId == productId);
    if (itemIndex != -1) {
      if (quantity > 0) {
        _cart.items[itemIndex].quantity = quantity;
      } else {
        _cart.items.removeAt(itemIndex); 
      }
    }
    notifyListeners();
  }

  /// Remove item from cart (clear all quantity)
  void removeItem(int productId) {
    _cart.items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  /// Checkout process (calls API)
  Future<OrderModel?> checkout({
    required String statusPayment,
    String? notes,
  }) async {
    if (_cart.items.isEmpty) {
      _errorMessage = 'Keranjang kosong.';
      notifyListeners();
      return null;
    }
    if (authController.currentUser == null) {
      _errorMessage = 'User belum login.';
      notifyListeners();
      return null;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userId = authController.currentUser!.id;
      
      final itemsJson = _cart.items
          .map((item) => item.toDetailTransactionJson())
          .toList();

      // Menggunakan CheckoutRequest yang diimpor secara eksplisit
      final request = CheckoutRequest(
        userId: userId,
        priceTotal: totalAmount,
        statusPayment: statusPayment,
        notes: notes,
        items: itemsJson,
      );

      final newOrder = await cartService.checkout(request: request);

      _cart = CartModel(); 
      _isLoading = false;
      notifyListeners();
      return newOrder;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().contains('Exception: ') ? e.toString().substring(11) : e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Clear the entire cart
  void clearCart() {
    _cart = CartModel();
    notifyListeners();
  }
}