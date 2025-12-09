// lib/features/management/users/models/warga_model.dart
import 'package:parisy_app/features/auth/models/user_model.dart';

class WargaModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String subRole; // rt, rw, bendahara, sekretaris, warga
  final DateTime createdAt;

  WargaModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.subRole,
    required this.createdAt,
  });

  factory WargaModel.fromUserModel(UserModel user) {
    return WargaModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone ?? 'N/A',
      address: user.address ?? 'N/A',
      subRole: user.subRole,
      createdAt: user.createdAt ?? DateTime.now(),
    );
  }

  factory WargaModel.fromJson(Map<String, dynamic> json) {
    return WargaModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? 'N/A',
      address: json['address'] ?? 'N/A',
      subRole: json['sub_role'] ?? 'warga',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
  
  WargaModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? subRole,
  }) {
    return WargaModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      subRole: subRole ?? this.subRole,
      createdAt: createdAt,
    );
  }
}