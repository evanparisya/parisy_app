// lib/features/user/marketplace/services/marketplace_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parisy_app/core/api/api_client.dart';
import '../models/product_model.dart';

class MarketplaceService {
  final ApiClient apiClient;
  final ImagePicker _imagePicker = ImagePicker();

  MarketplaceService({required this.apiClient});

  // --- Fetch Products ---
  Future<GetProductsResponse> getProducts() async {
    final response = await apiClient.dio.get('/vegetable/list');
    return GetProductsResponse.fromJson(response.data);
  }

  Future<GetProductsResponse> getAdminProducts() async {
    final response = await apiClient.dio.get('/vegetable/admin/list');
    return GetProductsResponse.fromJson(response.data);
  }

  Future<GetProductsResponse> getProductsByCategory(String category) async {
    final response = await apiClient.dio.get('/vegetable/by-category/$category');
    return GetProductsResponse.fromJson(response.data);
  }

  Future<GetProductsResponse> searchProducts(String query, {String? category}) async {
    final queryParams = <String, dynamic>{'q': query};
    if (category != null) queryParams['category'] = category;
    
    final response = await apiClient.dio.get('/vegetable/search', queryParameters: queryParams);
    return GetProductsResponse.fromJson(response.data);
  }

  // --- Mutations ---
  Future<ProductModel> addProductWithImage({
    required String name,
    required String description,
    required double price,
    required int stock,
    required XFile imageFile,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(bytes);

    final response = await apiClient.dio.post(
      '/vegetable/add',
      data: {
        'name': name,
        'desc': description,
        'price': price,
        'stock': stock,
        'image_base64': base64Image,
      },
    );
    return ProductModel.fromJson(response.data['vegetable'] ?? response.data);
  }

  Future<ProductModel> updateStock(int id, int stock) async {
    final response = await apiClient.dio.put('/vegetable/update-stock/$id', data: {'stock': stock});
    return ProductModel.fromJson(response.data['vegetable'] ?? response.data);
  }

  Future<void> deleteProduct(int id) async {
    await apiClient.dio.delete('/vegetable/delete/$id');
  }

  // --- Helpers ---
  Future<XFile?> pickImageFromCamera() async {
    return await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 80);
  }
}