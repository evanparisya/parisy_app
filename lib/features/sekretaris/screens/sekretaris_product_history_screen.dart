// lib/features/sekretaris/screens/sekretaris_product_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/user/marketplace/controllers/marketplace_controller.dart';
import 'package:parisy_app/features/user/marketplace/models/product_model.dart';
import 'package:intl/intl.dart';

class SekretarisProductHistoryScreen extends StatefulWidget {
  const SekretarisProductHistoryScreen({super.key});

  @override
  State<SekretarisProductHistoryScreen> createState() =>
      _SekretarisProductHistoryScreenState();
}

class _SekretarisProductHistoryScreenState
    extends State<SekretarisProductHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<MarketplaceController>().loadAdminProducts();
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
        iconTheme: IconThemeData(color: AppColors.primaryBlack),
        title: Text(
          'History Barang Jual Beli',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<MarketplaceController>(
        builder: (context, controller, child) {
          if (controller.state == MarketplaceState.loading &&
              controller.products.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.products.isEmpty) {
            return EmptyStateWidget(
              message: 'Tidak ada riwayat barang terdaftar.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadAdminProducts(),
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: controller.products.length,
              itemBuilder: (context, index) {
                final product = controller.products[index];
                return _ProductCard(
                  product: product,
                  onUpdateStock: () => _showUpdateStockDialog(context, product),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, ProductModel product) {
    final stockController = TextEditingController(
      text: product.stock.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stok'),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Stok Baru',
            hintText: 'Masukkan stok baru',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final newStock = int.tryParse(stockController.text);
              if (newStock == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stok harus berupa angka')),
                );
                return;
              }

              Navigator.pop(context);
              final success = await context
                  .read<MarketplaceController>()
                  .updateStock(product.id, newStock);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Stok berhasil diperbarui'
                          : 'Gagal memperbarui stok',
                    ),
                  ),
                );
              }
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onUpdateStock;

  const _ProductCard({required this.product, required this.onUpdateStock});

  Color _getStatusColor(String status) {
    return status == 'available' ? AppColors.primaryGreen : AppColors.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(product.status);
    final formattedPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(product.price);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutralGray),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.inventory, color: statusColor),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori: ${product.category.toUpperCase()} | Stok: ${product.stock}',
              style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray),
            ),
            if (product.createdByName != null)
              Text(
                'Oleh: ${product.createdByName}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.neutralDarkGray,
                ),
              ),
            if (product.createdAt != null)
              Text(
                'Tgl Daftar: ${DateFormat('dd MMM yyyy').format(product.createdAt!)}',
                style: TextStyle(
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
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primaryBlack),
              onPressed: onUpdateStock,
              tooltip: 'Update Stok',
            ),
          ],
        ),
      ),
    );
  }
}