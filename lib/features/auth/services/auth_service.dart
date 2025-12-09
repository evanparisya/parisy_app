// lib/features/auth/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/constants/dummy_data.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient apiClient;

  // Enable mock mode for testing (set to false when backend is ready)
  static const bool useMockAuth = true;

  AuthService({required this.apiClient});

  // Login dengan mock data untuk testing
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    // Jika mock mode aktif, gunakan mock data
    if (useMockAuth) {
      return _mockLogin(email: email, password: password);
    }

    // Jika tidak, gunakan API real
    return _apiLogin(email: email, password: password);
  }

  // Mock Login untuk testing (tanpa API)
  Future<AuthResponse> _mockLogin({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    final userMap = DummyData.mockUsers;
    UserModel? mockUser;

    // Menemukan user berdasarkan email
    if (userMap.containsKey(email)) {
      mockUser = userMap[email];
    }

    // Cek password. Di mock, password diasumsikan 'password' untuk semua user manajemen, dan password yang unik untuk user/warga.
    bool passwordMatch = false;
    if (mockUser != null) {
      if (mockUser.subRole != AppStrings.subRoleWarga && password == 'password') {
        passwordMatch = true;
      } else if (mockUser.email == 'warga@gmail.com' && password == 'password') {
        // Asumsi password warga juga 'password' untuk kemudahan testing
        passwordMatch = true;
      } else if (mockUser.email == 'admin@gmail.com' && password == 'password') {
        // Asumsi password admin juga 'password'
        passwordMatch = true;
      }
    }
    
    if (mockUser == null || !passwordMatch) {
        throw Exception('Email atau kata sandi salah');
    }

    return AuthResponse(
      success: true,
      message: 'Login berhasil',
      user: mockUser,
      token: 'mock_token_${mockUser.subRole}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // Real API Login
  Future<AuthResponse> _apiLogin({
    required String email,
    required String password,
  }) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);

      final response = await apiClient.dio.post(
        '/auth/login',
        data: loginRequest.toJson(),
      );

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(response.data);
      } else {
        // Cek jika response body memiliki pesan error
        final message = response.data['message'] ?? 'Login gagal';
        throw Exception(message);
      }
    } on DioException catch (e) {
      throw Exception('Login error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Register
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (useMockAuth) {
      return _mockRegister(email: email, password: password, name: name);
    }
    return _apiRegister(email: email, password: password, name: name);
  }

  // Mock Register untuk testing (tanpa API)
  Future<AuthResponse> _mockRegister({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(Duration(seconds: 2));

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('Data tidak boleh kosong');
    }
    
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch, // Unique mock ID
      name: name,
      email: email,
      role: AppStrings.roleUser, 
      subRole: AppStrings.subRoleWarga, // Default to warga
      phone: 'N/A',
      address: 'N/A',
      createdAt: DateTime.now(),
    );

    return AuthResponse(
      success: true,
      message: 'Registrasi berhasil',
      user: newUser,
      token: 'mock_token_register_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // Real API Register
  Future<AuthResponse> _apiRegister({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        name: name,
      );

      final response = await apiClient.dio.post(
        '/auth/register',
        data: registerRequest.toJson(),
      );

      if (response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        final message = response.data['message'] ?? 'Registrasi gagal';
        throw Exception(message);
      }
    } on DioException catch (e) {
      throw Exception('Register error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      if (!useMockAuth) {
        await _apiLogout();
      }
      apiClient.removeToken();
    } on DioException catch (e) {
      throw Exception('Logout error: ${e.message}');
    }
  }

  // Real API Logout
  Future<void> _apiLogout() async {
    await apiClient.dio.post('/auth/logout');
  }

  // Verify Token
  Future<UserModel> verifyToken() async {
    try {
      final response = await apiClient.dio.get('/auth/verify');

      if (response.statusCode == 200) {
        // Langsung parse data response sebagai UserModel
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Verifikasi token gagal');
      }
    } on DioException catch (e) {
      throw Exception('Verifikasi token error: ${e.message}');
    }
  }
}