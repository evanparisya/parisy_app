// lib/features/rw/screens/rw_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/auth/controllers/auth_controller.dart';
import 'package:parisy_app/features/management/users/controllers/user_management_controller.dart';
import 'package:parisy_app/features/user/marketplace/controllers/marketplace_controller.dart';
import 'rw_rt_management_screen.dart';
import 'rw_warga_screen.dart';
import 'rw_products_screen.dart';

class RwDashboardScreen extends StatefulWidget {
  const RwDashboardScreen({Key? key}) : super(key: key);

  @override
  State<RwDashboardScreen> createState() => _RwDashboardScreenState();
}

class _RwDashboardScreenState extends State<RwDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data for RW (All Warga and All RTs)
    Future.microtask(() {
      context.read<UserManagementController>().loadAllWarga(); 
      context.read<UserManagementController>().loadAllRT();
      context.read<MarketplaceController>().loadInitialData(); // Untuk total barang
    });
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserManagementController>();
    final marketplaceController = context.watch<MarketplaceController>();
    final currentUser = context.read<AuthController>().currentUser;
    
    // Calculate total Warga (Warga subRole)
    final totalWarga = userController.wargaList.where((w) => w.subRole == AppStrings.subRoleWarga).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'RW Dashboard',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
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
            _buildProfileHeader(currentUser?.name ?? 'Ketua RW', currentUser?.subRole ?? AppStrings.subRoleRW),
            SizedBox(height: 24),
            
            // --- Statistics Summary ---
            Text('Ringkasan Lingkungan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatisticCard(
                  title: 'Total RT', 
                  value: userController.rtList.length.toString(), 
                  icon: Icons.list_alt,
                  color: 0xFFF59E0B,
                )),
                SizedBox(width: 12),
                Expanded(child: _StatisticCard(
                  title: 'Total Warga', 
                  value: totalWarga.toString(), 
                  icon: Icons.people_alt,
                  color: 0xFF3B82F6,
                )),
                SizedBox(width: 12),
                Expanded(child: _StatisticCard(
                  title: 'Barang Jual Beli', 
                  value: marketplaceController.products.length.toString(), 
                  icon: Icons.storefront,
                  color: 0xFFEC4899,
                )),
              ],
            ),
            SizedBox(height: 32),

            // --- Menu Manajemen ---
            Text('Menu Manajemen RW', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
            SizedBox(height: 12),

            _AdminMenuButton(
              icon: Icons.group_add,
              title: 'Kelola Data Ketua RT',
              subtitle: 'Tambah, ubah, dan hapus data Ketua RT',
              color: 0xFFF59E0B,
              onTap: () => _navigateTo(RwRtManagementScreen()),
            ),
            _AdminMenuButton(
              icon: Icons.visibility,
              title: 'Data Warga (Read Only)',
              subtitle: 'Lihat data seluruh warga di lingkungan RW',
              color: 0xFF3B82F6,
              onTap: () => _navigateTo(RwWargaScreen()),
            ),
            _AdminMenuButton(
              icon: Icons.shopping_bag,
              title: 'Kelola Barang Jual Beli',
              subtitle: 'Buat, lihat, dan ubah barang (CRU)',
              color: 0xFFEC4899,
              onTap: () => _navigateTo(RwProductsScreen()),
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
            backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
            child: Icon(Icons.security, size: 30, color: AppColors.primaryGreen),
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

// Helper Widgets (Disalin agar konsisten dan mandiri)
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