import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/management/users/models/warga_model.dart';
import 'package:parisy_app/features/management/users/models/rt_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserManagementService {
  final ApiClient apiClient;

  UserManagementService({required this.apiClient});

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }
    return token;
  }

  WargaModel _parseUserData(Map<String, dynamic> json) {
    return WargaModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      subRole: json['sub_role'] ?? 'warga',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Future<List<WargaModel>> getAllUsers() async {
    try {
      final token = await _getToken();
      final response = await apiClient.getWithToken('auth/all', token);

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Gagal mengambil data pengguna');
      }

      final List<dynamic> usersData = response['data'] ?? [];
      return usersData.map((json) => _parseUserData(json)).toList();
    } catch (e) {
      throw Exception('Error mengambil data pengguna: $e');
    }
  }

  Future<List<WargaModel>> getUsersBySubRole(String subRole) async {
    try {
      final allUsers = await getAllUsers();
      return allUsers.where((user) => user.subRole == subRole).toList();
    } catch (e) {
      throw Exception(
        'Error mengambil data pengguna dengan sub_role $subRole: $e',
      );
    }
  }

  Future<WargaModel> addUser(WargaModel warga) async {
    try {
      final token = await _getToken();

      final response = await apiClient.postWithToken('auth/register', {
        'name': warga.name,
        'email': warga.email,
        'password': 'default123', 
        'role': warga.role,
        'sub_role': warga.subRole,
        'phone': warga.phone,
        'address': warga.address,
      }, token);

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Gagal menambahkan pengguna');
      }

      if (response['user'] != null) {
        return _parseUserData(response['user']);
      }

      return warga.copyWith(id: response['id'] ?? 0);
    } catch (e) {
      throw Exception('Error menambahkan pengguna: $e');
    }
  }

  Future<WargaModel> updateUser(WargaModel warga) async {
    try {
      final token = await _getToken();

      final updateData = {
        'name': warga.name,
        'address': warga.address,
        'phone': warga.phone,
      };

      final response = await apiClient.putWithToken(
        'auth/edit/${warga.id}',
        updateData,
        token,
      );

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Gagal mengupdate pengguna');
      }

      return warga.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw Exception('Error mengupdate pengguna: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final token = await _getToken();
      final response = await apiClient.deleteWithToken(
        'auth/delete/$id',
        token,
      );

      if (!response['success']) {
        throw Exception(response['message'] ?? 'Gagal menghapus pengguna');
      }
    } catch (e) {
      throw Exception('Error menghapus pengguna: $e');
    }
  }

  Future<List<RtModel>> getAllRT() async {
    try {
      final users = await getUsersBySubRole(AppStrings.subRoleRT);
      return users.map((warga) => RtModel.fromWargaModel(warga)).toList();
    } catch (e) {
      throw Exception('Error mengambil data RT: $e');
    }
  }

  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final users = await getAllUsers();

      final stats = <String, int>{
        'total': users.length,
        'admin': 0,
        'warga': 0,
        'rt': 0,
        'rw': 0,
        'sekretaris': 0,
        'bendahara': 0,
      };

      for (var user in users) {
        stats[user.subRole] = (stats[user.subRole] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Error mengambil statistik pengguna: $e');
    }
  }
}
