// lib/features/management/reporting/services/reporting_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/features/management/reporting/models/product_report_model.dart';
import 'package:parisy_app/features/management/reporting/models/transaction_report_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportingService {
  final ApiClient apiClient;

  ReportingService({required this.apiClient});

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

  // --- Get All Transaction History (Admin/Sekretaris) ---
  // GET /transaction/all - Mengambil semua transaksi dari semua user
  Future<List<TransactionReportModel>> getTransactionHistory() async {
    try {
      debugPrint('🔵 Fetching all transaction history...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.get(
        '/transaction/all',
        options: options,
      );

      debugPrint('✅ All transactions received: ${response.data}');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => TransactionReportModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching transactions: ${e.message}');
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal mengambil riwayat transaksi';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      debugPrint('❌ Error fetching transaction history: $e');
      rethrow;
    }
  }

  // --- Update Transaction Status (Admin/Sekretaris) ---
  // POST /transaction/update/[id]
  Future<bool> updateTransactionStatus({
    required int transactionId,
    String? transactionStatus,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      debugPrint('🔵 Updating transaction $transactionId...');
      final options = await _getAuthOptions();

      final Map<String, dynamic> data = {};
      if (transactionStatus != null)
        data['transaction_status'] = transactionStatus;
      if (paymentMethod != null) data['payment_method'] = paymentMethod;
      if (notes != null) data['notes'] = notes;

      final response = await apiClient.dio.post(
        '/transaction/update/$transactionId',
        data: data,
        options: options,
      );

      debugPrint('✅ Transaction updated: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('❌ DioException updating transaction: ${e.message}');
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal memperbarui transaksi';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      debugPrint('❌ Error updating transaction: $e');
      rethrow;
    }
  }

  // --- Get Transaction Detail (Admin/Sekretaris) ---
  // GET /transaction/detail/[id]
  Future<TransactionReportModel> getTransactionDetail(int transactionId) async {
    try {
      debugPrint('🔵 Fetching transaction detail for ID: $transactionId...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.get(
        '/transaction/detail/$transactionId',
        options: options,
      );

      debugPrint('✅ Transaction detail received: ${response.data}');
      return TransactionReportModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching detail: ${e.message}');
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal mengambil detail transaksi';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      debugPrint('❌ Error fetching transaction detail: $e');
      rethrow;
    }
  }

  // --- Delete Transaction (Admin/Sekretaris) ---
  // DELETE /transaction/delete/[id]
  Future<bool> deleteTransaction(int transactionId) async {
    try {
      debugPrint('🔵 Deleting transaction $transactionId...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.delete(
        '/transaction/delete/$transactionId',
        options: options,
      );

      debugPrint('✅ Transaction deleted: ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('❌ DioException deleting transaction: ${e.message}');
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal menghapus transaksi';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      debugPrint('❌ Error deleting transaction: $e');
      rethrow;
    }
  }

  // --- Get All Products History ---
  // GET /vegetable/list
  Future<List<ProductReportModel>> getProductHistory() async {
    try {
      debugPrint('🔵 Fetching product history...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.get(
        '/vegetable/admin/list',
        options: options,
      );

      debugPrint('✅ Products received: ${response.data}');

      if (response.data is Map && response.data['vegetables'] is List) {
        return (response.data['vegetables'] as List)
            .map((json) => ProductReportModel.fromJson(json))
            .toList();
      }

      if (response.data is List) {
        return (response.data as List)
            .map((json) => ProductReportModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('❌ DioException fetching products: ${e.message}');
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal mengambil data produk';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      debugPrint('❌ Error fetching product history: $e');
      rethrow;
    }
  }
}
