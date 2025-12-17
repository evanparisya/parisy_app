// lib/features/user/marketplace/services/marketplace_service.dart
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parisy_app/core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class MarketplaceService {
  final ApiClient apiClient;
  final ImagePicker _imagePicker = ImagePicker();

  MarketplaceService({required this.apiClient});

  // --- Helper Methods ---
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _setAuthToken() async {
    final token = await _getToken();
    if (token != null && token.isNotEmpty) {
      apiClient.dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<GetProductsResponse> _fetchProductsFromApi(String endpoint) async {
    try {
      final response = await apiClient.dio.get(endpoint);
      if (response.statusCode == 200) {
        // Backend returns array directly for list endpoints
        if (response.data is List) {
          final products = (response.data as List)
              .map((item) => ProductModel.fromJson(item))
              .toList();
          return GetProductsResponse(
            products: products,
            total: products.length,
          );
        }
        return GetProductsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch products');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching products: ${e.message}');
    }
  }

  Future<ProductModel> _fetchProductFromApi(String endpoint) async {
    try {
      final response = await apiClient.dio.get(endpoint);
      if (response.statusCode == 200) {
        // Backend /get/<id> returns vegetable data directly
        return ProductModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch product');
      }
    } on DioException catch (e) {
      throw Exception('Error fetching product: ${e.message}');
    }
  }

  Future<ProductModel> _updateProductApi(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      await _setAuthToken();
      final response = await apiClient.dio.put(endpoint, data: data);
      if (response.statusCode == 200) {
        return ProductModel.fromJson(
          response.data['vegetable'] ?? response.data,
        );
      } else {
        throw Exception('Failed to update product');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception(
          e.response?.data['message'] ?? 'Anda tidak memiliki izin',
        );
      }
      throw Exception('Error updating product: ${e.message}');
    }
  }

  // --- Read/List Products (Untuk tampilan Warga) ---
  Future<GetProductsResponse> getProducts() async {
    return _fetchProductsFromApi('/vegetable/list');
  }

  // --- Get Product Detail ---
  Future<ProductModel> getProductDetail(int id) async {
    return _fetchProductFromApi('/vegetable/get/$id');
  }

  // --- Get Products by Category ---
  Future<GetProductsResponse> getProductsByCategory(String category) async {
    return _fetchProductsFromApi('/vegetable/by-category/$category');
  }

  // --- Get Admin Products (All products including unavailable) ---
  Future<GetProductsResponse> getAdminProducts() async {
    return _fetchProductsFromApi('/vegetable/admin/list');
  }

  // --- Search Products ---
  Future<GetProductsResponse> searchProducts(
    String query, {
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query.isNotEmpty) queryParams['q'] = query;
      if (category != null && category.isNotEmpty)
        queryParams['category'] = category;

      final response = await apiClient.dio.get(
        '/vegetable/search',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        // Backend returns array directly
        if (response.data is List) {
          final products = (response.data as List)
              .map((item) => ProductModel.fromJson(item))
              .toList();
          return GetProductsResponse(
            products: products,
            total: products.length,
          );
        }
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
    try {
      await _setAuthToken();
      final response = await apiClient.dio.post(
        '/vegetable/add',
        data: {
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category': category,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ProductModel.fromJson(
          response.data['vegetable'] ?? response.data,
        );
      } else {
        throw Exception('Failed to add product');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
          e.response?.data['message'] ?? 'Data tidak lengkap',
        );
      }
      if (e.response?.statusCode == 409) {
        throw Exception(
          e.response?.data['message'] ??
              'Sayuran dengan nama tersebut sudah ada',
        );
      }
      if (e.response?.statusCode == 403) {
        throw Exception(
          e.response?.data['message'] ??
              'Anda tidak memiliki izin untuk menambah sayuran',
        );
      }
      throw Exception('Error adding product: ${e.message}');
    }
  }

  // --- Update Product (Digunakan oleh Admin/RT/RW) ---
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      await _setAuthToken();
      final response = await apiClient.dio.put(
        '/vegetable/update/${product.id}',
        data: {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'stock': product.stock,
          'category': product.category,
          'status': product.status,
        },
      );
      if (response.statusCode == 200) {
        return ProductModel.fromJson(
          response.data['vegetable'] ?? response.data,
        );
      } else {
        throw Exception('Failed to update product');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception(
          e.response?.data['message'] ??
              'Sayuran dengan nama tersebut sudah ada',
        );
      }
      if (e.response?.statusCode == 403) {
        throw Exception(
          e.response?.data['message'] ??
              'Anda tidak memiliki izin untuk mengupdate sayuran',
        );
      }
      throw Exception('Error updating product: ${e.message}');
    }
  }

  // --- Delete Product (Digunakan oleh Admin) ---
  Future<void> deleteProduct(int id) async {
    try {
      await _setAuthToken();
      final response = await apiClient.dio.delete('/vegetable/delete/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw Exception('Failed to delete product');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception(
          e.response?.data['message'] ??
              'Anda tidak memiliki izin untuk menghapus sayuran',
        );
      }
      throw Exception('Error deleting product: ${e.message}');
    }
  }

  // --- Update Stock (Digunakan oleh Admin/Sekretaris) ---
  Future<ProductModel> updateStock(int id, int newStock) async {
    return _updateProductApi('/vegetable/update-stock/$id', {'stock': newStock});
  }

  // --- Update Status (Digunakan oleh Admin/RT/RW) ---
  Future<ProductModel> updateStatus(int id, String newStatus) async {
    return _updateProductApi('/vegetable/update-status/$id', {
      'status': newStatus,
    });
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
