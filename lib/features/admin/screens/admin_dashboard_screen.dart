import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../controllers/admin_controller.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import 'admin_users_screen.dart';
import 'admin_products_screen.dart';
import 'admin_transactions_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    Future.microtask(() {
      context.read<AdminController>().loadUsers();
      context.read<AdminController>().loadProducts();
      // Transaksi hanya diload jika admin penuh
      final role = context.read<AuthController>().currentUser?.role;
      if (role == 'ADMIN') {
        context.read<AdminController>().loadTransactions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthController>().currentUser;
    final role = currentUser?.role;
    final isFullAdmin = role == 'ADMIN';
    final isRTRW = role == 'RT' || role == 'RW';

    return Scaffold(
      backgroundColor: Color(AppColors.neutralWhite),
      appBar: AppBar(
        backgroundColor: Color(AppColors.primaryGreen),
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Color(AppColors.neutralWhite),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [ProfileAppBarAction()],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(AppColors.primaryGreen),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(AppColors.neutralWhite),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Color(AppColors.primaryGreen),
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang, ${role ?? 'Pengguna'}!',
                          style: TextStyle(
                            color: Color(AppColors.neutralWhite),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentUser?.name ?? 'Pengguna',
                          style: TextStyle(
                            color: Color(AppColors.neutralWhite),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Statistics section
            Consumer<AdminController>(
              builder: (context, adminController, _) {
                return Row(
                  children: [
                    Expanded(
                      child: _StatisticCard(
                        title: 'Warga',
                        value: adminController.users.length.toString(),
                        icon: Icons.people,
                        color: 0xFF3B82F6,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatisticCard(
                        title: 'Barang',
                        value: adminController.products.length.toString(),
                        icon: Icons.shopping_bag,
                        color: 0xFFEC4899,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Hanya tampilkan Total Transaksi jika Admin Penuh
                    if (isFullAdmin)
                      Expanded(
                        child: _StatisticCard(
                          title: 'Transaksi',
                          value: adminController.transactions.length.toString(),
                          icon: Icons.receipt,
                          color: 0xFF8B5CF6,
                        ),
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: 24),

            // Admin Menu section
            Text(
              'Menu ${isFullAdmin ? 'Admin' : 'Manajemen'}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppColors.neutralBlack),
              ),
            ),
            SizedBox(height: 12),

            // Kelola Warga (Read access for RT/RW)
            if (isFullAdmin || isRTRW)
              _AdminMenuButton(
                icon: Icons.people,
                title: 'Kelola Warga',
                subtitle: isFullAdmin
                    ? 'Lihat, tambah, edit, hapus warga'
                    : 'Lihat data warga (Read Only)',
                color: 0xFF3B82F6,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminUsersScreen()),
                  );
                },
              ),
            SizedBox(height: 12),

            // Kelola Barang (CRUD access for RT/RW)
            if (isFullAdmin || isRTRW)
              _AdminMenuButton(
                icon: Icons.shopping_bag,
                title: 'Kelola Barang Jual Beli',
                subtitle: 'CRUD barang, cari, upload foto',
                color: 0xFFEC4899,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminProductsScreen(),
                    ),
                  );
                },
              ),
            SizedBox(height: 12),

            // Kelola Transaksi (Only for Admin)
            if (isFullAdmin)
              _AdminMenuButton(
                icon: Icons.receipt,
                title: 'Kelola Transaksi',
                subtitle: 'Lihat riwayat transaksi & uang',
                color: 0xFF8B5CF6,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminTransactionsScreen(),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final int color;

  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(AppColors.neutralWhite),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(color).withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(color), size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(color),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Color(AppColors.neutralDarkGray),
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

  const _AdminMenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(AppColors.neutralWhite),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(color).withOpacity(0.2), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
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
                      color: Color(AppColors.neutralBlack),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(AppColors.neutralDarkGray),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Color(color), size: 16),
          ],
        ),
      ),
    );
  }
}
