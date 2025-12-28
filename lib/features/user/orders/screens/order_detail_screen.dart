// lib/features/user/orders/screens/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/user/orders/controllers/order_controller.dart';
import 'package:parisy_app/features/user/orders/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() => _isLoading = true);
    try {
      final controller = context.read<OrderController>();
      final detail = await controller.getOrderDetail(_order.id);
      if (detail != null && mounted) {
        setState(() => _order = detail);
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

  Future<void> _showUpdateStatusDialog() async {
    String? selectedStatus = _order.statusTransaction;
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

    if (result != null && result != _order.statusTransaction) {
      await _updateStatus(result);
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    try {
      final controller = context.read<OrderController>();
      final success = await controller.updateOrderStatus(
        orderId: _order.id,
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
        await _loadOrderDetail();
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
          title: const Text('Hapus Pesanan'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus pesanan ini? Tindakan ini tidak dapat dibatalkan.',
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
      await _deleteOrder();
    }
  }

  Future<void> _deleteOrder() async {
    setState(() => _isLoading = true);
    try {
      final controller = context.read<OrderController>();
      final success = await controller.deleteOrder(_order.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dihapus'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.errorMessage ?? 'Gagal menghapus pesanan'),
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_order.statusTransaction);
    final formattedTotal = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
    ).format(_order.priceTotal);

    final backgroundColor = Color.fromARGB(
      (255 * 0.05).round(),
      statusColor.red,
      statusColor.green,
      statusColor.blue,
    );

    final isPending = _order.statusTransaction.toLowerCase() == 'pending';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlack),
        title: Text(
          'Detail Pesanan ${_order.code}',
          style: const TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isPending)
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
              onRefresh: _loadOrderDetail,
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
                                    _getStatusDisplayText(
                                      _order.statusTransaction,
                                    ).toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Kode: ${_order.code}',
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
                      value: _order.statusPayment.toUpperCase(),
                    ),
                    _DetailRow(
                      label: 'Tanggal Pesan',
                      value: DateFormat(
                        'dd MMM yyyy HH:mm',
                      ).format(_order.createdAt),
                    ),
                    _DetailRow(label: 'Catatan', value: _order.notes ?? '-'),
                    const SizedBox(height: 25),

                    // --- Detail Barang ---
                    const Text(
                      'Detail Barang Dipesan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const Divider(height: 20),
                    if (_order.details.isEmpty)
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
                      ..._order.details
                          .map((detail) => _ProductDetailTile(detail: detail))
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
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.neutralDarkGray),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold
                  ? AppColors.primaryBlack
                  : AppColors.neutralDarkGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDetailTile extends StatelessWidget {
  final OrderDetailModel detail;
  const _ProductDetailTile({required this.detail});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(detail.subtotal);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.neutralGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fastfood,
              size: 20,
              color: AppColors.neutralDarkGray,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.vegetableName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlack,
                  ),
                ),
                Text(
                  '${detail.quantity} x Rp${detail.priceUnit.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.neutralDarkGray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formattedPrice,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
