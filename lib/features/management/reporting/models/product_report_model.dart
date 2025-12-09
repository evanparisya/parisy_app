// lib/features/management/reporting/models/product_report_model.dart
// Category: daun, akar, bunga, buah
// Status: available, unavailable

class ProductReportModel {
  final int id;
  final String name;
  final String description; // Dari field 'desc' di DBML
  final double price;
  final int stock;
  final String image;
  final String category;
  final String status;
  final int createdBy;
  final String createdByName; // Field tambahan dari join users
  final DateTime createdAt;

  ProductReportModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    required this.category,
    required this.status,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
  });

  factory ProductReportModel.fromJson(Map<String, dynamic> json) {
    return ProductReportModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['desc'] ?? '', // Menggunakan 'desc' dari DBML
      price: (json['price'] ?? 0.0).toDouble(),
      stock: json['stock'] ?? 0,
      image: json['image'] ?? '',
      category: json['category'] ?? 'daun',
      status: json['status'] ?? 'available',
      createdBy: json['created_by'] ?? 0,
      createdByName: json['created_by_name'] ?? 'Admin/Penjual',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}