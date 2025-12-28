// lib/features/bendahara/screens/bendahara_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/auth/controllers/auth_controller.dart';
import 'package:parisy_app/features/management/finance/controllers/finance_controller.dart';
import 'package:parisy_app/features/management/finance/models/financial_report_model.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:intl/intl.dart';
import 'package:parisy_app/features/user/profile/screens/profile_screen.dart'; // Import ProfileScreen
import 'bendahara_finance_screen.dart';

class BendaharaDashboardScreen extends StatefulWidget {
  const BendaharaDashboardScreen({super.key});

  @override
  State<BendaharaDashboardScreen> createState() =>
      _BendaharaDashboardScreenState();
}

class _BendaharaDashboardScreenState extends State<BendaharaDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data for Bendahara
    Future.microtask(() {
      context.read<FinanceController>().loadFinanceData();
    });
  }

  // List of screens for BottomNavBar (2 items)
  late final List<Widget> _widgetOptions = <Widget>[
    _BendaharaDashboardContent(), // Tab 0: Dashboard Content
    const BendaharaFinanceScreen(), // Tab 1: Kelola Keuangan
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Helper function to get the current title
  String get _currentTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Bendahara Dashboard';
      case 1:
        return 'Kelola Uang & History';
      default:
        return 'Bendahara Dashboard';
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
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await context.read<AuthController>().logout(); // Perform logout
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.errorRed),
              ),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        } else if (result == 'logout') {
          _confirmLogout();
        }
      },
      icon: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
        child: Icon(
          Icons.monetization_on,
          size: 24,
          color: AppColors.primaryGreen,
        ), // Ikon Bendahara
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'profile',
          child: ListTile(leading: Icon(Icons.person), title: Text('Profil')),
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
    final financeController = context.watch<FinanceController>();
    final summary = financeController.summary;

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
      body:
          _selectedIndex == 0 &&
              financeController.state == FinanceState.loading &&
              summary == null
          ? Center(child: CircularProgressIndicator())
          : _widgetOptions.elementAt(_selectedIndex), // Display selected screen
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Keuangan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF10B981),
        unselectedItemColor: AppColors.neutralDarkGray,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Extracting the original dashboard content into a separate widget
class _BendaharaDashboardContent extends StatelessWidget {
  const _BendaharaDashboardContent();

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
            child: Icon(
              Icons.monetization_on,
              size: 30,
              color: AppColors.primaryGreen,
            ),
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
    final financeController = context.watch<FinanceController>();
    final currentUser = context.read<AuthController>().currentUser;
    final summary = financeController.summary;

    // Use RefreshIndicator to allow pull-to-refresh on the dashboard content
    return RefreshIndicator(
      onRefresh: financeController.loadFinanceData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header & Welcome ---
            _buildProfileHeader(
              context,
              currentUser?.name ?? 'Bendahara',
              currentUser?.subRole ?? AppStrings.subRoleBendahara,
            ),
            SizedBox(height: 24),

            // --- Financial Summary Card ---
            Text(
              'Ringkasan Keuangan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
              ),
            ),
            SizedBox(height: 12),
            if (summary != null) _FinancialSummaryCard(summary: summary),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widgets
class _SummaryBox extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray),
          ),
          SizedBox(height: 4),
          Text(
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialSummaryCard extends StatelessWidget {
  final FinancialReportModel summary;
  const _FinancialSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo Bersih',
              style: TextStyle(fontSize: 14, color: AppColors.neutralDarkGray),
            ),
            SizedBox(height: 4),
            Text(
              NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp ',
              ).format(summary.netBalance),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryBox(
                    title: 'Pemasukan',
                    value: summary.totalIncome,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _SummaryBox(
                    title: 'Pengeluaran',
                    value: summary.totalExpense,
                    color: AppColors.errorRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
