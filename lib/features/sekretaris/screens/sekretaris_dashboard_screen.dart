// lib/features/sekretaris/screens/sekretaris_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/auth/controllers/auth_controller.dart';
import 'package:parisy_app/features/management/reporting/controllers/reporting_controller.dart';
import 'sekretaris_transaction_history_screen.dart';
import 'sekretaris_product_history_screen.dart';

class SekretarisDashboardScreen extends StatefulWidget {
  const SekretarisDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SekretarisDashboardScreen> createState() => _SekretarisDashboardScreenState();
}

class _SekretarisDashboardScreenState extends State<SekretarisDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data for Sekretaris
    Future.microtask(() {
      context.read<ReportingController>().loadTransactionHistory();
      context.read<ReportingController>().loadProductHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportingController = context.watch<ReportingController>();
    final currentUser = context.read<AuthController>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Sekretaris Dashboard',
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
            _buildProfileHeader(currentUser?.name ?? 'Sekretaris', currentUser?.subRole ?? AppStrings.subRoleSekretaris),
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

            // --- Menu History ---
            Text('Menu History & Pelaporan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
            SizedBox(height: 12),

            _AdminMenuButton(
              icon: Icons.history,
              title: 'History Transaksi',
              subtitle: 'Lihat seluruh riwayat pembelian warga',
              color: 0xFF3B82F6,
              onTap: () => _navigateTo(SekretarisTransactionHistoryScreen()),
            ),
            _AdminMenuButton(
              icon: Icons.list_alt,
              title: 'History Barang Jual Beli',
              subtitle: 'Lihat daftar barang terdaftar dan statusnya',
              color: 0xFFEC4899,
              onTap: () => _navigateTo(SekretarisProductHistoryScreen()),
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
            child: Icon(Icons.assignment, size: 30, color: AppColors.primaryGreen),
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

// --- Helper Widgets (Disalin dari Bendahara Dashboard) ---
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