// lib/features/user/marketplace/services/marketplace_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/core/utils/category_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class MarketplaceService {
  final ApiClient apiClient;
  final ImagePicker _imagePicker = ImagePicker();

  MarketplaceService({required this.apiClient});

  // Helper method untuk mendapatkan token JWT
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }
    return token;
  }

  // Helper method untuk convert image file ke base64
  Future<String> _imageToBase64(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  // --- Fetch Products ---
  Future<GetProductsResponse> getProducts() async {
    final response = await apiClient.dio.get('/vegetable/list');
    return GetProductsResponse.fromJson(response.data);
  }

  Future<GetProductsResponse> getAdminProducts() async {
    try {
      final token = await _getToken();
      final response = await apiClient.dio.get(
        '/vegetable/admin/list',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return GetProductsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal mengambil data produk';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    }
  }

  Future<GetProductsResponse> getProductsByCategory(String category) async {
    final response = await apiClient.dio.get(
      '/vegetable/by-category/$category',
    );
    return GetProductsResponse.fromJson(response.data);
  }

  Future<GetProductsResponse> searchProducts(
    String query, {
    String? category,
  }) async {
    final queryParams = <String, dynamic>{'q': query};
    if (category != null) queryParams['category'] = category;

    final response = await apiClient.dio.get(
      '/vegetable/search',
      queryParameters: queryParams,
    );
    return GetProductsResponse.fromJson(response.data);
  }

  // --- Mutations ---
  Future<Map<String, dynamic>> addProductWithImage({
    required String name,
    required String description,
    required double price,
    required int stock,
    required XFile imageFile,
    String? category,
  }) async {
    try {
      final token = await _getToken();

      // Convert image to base64
      final imageBase64 = await _imageToBase64(imageFile);

      final data = {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'image': imageBase64,
      };

      // Hanya tambahkan category jika user memilih secara manual
      if (category != null && category.isNotEmpty) {
        data['category'] = category;
      }

      print('🔵 Sending product data with image...');
      final response = await apiClient.dio.post(
        '/vegetable/add',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Backend returns: { "message": "...", "vegetable": {...}, "predicted_category": "..." }
      final product = ProductModel.fromJson(response.data['vegetable']);
      final predictedCategory = response.data['predicted_category'];

      return {'product': product, 'predicted_category': predictedCategory};
    } on DioException catch (e) {
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal menambahkan produk';
        throw Exception(message);
      }
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  Future<ProductModel> updateStock(int id, int stock) async {
    try {
      final token = await _getToken();
      final response = await apiClient.dio.put(
        '/vegetable/update-stock/$id',
        data: {'stock': stock},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ProductModel.fromJson(response.data['vegetable'] ?? response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Gagal mengupdate stok';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    }
  }

  /// Update produk dengan foto baru
  Future<ProductModel> updateProductWithImage({
    required int id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required XFile imageFile,
    String? category,
  }) async {
    try {
      final token = await _getToken();

      // Convert image to base64
      final imageBase64 = await _imageToBase64(imageFile);

      final data = {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'image': imageBase64,
      };

      if (category != null && category.isNotEmpty) {
        data['category'] = category;
      }

      print('🔵 Updating product $id with new image...');
      final response = await apiClient.dio.put(
        '/vegetable/update/$id',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return ProductModel.fromJson(response.data['vegetable'] ?? response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal mengupdate produk';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    }
  }

  /// Update produk tanpa foto
  Future<ProductModel> updateProductWithoutImage({
    required int id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
  }) async {
    try {
      final token = await _getToken();

      final data = {
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
      };

      print('🔵 Updating product $id without new image...');
      final response = await apiClient.dio.put(
        '/vegetable/update/$id',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return ProductModel.fromJson(response.data['vegetable'] ?? response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal mengupdate produk';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final token = await _getToken();
      await apiClient.dio.delete(
        '/vegetable/delete/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Gagal menghapus produk';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    }
  }

  // --- AI Prediction ---
  /// Prediksi kategori dari gambar menggunakan AI
  /// API selalu mengembalikan salah satu dari: 'Sayur Daun', 'Sayur Akar', 'Sayur Bunga', 'Sayur Buah'
  Future<String> predictCategoryFromImage(XFile imageFile) async {
    print('🔵 Starting AI category prediction...');

    // Siapkan FormData untuk multipart upload
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'vegetable.jpg',
      ),
    });

    print('🔵 Sending image to AI prediction API (multipart/form-data)...');
    final response = await apiClient.dio.post(
      'https://sukinnamz-klasifikasi-kategori-sayur.hf.space/predict',
      data: formData,
      options: Options(
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'multipart/form-data',
      ),
    );

    print('🔵 AI Response: ${response.data}');

    final result = response.data;

    // Check status
    if (result['status'] != 'success') {
      throw Exception(result['message'] ?? 'Prediction failed');
    }

    // Get prediction value
    final aiCategory = result['prediction'];
    print('🔵 AI predicted category (raw): $aiCategory');

    // Normalize dari format AI (Sayur Daun) ke format DB (daun)
    final normalizedCategory = CategoryHelper.normalizeCategory(aiCategory);
    print('🟢 Normalized category: $normalizedCategory');

    // API selalu return valid category, tapi tetap validasi untuk safety
    if (normalizedCategory == null ||
        !CategoryHelper.isValid(normalizedCategory)) {
      throw Exception('AI returned invalid category: $aiCategory');
    }

    return normalizedCategory;
  }

  // --- Helpers ---
  Future<XFile?> pickImageFromCamera() async {
    return await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
  }
}
