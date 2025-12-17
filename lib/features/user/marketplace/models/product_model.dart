// lib/features/user/marketplace/models/product_model.dart

/// Product Model - Matches DBML 'vegetables' table
class ProductModel {
  final int id;
  final String name;
  final String description; // Matches DBML 'desc'
  final double price;
  final int stock;
  final String imageUrl; // Matches DBML 'image'
  final String category; // 'daun', 'akar', 'bunga', 'buah'
  final String status; // 'available', 'unavailable'
  final int createdBy;
  final DateTime? createdAt;
  final String? createdByName; // Tambahan untuk display

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.category,
    required this.createdBy,
    required this.status,
    this.createdAt,
    this.createdByName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Memastikan harga dan stok di-parse dengan benar
    // Backend mengirim price sebagai string, perlu di-parse
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    return ProductModel(
      id: parseInt(json['id']),
      name: json['name'] ?? '',
      description: json['description'] ?? json['desc'] ?? '',
      price: parsePrice(json['price']),
      stock: parseInt(json['stock']),
      imageUrl: json['image'] ?? json['image_url'] ?? '',
      category: json['category'] ?? 'daun',
      status: json['status'] ?? 'available',
      createdBy: parseInt(json['created_by']),
      createdByName: json['created_by_name'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'desc': description, // Use 'desc' for API consistency with DBML
      'price': price,
      'stock': stock,
      'image': imageUrl, // Use 'image' for API consistency with DBML
      'category': category,
      'status': status,
      'created_by': createdBy,
    };
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
    String? status,
    int? createdBy,
    DateTime? createdAt,
    String? createdByName,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      createdByName: createdByName ?? this.createdByName,
    );
  }
}

/// Request model for adding a product
class AddProductRequest {
  final String name;
  final String desc;
  final double price;
  final int stock;
  final String category;
  final String imageBase64;

  AddProductRequest({
    required this.name,
    required this.desc,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': desc,
      'price': price,
      'stock': stock,
      'category': category,
      'image_base64': imageBase64,
    };
  }
}

/// Response model for API get products
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
