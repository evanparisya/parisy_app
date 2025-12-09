// lib/features/management/reporting/services/reporting_service.dart
import 'package:parisy_app/core/api/api_client.dart';
import 'package:parisy_app/features/management/reporting/models/product_report_model.dart';
import 'package:parisy_app/features/management/reporting/models/transaction_report_model.dart';

class ReportingService {
  final ApiClient apiClient;

  static const bool useMock = true;

  ReportingService({required this.apiClient});

  // --- History Transaksi ---
  Future<List<TransactionReportModel>> getTransactionHistory() async {
    if (useMock) {
      await Future.delayed(Duration(seconds: 1));
      return [
        TransactionReportModel(
          id: 1, code: 'TRX-001', userId: 6, userName: 'Warga Biasa', priceTotal: 45000.0,
          statusTransaction: 'paid', statusPayment: 'transfer', createdAt: DateTime(2025, 12, 5, 10, 30),
          details: [
            DetailTransactionModel(vegetableId: 101, vegetableName: 'Bayam Merah Organik', quantity: 3, priceUnit: 15000, subtotal: 45000),
          ],
        ),
        TransactionReportModel(
          id: 2, code: 'TRX-002', userId: 10, userName: 'Budi Santoso', priceTotal: 22000.0,
          statusTransaction: 'pending', statusPayment: 'cash', createdAt: DateTime(2025, 12, 6, 11, 0),
          details: [
            DetailTransactionModel(vegetableId: 102, vegetableName: 'Wortel Jumbo', quantity: 1, priceUnit: 22000, subtotal: 22000),
          ],
        ),
      ];
    }
    throw UnimplementedError('API get transaction history belum diimplementasi');
  }

  // --- History Barang ---
  Future<List<ProductReportModel>> getProductHistory() async {
    if (useMock) {
      await Future.delayed(Duration(seconds: 1));
      return [
        ProductReportModel(
          id: 101, name: 'Bayam Merah Organik', description: 'Bayam segar', price: 15000, stock: 50, image: '', category: 'daun', status: 'available', createdBy: 1, createdByName: 'Admin Utama', createdAt: DateTime(2024, 1, 1),
        ),
        ProductReportModel(
          id: 102, name: 'Wortel Jumbo', description: 'Wortel impor', price: 22000, stock: 15, image: '', category: 'akar', status: 'available', createdBy: 2, createdByName: 'Ketua RT 01', createdAt: DateTime(2024, 1, 5),
        ),
      ];
    }
    throw UnimplementedError('API get product history belum diimplementasi');
  }
}