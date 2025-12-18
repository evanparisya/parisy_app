// lib/features/user/marketplace/screens/product_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/user/cart/controllers/cart_controller.dart';
import 'package:parisy_app/features/user/marketplace/models/product_model.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
    ).format(widget.product.price);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryBlack),
        title: Text(
          'Detail Produk',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image - only show if image exists
                  if (widget.product.imageUrl.isNotEmpty)
                    Center(
                      child: Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: AppColors.neutralGray,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            base64Decode(widget.product.imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  if (widget.product.imageUrl.isNotEmpty) SizedBox(height: 20),

                  // Name and Category
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.product.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Price and Stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedPrice,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                      Text(
                        'Stok: ${widget.product.stock}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.neutralDarkGray,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Description
                  Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.product.description.isEmpty
                        ? 'Tidak ada deskripsi.'
                        : widget.product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.neutralDarkGray,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 40),

                  // Seller Info (Placeholder)
                  Text(
                    'Penjual',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.neutralDarkGray,
                      child: Icon(Icons.person, color: AppColors.neutralWhite),
                    ),
                    title: Text(
                      widget.product.createdByName ?? 'Admin/Penjual',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('ID: ${widget.product.createdBy}'),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Bar (Quantity & Add to Cart)
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralDarkGray.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity Selector
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.neutralDarkGray.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, size: 20),
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                ),
                Text(
                  '$_quantity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlack,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, size: 20),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          // Add to Cart Button
          Expanded(
            child: PrimaryButton(
              label: 'Add to Cart',
              backgroundColor: AppColors.primaryBlack,
              onPressed: () {
                final cartController = context.read<CartController>();
                cartController.addItem(
                  productId: widget.product.id,
                  name: widget.product.name,
                  price: widget.product.price,
                );
                cartController.updateQuantity(widget.product.id, _quantity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.product.name} (x$_quantity) ditambahkan!',
                    ),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
