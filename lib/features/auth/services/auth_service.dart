import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService({required this.apiClient});

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await apiClient.post('auth/login', {
        'email': email,
        'password': password,
      });

      if (result['success'] == true) {
        if (result['token'] == null || result['user'] == null) {
          return {
            'success': false,
            'message': 'Response tidak lengkap dari server',
          };
        }

        await _saveAuthData(
          token: result['token'].toString(),
          userData: result['user'],
        );
      }

      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat login: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String address,
    String phone,
    String password,
    String role,
    String subRole,
  ) async {
    try {
      return await apiClient.post('auth/register', {
        'name': name,
        'email': email,
        'address': address,
        'phone': phone,
        'password': password,
        'role': role,
        'sub_role': subRole,
      });
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat registrasi: ${e.toString()}',
      };
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _saveAuthData({
    required String token,
    required Map<String, dynamic> userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', json.encode(userData));
  }
}
