import 'package:parisy_app/features/auth/models/user_model.dart';

class AdminUserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime createdAt;
  final String? role; // resident, seller, etc

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.createdAt,
    this.role,
  });

  // Convert UserModel to AdminUserModel
  factory AdminUserModel.fromUserModel(UserModel user) {
    return AdminUserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone ?? 'N/A',
      address: user.address ?? 'N/A',
      createdAt: user.createdAt ?? DateTime.now(),
    );
  }

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      createdAt: DateTime.parse(json['createdAt']),
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'role': role,
    };
  }
}
