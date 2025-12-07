/// User Model - Represents authenticated user
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? address;
  final DateTime? createdAt;
  final String? role; // [WAJIB: Field role]

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.address,
    this.createdAt,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'role': role,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? address,
    DateTime? createdAt,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
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

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'name': name};
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
    // Handle both formats: data.user and direct user field
    final userData = json['data']?['user'] ?? json['user'] ?? {};
    return AuthResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      token: json['data']?['token'] ?? json['token'] ?? '',
      user: UserModel.fromJson(userData),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'user': user.toJson(),
    };
  }
}