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

  // --- Helper Method ---
  Future<T?> _executeWithState<T>(Future<T> Function() operation) async {
    try {
      _state = MarketplaceState.loading;
      notifyListeners();

      final result = await operation();

      _state = MarketplaceState.loaded;
      _errorMessage = null;
      notifyListeners();
      return result;
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> _executeMutation(
    Future<ProductModel> Function() operation,
    void Function(ProductModel) onSuccess,
  ) async {
    try {
      final result = await operation();
      onSuccess(result);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Load Products ---
  Future<void> loadProducts() async {
    await _executeWithState(() async {
      final response = await marketplaceService.getProducts();
      _products = response.products;
    });
  }

  Future<void> loadInitialData() async {
    await loadProducts();
  }

  Future<void> resetFilters() async {
    _selectedCategory = null;
    await loadProducts();
  }

  // --- Get Product Detail ---
  Future<ProductModel?> getProductDetail(int id) async {
    return _executeWithState(() => marketplaceService.getProductDetail(id));
  }

  // --- Get Products by Category (via service) ---
  Future<void> loadProductsByCategory(String category) async {
    _selectedCategory = category;
    await _executeWithState(() async {
      final response = await marketplaceService.getProductsByCategory(category);
      _products = response.products;
    });
  }

  // --- Get Admin Products (All including unavailable) ---
  Future<void> loadAdminProducts() async {
    await _executeWithState(() async {
      final response = await marketplaceService.getAdminProducts();
      _products = response.products;
    });
  }

  // --- Filter & Search Products ---
  Future<void> filterByCategory(String? category) async {
    _selectedCategory = category;

    if (category == null) {
      await loadProducts();
    } else {
      await loadProductsByCategory(category);
    }
  }

  Future<void> searchProducts(String query, {String? category}) async {
    if (query.isEmpty && category == null) {
      await loadProducts();
      return;
    }

    await _executeWithState(() async {
      final response = await marketplaceService.searchProducts(
        query,
        category: category ?? _selectedCategory,
      );
      _products = response.products;
    });
  }

  // --- CRU/CRUD Logic (Digunakan oleh Admin/RT/RW screens) ---
  Future<bool> addProduct(ProductModel product) async {
    return _executeMutation(
      () => marketplaceService.addProduct(
        name: product.name,
        description: product.description,
        price: product.price,
        stock: product.stock,
        category: product.category,
      ),
      (newProduct) => _products.insert(0, newProduct),
    );
  }

  Future<bool> updateProduct(ProductModel product) async {
    return _executeMutation(() => marketplaceService.updateProduct(product), (
      updatedProduct,
    ) {
      final index = _products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) _products[index] = updatedProduct;
    });
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

  // --- Update Stock (Untuk Admin/Sekretaris) ---
  Future<bool> updateStock(int id, int newStock) async {
    return _executeMutation(
      () => marketplaceService.updateStock(id, newStock),
      (updatedProduct) {
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) _products[index] = updatedProduct;
      },
    );
  }

  // --- Update Status (Untuk Admin/RT/RW) ---
  Future<bool> updateStatus(int id, String newStatus) async {
    return _executeMutation(
      () => marketplaceService.updateStatus(id, newStatus),
      (updatedProduct) {
        final index = _products.indexWhere((p) => p.id == id);
        if (index != -1) _products[index] = updatedProduct;
      },
    );
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
