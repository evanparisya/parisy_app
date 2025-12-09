// lib/features/sekretaris/screens/sekretaris_transaction_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/management/reporting/controllers/reporting_controller.dart';
import 'package:parisy_app/features/management/reporting/models/transaction_report_model.dart';
import 'package:intl/intl.dart';

class SekretarisTransactionHistoryScreen extends StatefulWidget {
  const SekretarisTransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SekretarisTransactionHistoryScreen> createState() => _SekretarisTransactionHistoryScreenState();
}

class _SekretarisTransactionHistoryScreenState extends State<SekretarisTransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ReportingController>().loadTransactionHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryBlack),
        title: Text('History Transaksi', style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ReportingController>(
        builder: (context, controller, child) {
          if (controller.state == ReportingState.loading && controller.transactionHistory.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.transactionHistory.isEmpty) {
            return EmptyStateWidget(message: 'Tidak ada riwayat transaksi.');
          }

          return RefreshIndicator(
            onRefresh: controller.loadTransactionHistory,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: controller.transactionHistory.length,
              itemBuilder: (context, index) {
                final transaction = controller.transactionHistory[index];
                return _TransactionCard(transaction: transaction);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionReportModel transaction;
  const _TransactionCard({required this.transaction});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid': return AppColors.primaryGreen;
      case 'pending': return AppColors.accentYellow;
      case 'failed': return AppColors.errorRed;
      default: return AppColors.neutralDarkGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(transaction.statusTransaction);
    final formattedPrice = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(transaction.priceTotal);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.neutralGray)),
      child: ListTile(
        onTap: () => _showDetailDialog(context, transaction),
        contentPadding: EdgeInsets.all(16),
        title: Text(transaction.code, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Oleh: ${transaction.userName}', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
            Text('Tgl: ${DateFormat('dd MMM yyyy HH:mm').format(transaction.createdAt)}', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(formattedPrice, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(transaction.statusTransaction.toUpperCase(), style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDetailDialog(BuildContext context, TransactionReportModel transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Transaksi ${transaction.code}'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Total: Rp ${transaction.priceTotal.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Status: ${transaction.statusTransaction.toUpperCase()} (${transaction.statusPayment})'),
              SizedBox(height: 10),
              Text('Pembeli: ${transaction.userName} (ID: ${transaction.userId})'),
              SizedBox(height: 15),
              Text('Detail Barang:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...transaction.details.map((d) => Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(' - ${d.vegetableName} (x${d.quantity}) @Rp${d.priceUnit.toStringAsFixed(0)}'),
              )),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Tutup'))],
      ),
    );
  }
}