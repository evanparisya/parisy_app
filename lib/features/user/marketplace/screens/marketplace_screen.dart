// lib/features/user/marketplace/screens/marketplace_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
// Ganti alias untuk menghindari ambiguous import dengan ErrorWidget bawaan Flutter
import 'package:parisy_app/core/widgets/common_widgets.dart' as common;
// import 'package:parisy_app/features/user/marketplace/models/product_model.dart'; // Dihapus: Unused Import
import 'package:parisy_app/features/user/cart/controllers/cart_controller.dart';
import 'package:parisy_app/features/user/marketplace/controllers/marketplace_controller.dart';
import 'package:parisy_app/features/user/marketplace/models/product_model.dart'; // Dipakai lagi di product_card
import 'package:parisy_app/features/user/marketplace/widgets/product_card.dart';
import 'product_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() {
      if (mounted) {
        context.read<MarketplaceController>().loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Perbaikan 1: Pindahkan _buildCategoryFilter, _getCategoryIcon, dan _CategoryItem ke dalam State Class
  // atau ubah menjadi method atau class luar yang diakses dengan benar.
  // Karena mereka hanya digunakan di sini, kita akan menjadikannya method internal dan Class internal.

  // Perbaikan 5: Menambahkan _buildCategoryFilter sebagai metode internal
  Widget _buildCategoryFilter(MarketplaceController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        height: 80,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            // All Category Button
            _CategoryItem(
              label: 'All',
              icon: Icons.all_inclusive,
              isSelected: controller.selectedCategory == null,
              onTap: controller.resetFilters,
            ),
            SizedBox(width: 10),
            // Category items (Fruits, Drinks, Snack, Food -> diganti dengan DBML categories)
            ...controller.categories
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _CategoryItem(
                      label:
                          category.substring(0, 1).toUpperCase() +
                          category.substring(1),
                      icon: _getCategoryIcon(category),
                      isSelected: controller.selectedCategory == category,
                      onTap: () => controller.filterByCategory(category),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  // Perbaikan 5: Menambahkan _getCategoryIcon sebagai metode internal
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'daun':
        return Icons.grass;
      case 'akar':
        return Icons.science;
      case 'bunga':
        return Icons.local_florist;
      case 'buah':
        return Icons.apple;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            // AppBar disesuaikan agar cocok dengan desain Screen 2
            floating: true,
            pinned: true,
            snap: false,
            backgroundColor: AppColors.background,
            elevation: 0,
            expandedHeight: 220.0,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context),
                    _buildSearchBar(context, controller),
                    _buildCategoryFilter(controller),
                  ],
                ),
              ),
            ),
          ),

          if (controller.state == MarketplaceState.loading &&
              controller.products.isEmpty)
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.state == MarketplaceState.error)
            SliverFillRemaining(
              child: common.ErrorWidget(
                message: controller.errorMessage ?? 'Gagal memuat.',
                onRetry: controller.loadInitialData,
              ),
            )
          else if (controller.products.isEmpty)
            SliverFillRemaining(
              child: common.EmptyStateWidget(
                message: 'Tidak ada produk ditemukan.',
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = controller.products[index];
                  return ProductCard(
                    product: product,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailScreen(product: product),
                      ),
                    ),
                    onAddToCart: () {
                      if (!mounted) return;
                      context.read<CartController>().addItem(
                        productId: product.id,
                        name: product.name,
                        price: product.price,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} ditambahkan!'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    },
                  );
                }, childCount: controller.products.length),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.delivery_dining,
                color: AppColors.primaryBlack,
                size: 18,
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Delivery to 112 Diniyah, Riyadh',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.neutralDarkGray,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.notifications_none,
                color: AppColors.primaryBlack,
                size: 24,
              ),
              SizedBox(width: 8),
              Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.primaryBlack,
                size: 24,
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Hungry? Order & Eat.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    MarketplaceController controller,
  ) {
    // Memecah Color untuk mengatasi Deprecated: red, green, blue
    final Color neutralDarkGray = AppColors.neutralDarkGray;
    final Color neutralGray = AppColors.neutralGray;

    // Perbaikan 4: Gunakan Color.fromARGB untuk mengatasi deprecation
    final Color hintColorWithOpacity = Color.fromARGB(
      (255 * 0.5).round(),
      neutralDarkGray.red,
      neutralDarkGray.green,
      neutralDarkGray.blue,
    );

    final Color fillColorWithOpacity = Color.fromARGB(
      (255 * 0.5).round(),
      neutralGray.red,
      neutralGray.green,
      neutralGray.blue,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for fast food...',
                hintStyle: TextStyle(color: hintColorWithOpacity),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.neutralDarkGray,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 10,
                ),
                filled: true,
                fillColor: fillColorWithOpacity,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                controller.searchProducts(value);
              },
            ),
          ),
          SizedBox(width: 10),
          // Tombol Camera untuk searching dengan kamera
          GestureDetector(
            onTap: () {
              controller.pickImageFromCamera();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Membuka kamera untuk mencari...')),
              );
            },
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.camera_alt, color: AppColors.neutralWhite),
            ),
          ),
        ],
      ),
    );
  }
}

// Perbaikan 3: Pindahkan _CategoryItem ke luar State class agar dapat digunakan
class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppColors.primaryBlack
        : AppColors.neutralDarkGray;
    final bgColor = isSelected ? AppColors.neutralWhite : AppColors.neutralGray;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.primaryBlack, width: 2)
                  : null,
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
