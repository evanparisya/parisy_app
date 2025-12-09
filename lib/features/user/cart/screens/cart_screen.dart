// lib/features/user/cart/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/user/orders/screens/order_history_screen.dart';
import 'package:parisy_app/features/user/cart/controllers/cart_controller.dart';
import 'package:parisy_app/features/user/cart/models/cart_item_model.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          // AppBar sudah ada di MainNavigationApp, tapi ini untuk memastikan judul
          body: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate([
                  if (controller.itemCount == 0)
                    Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: EmptyStateWidget(message: 'Keranjang Anda kosong. Mari mulai berbelanja!'),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Items (${controller.cart.itemUniqueCount})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
                          SizedBox(height: 12),
                          ...controller.cart.items.map((item) => _CartItemCard(item: item, controller: controller)).toList(),
                        ],
                      ),
                    ),
                ]),
              ),
            ],
          ),
          bottomNavigationBar: controller.itemCount > 0 ? _buildCheckoutBar(context, controller) : null,
        );
      },
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kosongkan Keranjang'),
        content: Text('Anda yakin ingin menghapus semua item dari keranjang?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          TextButton(
            onPressed: () {
              context.read<CartController>().clearCart();
              Navigator.pop(context);
            },
            child: Text('Hapus Semua', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartController controller) {
    final formattedTotal = NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(controller.totalAmount);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        boxShadow: [BoxShadow(color: AppColors.neutralDarkGray.withOpacity(0.1), blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pembayaran:', style: TextStyle(fontSize: 16, color: AppColors.neutralDarkGray)),
              Text(formattedTotal, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
            ],
          ),
          SizedBox(height: 15),
          PrimaryButton(
            label: 'Checkout',
            isLoading: controller.isLoading,
            backgroundColor: AppColors.primaryBlack,
            onPressed: () => _showCheckoutDialog(context, controller),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, CartController controller) {
    String selectedPayment = 'cash';
    final TextEditingController notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Konfirmasi Pembelian', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
                  SizedBox(height: 15),
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Pembayaran:', style: TextStyle(fontSize: 16, color: AppColors.neutralDarkGray)),
                      Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(controller.totalAmount), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                    ],
                  ),
                  SizedBox(height: 15),
                  // Payment Method
                  Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w600)),
                  ListTile(
                    title: Text('Transfer'),
                    leading: Radio<String>(
                      value: 'transfer',
                      groupValue: selectedPayment,
                      onChanged: (value) => setModalState(() => selectedPayment = value!),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    title: Text('Cash (Bayar di Tempat)'),
                    leading: Radio<String>(
                      value: 'cash',
                      groupValue: selectedPayment,
                      onChanged: (value) => setModalState(() => selectedPayment = value!),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SizedBox(height: 15),
                  // Notes
                  InputField(
                    label: 'Catatan (Opsional)',
                    hint: 'Misal: Titip di pos keamanan',
                    controller: notesController,
                  ),
                  SizedBox(height: 20),
                  // Checkout Button
                  PrimaryButton(
                    label: 'Bayar Sekarang',
                    isLoading: controller.isLoading,
                    backgroundColor: AppColors.primaryBlack,
                    onPressed: () async {
                      Navigator.pop(context); // Close dialog first
                      final order = await controller.checkout(
                        statusPayment: selectedPayment,
                        notes: notesController.text,
                      );
                      if (order != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Checkout berhasil! Kode: ${order.code}'), backgroundColor: AppColors.primaryGreen),
                        );
                        // Redirect ke halaman history order
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderHistoryScreen()));
                      } else {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(controller.errorMessage ?? 'Checkout gagal.'), backgroundColor: AppColors.errorRed),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final CartController controller;

  const _CartItemCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.subtotal);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.neutralGray)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Item Image Placeholder
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.neutralGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.fastfood, color: AppColors.neutralDarkGray),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
                  Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(item.price), style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
                ],
              ),
            ),
            
            // Quantity Selector & Subtotal
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        controller.updateQuantity(item.productId, item.quantity - 1);
                      },
                      child: Icon(item.quantity > 1 ? Icons.remove_circle_outline : Icons.delete_outline, color: item.quantity > 1 ? AppColors.primaryBlack : AppColors.errorRed, size: 24),
                    ),
                    SizedBox(width: 8),
                    Text(item.quantity.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                          controller.updateQuantity(item.productId, item.quantity + 1);
                      },
                      child: Icon(Icons.add_circle_outline, color: AppColors.primaryBlack, size: 24),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(formattedPrice, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}