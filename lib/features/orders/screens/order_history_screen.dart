import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../controllers/order_controller.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderController>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.neutralGray),
      appBar: AppBar(
        backgroundColor: Color(AppColors.neutralWhite),
        elevation: 1,
        title: Text(
          'Riwayat Pesanan',
          style: TextStyle(
            color: Color(AppColors.neutralBlack),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [ProfileAppBarAction()],
      ),
      body: Consumer<OrderController>(
        builder: (context, orderController, child) {
          if (orderController.state == OrderState.loading) {
            return LoadingWidget(message: 'Memuat pesanan...');
          }

          if (orderController.state == OrderState.error) {
            return ErrorWidget(
              message:
                  orderController.errorMessage ??
                  'Terjadi kesalahan saat memuat pesanan',
              onRetry: () => orderController.loadOrders(),
            );
          }

          if (orderController.orders.isEmpty) {
            return EmptyStateWidget(message: 'Belum ada pesanan');
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orderController.orders.length,
            itemBuilder: (context, index) {
              final order = orderController.orders[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderDetailScreen(orderId: order.id),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(AppColors.neutralWhite),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(AppColors.neutralGray),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pesanan #${order.id.substring(0, 8)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.neutralBlack),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: orderController
                                  .getStatusColor(order.status)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              orderController.getStatusLabel(order.status),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: orderController.getStatusColor(
                                  order.status,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(AppColors.neutralDarkGray),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Rp ${order.totalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(AppColors.primaryGreen),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Tanggal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(AppColors.neutralDarkGray),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(AppColors.neutralBlack),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${order.items.length} produk',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(AppColors.neutralDarkGray),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderController>().getOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.neutralGray),
      appBar: AppBar(
        backgroundColor: Color(AppColors.neutralWhite),
        elevation: 1,
        title: Text(
          'Detail Pesanan',
          style: TextStyle(
            color: Color(AppColors.neutralBlack),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [ProfileAppBarAction()],
      ),
      body: Consumer<OrderController>(
        builder: (context, orderController, child) {
          if (orderController.state == OrderState.loading) {
            return LoadingWidget(message: 'Memuat detail pesanan...');
          }

          if (orderController.state == OrderState.error) {
            return ErrorWidget(
              message:
                  orderController.errorMessage ??
                  'Terjadi kesalahan saat memuat detail pesanan',
              onRetry: () => orderController.getOrderDetail(widget.orderId),
            );
          }

          final order = orderController.selectedOrder;
          if (order == null) {
            return EmptyStateWidget(message: 'Pesanan tidak ditemukan');
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(AppColors.neutralWhite),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(AppColors.neutralGray),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Pesanan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.neutralBlack),
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: orderController
                              .getStatusColor(order.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getStatusIcon(order.status),
                              color: orderController.getStatusColor(
                                order.status,
                              ),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                orderController.getStatusLabel(order.status),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: orderController.getStatusColor(
                                    order.status,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Items
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(AppColors.neutralWhite),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(AppColors.neutralGray),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produk (${order.items.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.neutralBlack),
                        ),
                      ),
                      SizedBox(height: 12),
                      ...order.items.map((item) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(AppColors.neutralBlack),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'x${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(AppColors.neutralDarkGray),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rp ${item.productPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(AppColors.primaryGreen),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Shipping Info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(AppColors.neutralWhite),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(AppColors.neutralGray),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Pengiriman',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.neutralBlack),
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildInfoRow('Alamat', order.address),
                      _buildInfoRow('Nomor Telepon', order.phoneNumber),
                      if (order.notes != null && order.notes!.isNotEmpty)
                        _buildInfoRow('Catatan', order.notes!),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Total
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(AppColors.neutralWhite),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(AppColors.neutralGray),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Harga'),
                          Text(
                            'Rp ${order.totalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.primaryGreen),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                if (order.status.toLowerCase() == 'pending' ||
                    order.status.toLowerCase() == 'processing')
                  PrimaryButton(
                    label: 'Batalkan Pesanan',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Batalkan Pesanan?'),
                          content: Text(
                            'Apakah Anda yakin ingin membatalkan pesanan ini?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Tidak'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                final success = await orderController
                                    .cancelOrder(order.id);
                                if (success && mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Pesanan berhasil dibatalkan',
                                      ),
                                      backgroundColor: Color(
                                        AppColors.successGreen,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Ya, batalkan',
                                style: TextStyle(
                                  color: Color(AppColors.errorRed),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(AppColors.neutralDarkGray),
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(AppColors.neutralBlack),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.hourglass_bottom;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}
