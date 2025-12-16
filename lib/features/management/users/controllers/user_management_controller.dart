import 'package:flutter/material.dart';
import 'package:parisy_app/features/management/users/models/warga_model.dart';
import 'package:parisy_app/features/management/users/models/rt_model.dart';
import 'package:parisy_app/features/management/users/services/user_management_service.dart';

class UserManagementController extends ChangeNotifier {
  final UserManagementService _service;

  UserManagementController({required UserManagementService service})
    : _service = service;

  List<WargaModel> _users = [];
  List<RtModel> _rtUsers = [];
  Map<String, dynamic> _stats = {};

  bool _isLoading = false;
  String? _error;


  List<WargaModel> get users => _users;
  List<RtModel> get rtUsers => _rtUsers;
  Map<String, dynamic> get stats => _stats;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get errorMessage => _error;
  bool get hasError => _error != null;

  List<WargaModel> get wargaList => _users;
  List<RtModel> get rtList => _rtUsers;
  Map<String, dynamic>? get userStats => _stats.isNotEmpty ? _stats : null;

  List<WargaModel> getUsersBySubRole(String subRole) {
    return _users.where((user) => user.subRole == subRole).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setUsers(List<WargaModel> users) {
    _users = users;
    notifyListeners();
  }

  void _setRtUsers(List<RtModel> rtUsers) {
    _rtUsers = rtUsers;
    notifyListeners();
  }

  void _setStats(Map<String, dynamic> stats) {
    _stats = stats;
    notifyListeners();
  }

  Future<void> loadAllUsers() async {
    _setLoading(true);
    _setError(null);

    try {
      final users = await _service.getAllUsers();
      _setUsers(users);
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error loading users: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUsersBySubRole(String subRole) async {
    _setLoading(true);
    _setError(null);

    try {
      final users = await _service.getUsersBySubRole(subRole);
      _setUsers(users);
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error loading users by sub_role: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRTUsers() async {
    _setLoading(true);
    _setError(null);

    try {
      final rtUsers = await _service.getAllRT();
      _setRtUsers(rtUsers);
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error loading RT users: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadStats() async {
    _setLoading(true);
    _setError(null);

    try {
      final stats = await _service.getUserStats();
      _setStats(stats);
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error loading stats: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addUser(WargaModel user) async {
    _setLoading(true);
    _setError(null);

    try {
      final newUser = await _service.addUser(user);

      _users = [..._users, newUser];
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error adding user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUser(WargaModel user) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedUser = await _service.updateUser(user);

      final index = _users.indexWhere((u) => u.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error updating user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser(int userId) async {
    _setLoading(true);
    _setError(null);

    try {
      await _service.deleteUser(userId);

      _users = _users.where((u) => u.id != userId).toList();
      notifyListeners();

      return true;
    } catch (e) {
      _setError(e.toString());
      debugPrint('Error deleting user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }

  Future<void> refresh() async {
    await Future.wait([loadAllUsers(), loadStats()]);
  }

  Future<void> loadAllWarga() => loadAllUsers();

  Future<void> loadWargaByRT(String subRole) => loadUsersBySubRole(subRole);

  Future<void> loadAllRT() => loadRTUsers();

  Future<bool> addWarga(WargaModel warga) => addUser(warga);

  Future<bool> updateWarga(WargaModel warga) => updateUser(warga);

  Future<bool> deleteWarga(int userId) => deleteUser(userId);
}
