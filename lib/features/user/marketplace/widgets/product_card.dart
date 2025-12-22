// lib/features/user/marketplace/widgets/product_card.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/user/marketplace/models/product_model.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    // Simulasi harga $XX.XX sesuai desain, konversi harga aslinya ke satuan 1000
    final formattedPrice = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$ ',
    ).format(product.price / 10000);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.neutralDarkGray.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and Discount Badge - always show with error handling
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.neutralGray,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: _buildProductImage(),
                    ),
                  ),
                  // Placeholder Discount Badge (Mirip desain)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlack,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-25%',
                        style: TextStyle(
                          color: AppColors.neutralWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                // PERBAIKAN OVERFLOW: Mengurangi padding vertikal dari 12 ke 8
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralDarkGray,
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedPrice,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        // Add to Cart Button (Mirip desain)
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add,
                              color: AppColors.neutralWhite,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    // Jika imageUrl kosong atau null, langsung tampilkan placeholder
    if (product.imageUrl.isEmpty) {
      return _buildPlaceholderImage();
    }

    try {
      // Decode base64 image dengan error handling
      final imageBytes = base64Decode(product.imageUrl);
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Jika decode berhasil tapi render gagal, gunakan placeholder
          return _buildPlaceholderImage();
        },
      );
    } catch (e) {
      // Jika base64 decode gagal, gunakan placeholder
      print('⚠️ Error decoding image for ${product.name}: $e');
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.neutralGray,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: AppColors.neutralDarkGray,
            ),
            SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(color: AppColors.neutralDarkGray, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
