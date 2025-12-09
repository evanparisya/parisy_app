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

  // Getters
  MarketplaceState get state => _state;
  List<ProductModel> get products => _products;
  String? get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;
  // Kategori sesuai enum vegetables DBML: daun, akar, bunga, buah
  List<String> get categories => ['daun', 'akar', 'bunga', 'buah']; 

  // --- Load Products ---
  Future<void> loadProducts() async {
    try {
      _state = MarketplaceState.loading;
      final response = await marketplaceService.getProducts();
      _products = response.products;
      _state = MarketplaceState.loaded;
      _errorMessage = null;
      notifyListeners(); 
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
      notifyListeners(); 
    }
  }

  Future<void> loadInitialData() async {
    await loadProducts();
  }

  Future<void> resetFilters() async {
    _selectedCategory = null;
    await loadProducts();
  }

  // --- Filter & Search Products ---
  Future<void> filterByCategory(String? category) async {
    _selectedCategory = category;
    
    // Simpel filter: load semua dan filter lokal
    await loadProducts(); 
    
    if (category != null) {
      _products = _products.where((p) => p.category == category).toList();
    }
    notifyListeners();
  }

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
      notifyListeners(); 
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
      notifyListeners(); 
    }
  }

  // --- CRU/CRUD Logic (Digunakan oleh Admin/RT/RW screens) ---
  Future<bool> addProduct(ProductModel product) async {
    try {
      final newProduct = await marketplaceService.addProduct(
        name: product.name,
        description: product.description,
        price: product.price,
        stock: product.stock,
        category: product.category,
      );
      _products.insert(0, newProduct);
      notifyListeners(); 
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners(); 
      return false;
    }
  }

  Future<bool> updateProduct(ProductModel product) async {
     try {
      final updatedProduct = await marketplaceService.updateProduct(product);
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
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

  // --- Camera ---
  Future<XFile?> pickImageFromCamera() async {
    try {
      return await marketplaceService.pickImageFromCamera();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}