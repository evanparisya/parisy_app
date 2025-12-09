// lib/features/user/orders/screens/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/user/orders/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return AppColors.primaryGreen;
      case 'pending':
        return AppColors.accentYellow;
      case 'failed':
        return AppColors.errorRed;
      default:
        return AppColors.neutralDarkGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.statusTransaction);
    final formattedTotal = NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(order.priceTotal);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryBlack),
        title: Text(
          'Detail Pesanan ${order.code}',
          style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Status ---
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: statusColor)),
              color: statusColor.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: statusColor),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status Transaksi:', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
                          Text(order.statusTransaction.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: statusColor, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Kode: ${order.code}', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25),

            // --- Ringkasan Pembayaran ---
            Text('Ringkasan Pembayaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
            Divider(height: 20),
            _DetailRow(label: 'Total Harga', value: formattedTotal, isBold: true),
            _DetailRow(label: 'Metode Bayar', value: order.statusPayment.toUpperCase()),
            _DetailRow(label: 'Tanggal Pesan', value: DateFormat('dd MMM yyyy HH:mm').format(order.createdAt)),
            _DetailRow(label: 'Catatan', value: order.notes ?? '-'),
            SizedBox(height: 25),

            // --- Detail Barang ---
            Text('Detail Barang Dipesan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
            Divider(height: 20),
            ...order.details.map((detail) => _ProductDetailTile(detail: detail)).toList(),
          ],
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
  const _DetailRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.neutralDarkGray)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primaryBlack : AppColors.neutralDarkGray,
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
    final formattedPrice = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(detail.subtotal);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.neutralGray, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.fastfood, size: 20, color: AppColors.neutralDarkGray),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(detail.vegetableName, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryBlack)),
                Text('${detail.quantity} x Rp${detail.priceUnit.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
              ],
            ),
          ),
          Text(formattedPrice, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
        ],
      ),
    );
  }
}