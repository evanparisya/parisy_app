import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../cart/controllers/cart_controller.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.neutralWhite),
      appBar: AppBar(
        backgroundColor: Color(AppColors.neutralWhite),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(AppColors.primaryBlack)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Produk',
          style: TextStyle(
            color: Color(AppColors.primaryBlack),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          ProfileAppBarAction(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Color(AppColors.neutralGray),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.product.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: Color(AppColors.neutralDarkGray),
                            size: 80,
                          );
                        },
                      )
                    : Icon(
                        Icons.image_not_supported,
                        color: Color(AppColors.neutralDarkGray),
                        size: 80,
                      ),
              ),
              SizedBox(height: 20),

              // Product Name
              Text(
                widget.product.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryBlack),
                ),
              ),
              SizedBox(height: 8),

              // Category
              if (widget.product.category != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(AppColors.primaryGreen).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.product.category!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(AppColors.primaryGreen),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              SizedBox(height: 12),

              // Rating
              if (widget.product.rating != null)
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < widget.product.rating!.toInt()
                            ? Icons.star
                            : Icons.star_border,
                        color: Color(AppColors.accentYellow),
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${widget.product.rating} (${widget.product.reviewCount ?? 0} ulasan)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(AppColors.neutralDarkGray),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 16),

              // Price
              Text(
                'Rp ${widget.product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.')}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryGreen),
                ),
              ),
              SizedBox(height: 16),

              // Stock Status
              if (widget.product.stock != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.product.stock! > 0
                        ? Color(AppColors.successGreen).withOpacity(0.1)
                        : Color(AppColors.errorRed).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.product.stock! > 0
                        ? 'Stok tersedia: ${widget.product.stock}'
                        : 'Stok habis',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.product.stock! > 0
                          ? Color(AppColors.successGreen)
                          : Color(AppColors.errorRed),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              SizedBox(height: 20),

              // Description
              if (widget.product.description != null) ...[
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.primaryBlack),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.product.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(AppColors.neutralDarkGray),
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 20),
              ],

              // Quantity Selector
              Text(
                'Jumlah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryBlack),
                ),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(AppColors.neutralGray)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      icon: Icon(Icons.remove),
                      color: Color(AppColors.primaryGreen),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '$_quantity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _quantity++),
                      icon: Icon(Icons.add),
                      color: Color(AppColors.primaryGreen),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Add to Cart Button
              PrimaryButton(
                label: 'Tambah ke Keranjang',
                onPressed: () {
                  if (widget.product.stock != null &&
                      widget.product.stock! > 0) {
                    context.read<CartController>().addItem(
                      productId: widget.product.id,
                      name: widget.product.name,
                      price: widget.product.price,
                    );
                    // Update quantity if more than 1
                    if (_quantity > 1) {
                      context.read<CartController>().updateQuantity(
                        widget.product.id,
                        _quantity,
                      );
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${widget.product.name} ditambahkan ke keranjang',
                        ),
                        backgroundColor: Color(AppColors.successGreen),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
              SizedBox(height: 12),

              // Buy Now Button (secondary)
              SecondaryButton(
                label: 'Beli Sekarang',
                onPressed: () {
                  if (widget.product.stock != null &&
                      widget.product.stock! > 0) {
                    context.read<CartController>().addItem(
                      productId: widget.product.id,
                      name: widget.product.name,
                      price: widget.product.price,
                    );
                    // Update quantity if more than 1
                    if (_quantity > 1) {
                      context.read<CartController>().updateQuantity(
                        widget.product.id,
                        _quantity,
                      );
                    }
                    Navigator.pushNamed(context, '/cart');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
