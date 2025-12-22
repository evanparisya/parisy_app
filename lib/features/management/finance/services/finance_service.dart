// lib/features/management/finance/services/finance_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/features/management/finance/models/cash_flow_model.dart';
import 'package:parisy_app/features/management/finance/models/financial_report_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinanceService {
  final ApiClient apiClient;

  FinanceService({required this.apiClient});

  /// Helper method to get JWT token
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }
    return token;
  }

  /// Helper method to get authorization options
  Future<Options> _getAuthOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // --- Get Financial Summary ---
  // GET /finance/summary
  Future<FinancialReportModel> getFinancialSummary() async {
    try {
      debugPrint('🔵 Fetching financial summary...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.get(
        '/finance/summary',
        options: options,
      );

      debugPrint('✅ Financial summary received: ${response.data}');
      return FinancialReportModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching summary: ${e.message}');
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal mengambil ringkasan keuangan';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      debugPrint('❌ Error fetching financial summary: $e');
      rethrow;
    }
  }

  // --- Get Cash Flow History ---
  // GET /finance/history
  Future<List<CashFlowEntry>> getCashFlowHistory() async {
    try {
      debugPrint('🔵 Fetching cash flow history...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.get(
        '/finance/history',
        options: options,
      );

      debugPrint('✅ Cash flow history received: ${response.data}');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => CashFlowEntry.fromJson(json))
            .toList();
      }

      if (response.data is Map && response.data['history'] is List) {
        return (response.data['history'] as List)
            .map((json) => CashFlowEntry.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching cash flow: ${e.message}');
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal mengambil riwayat arus kas';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      debugPrint('❌ Error fetching cash flow history: $e');
      rethrow;
    }
  }

  // --- Add/Create Cash Flow Entry ---
  // POST /finance/create
  Future<bool> createCashFlow(CashFlowEntry entry) async {
    try {
      debugPrint('🔵 Creating cash flow entry...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.post(
        '/finance/create',
        data: {
          'description': entry.description,
          'amount': entry.amount,
          'type': entry.type,
          'date': entry.date.toIso8601String(),
          'source_or_destination': entry.sourceOrDestination,
        },
        options: options,
      );

      debugPrint('✅ Cash flow created: ${response.data}');
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('❌ DioException creating cash flow: ${e.message}');
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal menambahkan arus kas';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      debugPrint('❌ Error creating cash flow: $e');
      rethrow;
    }
  }

  // --- Update Cash Flow Entry ---
  // POST /finance/update/[id]
  Future<bool> updateCashFlow(CashFlowEntry entry) async {
    try {
      debugPrint('🔵 Updating cash flow entry ${entry.id}...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.post(
        '/finance/update/${entry.id}',
        data: {
          'description': entry.description,
          'amount': entry.amount,
          'type': entry.type,
          'date': entry.date.toIso8601String(),
          'source_or_destination': entry.sourceOrDestination,
        },
        options: options,
      );

      debugPrint('✅ Cash flow updated: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('❌ DioException updating cash flow: ${e.message}');
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal memperbarui arus kas';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      debugPrint('❌ Error updating cash flow: $e');
      rethrow;
    }
  }

  // --- Delete Cash Flow Entry ---
  // DELETE /finance/delete/[id]
  Future<bool> deleteCashFlow(int id) async {
    try {
      debugPrint('🔵 Deleting cash flow entry $id...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.delete(
        '/finance/delete/$id',
        options: options,
      );

      debugPrint('✅ Cash flow deleted: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('❌ DioException deleting cash flow: ${e.message}');
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal menghapus arus kas';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      debugPrint('❌ Error deleting cash flow: $e');
      rethrow;
    }
  }

  // --- Manage Cash Flow (Backward compatible) ---
  Future<bool> manageCashFlow(CashFlowEntry entry) async {
    if (entry.id == 0) {
      return createCashFlow(entry);
    } else {
      return updateCashFlow(entry);
    }
  }
}
