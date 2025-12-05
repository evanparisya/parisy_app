import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
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

    // Check admin credentials
    if (email == 'admin@gmail.com' && password == 'password') {
      return AuthResponse(
        success: true,
        message: 'Login berhasil',
        user: UserModel(
          id: 'ADMIN-001',
          name: 'Admin Parisy',
          email: email,
          phone: '081234567890',
          address: 'Jakarta, Indonesia',
          createdAt: DateTime.now(),
        ),
        token: 'mock_token_admin_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    // Check user credentials
    if (email == 'user@gmail.com' && password == 'password') {
      return AuthResponse(
        success: true,
        message: 'Login berhasil',
        user: UserModel(
          id: 'USER-001',
          name: 'User',
          email: email,
          phone: '081234567890',
          address: 'Jakarta, Indonesia',
          createdAt: DateTime.now(),
        ),
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    // Check other dummy accounts
    final dummyAccounts = {
      'user@example.com': 'password123',
      'seller@example.com': 'seller123',
    };

    if (dummyAccounts.containsKey(email) && dummyAccounts[email] == password) {
      return AuthResponse(
        success: true,
        message: 'Login berhasil',
        user: UserModel(
          id: 'USER-${DateTime.now().millisecondsSinceEpoch}',
          name: email.split('@')[0].toUpperCase(),
          email: email,
          phone: '081234567890',
          address: 'Jakarta, Indonesia',
          createdAt: DateTime.now(),
        ),
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    throw Exception('Email atau password salah');
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
        throw Exception('Login failed');
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
    // Jika mock mode aktif, gunakan mock data
    if (useMockAuth) {
      return _mockRegister(email: email, password: password, name: name);
    }
    
    // Jika tidak, gunakan API real
    return _apiRegister(email: email, password: password, name: name);
  }

  // Mock Register untuk testing (tanpa API)
  Future<AuthResponse> _mockRegister({
    required String email,
    required String password,
    required String name,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    // Validasi sederhana
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('Data tidak boleh kosong');
    }

    // Mock registration success
    return AuthResponse(
      success: true,
      message: 'Registrasi berhasil',
      user: UserModel(
        id: 'USER-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        phone: '081234567890',
        address: 'Jakarta, Indonesia',
        createdAt: DateTime.now(),
      ),
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
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
        throw Exception('Register failed');
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
      // Jika mock mode aktif, gunakan mock logout
      if (useMockAuth) {
        await _mockLogout();
      } else {
        // Jika tidak, gunakan API real
        await _apiLogout();
      }
      apiClient.removeToken();
    } on DioException catch (e) {
      throw Exception('Logout error: ${e.message}');
    }
  }

  // Mock Logout
  Future<void> _mockLogout() async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
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
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Token verification failed');
      }
    } on DioException catch (e) {
      throw Exception('Token verification error: ${e.message}');
    }
  }
}
