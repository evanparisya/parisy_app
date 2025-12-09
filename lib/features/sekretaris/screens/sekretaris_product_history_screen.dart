// lib/features/sekretaris/screens/sekretaris_product_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/management/reporting/controllers/reporting_controller.dart';
import 'package:parisy_app/features/management/reporting/models/product_report_model.dart';
import 'package:intl/intl.dart';

class SekretarisProductHistoryScreen extends StatefulWidget {
  const SekretarisProductHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SekretarisProductHistoryScreen> createState() => _SekretarisProductHistoryScreenState();
}

class _SekretarisProductHistoryScreenState extends State<SekretarisProductHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ReportingController>().loadProductHistory();
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
        title: Text('History Barang Jual Beli', style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ReportingController>(
        builder: (context, controller, child) {
          if (controller.state == ReportingState.loading && controller.productHistory.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.productHistory.isEmpty) {
            return EmptyStateWidget(message: 'Tidak ada riwayat barang terdaftar.');
          }

          return RefreshIndicator(
            onRefresh: controller.loadProductHistory,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: controller.productHistory.length,
              itemBuilder: (context, index) {
                final product = controller.productHistory[index];
                return _ProductCard(product: product);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductReportModel product;
  const _ProductCard({required this.product});

  Color _getStatusColor(String status) {
    return status == 'available' ? AppColors.primaryGreen : AppColors.errorRed;
  }
  
  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(product.status);
    final formattedPrice = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(product.price);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.neutralGray)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.inventory, color: statusColor),
        ),
        title: Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kategori: ${product.category.toUpperCase()} | Stok: ${product.stock}', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
            Text('Oleh: ${product.createdByName}', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
            Text('Tgl Daftar: ${DateFormat('dd MMM yyyy').format(product.createdAt)}', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(formattedPrice, style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(product.status.toUpperCase(), style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}