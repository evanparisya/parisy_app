import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(AppColors.neutralWhite),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(AppColors.neutralGray), width: 1),
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
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(AppColors.neutralGray),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: Color(AppColors.neutralDarkGray),
                          );
                        },
                      )
                    : Icon(
                        Icons.image_not_supported,
                        color: Color(AppColors.neutralDarkGray),
                      ),
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(AppColors.neutralBlack),
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Color(AppColors.accentYellow),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${product.rating ?? 4.5}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(AppColors.neutralBlack),
                          ),
                        ),
                        Text(
                          ' (${product.reviewCount ?? 0})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(AppColors.neutralDarkGray),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.accentNeon),
                          ),
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(AppColors.accentNeon),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Color(AppColors.neutralWhite),
                              size: 18,
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
}

class CameraOverlay extends StatelessWidget {
  final VoidCallback onCapture;
  final VoidCallback onClose;

  const CameraOverlay({
    Key? key,
    required this.onCapture,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Close button
        Positioned(
          top: 20,
          right: 20,
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(AppColors.neutralBlack).withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.close, color: Color(AppColors.neutralWhite)),
            ),
          ),
        ),
        // Capture button
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: onCapture,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Color(AppColors.accentNeon),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Color(AppColors.neutralWhite),
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
