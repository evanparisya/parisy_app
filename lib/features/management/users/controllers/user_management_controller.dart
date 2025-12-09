// lib/features/management/users/controllers/user_management_controller.dart (Perbaikan)

import 'package:flutter/material.dart';
import 'package:parisy_app/features/management/users/models/warga_model.dart';
import 'package:parisy_app/features/management/users/models/rt_model.dart';
import 'package:parisy_app/features/management/users/services/user_management_service.dart';
import 'package:parisy_app/core/constants/app_constants.dart';

enum UserManagementState { initial, loading, loaded, error }

class UserManagementController extends ChangeNotifier {
  final UserManagementService service;

  UserManagementState _state = UserManagementState.initial;
  String? _errorMessage;
  List<WargaModel> _wargaList = [];
  List<RtModel> _rtList = [];

  UserManagementController({required this.service});

  UserManagementState get state => _state;
  String? get errorMessage => _errorMessage;
  List<WargaModel> get wargaList => _wargaList;
  List<RtModel> get rtList => _rtList;

  // --- Warga (Digunakan oleh Admin/RT/RW) ---

  Future<void> loadAllWarga() async {
    try {
      _state = UserManagementState.loading;
      notifyListeners();
      _wargaList = await service.getAllUsers();
      _state = UserManagementState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = UserManagementState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadWargaByRT(String rtIdentifier) async {
    try {
      _state = UserManagementState.loading;
      notifyListeners();

      // Perbaikan baris 44: Mengakses properti statis langsung melalui nama kelas
      if (UserManagementService.useMock) { 
        await loadAllWarga(); 
        // Simulasi filter: di implementasi nyata, ini akan memanggil API /users?rt_id=X
        _wargaList = _wargaList.where((w) => w.subRole == AppStrings.subRoleWarga).toList();
        _state = UserManagementState.loaded;
        return;
      }
      throw UnimplementedError('Filter Warga by RT belum diimplementasi');

    } catch (e) {
      _state = UserManagementState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }


  Future<bool> addWarga(WargaModel warga) async {
    try {
      _state = UserManagementState.loading;
      notifyListeners();
      await service.addUser(warga);
      await loadAllWarga();
      return true;
    } catch (e) {
      _state = UserManagementState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWarga(WargaModel warga) async {
    try {
      _state = UserManagementState.loading;
      notifyListeners();
      await service.updateUser(warga);
      await loadAllWarga();
      return true;
    } catch (e) {
      _state = UserManagementState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWarga(int id) async {
    try {
      _state = UserManagementState.loading;
      notifyListeners();
      await service.deleteUser(id);
      await loadAllWarga();
      return true;
    } catch (e) {
      _state = UserManagementState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Kelola RT (Digunakan oleh RW) ---

  Future<void> loadAllRT() async {
    try {
      _state = UserManagementState.loading;
      notifyListeners();
      _rtList = await service.getAllRT();
      _state = UserManagementState.loaded;
      _errorMessage = null;
    } catch (e) {
      _state = UserManagementState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
}