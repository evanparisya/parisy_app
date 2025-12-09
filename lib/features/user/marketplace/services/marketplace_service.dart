// lib/features/user/marketplace/services/marketplace_service.dart
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/core/constants/dummy_data.dart';
import '../models/product_model.dart';

class MarketplaceService {
  final ApiClient apiClient;
  final ImagePicker _imagePicker = ImagePicker();

  static const bool useMockMarketplace = true;

  MarketplaceService({required this.apiClient});

  // --- Read/List Products (Untuk tampilan Warga) ---
  Future<GetProductsResponse> getProducts() async {
    if (useMockMarketplace) {
      await Future.delayed(Duration(seconds: 1));
      final mockProducts = DummyData.mockProducts.map((p) => p.copyWith(createdByName: 'Penjual Mock')).toList();
      return GetProductsResponse(
        products: mockProducts.where((p) => p.status == 'available').toList(),
        total: mockProducts.length,
      );
    }
    try {
      final response = await apiClient.dio.get('/marketplace/products');
      if (response.statusCode == 200) {
        return GetProductsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch products');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching products: ${e.message}');
    }
  }

  // --- Search Products ---
  Future<GetProductsResponse> searchProducts(String query) async {
    if (useMockMarketplace) {
      await Future.delayed(Duration(milliseconds: 500));
      final filtered = DummyData.mockProducts
          .where((p) => 
              p.status == 'available' &&
              (p.name.toLowerCase().contains(query.toLowerCase()) || 
               p.description.toLowerCase().contains(query.toLowerCase())))
          .toList();

      return GetProductsResponse(products: filtered, total: filtered.length);
    }
    try {
      final response = await apiClient.dio.get(
        '/marketplace/products',
        queryParameters: {'q': query},
      );
      if (response.statusCode == 200) {
        return GetProductsResponse.fromJson(response.data);
      } else {
        throw Exception('Search failed');
      }
    } on DioException catch (e) {
      throw Exception('Search error: ${e.message}');
    }
  }

  // --- Add/Create Product (Digunakan oleh Admin/RT/RW) ---
  Future<ProductModel> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
  }) async {
    if (useMockMarketplace) {
      await Future.delayed(Duration(seconds: 1));
      final newId = DummyData.mockProducts.map((p) => p.id).fold(0, (a, b) => a > b ? a : b) + 1;
      final newProduct = ProductModel(
        id: newId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageUrl: 'https://via.placeholder.com/300?text=$name',
        category: category,
        status: 'available',
        createdBy: 1, // Mock user ID
        createdAt: DateTime.now(),
        createdByName: 'Penjual Baru Mock',
      );
      DummyData.mockProducts.add(newProduct);
      return newProduct;
    }
    throw UnimplementedError('API addProduct belum diimplementasi');
  }

  // --- Update Product (Digunakan oleh Admin/RT/RW) ---
  Future<ProductModel> updateProduct(ProductModel product) async {
    if (useMockMarketplace) {
      await Future.delayed(Duration(seconds: 1));
      final index = DummyData.mockProducts.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        DummyData.mockProducts[index] = product;
        return product;
      }
      throw Exception('Produk tidak ditemukan saat update.');
    }
    throw UnimplementedError('API updateProduct belum diimplementasi');
  }

  // --- Delete Product (Digunakan oleh Admin) ---
  Future<void> deleteProduct(int id) async {
    if (useMockMarketplace) {
      await Future.delayed(Duration(seconds: 1));
      DummyData.mockProducts.removeWhere((p) => p.id == id);
      return;
    }
    throw UnimplementedError('API deleteProduct belum diimplementasi');
  }

  // --- Camera/Image Picker (Digunakan untuk searching dengan kamera) ---
  Future<XFile?> pickImageFromCamera() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Error picking image: $e');
    }
  }
}