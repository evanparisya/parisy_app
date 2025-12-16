// lib/features/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/auth/controllers/auth_controller.dart';
import 'package:parisy_app/features/management/users/controllers/user_management_controller.dart';
import 'package:parisy_app/features/management/finance/controllers/finance_controller.dart';
import 'package:parisy_app/features/user/marketplace/controllers/marketplace_controller.dart';
import 'package:parisy_app/features/management/reporting/controllers/reporting_controller.dart';
import 'package:parisy_app/features/user/profile/screens/profile_screen.dart'; // Import ProfileScreen
import 'admin_warga_screen.dart';
import 'admin_products_screen.dart';
import 'admin_finance_screen.dart';
import 'admin_transaction_history_screen.dart';
// import 'admin_product_history_screen.dart'; // Dianggap sebagai bagian dari AdminTransactionHistoryScreen/Pelaporan

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0; // State untuk BottomNavBar

  @override
  void initState() {
    super.initState();
    // Load all necessary data for Admin dashboard
    Future.microtask(() {
      context.read<UserManagementController>().loadAllWarga();
      context.read<MarketplaceController>().loadInitialData(); 
      context.read<FinanceController>().loadFinanceData();
      context.read<ReportingController>().loadTransactionHistory();
    });
  }
  
  // List of screens for BottomNavBar (5 items)
  late final List<Widget> _widgetOptions = <Widget>[
    const _AdminDashboardContent(), // Tab 0: Dashboard (Ringkasan)
    const AdminWargaScreen(), // Tab 1: Warga (CRUD)
    const AdminProductsScreen(), // Tab 2: Barang (CRUD)
    const AdminFinanceScreen(), // Tab 3: Keuangan
    const AdminTransactionHistoryScreen(), // Tab 4: Pelaporan
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  // Helper function to get the current title
  String get _currentTitle {
    switch (_selectedIndex) {
      case 0: return 'Admin Dashboard';
      case 1: return 'CRUD Data Warga';
      case 2: return 'CRUD Barang Jual Beli';
      case 3: return 'Kelola Uang & History Keuangan';
      case 4: return 'History Transaksi & Barang';
      default: return 'Admin Dashboard';
    }
  }

  // New function for Logout Confirmation
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                context.read<AuthController>().logout(); // Perform logout
              },
              child: const Text('Logout', style: TextStyle(color: AppColors.errorRed)),
            ),
          ],
        );
      },
    );
  }

  // New function to show profile/logout menu
  Widget _buildProfileMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String result) {
        switch (result) {
          case 'profile':
            // Navigate to Profile Screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            break;
          case 'logout':
            _confirmLogout();
            break;
        }
      },
      // Menggunakan CircleAvatar sebagai 'gambar profile' di App Bar
      icon: CircleAvatar( 
        backgroundColor: AppColors.errorRed.withOpacity(0.2),
        child: Icon(Icons.shield, size: 24, color: AppColors.errorRed), // Ikon Admin
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'profile',
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Profil'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout, color: AppColors.errorRed),
            title: Text('Logout', style: TextStyle(color: AppColors.errorRed)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _currentTitle,
          style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _buildProfileMenu(context), // Menu Profil/Logout
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex), // Display selected screen
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Warga',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Barang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Keuangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pelaporan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.errorRed,
        unselectedItemColor: AppColors.neutralDarkGray,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Extracting the Dashboard Content from original file
class _AdminDashboardContent extends StatelessWidget {
  const _AdminDashboardContent();

  Widget _buildProfileHeader(String name, String role) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutralGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.errorRed.withOpacity(0.2),
            child: Icon(Icons.shield, size: 30, color: AppColors.errorRed),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
              Text(
                'Peran: ${role.toUpperCase()}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.neutralDarkGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserManagementController>();
    final marketplaceController = context.watch<MarketplaceController>();
    final financeController = context.watch<FinanceController>();
    final currentUser = context.read<AuthController>().currentUser;
    final totalWarga = userController.wargaList.length; 
    final netBalance = financeController.summary?.netBalance ?? 0.0;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header & Welcome ---
          _buildProfileHeader(currentUser?.name ?? 'Admin', currentUser?.subRole ?? AppStrings.subRoleAdmin),
          SizedBox(height: 24),
          
          // --- Statistics Summary ---
          Text('Ringkasan Total Aset', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatisticCard(
                title: 'Total Warga', 
                value: totalWarga.toString(), 
                icon: Icons.people_alt,
                color: 0xFF3B82F6,
              )),
              SizedBox(width: 12),
              Expanded(child: _StatisticCard(
                title: 'Total Barang', 
                value: marketplaceController.products.length.toString(), 
                icon: Icons.storefront,
                color: 0xFFEC4899,
              )),
              SizedBox(width: 12),
              Expanded(child: _StatisticCard(
                title: 'Saldo Bersih', 
                value: netBalance > 0 ? '+Rp${netBalance.toStringAsFixed(0)}' : 'Rp0', 
                icon: Icons.account_balance,
                color: 0xFF10B981,
              )),
            ],
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Helper Widgets (Dipertahankan dari file asli)
class _StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final int color;
  const _StatisticCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(color).withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(color), size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(color),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.neutralDarkGray,
            ),
          ),
        ],
      ),
    );
  }
}
// Note: _AdminMenuButton dan _navigateTo dihapus karena diganti BottomNavBar