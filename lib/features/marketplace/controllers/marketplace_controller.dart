import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../services/marketplace_service.dart';

/// Marketplace State enum
/// Demonstrates: State Management 🔄
enum MarketplaceState { initial, loading, loaded, error }

/// Marketplace Controller - State Management with Provider + ChangeNotifier
/// Demonstrates: State Management 🔄 + Async ⏳
class MarketplaceController extends ChangeNotifier {
  final MarketplaceService marketplaceService;

  // State variables
  /// Demonstrates: State Management 🔄
  MarketplaceState _state = MarketplaceState.initial;
  List<ProductModel> _products = [];
  List<String> _categories = [];
  String? _selectedCategory;
  String? _errorMessage;
  bool _isAddingProduct = false;

  MarketplaceController({required this.marketplaceService});

  // Getters
  MarketplaceState get state => _state;
  List<ProductModel> get products => _products;
  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;
  bool get isAddingProduct => _isAddingProduct;

  /// Load all products from API
  /// Demonstrates: Async ⏳ + State Management 🔄
  Future<void> loadProducts() async {
    try {
      _state = MarketplaceState.loading;
      final response = await marketplaceService.getProducts();
      _products = response.products;
      _state = MarketplaceState.loaded;
      _errorMessage = null;
      notifyListeners(); // Notify UI only once after all updates
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
      notifyListeners(); // Notify UI only once after error
    }
  }

  /// Load initial data (for page load)
  Future<void> loadInitialData() async {
    await loadProducts();
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (_state == MarketplaceState.loading) return;

    try {
      _state = MarketplaceState.loading;
      final response = await marketplaceService.getProducts();
      _products.addAll(response.products);
      _state = MarketplaceState.loaded;
      notifyListeners(); // Notify only once after all updates
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
      notifyListeners(); // Notify only once after error
    }
  }

  /// Filter products by category
  Future<void> filterByCategory(String? category) async {
    _selectedCategory = category;
    if (category == null) {
      await loadProducts();
    } else {
      try {
        _state = MarketplaceState.loading;
        // For now, just reload all products
        // In a real app, this would filter on the backend
        final response = await marketplaceService.getProducts();
        _products = response.products;
        _state = MarketplaceState.loaded;
        _errorMessage = null;
        notifyListeners(); // Notify only once after all updates
      } catch (e) {
        _state = MarketplaceState.error;
        _errorMessage = e.toString();
        notifyListeners(); // Notify only once after error
      }
    }
  }

  /// Reset filters
  Future<void> resetFilters() async {
    _selectedCategory = null;
    await loadProducts();
  }

  /// Search products
  /// Demonstrates: Async ⏳ + State Management 🔄
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      await loadProducts();
      return;
    }

    try {
      _state = MarketplaceState.loading;
      final response = await marketplaceService.searchProducts(query);
      _products = response.products;
      _state = MarketplaceState.loaded;
      _errorMessage = null;
      notifyListeners(); // Notify UI only once after all updates
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
      notifyListeners(); // Notify UI only once after error
    }
  }

  /// Add product with camera image
  /// Demonstrates: Camera 📷 + Async ⏳ + State Management 🔄 + JSON 📄
  Future<bool> addProductWithCamera({
    required XFile image,
    required String name,
    required double price,
  }) async {
    try {
      _isAddingProduct = true;
      notifyListeners(); // Notify UI: adding product

      final newProduct = await marketplaceService.addProduct(
        image: image,
        name: name,
        price: price,
      );

      // Add to local list
      _products.insert(0, newProduct);
      _isAddingProduct = false;
      notifyListeners(); // Notify UI: product added

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isAddingProduct = false;
      notifyListeners(); // Notify UI: error
      return false;
    }
  }

  /// Pick image from camera
  /// Demonstrates: Camera 📷
  Future<XFile?> pickImageFromCamera() async {
    try {
      return await marketplaceService.pickImageFromCamera();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
