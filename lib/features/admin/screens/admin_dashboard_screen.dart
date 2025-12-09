// lib/features/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/auth/controllers/auth_controller.dart';
import 'package:parisy_app/features/management/users/controllers/user_management_controller.dart';
import 'package:parisy_app/features/management/finance/controllers/finance_controller.dart';
import 'package:parisy_app/features/user/marketplace/controllers/marketplace_controller.dart';
import 'package:parisy_app/features/management/reporting/controllers/reporting_controller.dart';
import 'admin_warga_screen.dart';
import 'admin_products_screen.dart';
import 'admin_finance_screen.dart';
import 'admin_transaction_history_screen.dart';
import 'admin_product_history_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserManagementController>();
    final marketplaceController = context.watch<MarketplaceController>();
    final financeController = context.watch<FinanceController>();
    final currentUser = context.read<AuthController>().currentUser;
    final totalWarga = userController.wargaList.length; 
    final netBalance = financeController.summary?.netBalance ?? 0.0;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.errorRed),
            onPressed: () => context.read<AuthController>().logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
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

            // --- Menu Manajemen ---
            Text('Menu Akses Penuh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
            SizedBox(height: 12),

            // Warga (CRUD)
            _AdminMenuButton(
              icon: Icons.person_add,
              title: 'CRUD Data Warga',
              subtitle: 'Tambah, edit, hapus data warga dan manajemen',
              color: 0xFF3B82F6,
              onTap: () => _navigateTo(AdminWargaScreen()),
            ),
            // Barang (CRUD)
            _AdminMenuButton(
              icon: Icons.shopping_bag,
              title: 'CRUD Barang Jual Beli',
              subtitle: 'Manajemen penuh stok dan produk',
              color: 0xFFEC4899,
              onTap: () => _navigateTo(AdminProductsScreen()),
            ),
            // Keuangan (Kelola Uang & History)
            _AdminMenuButton(
              icon: Icons.account_balance_wallet,
              title: 'Kelola Uang & History Keuangan',
              subtitle: 'Atur pemasukan, pengeluaran, dan saldo kas',
              color: 0xFF10B981,
              onTap: () => _navigateTo(AdminFinanceScreen()),
            ),
            // History (Transaksi)
            _AdminMenuButton(
              icon: Icons.receipt_long,
              title: 'History Transaksi (Sekretaris)',
              subtitle: 'Lihat riwayat pembelian seluruh warga',
              color: 0xFFF59E0B,
              onTap: () => _navigateTo(AdminTransactionHistoryScreen()),
            ),
            // History (Barang)
            _AdminMenuButton(
              icon: Icons.inventory,
              title: 'History Barang Terdaftar (Sekretaris)',
              subtitle: 'Lihat semua barang terdaftar dari semua penjual',
              color: 0xFF8B5CF6,
              onTap: () => _navigateTo(AdminProductHistoryScreen()),
            ),
          ],
        ),
      ),
    );
  }

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

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

// --- Helper Widgets (Disalin untuk menjaga konsistensi) ---
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

class _AdminMenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int color;
  final VoidCallback onTap;

  const _AdminMenuButton({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutralGray, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Color(color), size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutralDarkGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppColors.neutralDarkGray, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}