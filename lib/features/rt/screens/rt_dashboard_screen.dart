// lib/features/rt/screens/rt_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/auth/controllers/auth_controller.dart';
import 'package:parisy_app/features/management/users/controllers/user_management_controller.dart';
import 'package:parisy_app/features/user/marketplace/controllers/marketplace_controller.dart';
import 'rt_warga_screen.dart';
import 'rt_products_screen.dart';

class RtDashboardScreen extends StatefulWidget {
  const RtDashboardScreen({super.key});

  @override
  State<RtDashboardScreen> createState() => _RtDashboardScreenState();
}

class _RtDashboardScreenState extends State<RtDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data for RT (Warga RT-nya saja)
    Future.microtask(() {
      // Asumsi RT hanya bisa melihat warga biasa dan dirinya sendiri
      context.read<UserManagementController>().loadWargaByRT(AppStrings.subRoleRT); 
      context.read<MarketplaceController>().loadInitialData(); // Untuk total barang
    });
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserManagementController>();
    final marketplaceController = context.watch<MarketplaceController>();
    final currentUser = context.read<AuthController>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'RT Dashboard',
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
            _buildProfileHeader(currentUser?.name ?? 'Ketua RT', currentUser?.subRole ?? AppStrings.subRoleRT),
            SizedBox(height: 24),
            
            // --- Statistics Summary ---
            Text('Ringkasan Aset', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatisticCard(
                  title: 'Warga RT', 
                  // Hanya menampilkan jumlah warga yang dimuat (Warga biasa + dirinya)
                  value: userController.wargaList.length.toString(), 
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
            Text('Menu Manajemen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
            SizedBox(height: 12),

            _AdminMenuButton(
              icon: Icons.visibility,
              title: 'Data Warga (Read Only)',
              subtitle: 'Lihat data warga di lingkungan RT Anda',
              color: 0xFF3B82F6,
              onTap: () => _navigateTo(RtWargaScreen()),
            ),
            _AdminMenuButton(
              icon: Icons.shopping_bag,
              title: 'Kelola Barang Jual Beli',
              subtitle: 'Buat, lihat, dan ubah barang (CRU)',
              color: 0xFFEC4899,
              onTap: () => _navigateTo(RtProductsScreen()),
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
            child: Icon(Icons.group, size: 30, color: AppColors.primaryGreen),
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

// Helper Widgets (Disalin agar konsisten dengan Admin Dashboard)
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