// lib/features/user/marketplace/controllers/marketplace_controller.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../services/marketplace_service.dart';

enum MarketplaceState { initial, loading, loaded, error }

class MarketplaceController extends ChangeNotifier {
  final MarketplaceService marketplaceService;

  MarketplaceState _state = MarketplaceState.initial;
  List<ProductModel> _products = [];
  String? _selectedCategory;
  String? _errorMessage;

  MarketplaceController({required this.marketplaceService});

  // --- Getters ---
  MarketplaceState get state => _state;
  List<ProductModel> get products => _products;
  String? get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;
  List<String> get categories => ['daun', 'akar', 'bunga', 'buah'];

  // --- Methods Load Data ---
  Future<void> loadInitialData() async {
    await loadProducts();
  }

  Future<void> loadProducts() async {
    _state = MarketplaceState.loading;
    notifyListeners();
    try {
      final response = await marketplaceService.getProducts();
      _products = response.products;
      _state = MarketplaceState.loaded;
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadAdminProducts() async {
    _state = MarketplaceState.loading;
    notifyListeners();
    try {
      final response = await marketplaceService.getAdminProducts();
      _products = response.products;
      _state = MarketplaceState.loaded;
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadProductsByCategory(String category) async {
    _selectedCategory = category;
    _state = MarketplaceState.loading;
    notifyListeners();
    try {
      final response = await marketplaceService.getProductsByCategory(category);
      _products = response.products;
      _state = MarketplaceState.loaded;
    } catch (e) {
      _state = MarketplaceState.error;
    }
    notifyListeners();
  }

  // --- Filter & Search ---
  Future<void> filterByCategory(String? category) async {
    if (category == null) {
      await resetFilters();
    } else {
      await loadProductsByCategory(category);
    }
  }

  Future<void> resetFilters() async {
    _selectedCategory = null;
    await loadProducts();
  }

  Future<void> searchProducts(String query, {String? category}) async {
    _state = MarketplaceState.loading;
    notifyListeners();
    try {
      final response = await marketplaceService.searchProducts(
        query, 
        category: category ?? _selectedCategory
      );
      _products = response.products;
      _state = MarketplaceState.loaded;
    } catch (e) {
      _state = MarketplaceState.error;
    }
    notifyListeners();
  }

  // --- Mutation Methods (Kamera & Prediksi) ---
  Future<bool> addProductWithCamera({
    required String name,
    required String description,
    required double price,
    required int stock,
    required XFile image,
  }) async {
    try {
      _state = MarketplaceState.loading;
      notifyListeners();
      
      // Mengirim ke service yang akan melakukan konversi base64
      final newProduct = await marketplaceService.addProductWithImage(
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageFile: image,
      );
      
      _products.insert(0, newProduct);
      _state = MarketplaceState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStock(int id, int newStock) async {
    try {
      final updatedProduct = await marketplaceService.updateStock(id, newStock);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await marketplaceService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<XFile?> pickImageFromCamera() async {
    return await marketplaceService.pickImageFromCamera();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}