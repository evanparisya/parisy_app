import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';

/// Cart State enum
/// Demonstrates: State Management 🔄
enum CartState { initial, loaded, checking_out, error }

/// Cart Controller - State Management with local + API cart
/// Demonstrates: State Management 🔄 + Async ⏳
class CartController extends ChangeNotifier {
  final CartService cartService;

  // State variables
  /// Demonstrates: State Management 🔄
  CartState _state = CartState.initial;
  List<CartItem> _items = [];
  String? _errorMessage;
  bool _isCheckingOut = false;
  String? _lastOrderId;

  CartController({required this.cartService});

  // Getters
  CartState get state => _state;
  List<CartItem> get items => _items;
  String? get errorMessage => _errorMessage;
  bool get isCheckingOut => _isCheckingOut;
  String? get lastOrderId => _lastOrderId;
  int get itemCount => _items.length;

  /// Calculate total price
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  /// Add item to cart
  /// Demonstrates: State Management 🔄
  void addItem({
    required String productId,
    required String name,
    required double price,
  }) {
    // Check if item already exists
    final existingIndex = _items.indexWhere(
      (item) => item.productId == productId,
    );

    if (existingIndex >= 0) {
      // Increase quantity
      _items[existingIndex] = CartItem(
        productId: _items[existingIndex].productId,
        name: _items[existingIndex].name,
        price: _items[existingIndex].price,
        quantity: _items[existingIndex].quantity + 1,
      );
    } else {
      // Add new item
      _items.add(
        CartItem(productId: productId, name: name, price: price, quantity: 1),
      );
    }

    _state = CartState.loaded;
    _errorMessage = null;
    notifyListeners(); // Notify UI: cart updated
  }

  /// Remove item from cart
  /// Demonstrates: State Management 🔄
  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    if (_items.isEmpty) {
      _state = CartState.initial;
    } else {
      _state = CartState.loaded;
    }
    notifyListeners(); // Notify UI: cart updated
  }

  /// Update item quantity
  /// Demonstrates: State Management 🔄
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final itemIndex = _items.indexWhere((item) => item.productId == productId);
    if (itemIndex >= 0) {
      _items[itemIndex] = CartItem(
        productId: _items[itemIndex].productId,
        name: _items[itemIndex].name,
        price: _items[itemIndex].price,
        quantity: quantity,
      );
      notifyListeners(); // Notify UI: cart updated
    }
  }

  /// Clear cart
  /// Demonstrates: State Management 🔄
  void clearCart() {
    _items.clear();
    _state = CartState.initial;
    _errorMessage = null;
    notifyListeners(); // Notify UI: cart cleared
  }

  /// Checkout
  /// Demonstrates: Async ⏳ + State Management 🔄 + JSON 📄
  Future<bool> checkout({
    required String address,
    required String phone,
    String? notes,
  }) async {
    if (_items.isEmpty) {
      _errorMessage = 'Cart is empty';
      notifyListeners();
      return false;
    }

    try {
      _isCheckingOut = true;
      notifyListeners(); // Notify UI: checking out

      // Create checkout request
      /// Demonstrates: JSON serialization ✅
      final request = CheckoutRequest(
        items: _items,
        address: address,
        phone: phone,
        notes: notes ?? '',
      );

      // Send to API
      /// Demonstrates: Async ⏳ + RestAPI 🌐 + JSON 📄
      final response = await cartService.checkout(request);

      _lastOrderId = response.orderId;
      _items.clear();
      _state = CartState.loaded;
      _errorMessage = null;
      _isCheckingOut = false;
      notifyListeners(); // Notify UI: checkout success

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isCheckingOut = false;
      notifyListeners(); // Notify UI: error
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
