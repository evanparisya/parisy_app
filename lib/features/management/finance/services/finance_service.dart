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
  // Returns: total_income, total_pending, total_cancelled, counts
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

  // --- Get Transaction History (Finance) ---
  // GET /finance/history
  // Query params: status (pending/completed/cancelled), start_date, end_date
  Future<List<CashFlowEntry>> getCashFlowHistory({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      debugPrint('🔵 Fetching finance history...');
      final options = await _getAuthOptions();

      // Build query parameters
      final Map<String, dynamic> queryParams = {};
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await apiClient.dio.get(
        '/finance/history',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: options,
      );

      debugPrint('✅ Finance history received: ${response.data}');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => CashFlowEntry.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching history: ${e.message}');
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal mengambil riwayat transaksi';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      debugPrint('❌ Error fetching finance history: $e');
      rethrow;
    }
  }

  // --- Backward compatible methods (no longer needed for backend) ---
  // These methods are kept for UI compatibility but will throw not implemented

  Future<bool> createCashFlow(CashFlowEntry entry) async {
    throw UnimplementedError('Backend tidak mendukung create cash flow manual');
  }

  Future<bool> updateCashFlow(CashFlowEntry entry) async {
    throw UnimplementedError('Backend tidak mendukung update cash flow manual');
  }

  Future<bool> deleteCashFlow(int id) async {
    throw UnimplementedError('Backend tidak mendukung delete cash flow manual');
  }

  Future<bool> manageCashFlow(CashFlowEntry entry) async {
    throw UnimplementedError('Backend tidak mendukung manage cash flow manual');
  }
}
