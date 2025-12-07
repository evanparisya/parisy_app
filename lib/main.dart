import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/widgets/common_widgets.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/cart/controllers/cart_controller.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/marketplace/screens/marketplace_screen.dart';
import 'features/orders/screens/order_history_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'injection_container.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: InjectionContainer.provideProviders(),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(AppColors.primaryGreen),
          ),
          fontFamily: 'Poppins',
        ),
        // Tambahkan rute untuk ProfileScreen (Jika belum ada)
        routes: {
          '/login': (context) => LoginScreen(),
          '/cart': (context) => MainNavigationApp(initialIndex: 2),
          '/profile': (context) => ProfileScreen(),
        },
        home: const RootApp(),
      ),
    );
  }
}

class RootApp extends StatelessWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        if (authController.isAuthenticated) {
          // Check role: ADMIN, RT, atau RW
          final role = authController.currentUser?.role;
          final isManagement = role == 'ADMIN' || role == 'RT' || role == 'RW';

          if (isManagement) {
            return AdminDashboardScreen();
          } else {
            return MainNavigationApp();
          }
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

class MainNavigationApp extends StatefulWidget {
  final int initialIndex;
  const MainNavigationApp({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainNavigationApp> createState() => _MainNavigationAppState();
}

class _MainNavigationAppState extends State<MainNavigationApp> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const MarketplaceScreen(),
    const OrderHistoryScreen(),
    const CartScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: Consumer<CartController>(
          builder: (context, cartController, _) {
            return BottomNavigationBar(
              currentIndex: _currentIndex,
              backgroundColor: Color(AppColors.neutralWhite),
              selectedItemColor: Color(AppColors.primaryGreen),
              unselectedItemColor: Color(AppColors.neutralDarkGray),
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.storefront_outlined),
                  activeIcon: Icon(Icons.storefront),
                  label: 'Marketplace',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  activeIcon: Icon(Icons.shopping_bag),
                  label: 'Pesanan',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: cartController.itemCount > 0
                        ? Text('${cartController.itemCount}')
                        : null,
                    child: Icon(Icons.shopping_cart_outlined),
                  ),
                  activeIcon: Badge(
                    label: cartController.itemCount > 0
                        ? Text('${cartController.itemCount}')
                        : null,
                    child: Icon(Icons.shopping_cart),
                  ),
                  label: 'Keranjang',
                ),
              ],
            );
          },
        ),
        appBar: AppBar(
          backgroundColor: Color(AppColors.primaryGreen),
          elevation: 0,
          title: Consumer<AuthController>(
            builder: (context, authController, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.appName,
                          style: TextStyle(
                            color: Color(AppColors.neutralWhite),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Halo, ${authController.currentUser?.name ?? 'User'}',
                          style: TextStyle(
                            color: Color(AppColors.neutralWhite),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Profile action (visible as an icon on the AppBar)
                  ProfileAppBarAction(iconColor: Color(AppColors.neutralWhite)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
