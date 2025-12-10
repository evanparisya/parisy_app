// lib/features/user/orders/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
// FIX 1: Gunakan alias 'common' untuk menghindari konflik nama dengan ErrorWidget bawaan Flutter
import 'package:parisy_app/core/widgets/common_widgets.dart' as common;
// CORRECTED: gunakan 'orders' (plural) sesuai struktur folder
import 'package:parisy_app/features/user/orders/controllers/order_controller.dart';
import 'package:parisy_app/features/user/orders/models/order_model.dart';
import 'package:parisy_app/features/user/orders/screens/order_detail_screen.dart'; // NEW IMPORT
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil loadOrderHistory setelah frame pertama agar context.read menemukan provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderController>().loadOrderHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, controller, child) {
        if (controller.state == OrderState.loading && controller.orderHistory.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.state == OrderState.error) {
          // FIX 1: Menggunakan alias 'common.' untuk memanggil ErrorWidget kustom
          return common.ErrorWidget(message: controller.errorMessage ?? 'Gagal memuat riwayat pesanan.', onRetry: controller.loadOrderHistory);
        }

        if (controller.orderHistory.isEmpty) {
          // FIX 1: Menggunakan alias 'common.' untuk memanggil EmptyStateWidget kustom
          return common.EmptyStateWidget(message: 'Anda belum memiliki riwayat pesanan.');
        }

        return RefreshIndicator(
          onRefresh: controller.loadOrderHistory,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.orderHistory.length,
            itemBuilder: (context, index) {
              final order = controller.orderHistory[index];
              return _OrderCard(order: order);
            },
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

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

  // Helper untuk mengganti .withOpacity(0.1) dengan Color.fromARGB
  Color _getColorWithOpacity(Color color, double opacity) {
    int alpha = (255 * opacity).round();
    return Color.fromARGB(alpha, color.red, color.green, color.blue);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.statusTransaction);
    final formattedPrice = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(order.priceTotal);

    // FIX 3: Mengganti semua `statusColor.withOpacity(0.1)` dengan helper baru
    final backgroundOpacityColor = _getColorWithOpacity(statusColor, 0.1); 

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutralGray),
      ),
      child: ListTile(
        // NAVIGASI KE DETAIL SCREEN BARU
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          );
        },
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          // FIX 3: Deprecated member use (.withOpacity)
          backgroundColor: backgroundOpacityColor,
          child: Icon(Icons.shopping_bag, color: statusColor),
        ),
        title: Text(order.code, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: $formattedPrice',
              style: const TextStyle(fontSize: 14, color: AppColors.primaryBlack, fontWeight: FontWeight.w600),
            ),
            Text(
              'Tgl: ${DateFormat('dd MMM yyyy HH:mm').format(order.createdAt)}',
              style: const TextStyle(fontSize: 12, color: AppColors.neutralDarkGray),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            // FIX 3: Deprecated member use (.withOpacity)
            color: backgroundOpacityColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            order.statusTransaction.toUpperCase(),
            style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}