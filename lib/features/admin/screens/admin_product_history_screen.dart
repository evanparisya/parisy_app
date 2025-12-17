// lib/features/admin/screens/admin_product_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/user/marketplace/controllers/marketplace_controller.dart';
import 'package:parisy_app/features/user/marketplace/models/product_model.dart';
import 'package:intl/intl.dart';

class AdminProductHistoryScreen extends StatefulWidget {
  const AdminProductHistoryScreen({super.key});

  @override
  State<AdminProductHistoryScreen> createState() =>
      _AdminProductHistoryScreenState();
}

class _AdminProductHistoryScreenState extends State<AdminProductHistoryScreen> {
  String? _selectedCategory;

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
      // appBar: AppBar(
      //   backgroundColor: AppColors.background,
      //   elevation: 0,
      //   iconTheme: IconThemeData(color: AppColors.primaryBlack),
      //   title: Text(
      //     'History Barang Terdaftar',
      //     style: TextStyle(
      //       color: AppColors.primaryBlack,
      //       fontWeight: FontWeight.bold,
      //     ),
      //   ),
      // ),
      body: Column(
        children: [
          // Category Filter
          Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    label: 'Semua',
                    isSelected: _selectedCategory == null,
                    onTap: () {
                      setState(() => _selectedCategory = null);
                      context.read<MarketplaceController>().loadAdminProducts();
                    },
                  ),
                  SizedBox(width: 8),
                  ...[' daun', 'akar', 'bunga', 'buah'].map(
                    (cat) => Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: cat.toUpperCase(),
                        isSelected: _selectedCategory == cat,
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          context
                              .read<MarketplaceController>()
                              .loadProductsByCategory(cat);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Products List
          Expanded(
            child: Consumer<MarketplaceController>(
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
                  onRefresh: () => _selectedCategory == null
                      ? controller.loadAdminProducts()
                      : controller.loadProductsByCategory(_selectedCategory!),
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: controller.products.length,
                    itemBuilder: (context, index) {
                      final product = controller.products[index];
                      return _ProductCard(
                        product: product,
                        onUpdateStock: () =>
                            _showUpdateStockDialog(context, product),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
        title: Text('Update Stok - ${product.name}'),
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
              if (newStock == null || newStock < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stok harus berupa angka positif')),
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

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : AppColors.neutralGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.neutralWhite : AppColors.primaryBlack,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(Icons.inventory, color: statusColor),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kategori: ${product.category.toUpperCase()} | Stok: ${product.stock}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralDarkGray,
                    ),
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
                      'Tgl: ${DateFormat('dd MMM yyyy').format(product.createdAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralDarkGray,
                      ),
                    ),
                  SizedBox(height: 4),
                  Text(
                    formattedPrice,
                    style: TextStyle(
                      color: AppColors.primaryBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                IconButton(
                  icon: Icon(Icons.edit, size: 20),
                  onPressed: onUpdateStock,
                  tooltip: 'Update Stok',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}