// lib/features/user/marketplace/services/marketplace_service.dart
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/core/constants/dummy_data.dart';
import '../models/product_model.dart';

class MarketplaceService {
  final ApiClient apiClient;
  final ImagePicker _imagePicker = ImagePicker();

  static const bool useMockMarketplace = false;

  MarketplaceService({required this.apiClient});

  // --- Helper Methods ---
  Future<T> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    required Future<T> Function() mockCall,
  }) async {
    if (useMockMarketplace) {
      return await mockCall();
    }
    return await apiCall();
  }

  Future<GetProductsResponse> _fetchProductsFromApi(String endpoint) async {
    try {
      final response = await apiClient.dio.get(endpoint);
      if (response.statusCode == 200) {
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
        return ProductModel.fromJson(response.data['product'] ?? response.data);
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
      final response = await apiClient.dio.put(endpoint, data: data);
      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data['product'] ?? response.data);
      } else {
        throw Exception('Failed to update product');
      }
    } on DioException catch (e) {
      throw Exception('Error updating product: ${e.message}');
    }
  }

  // --- Read/List Products (Untuk tampilan Warga) ---
  Future<GetProductsResponse> getProducts() async {
    return _handleApiCall(
      mockCall: () async {
        await Future.delayed(Duration(seconds: 1));
        final mockProducts = DummyData.mockProducts
            .map((p) => p.copyWith(createdByName: 'Penjual Mock'))
            .toList();
        return GetProductsResponse(
          products: mockProducts.where((p) => p.status == 'available').toList(),
          total: mockProducts.length,
        );
      },
      apiCall: () => _fetchProductsFromApi('/marketplace/products'),
    );
  }

  // --- Get Product Detail ---
  Future<ProductModel> getProductDetail(int id) async {
    return _handleApiCall(
      mockCall: () async {
        await Future.delayed(Duration(milliseconds: 500));
        return DummyData.mockProducts.firstWhere(
          (p) => p.id == id,
          orElse: () => throw Exception('Produk tidak ditemukan'),
        );
      },
      apiCall: () => _fetchProductFromApi('/marketplace/products/$id'),
    );
  }

  // --- Get Products by Category ---
  Future<GetProductsResponse> getProductsByCategory(String category) async {
    return _handleApiCall(
      mockCall: () async {
        await Future.delayed(Duration(milliseconds: 500));
        final filtered = DummyData.mockProducts
            .where((p) => p.status == 'available' && p.category == category)
            .toList();
        return GetProductsResponse(products: filtered, total: filtered.length);
      },
      apiCall: () =>
          _fetchProductsFromApi('/marketplace/products/category/$category'),
    );
  }

  // --- Get Admin Products (All products including unavailable) ---
  Future<GetProductsResponse> getAdminProducts() async {
    return _handleApiCall(
      mockCall: () async {
        await Future.delayed(Duration(seconds: 1));
        final sortedProducts = List<ProductModel>.from(DummyData.mockProducts)
          ..sort((a, b) {
            if (a.status == b.status) return a.name.compareTo(b.name);
            return a.status == 'available' ? -1 : 1;
          });
        return GetProductsResponse(
          products: sortedProducts,
          total: sortedProducts.length,
        );
      },
      apiCall: () => _fetchProductsFromApi('/marketplace/admin/products'),
    );
  }

  // --- Search Products ---
  Future<GetProductsResponse> searchProducts(
    String query, {
    String? category,
  }) async {
    if (useMockMarketplace) {
      await Future.delayed(Duration(milliseconds: 500));
      var filtered = DummyData.mockProducts
          .where((p) => p.status == 'available')
          .toList();

      // Filter by query (name or description)
      if (query.isNotEmpty) {
        filtered = filtered
            .where(
              (p) =>
                  p.name.toLowerCase().contains(query.toLowerCase()) ||
                  p.description.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }

      // Filter by category
      if (category != null && category.isNotEmpty) {
        filtered = filtered.where((p) => p.category == category).toList();
      }

      // Sort by name
      filtered.sort((a, b) => a.name.compareTo(b.name));

      return GetProductsResponse(products: filtered, total: filtered.length);
    }
    try {
      final queryParams = <String, dynamic>{};
      if (query.isNotEmpty) queryParams['q'] = query;
      if (category != null && category.isNotEmpty)
        queryParams['category'] = category;

      final response = await apiClient.dio.get(
        '/marketplace/products/search',
        queryParameters: queryParams,
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
    return _handleApiCall(
      mockCall: () async {
        await Future.delayed(Duration(seconds: 1));
        final newId =
            DummyData.mockProducts
                .map((p) => p.id)
                .fold(0, (a, b) => a > b ? a : b) +
            1;
        final newProduct = ProductModel(
          id: newId,
          name: name,
          description: description,
          price: price,
          stock: stock,
          imageUrl: 'https://via.placeholder.com/300?text=$name',
          category: category,
          status: 'available',
          createdBy: 1,
          createdAt: DateTime.now(),
          createdByName: 'Penjual Baru Mock',
        );
        DummyData.mockProducts.add(newProduct);
        return newProduct;
      },
      apiCall: () async {
        try {
          final response = await apiClient.dio.post(
            '/marketplace/products',
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
              response.data['product'] ?? response.data,
            );
          } else {
            throw Exception('Failed to add product');
          }
        } on DioException catch (e) {
          throw Exception('Error adding product: ${e.message}');
        }
      },
    );
  }

  // --- Update Product (Digunakan oleh Admin/RT/RW) ---
  Future<ProductModel> updateProduct(ProductModel product) async {
    return _handleApiCall(
      mockCall: () async {
        await Future.delayed(Duration(seconds: 1));
        final index = DummyData.mockProducts.indexWhere(
          (p) => p.id == product.id,
        );
        if (index >= 0) {
          DummyData.mockProducts[index] = product;
          return product;
        }
        throw Exception('Produk tidak ditemukan saat update.');
      },
      apiCall: () async {
        try {
          final response = await apiClient.dio.put(
            '/marketplace/products/${product.id}',
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
              response.data['product'] ?? response.data,
            );
          } else {
            throw Exception('Failed to update product');
          }
        } on DioException catch (e) {
          throw Exception('Error updating product: ${e.message}');
        }
      },
    );
  }

  // --- Delete Product (Digunakan oleh Admin) ---
  Future<void> deleteProduct(int id) async {
    return _handleApiCall(
      mockCall: () async {
        await Future.delayed(Duration(seconds: 1));
        DummyData.mockProducts.removeWhere((p) => p.id == id);
      },
      apiCall: () async {
        try {
          final response = await apiClient.dio.delete(
            '/marketplace/products/$id',
          );
          if (response.statusCode == 200 || response.statusCode == 204) {
            return;
          } else {
            throw Exception('Failed to delete product');
          }
        } on DioException catch (e) {
          throw Exception('Error deleting product: ${e.message}');
        }
      },
    );
  }

  // --- Update Stock (Digunakan oleh Admin/Sekretaris) ---
  Future<ProductModel> updateStock(int id, int newStock) async {
    return _handleApiCall(
      mockCall: () async {
        await Future.delayed(Duration(seconds: 1));
        final index = DummyData.mockProducts.indexWhere((p) => p.id == id);
        if (index >= 0) {
          final updatedProduct = DummyData.mockProducts[index].copyWith(
            stock: newStock,
          );
          DummyData.mockProducts[index] = updatedProduct;
          return updatedProduct;
        }
        throw Exception('Produk tidak ditemukan saat update stock.');
      },
      apiCall: () => _updateProductApi('/marketplace/products/$id/stock', {
        'stock': newStock,
      }),
    );
  }

  // --- Update Status (Digunakan oleh Admin/RT/RW) ---
  Future<ProductModel> updateStatus(int id, String newStatus) async {
    return _handleApiCall(
      mockCall: () async {
        await Future.delayed(Duration(seconds: 1));
        if (newStatus != 'available' && newStatus != 'unavailable') {
          throw Exception('Status harus "available" atau "unavailable"');
        }
        final index = DummyData.mockProducts.indexWhere((p) => p.id == id);
        if (index >= 0) {
          final updatedProduct = DummyData.mockProducts[index].copyWith(
            status: newStatus,
          );
          DummyData.mockProducts[index] = updatedProduct;
          return updatedProduct;
        }
        throw Exception('Produk tidak ditemukan saat update status.');
      },
      apiCall: () => _updateProductApi('/marketplace/products/$id/status', {
        'status': newStatus,
      }),
    );
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
