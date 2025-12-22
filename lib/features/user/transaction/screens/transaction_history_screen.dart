// lib/features/user/transaction/screens/transaction_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart' as common;
import 'package:parisy_app/features/user/transaction/controllers/transaction_controller.dart';
import 'package:parisy_app/features/user/transaction/models/transaction_model.dart';
import 'package:parisy_app/features/user/transaction/screens/transaction_detail_screen.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionController>().loadTransactionHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlack),
        title: const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TransactionController>().loadTransactionHistory();
            },
          ),
        ],
      ),
      body: Consumer<TransactionController>(
        builder: (context, controller, child) {
          if (controller.state == TransactionState.loading &&
              controller.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.state == TransactionState.error) {
            return common.ErrorWidget(
              message:
                  controller.errorMessage ?? 'Gagal memuat riwayat transaksi.',
              onRetry: controller.loadTransactionHistory,
            );
          }

          if (controller.transactions.isEmpty) {
            return const common.EmptyStateWidget(
              message: 'Anda belum memiliki riwayat transaksi.',
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadTransactionHistory,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.transactions.length,
              itemBuilder: (context, index) {
                final transaction = controller.transactions[index];
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
  final TransactionModel transaction;
  const _TransactionCard({required this.transaction});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return AppColors.primaryGreen;
      case 'pending':
      case 'processing':
        return AppColors.accentYellow;
      case 'failed':
      case 'cancelled':
        return AppColors.errorRed;
      default:
        return AppColors.neutralDarkGray;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'processing':
        return Icons.sync;
      case 'failed':
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.shopping_bag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(transaction.transactionStatus);
    final statusIcon = _getStatusIcon(transaction.transactionStatus);
    final formattedPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(transaction.totalPrice);

    final backgroundColor = Color.fromARGB(
      (255 * 0.1).round(),
      statusColor.red,
      statusColor.green,
      statusColor.blue,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutralGray),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TransactionDetailScreen(transaction: transaction),
            ),
          );
        },
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: backgroundColor,
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          transaction.code,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Total: $formattedPrice',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              transaction.createdAt != null
                  ? DateFormat(
                      'dd MMM yyyy HH:mm',
                    ).format(transaction.createdAt!)
                  : '-',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutralDarkGray,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  transaction.paymentMethod.toLowerCase() == 'transfer'
                      ? Icons.account_balance
                      : Icons.payments,
                  size: 14,
                  color: AppColors.neutralDarkGray,
                ),
                const SizedBox(width: 4),
                Text(
                  transaction.paymentMethod.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.neutralDarkGray,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            transaction.statusDisplayText.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
