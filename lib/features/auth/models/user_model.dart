// lib/features/auth/models/user_model.dart

/// User Model - Represents authenticated user (Matches DBML 'users' table)
class UserModel {
  final int id;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final String role;       // 'admin' or 'user' (from DBML)
  final String subRole;    // 'warga', 'rt', 'rw', 'bendahara', 'sekretaris' (from DBML)
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.subRole,
    this.phone,
    this.address,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Memastikan ID di-parse sebagai int
    final idValue = json['id'] is String ? int.tryParse(json['id']) : json['id'];
    
    // Default role jika tidak ada
    final String defaultRole = json['sub_role'] == 'admin' ? 'admin' : 'user';

    return UserModel(
      id: idValue ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      role: json['role'] ?? defaultRole,
      subRole: json['sub_role'] ?? 'warga',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'role': role,
      'sub_role': subRole,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? email,
    String? name,
    String? phone,
    String? address,
    DateTime? createdAt,
    String? role,
    String? subRole,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      subRole: subRole ?? this.subRole,
    );
  }
}

/// Login Request - For login API call
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

/// Register Request - For register API call
class RegisterRequest {
  final String email;
  final String password;
  final String name;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  // Menambahkan role default 'user' dan sub_role 'warga' saat register awal
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'role': 'user', 
      'sub_role': 'warga',
    };
  }
}

/// Auth Response - Response from auth endpoints
class AuthResponse {
  final bool success;
  final String message;
  final String token;
  final UserModel user;

  AuthResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final userData = json['data']?['user'] ?? json['user'] ?? {};
    return AuthResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      token: json['data']?['token'] ?? json['token'] ?? '',
      user: UserModel.fromJson(userData),
    );
  }
}