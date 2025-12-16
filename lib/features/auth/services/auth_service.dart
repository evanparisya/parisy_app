import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService({required this.apiClient});

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await apiClient.post('auth/login', {
        'email': email,
        'password': password,
      });

      if (result['success'] == true) {
        // Check if token and user exist in response
        if (result['token'] != null && result['user'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', result['token'].toString());
          await prefs.setString('user', json.encode(result['user']));
        } else {
          print('Warning: Login successful but missing token or user data');
          return {
            'success': false,
            'message': 'Response tidak lengkap dari server',
          };
        }
      }

      return result;
    } catch (e) {
      print('Login service error: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat login: ${e.toString()}',
      };
    }
  }

  // Register
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String address,
    String phone,
    String password,
  String role,
  String subRole
  ) async {
    return await apiClient.post('auth/register', {
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
      'password': password,
      'role': role,
      'sub_role': subRole,
    });
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
