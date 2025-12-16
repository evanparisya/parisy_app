// lib/features/sekretaris/screens/sekretaris_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/auth/controllers/auth_controller.dart';
import 'package:parisy_app/features/management/reporting/controllers/reporting_controller.dart';
import 'package:parisy_app/features/user/profile/screens/profile_screen.dart'; // Import ProfileScreen
import 'sekretaris_transaction_history_screen.dart';
import 'sekretaris_product_history_screen.dart';

class SekretarisDashboardScreen extends StatefulWidget {
  const SekretarisDashboardScreen({super.key});

  @override
  State<SekretarisDashboardScreen> createState() => _SekretarisDashboardScreenState();
}

class _SekretarisDashboardScreenState extends State<SekretarisDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data for Sekretaris
    Future.microtask(() {
      context.read<ReportingController>().loadTransactionHistory();
      context.read<ReportingController>().loadProductHistory();
    });
  }

  // List of screens for BottomNavBar (3 items)
  late final List<Widget> _widgetOptions = <Widget>[
    const _SekretarisDashboardContent(), // Tab 0: Dashboard Content
    const SekretarisTransactionHistoryScreen(), // Tab 1: History Transaksi
    const SekretarisProductHistoryScreen(),     // Tab 2: History Barang
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  // Helper function to get the current title
  String get _currentTitle {
    switch (_selectedIndex) {
      case 0: return 'Sekretaris Dashboard';
      case 1: return 'History Transaksi';
      case 2: return 'History Barang Jual Beli';
      default: return 'Sekretaris Dashboard';
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
        if (result == 'profile') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
        } else if (result == 'logout') {
          _confirmLogout();
        }
      },
      icon: CircleAvatar( 
        radius: 18,
        backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
        child: Icon(Icons.assignment, size: 24, color: AppColors.primaryGreen), // Ikon Sekretaris
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
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Barang',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF3B82F6),
        unselectedItemColor: AppColors.neutralDarkGray,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Extracting the original dashboard content into a separate widget
class _SekretarisDashboardContent extends StatelessWidget {
  const _SekretarisDashboardContent();

  Widget _buildProfileHeader(BuildContext context, String name, String role) {
    final currentUser = context.read<AuthController>().currentUser;
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
            backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
            child: Icon(Icons.assignment, size: 30, color: AppColors.primaryGreen),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentUser?.name ?? name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlack,
                ),
              ),
              Text(
                'Peran: ${currentUser?.subRole.toUpperCase() ?? role.toUpperCase()}',
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
    final reportingController = context.watch<ReportingController>();
    final currentUser = context.read<AuthController>().currentUser;

    return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header & Welcome ---
            _buildProfileHeader(context, currentUser?.name ?? 'Sekretaris', currentUser?.subRole ?? AppStrings.subRoleSekretaris),
            SizedBox(height: 24),
            
            // --- Statistics Summary ---
            Text('Ringkasan Laporan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatisticCard(
                  title: 'Total Transaksi', 
                  value: reportingController.transactionHistory.length.toString(), 
                  icon: Icons.receipt_long,
                  color: 0xFF3B82F6,
                )),
                SizedBox(width: 12),
                Expanded(child: _StatisticCard(
                  title: 'Total Barang Terdaftar', 
                  value: reportingController.productHistory.length.toString(), 
                  icon: Icons.inventory,
                  color: 0xFFEC4899,
                )),
              ],
            ),
            SizedBox(height: 32),
          ],
        ),
      );
  }
}

// --- Helper Widgets
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