/// Product Model - JSON parsing untuk core marketplace
/// Demonstrates: JSON ✅
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String? description;
  final String? category;
  final double? rating;
  final int? reviewCount;
  final int? stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description,
    this.category,
    this.rating,
    this.reviewCount,
    this.stock,
  });

  /// JSON → Dart Object
  /// Demonstrates: JSON deserialization ✅
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? '',
      description: json['description'],
      category: json['category'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'],
      stock: json['stock'],
    );
  }

  /// Dart Object → JSON
  /// Demonstrates: JSON serialization ✅
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'description': description,
      'category': category,
      'rating': rating,
      'review_count': reviewCount,
      'stock': stock,
    };
  }

  @override
  String toString() => 'ProductModel(id: $id, name: $name, price: $price)';
}

/// Request model untuk menambah product dengan camera
/// Demonstrates: JSON + Camera integration ✅
class AddProductRequest {
  final String? imageBase64;
  final String name;
  final double price;

  AddProductRequest({
    required this.imageBase64,
    required this.name,
    required this.price,
  });

  /// Konversi ke JSON untuk API request
  /// Demonstrates: JSON serialization ✅
  Map<String, dynamic> toJson() {
    return {'image': imageBase64, 'name': name, 'price': price};
  }
}

/// Response model untuk API get products
/// Demonstrates: JSON parsing for collection ✅
class GetProductsResponse {
  final List<ProductModel> products;
  final int total;

  GetProductsResponse({required this.products, required this.total});

  factory GetProductsResponse.fromJson(Map<String, dynamic> json) {
    return GetProductsResponse(
      products: List<ProductModel>.from(
        (json['products'] as List? ?? []).map((x) => ProductModel.fromJson(x)),
      ),
      total: json['total'] ?? 0,
    );
  }
}
