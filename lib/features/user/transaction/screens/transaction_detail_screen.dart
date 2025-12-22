// lib/features/user/transaction/screens/transaction_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/user/transaction/controllers/transaction_controller.dart';
import 'package:parisy_app/features/user/transaction/models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late TransactionModel _transaction;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
    _loadTransactionDetail();
  }

  Future<void> _loadTransactionDetail() async {
    setState(() => _isLoading = true);
    try {
      final controller = context.read<TransactionController>();
      final detail = await controller.getTransactionDetail(_transaction.id);
      if (detail != null && mounted) {
        setState(() => _transaction = detail);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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

  Future<void> _showUpdateStatusDialog() async {
    String? selectedStatus = _transaction.transactionStatus;
    final statuses = [
      'pending',
      'paid',
      'processing',
      'completed',
      'cancelled',
    ];

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Status'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
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
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, selectedStatus),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (result != null && result != _transaction.transactionStatus) {
      await _updateStatus(result);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      final controller = context.read<TransactionController>();
      final success = await controller.updateTransactionStatus(
        transactionId: _transaction.id,
        transactionStatus: newStatus,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status berhasil diperbarui'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        // Reload detail
        await _loadTransactionDetail();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              controller.errorMessage ?? 'Gagal memperbarui status',
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Transaksi'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Hapus',
                style: TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _deleteTransaction();
    }
  }

  Future<void> _deleteTransaction() async {
    setState(() => _isLoading = true);
    try {
      final controller = context.read<TransactionController>();
      final success = await controller.deleteTransaction(_transaction.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil dihapus'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              controller.errorMessage ?? 'Gagal menghapus transaksi',
            ),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    final statusColor = _getStatusColor(_transaction.transactionStatus);
    final formattedTotal = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(_transaction.totalPrice);

    final backgroundColor = Color.fromARGB(
      (255 * 0.05).round(),
      statusColor.red,
      statusColor.green,
      statusColor.blue,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlack),
        title: Text(
          'Detail Transaksi',
          style: const TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_transaction.isPending)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'update') {
                  _showUpdateStatusDialog();
                } else if (value == 'delete') {
                  _showDeleteConfirmation();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'update',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Update Status'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                      SizedBox(width: 8),
                      Text(
                        'Hapus',
                        style: TextStyle(color: AppColors.errorRed),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTransactionDetail,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header Status ---
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: statusColor),
                      ),
                      color: backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: statusColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Status Transaksi:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.neutralDarkGray,
                                    ),
                                  ),
                                  Text(
                                    _transaction.statusDisplayText
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kode: ${_transaction.code}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- Ringkasan Pembayaran ---
                    const Text(
                      'Ringkasan Pembayaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const Divider(height: 20),
                    _DetailRow(
                      label: 'Total Harga',
                      value: formattedTotal,
                      isBold: true,
                    ),
                    _DetailRow(
                      label: 'Metode Bayar',
                      value: _transaction.paymentMethod.toUpperCase(),
                    ),
                    _DetailRow(
                      label: 'Tanggal Transaksi',
                      value: _transaction.createdAt != null
                          ? DateFormat(
                              'dd MMM yyyy HH:mm',
                            ).format(_transaction.createdAt!)
                          : '-',
                    ),
                    if (_transaction.updatedAt != null)
                      _DetailRow(
                        label: 'Terakhir Diperbarui',
                        value: DateFormat(
                          'dd MMM yyyy HH:mm',
                        ).format(_transaction.updatedAt!),
                      ),
                    _DetailRow(
                      label: 'Catatan',
                      value: _transaction.notes ?? '-',
                    ),
                    const SizedBox(height: 25),

                    // --- Detail Barang ---
                    const Text(
                      'Detail Barang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const Divider(height: 20),
                    if (_transaction.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'Tidak ada detail item',
                            style: TextStyle(color: AppColors.neutralDarkGray),
                          ),
                        ),
                      )
                    else
                      ..._transaction.items
                          .map((item) => _TransactionItemTile(item: item))
                          .toList(),
                  ],
                ),
              ),
            ),
    );
  }
}

// --- Helper Widgets ---

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.neutralDarkGray,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold
                    ? AppColors.primaryBlack
                    : AppColors.neutralDarkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItemTile extends StatelessWidget {
  final TransactionDetailModel item;

  const _TransactionItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(item.subtotal);

    final formattedUnitPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(item.unitPrice);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.neutralGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.eco,
              size: 22,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produk #${item.vegetableId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity} x $formattedUnitPrice',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.neutralDarkGray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formattedPrice,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
