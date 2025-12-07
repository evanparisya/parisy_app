import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/marketplace_controller.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';
import '../models/product_model.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

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
    _scrollController.addListener(_onScroll);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceController>().loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Reached bottom, load more
      context.read<MarketplaceController>().loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.neutralGray),
      appBar: AppBar(
        backgroundColor: Color(AppColors.neutralWhite),
        elevation: 1,
        title: Text(
          AppStrings.marketplace,
          style: TextStyle(
            color: Color(AppColors.neutralBlack),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ProfileAppBarAction(),
        ],
      ),
      body: Consumer<MarketplaceController>(
        builder: (context, controller, child) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search input
                      Container(
                        decoration: BoxDecoration(
                          color: Color(AppColors.neutralWhite),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(AppColors.neutralGray),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: AppStrings.search,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    controller.resetFilters();
                                  } else {
                                    controller.searchProducts(value);
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                Icons.search,
                                color: Color(AppColors.neutralDarkGray),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      // Camera button
                      GestureDetector(
                        onTap: () {
                          // Navigate to camera
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Buka kamera')),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Color(AppColors.accentBlue),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Color(AppColors.neutralWhite),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Cari dengan Kamera',
                                style: TextStyle(
                                  color: Color(AppColors.neutralWhite),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Categories
              if (controller.categories.isNotEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        GestureDetector(
                          onTap: () => controller.resetFilters(),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: controller.selectedCategory == null
                                  ? Color(AppColors.primaryGreen)
                                  : Color(AppColors.neutralWhite),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Color(AppColors.neutralGray),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Semua',
                                style: TextStyle(
                                  color: controller.selectedCategory == null
                                      ? Color(AppColors.neutralWhite)
                                      : Color(AppColors.neutralBlack),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ...controller.categories.map((category) {
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  controller.filterByCategory(category),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: controller.selectedCategory == category
                                      ? Color(AppColors.primaryGreen)
                                      : Color(AppColors.neutralWhite),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Color(AppColors.neutralGray),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color:
                                          controller.selectedCategory ==
                                              category
                                          ? Color(AppColors.neutralWhite)
                                          : Color(AppColors.neutralBlack),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 12)),
              // Products grid or states
              if (controller.state == MarketplaceState.loading &&
                  controller.products.isEmpty)
                SliverFillRemaining(
                  child: LoadingWidget(message: 'Memuat produk...'),
                )
              else if (controller.state == MarketplaceState.error)
                SliverFillRemaining(
                  child: ErrorWidget(
                    message:
                        controller.errorMessage ??
                        'Terjadi kesalahan saat memuat produk',
                    onRetry: () => controller.loadInitialData(),
                  ),
                )
              else if (controller.products.isEmpty)
                SliverFillRemaining(
                  child: EmptyStateWidget(message: 'Tidak ada produk'),
                )
              else
                Selector<MarketplaceController, List<ProductModel>>(
                  selector: (_, ctrl) => ctrl.products,
                  builder: (context, products, _) {
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              // Navigate to product detail
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailScreen(product: product),
                                ),
                              );
                            },
                            onAddToCart: () {
                              // Add to cart
                              context.read<CartController>().addItem(
                                productId: product.id,
                                name: product.name,
                                price: product.price,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} ditambahkan ke keranjang',
                                  ),
                                  backgroundColor: Color(
                                    AppColors.successGreen,
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          );
                        }, childCount: products.length),
                      ),
                    );
                  },
                ),
              // Loading indicator at bottom for pagination
              if (controller.state == MarketplaceState.loading &&
                  controller.products.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(AppColors.primaryGreen),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
