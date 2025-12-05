import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'core/api/api_client.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/services/auth_service.dart';
import 'features/admin/controllers/admin_controller.dart';
import 'features/admin/services/admin_service.dart';
import 'features/cart/controllers/cart_controller.dart';
import 'features/cart/services/cart_service.dart';
import 'features/marketplace/controllers/marketplace_controller.dart';
import 'features/marketplace/services/marketplace_service.dart';
import 'features/orders/controllers/order_controller.dart';
import 'features/orders/services/order_service.dart';
import 'features/profile/controllers/profile_controller.dart';

class InjectionContainer {
  static List<SingleChildWidget> provideProviders() {
    return [
      // API Client (Singleton)
      Provider<ApiClient>(create: (_) => ApiClient()),
      // Auth
      ProxyProvider<ApiClient, AuthService>(
        update: (_, apiClient, __) => AuthService(apiClient: apiClient),
      ),
      ChangeNotifierProxyProvider<AuthService, AuthController>(
        create: (_) =>
            AuthController(authService: AuthService(apiClient: ApiClient())),
        update: (_, authService, __) =>
            AuthController(authService: authService),
      ),
      // Admin
      Provider<AdminService>(create: (_) => AdminService()),
      ChangeNotifierProxyProvider<AdminService, AdminController>(
        create: (_) => AdminController(adminService: AdminService()),
        update: (_, adminService, __) =>
            AdminController(adminService: adminService),
      ),
      // Marketplace
      ProxyProvider<ApiClient, MarketplaceService>(
        update: (_, apiClient, __) => MarketplaceService(apiClient: apiClient),
      ),
      ChangeNotifierProxyProvider<MarketplaceService, MarketplaceController>(
        create: (_) => MarketplaceController(
          marketplaceService: MarketplaceService(apiClient: ApiClient()),
        ),
        update: (_, marketplaceService, __) =>
            MarketplaceController(marketplaceService: marketplaceService),
      ),
      // Cart
      ProxyProvider<ApiClient, CartService>(
        update: (_, apiClient, __) => CartService(apiClient: apiClient),
      ),
      ChangeNotifierProxyProvider<CartService, CartController>(
        create: (_) =>
            CartController(cartService: CartService(apiClient: ApiClient())),
        update: (_, cartService, __) =>
            CartController(cartService: cartService),
      ),
      // Orders
      ProxyProvider<ApiClient, OrderService>(
        update: (_, apiClient, __) => OrderService(apiClient: apiClient),
      ),
      ChangeNotifierProxyProvider<OrderService, OrderController>(
        create: (_) =>
            OrderController(orderService: OrderService(apiClient: ApiClient())),
        update: (_, orderService, __) =>
            OrderController(orderService: orderService),
      ),
      // Profile (depends on AuthController)
      ChangeNotifierProxyProvider<AuthController, ProfileController>(
        create: (_) => ProfileController(
          authController: AuthController(
            authService: AuthService(apiClient: ApiClient()),
          ),
        ),
        update: (_, authController, __) =>
            ProfileController(authController: authController),
      ),
    ];
  }
}
