// lib/features/user/transaction/services/transaction_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:parisy_app/core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final ApiClient apiClient;

  TransactionService({required this.apiClient});

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

  /// Create a new transaction
  /// POST /transaction/create
  Future<CreateTransactionResponse> createTransaction({
    required CreateTransactionRequest request,
  }) async {
    try {
      debugPrint('🔵 Creating transaction...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.post(
        '/transaction/create',
        data: request.toJson(),
        options: options,
      );

      debugPrint('✅ Transaction created: ${response.data}');
      return CreateTransactionResponse.fromJson(
        response.data,
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      debugPrint('❌ DioException creating transaction: ${e.message}');
      if (e.response != null) {
        final message =
            e.response?.data['message'] ?? 'Gagal membuat transaksi';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    } catch (e) {
      debugPrint('❌ Error creating transaction: $e');
      rethrow;
    }
  }

  /// Update transaction status
  /// POST /transaction/update/[id]
  Future<bool> updateTransaction({
    required int transactionId,
    required UpdateTransactionRequest request,
  }) async {
    try {
      debugPrint('🔵 Updating transaction $transactionId...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.post(
        '/transaction/update/$transactionId',
        data: request.toJson(),
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

  /// Get transaction history for logged in user
  /// GET /transaction/history
  Future<List<TransactionModel>> getTransactionHistory() async {
    try {
      debugPrint('🔵 Fetching transaction history...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.get(
        '/transaction/history',
        options: options,
      );

      debugPrint('✅ Transaction history received: ${response.data}');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => TransactionModel.fromJson(json))
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
      debugPrint('❌ Error fetching transaction history: $e');
      rethrow;
    }
  }

  /// Get transaction detail by ID
  /// GET /transaction/detail/[id]
  Future<TransactionModel> getTransactionDetail(int transactionId) async {
    try {
      debugPrint('🔵 Fetching transaction detail for ID: $transactionId...');
      final options = await _getAuthOptions();

      final response = await apiClient.dio.get(
        '/transaction/detail/$transactionId',
        options: options,
      );

      debugPrint('✅ Transaction detail received: ${response.data}');
      return TransactionModel.fromJson(response.data);
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

  /// Delete a transaction
  /// DELETE /transaction/delete/[id]
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
}
