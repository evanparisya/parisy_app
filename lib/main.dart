import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
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
          // Check if user is admin or regular user
          final isAdmin = authController.currentUser?.id.startsWith('ADMIN') ?? false;
          
          if (isAdmin) {
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
  const MainNavigationApp({Key? key}) : super(key: key);

  @override
  State<MainNavigationApp> createState() => _MainNavigationAppState();
}

class _MainNavigationAppState extends State<MainNavigationApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MarketplaceScreen(),
    const OrderHistoryScreen(),
    const CartScreen(),
  ];

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
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(),
                          ),
                        );
                      } else if (value == 'logout') {
                        context.read<AuthController>().logout();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'profile', child: Text('Profile')),
                      PopupMenuItem(value: 'logout', child: Text('Logout')),
                    ],
                    child: Icon(
                      Icons.account_circle,
                      color: Color(AppColors.neutralWhite),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Legacy placeholder for old code (bisa dihapus)
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
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
