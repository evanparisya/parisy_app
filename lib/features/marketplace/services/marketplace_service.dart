import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../models/product_model.dart';

/// Marketplace Service - Demonstrates all 6 core features
/// Camera 📷 + JSON 📄 + Async ⏳ + RestAPI 🌐
class MarketplaceService {
  final ApiClient apiClient;
  final ImagePicker _imagePicker = ImagePicker();

  // Enable mock mode for testing (set to false when backend is ready)
  static const bool useMockMarketplace = true;

  MarketplaceService({required this.apiClient});

  /// Get all products from API or mock
  /// Demonstrates: Async ⏳ + RestAPI 🌐 + JSON 📄
  Future<GetProductsResponse> getProducts() async {
    if (useMockMarketplace) {
      return _mockGetProducts();
    }
    return _apiGetProducts();
  }

  /// Mock get products
  Future<GetProductsResponse> _mockGetProducts() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    final mockProducts = [
      ProductModel(
        id: 'PROD-001',
        name: 'Laptop Gaming ASUS ROG',
        price: 15000000.0,
        imageUrl: 'https://via.placeholder.com/300x300?text=Laptop+Gaming',
        description:
            'Laptop gaming performa tinggi dengan prosesor Intel Core i9 dan GPU RTX 4090. Sempurna untuk gaming dan rendering video.',
        category: 'Elektronik',
        rating: 4.8,
        reviewCount: 156,
        stock: 12,
      ),
      ProductModel(
        id: 'PROD-002',
        name: 'Smartphone Flagship 5G',
        price: 8999000.0,
        imageUrl: 'https://via.placeholder.com/300x300?text=Smartphone',
        description:
            'Smartphone flagship dengan layar 6.7" AMOLED 120Hz, kamera 200MP, dan baterai 5000mAh.',
        category: 'Elektronik',
        rating: 4.7,
        reviewCount: 243,
        stock: 25,
      ),
      ProductModel(
        id: 'PROD-003',
        name: 'Earbuds Wireless Premium',
        price: 1200000.0,
        imageUrl: 'https://via.placeholder.com/300x300?text=Earbuds',
        description:
            'True wireless earbuds dengan noise cancellation aktif, 8 jam battery life per charge.',
        category: 'Aksesoris',
        rating: 4.5,
        reviewCount: 89,
        stock: 50,
      ),
      ProductModel(
        id: 'PROD-004',
        name: 'Kemeja Premium Cotton',
        price: 250000.0,
        imageUrl: 'https://via.placeholder.com/300x300?text=Kemeja',
        description:
            'Kemeja pria premium dari katun 100% berkualitas tinggi. Tersedia dalam berbagai ukuran dan warna.',
        category: 'Fashion',
        rating: 4.6,
        reviewCount: 142,
        stock: 100,
      ),
      ProductModel(
        id: 'PROD-005',
        name: 'Kopi Specialty Arabica',
        price: 85000.0,
        imageUrl: 'https://via.placeholder.com/300x300?text=Kopi',
        description:
            'Kopi specialty arabica pilihan dari berbagai region dengan roasting yang sempurna. Berat bersih 500g.',
        category: 'Makanan',
        rating: 4.9,
        reviewCount: 267,
        stock: 200,
      ),
    ];

    return GetProductsResponse(
      products: mockProducts,
      total: mockProducts.length,
    );
  }

  /// Real API get products
  Future<GetProductsResponse> _apiGetProducts() async {
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

  /// Search products by query
  /// Demonstrates: Async ⏳ + RestAPI 🌐 + JSON 📄
  Future<GetProductsResponse> searchProducts(String query) async {
    if (useMockMarketplace) {
      return _mockSearchProducts(query);
    }
    return _apiSearchProducts(query);
  }

  /// Mock search products
  Future<GetProductsResponse> _mockSearchProducts(String query) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    final mockProducts = [
      ProductModel(
        id: 'PROD-001',
        name: 'Laptop Gaming ASUS ROG',
        price: 15000000.0,
        imageUrl: 'https://via.placeholder.com/300x300?text=Laptop+Gaming',
      ),
      ProductModel(
        id: 'PROD-002',
        name: 'Smartphone Flagship 5G',
        price: 8999000.0,
        imageUrl: 'https://via.placeholder.com/300x300?text=Smartphone',
      ),
    ];

    // Filter by query
    final filtered = mockProducts
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return GetProductsResponse(products: filtered, total: filtered.length);
  }

  /// Real API search products
  Future<GetProductsResponse> _apiSearchProducts(String query) async {
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

  /// Add new product with camera image
  /// Demonstrates: Camera 📷 + Async ⏳ + JSON 📄 + RestAPI 🌐
  Future<ProductModel> addProduct({
    required XFile image,
    required String name,
    required double price,
  }) async {
    try {
      /// Read image file and convert to Base64
      /// Demonstrates: Camera 📷
      final imageBytes = await image.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      /// Create request model
      /// Demonstrates: JSON serialization ✅
      final request = AddProductRequest(
        imageBase64: imageBase64,
        name: name,
        price: price,
      );

      /// Send to API
      /// Demonstrates: Async ⏳ + RestAPI 🌐 + JSON 📄
      final response = await apiClient.dio.post(
        '/marketplace/products',
        data: request.toJson(),
      );

      if (response.statusCode == 201) {
        return ProductModel.fromJson(response.data);
      } else {
        throw Exception('Failed to add product');
      }
    } on DioException catch (e) {
      throw Exception('Error adding product: ${e.message}');
    }
  }

  /// Pick image from camera
  /// Demonstrates: Camera 📷
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
