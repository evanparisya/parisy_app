// lib/features/management/users/services/user_management_service.dart
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/constants/dummy_data.dart';
import 'package:parisy_app/features/management/users/models/warga_model.dart';
import 'package:parisy_app/features/management/users/models/rt_model.dart';
import 'package:parisy_app/features/management/users/models/rw_model.dart';

class UserManagementService {
  final ApiClient apiClient;

  // Gunakan mock untuk pengembangan awal
  static const bool useMock = true;

  UserManagementService({required this.apiClient});

  // --- MOCK STORAGE (Perlu diimplementasi secara penuh di backend Flask) ---
  static final List<WargaModel> _mockUsersList = DummyData.mockUsers.values
      .map((u) => WargaModel.fromUserModel(u))
      .toList();
  // --- END MOCK STORAGE ---

  Future<List<WargaModel>> getAllUsers() async {
    if (useMock) {
      await Future.delayed(Duration(seconds: 1));
      // Hanya menampilkan warga dan RT/RW, tidak termasuk Admin
      return List.from(_mockUsersList.where((u) => u.subRole != AppStrings.subRoleAdmin));
    }
    throw UnimplementedError('API fetch all users belum diimplementasi');
  }

  Future<List<WargaModel>> getWargaBySubRole(String subRole) async {
    if (useMock) {
      await Future.delayed(Duration(milliseconds: 500));
      return List.from(_mockUsersList.where((u) => u.subRole == subRole));
    }
    throw UnimplementedError();
  }

  Future<WargaModel> addUser(WargaModel warga) async {
    if (useMock) {
      await Future.delayed(Duration(seconds: 1));
      final newId = _mockUsersList.map((u) => u.id).fold(0, (a, b) => a > b ? a : b) + 1;
      final newWarga = warga.copyWith(
        name: warga.name, // Diabaikan di sini, nanti di controller
        email: warga.email,
        phone: warga.phone,
        address: warga.address,
      );
      _mockUsersList.add(newWarga);
      return newWarga;
    }
    throw UnimplementedError('API add user belum diimplementasi');
  }

  Future<WargaModel> updateUser(WargaModel warga) async {
    if (useMock) {
      await Future.delayed(Duration(seconds: 1));
      final index = _mockUsersList.indexWhere((u) => u.id == warga.id);
      if (index >= 0) {
        _mockUsersList[index] = warga;
        return warga;
      }
      throw Exception('Warga tidak ditemukan');
    }
    throw UnimplementedError('API update user belum diimplementasi');
  }

  Future<void> deleteUser(int id) async {
    if (useMock) {
      await Future.delayed(Duration(seconds: 1));
      _mockUsersList.removeWhere((u) => u.id == id);
      return;
    }
    throw UnimplementedError('API delete user belum diimplementasi');
  }

  // --- Kelola RT (Fungsi khusus RW) ---
  Future<List<RtModel>> getAllRT() async {
    if (useMock) {
      await Future.delayed(Duration(milliseconds: 500));
      return List.from(_mockUsersList.where((u) => u.subRole == AppStrings.subRoleRT).map((u) => RtModel.fromWargaModel(u)));
    }
    throw UnimplementedError();
  }
}