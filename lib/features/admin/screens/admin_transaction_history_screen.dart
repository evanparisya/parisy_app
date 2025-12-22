// lib/features/admin/screens/admin_transaction_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/management/reporting/controllers/reporting_controller.dart';
import 'package:parisy_app/features/management/reporting/models/transaction_report_model.dart';
import 'package:intl/intl.dart';

class AdminTransactionHistoryScreen extends StatefulWidget {
  const AdminTransactionHistoryScreen({super.key});

  @override
  State<AdminTransactionHistoryScreen> createState() =>
      _AdminTransactionHistoryScreenState();
}

class _AdminTransactionHistoryScreenState
    extends State<AdminTransactionHistoryScreen> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ReportingController>().loadTransactionHistory();
    });
  }

  List<TransactionReportModel> _getFilteredTransactions(
    List<TransactionReportModel> transactions,
  ) {
    if (_filterStatus == 'all') return transactions;
    return transactions
        .where((t) => t.statusTransaction.toLowerCase() == _filterStatus)
        .toList();
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
          'History Transaksi',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filterStatus = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Semua')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'paid', child: Text('Paid')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
              const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
          ),
        ],
      ),
      body: Consumer<ReportingController>(
        builder: (context, controller, child) {
          if (controller.state == ReportingState.loading &&
              controller.transactionHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredTransactions = _getFilteredTransactions(
            controller.transactionHistory,
          );

          if (filteredTransactions.isEmpty) {
            return EmptyStateWidget(
              message: _filterStatus == 'all'
                  ? 'Tidak ada riwayat transaksi.'
                  : 'Tidak ada transaksi dengan status $_filterStatus.',
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadTransactionHistory,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
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

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'paid':
        return 'Dibayar';
      case 'processing':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'failed':
        return 'Gagal';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(transaction.statusTransaction);
    final formattedPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(transaction.priceTotal);
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
        onTap: () => _showDetailDialog(context, transaction),
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          transaction.code,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Oleh: ${transaction.userName}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutralDarkGray,
              ),
            ),
            Text(
              'Tgl: ${DateFormat('dd MMM yyyy HH:mm').format(transaction.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutralDarkGray,
              ),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formattedPrice,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusDisplayText(
                  transaction.statusTransaction,
                ).toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(
    BuildContext context,
    TransactionReportModel transaction,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Detail Transaksi ${transaction.code}'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(
                'Total: Rp ${transaction.priceTotal.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Status: '),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        transaction.statusTransaction,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusDisplayText(
                        transaction.statusTransaction,
                      ).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(transaction.statusTransaction),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text('Metode Bayar: ${transaction.statusPayment.toUpperCase()}'),
              const SizedBox(height: 10),
              Text(
                'Pembeli: ${transaction.userName} (ID: ${transaction.userId})',
              ),
              if (transaction.notes != null &&
                  transaction.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Catatan: ${transaction.notes}'),
              ],
              const SizedBox(height: 15),
              const Text(
                'Detail Barang:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...transaction.details.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    ' - ${d.vegetableName} (x${d.quantity}) @Rp${d.priceUnit.toStringAsFixed(0)}',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showUpdateStatusDialog(context, transaction);
            },
            child: const Text('Ubah Status'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showDeleteConfirmDialog(context, transaction);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(
    BuildContext context,
    TransactionReportModel transaction,
  ) {
    String? selectedStatus = transaction.statusTransaction;
    final statuses = [
      'pending',
      'paid',
      'processing',
      'completed',
      'cancelled',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Update Status ${transaction.code}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: statuses.map((status) {
                  return RadioListTile<String>(
                    title: Text(_getStatusDisplayText(status)),
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (value) {
                      setDialogState(() => selectedStatus = value);
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedStatus != null &&
                        selectedStatus != transaction.statusTransaction) {
                      Navigator.pop(dialogContext);
                      await _updateStatus(
                        context,
                        transaction.id,
                        selectedStatus!,
                      );
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    TransactionReportModel transaction,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus transaksi ${transaction.code}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deleteTransaction(context, transaction.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    int transactionId,
    String newStatus,
  ) async {
    final controller = context.read<ReportingController>();
    final success = await controller.updateTransactionStatus(
      transactionId: transactionId,
      transactionStatus: newStatus,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Status berhasil diperbarui'
                : (controller.errorMessage ?? 'Gagal memperbarui status'),
          ),
          backgroundColor: success
              ? AppColors.primaryGreen
              : AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    int transactionId,
  ) async {
    final controller = context.read<ReportingController>();
    final success = await controller.deleteTransaction(transactionId);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Transaksi berhasil dihapus'
                : (controller.errorMessage ?? 'Gagal menghapus transaksi'),
          ),
          backgroundColor: success
              ? AppColors.primaryGreen
              : AppColors.errorRed,
        ),
      );
    }
  }
}
