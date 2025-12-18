// lib/features/user/marketplace/widgets/stream_product_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/marketplace_controller.dart';
import '../models/product_model.dart';

/// Contoh widget yang menggunakan Stream untuk real-time updates
class StreamProductList extends StatelessWidget {
  const StreamProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<MarketplaceController>();

    return Column(
      children: [
        // Stream untuk notifikasi messages
        StreamBuilder<String>(
          stream: controller.notificationStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Tampilkan snackbar saat ada notifikasi baru
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(snapshot.data!),
                    duration: const Duration(seconds: 2),
                  ),
                );
              });
            }
            return const SizedBox.shrink();
          },
        ),

        // Stream untuk product list updates
        Expanded(
          child: StreamBuilder<List<ProductModel>>(
            stream: controller.productsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Tidak ada produk tersedia'));
              }

              final products = snapshot.data!;
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('Rp ${product.price}'),
                    trailing: Text('Stock: ${product.stock}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
