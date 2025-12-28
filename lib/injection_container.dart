// lib/injection_container.dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'core/api/api_client.dart';

// Auth Module
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/services/auth_service.dart';

// Management Module Logic (Terpusat)
import 'features/management/users/controllers/user_management_controller.dart';
import 'features/management/users/services/user_management_service.dart';
import 'features/management/finance/controllers/finance_controller.dart';
import 'features/management/finance/services/finance_service.dart';
import 'features/management/reporting/controllers/reporting_controller.dart';
import 'features/management/reporting/services/reporting_service.dart';

// User Features (Marketplace, Cart, Orders, Profile, Transaction)
import 'features/user/marketplace/controllers/marketplace_controller.dart';
import 'features/user/marketplace/services/marketplace_service.dart';
import 'features/user/cart/controllers/cart_controller.dart';
import 'features/user/cart/services/cart_service.dart';
import 'features/user/orders/controllers/order_controller.dart';
import 'features/user/orders/services/order_service.dart';
import 'features/user/profile/controllers/profile_controller.dart';
import 'features/user/transaction/controllers/transaction_controller.dart';
import 'features/user/transaction/services/transaction_service.dart';

class InjectionContainer {
  static List<SingleChildWidget> provideProviders() {
    return [
      // 1. Core Services (Singleton)
      Provider<ApiClient>(create: (_) => ApiClient()),

      // 2. Auth Module
      ProxyProvider<ApiClient, AuthService>(
        update: (_, apiClient, __) => AuthService(apiClient: apiClient),
      ),
      ChangeNotifierProxyProvider<AuthService, AuthController>(
        create: (context) =>
            AuthController(authService: context.read<AuthService>()),
        update: (_, authService, existingController) =>
            AuthController(authService: authService),
      ),

      // 3. Management Module (Services and Controllers)

      // Users Management (Admin, RT, RW)
      ProxyProvider<ApiClient, UserManagementService>(
        update: (_, apiClient, __) =>
            UserManagementService(apiClient: apiClient),
      ),
      ChangeNotifierProxyProvider<
        UserManagementService,
        UserManagementController
      >(
        create: (context) => UserManagementController(
          service: context.read<UserManagementService>(),
        ),
        update: (_, service, existingController) =>
            UserManagementController(service: service),
      ),

      // Finance Management (Admin, Bendahara)
      ProxyProvider<ApiClient, FinanceService>(
        update: (_, apiClient, __) => FinanceService(apiClient: apiClient),
      ),
      ChangeNotifierProxyProvider<FinanceService, FinanceController>(
        create: (context) =>
            FinanceController(service: context.read<FinanceService>()),
        update: (_, service, existingController) =>
            FinanceController(service: service),
      ),

      // Reporting Management (Admin, Sekretaris)
      ProxyProvider<ApiClient, ReportingService>(
        update: (_, apiClient, __) => ReportingService(apiClient: apiClient),
      ),
      ChangeNotifierProxyProvider<ReportingService, ReportingController>(
        create: (context) =>
            ReportingController(service: context.read<ReportingService>()),
        update: (_, service, existingController) =>
            ReportingController(service: service),
      ),

      // 4. User Features Module

      // Marketplace
      ProxyProvider<ApiClient, MarketplaceService>(
        update: (_, apiClient, __) => MarketplaceService(apiClient: apiClient),
      ),
      ChangeNotifierProxyProvider<MarketplaceService, MarketplaceController>(
        create: (context) => MarketplaceController(
          marketplaceService: context.read<MarketplaceService>(),
        ),
        update: (_, service, existingController) =>
            MarketplaceController(marketplaceService: service),
      ),

      // Orders
      ProxyProvider<ApiClient, OrderService>(
        update: (_, apiClient, __) => OrderService(apiClient: apiClient),
      ),
      ChangeNotifierProxyProvider2<
        OrderService,
        AuthController,
        OrderController
      >(
        create: (context) => OrderController(
          orderService: context.read<OrderService>(),
          authController: context.read<AuthController>(),
        ),
        update: (_, service, authController, existingController) =>
            OrderController(
              orderService: service,
              authController: authController,
            ),
      ),

      // Cart
      ProxyProvider<ApiClient, CartService>(
        update: (_, apiClient, __) => CartService(apiClient: apiClient),
      ),
      ChangeNotifierProxyProvider2<CartService, AuthController, CartController>(
        create: (context) => CartController(
          cartService: context.read<CartService>(),
          authController: context.read<AuthController>(),
        ),
        update: (_, service, authController, existingController) =>
            CartController(
              cartService: service,
              authController: authController,
            ),
      ),

      // Transaction
      ProxyProvider<ApiClient, TransactionService>(
        update: (_, apiClient, __) => TransactionService(apiClient: apiClient),
      ),
      ChangeNotifierProxyProvider<TransactionService, TransactionController>(
        create: (context) => TransactionController(
          transactionService: context.read<TransactionService>(),
        ),
        update: (_, service, existingController) =>
            TransactionController(transactionService: service),
      ),

      // Profile (Requires AuthController)
      ChangeNotifierProxyProvider<AuthController, ProfileController>(
        create: (context) =>
            ProfileController(authController: context.read<AuthController>()),
        update: (_, authController, existingController) =>
            ProfileController(authController: authController),
      ),
    ];
  }
}
