// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/screens/login_screen.dart';

// Import Screens Roles
import 'features/admin/screens/admin_dashboard_screen.dart';
import 'features/rt/screens/rt_dashboard_screen.dart';
import 'features/rw/screens/rw_dashboard_screen.dart';
import 'features/sekretaris/screens/sekretaris_dashboard_screen.dart';
import 'features/bendahara/screens/bendahara_dashboard_screen.dart';

// Import User Features
import 'features/user/cart/controllers/cart_controller.dart';
import 'features/user/marketplace/screens/marketplace_screen.dart';
import 'features/user/cart/screens/cart_screen.dart';
import 'features/user/orders/screens/order_history_screen.dart'; // Perbaikan Impor
import 'features/user/profile/screens/profile_screen.dart';

import 'injection_container.dart'; // Import dipertahankan

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // FIX 1 & 3: Akses static method dengan nama kelas InjectionContainer
      providers: InjectionContainer.provideProviders(), 
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryGreen,
          ),
          fontFamily: 'Poppins',
        ),
        // Definisikan rute global jika diperlukan
        routes: {
          '/login': (context) => LoginScreen(),
          '/user_home': (context) => MainNavigationApp(initialIndex: 0),
        },
        home: const RootApp(),
      ),
    );
  }
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Memantau status otentikasi
    // Perbaikan: Hapus local variable authController jika tidak digunakan di RootApp
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        if (authController.isAuthenticated && authController.currentUser != null) {
          final subRole = authController.currentUser!.subRole;

          // Pisahkan routing berdasarkan sub_role manajemen
          switch (subRole) {
            case AppStrings.subRoleAdmin:
              return AdminDashboardScreen();
            case AppStrings.subRoleRT:
              return RtDashboardScreen();
            case AppStrings.subRoleRW:
              return RwDashboardScreen();
            case AppStrings.subRoleBendahara:
              return BendaharaDashboardScreen();
            case AppStrings.subRoleSekretaris:
              return SekretarisDashboardScreen();
            case AppStrings.subRoleWarga:
            default:
              return MainNavigationApp(); // Default Warga
          }
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

// Navigasi Utama untuk peran 'Warga' (User)
class MainNavigationApp extends StatefulWidget {
  final int initialIndex;
  const MainNavigationApp({super.key, this.initialIndex = 0});

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
    // FIX 4: Ganti WillPopScope dengan PopScope
    return PopScope(
      canPop: false, // Mencegah kembali dari Home
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Consumer<CartController>(
          builder: (context, cartController, _) {
            // FIX 2: Ganti itemUniqueCount (yang tidak terdefinisi) dengan itemCount (yang benar)
            final cartItemCount = cartController.itemCount; 

            return BottomNavigationBar(
              currentIndex: _currentIndex,
              backgroundColor: AppColors.background,
              selectedItemColor: AppColors.primaryBlack, 
              unselectedItemColor: AppColors.neutralDarkGray,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              items: [
                _buildNavItem(Icons.storefront_outlined, Icons.storefront, 'Home', 0),
                _buildNavItem(Icons.shopping_bag_outlined, Icons.shopping_bag, 'Pesanan', 1),
                _buildNavItemWithBadge(cartItemCount, Icons.shopping_cart_outlined, Icons.shopping_cart, 'Keranjang', 2),
              ],
            );
          },
        ),
        appBar: _buildAppBar(context),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData outlineIcon, IconData filledIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(_currentIndex == index ? filledIcon : outlineIcon),
      label: label,
    );
  }

  BottomNavigationBarItem _buildNavItemWithBadge(int count, IconData outlineIcon, IconData filledIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Badge(
        label: count > 0 ? Text('$count', style: TextStyle(color: AppColors.neutralWhite, fontSize: 10)) : null,
        backgroundColor: AppColors.errorRed,
        isLabelVisible: count > 0,
        child: Icon(_currentIndex == index ? filledIcon : outlineIcon),
      ),
      label: label,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final authController = context.read<AuthController>();
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Text(
        AppStrings.appName,
        style: TextStyle(
          color: AppColors.primaryBlack,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'profile') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            } else if (value == 'logout') {
              // Perbaikan: Tambahkan mounted check sebelum read (walaupun di sini aman, ini praktik terbaik)
              if (!mounted) return; 
              context.read<AuthController>().logout();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'profile', child: Text('Profile')),
            PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.neutralGray,
              child: Icon(Icons.person, color: AppColors.neutralDarkGray, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}