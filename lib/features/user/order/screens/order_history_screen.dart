// lib/features/user/orders/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/user/orders/controllers/order_controller.dart';
import 'package:parisy_app/features/user/orders/models/order_model.dart';
import 'package:parisy_app/features/user/orders/screens/order_detail_screen.dart'; // NEW IMPORT
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OrderController>().loadOrderHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, controller, child) {
        if (controller.state == OrderState.loading && controller.orderHistory.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.state == OrderState.error) {
          return ErrorWidget(message: controller.errorMessage ?? 'Gagal memuat riwayat pesanan.', onRetry: controller.loadOrderHistory);
        }

        if (controller.orderHistory.isEmpty) {
          return EmptyStateWidget(message: 'Anda belum memiliki riwayat pesanan.');
        }

        return RefreshIndicator(
          onRefresh: controller.loadOrderHistory,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.statusTransaction);
    final formattedPrice = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(order.priceTotal);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
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
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.shopping_bag, color: statusColor),
        ),
        title: Text(order.code, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: $formattedPrice',
              style: TextStyle(fontSize: 14, color: AppColors.primaryBlack, fontWeight: FontWeight.w600),
            ),
            Text(
              'Tgl: ${DateFormat('dd MMM yyyy HH:mm').format(order.createdAt)}',
              style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray),
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
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