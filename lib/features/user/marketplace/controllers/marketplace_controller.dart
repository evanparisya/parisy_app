// lib/features/user/marketplace/controllers/marketplace_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parisy_app/core/utils/category_helper.dart';
import '../models/product_model.dart';
import '../services/marketplace_service.dart';

enum MarketplaceState { initial, loading, loaded, error }

class MarketplaceController extends ChangeNotifier {
  final MarketplaceService marketplaceService;

  MarketplaceState _state = MarketplaceState.initial;
  List<ProductModel> _products = [];
  String? _selectedCategory;
  String? _errorMessage;

  // Stream untuk real-time product updates
  final StreamController<List<ProductModel>> _productsStreamController =
      StreamController<List<ProductModel>>.broadcast();

  // Stream untuk notifications/messages
  final StreamController<String> _notificationStreamController =
      StreamController<String>.broadcast();

  MarketplaceController({required this.marketplaceService});

  // --- Getters ---
  MarketplaceState get state => _state;
  List<ProductModel> get products => _products;
  String? get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;
  List<String> get categories => CategoryHelper.categories;

  // Stream getters
  Stream<List<ProductModel>> get productsStream =>
      _productsStreamController.stream;
  Stream<String> get notificationStream => _notificationStreamController.stream;

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
      // Broadcast ke stream
      _productsStreamController.add(_products);
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
      _notificationStreamController.add('Gagal memuat produk: $e');
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
      // Broadcast ke stream
      _productsStreamController.add(_products);
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
      _notificationStreamController.add('Gagal memuat produk admin: $e');
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
      // Broadcast ke stream
      _productsStreamController.add(_products);
    } catch (e) {
      _state = MarketplaceState.error;
      _notificationStreamController.add('Gagal memuat produk kategori: $e');
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
        category: category ?? _selectedCategory,
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
    String? category,
  }) async {
    try {
      _state = MarketplaceState.loading;
      notifyListeners();

      // Mengirim ke service yang akan melakukan konversi base64 dan prediksi kategori
      final result = await marketplaceService.addProductWithImage(
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageFile: image,
        category: category,
      );

      // result berisi: product dan predicted_category (optional)
      _products.insert(0, result['product']);

      // Broadcast ke stream
      _productsStreamController.add(_products);
      _notificationStreamController.add('Produk berhasil ditambahkan');

      // Simpan predicted category jika ada untuk ditampilkan ke user
      final predictedCategory = result['predicted_category'];
      if (predictedCategory != null) {
        _errorMessage = 'Kategori diprediksi: $predictedCategory';
      }

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
        // Broadcast ke stream
        _productsStreamController.add(_products);
        _notificationStreamController.add('Stok berhasil diupdate');
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _notificationStreamController.add('Gagal update stok: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update produk dengan foto baru (akan prediksi kategori otomatis jika category null)
  Future<bool> updateProductWithNewImage({
    required int id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required XFile image,
    String? category,
  }) async {
    try {
      _state = MarketplaceState.loading;
      notifyListeners();

      final updatedProduct = await marketplaceService.updateProductWithImage(
        id: id,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageFile: image,
        category: category,
      );

      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
        // Broadcast ke stream
        _productsStreamController.add(_products);
        _notificationStreamController.add(
          'Produk berhasil diupdate dengan foto baru',
        );
      }

      _state = MarketplaceState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
      _notificationStreamController.add('Gagal update produk: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update produk tanpa foto baru
  Future<bool> updateProductWithoutImage({
    required int id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
  }) async {
    try {
      _state = MarketplaceState.loading;
      notifyListeners();

      final updatedProduct = await marketplaceService.updateProductWithoutImage(
        id: id,
        name: name,
        description: description,
        price: price,
        stock: stock,
        category: category,
      );

      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
        // Broadcast ke stream
        _productsStreamController.add(_products);
        _notificationStreamController.add('Produk berhasil diupdate');
      }

      _state = MarketplaceState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = MarketplaceState.error;
      _errorMessage = e.toString();
      _notificationStreamController.add('Gagal update produk: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await marketplaceService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      // Broadcast ke stream
      _productsStreamController.add(_products);
      _notificationStreamController.add('Produk berhasil dihapus');
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _notificationStreamController.add('Gagal hapus produk: $e');
      notifyListeners();
    }
  }

  Future<XFile?> pickImageFromCamera() async {
    return await marketplaceService.pickImageFromCamera();
  }

  /// Prediksi kategori dari gambar menggunakan AI
  /// Throws exception jika gagal
  Future<String> predictCategory(XFile imageFile) async {
    return await marketplaceService.predictCategoryFromImage(imageFile);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _productsStreamController.close();
    _notificationStreamController.close();
    super.dispose();
  }
}
