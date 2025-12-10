// lib/features/bendahara/screens/bendahara_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/auth/controllers/auth_controller.dart';
import 'package:parisy_app/features/management/finance/controllers/finance_controller.dart';
import 'package:parisy_app/features/management/finance/models/financial_report_model.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:intl/intl.dart';
import 'bendahara_finance_screen.dart';

class BendaharaDashboardScreen extends StatefulWidget {
  const BendaharaDashboardScreen({super.key});

  @override
  State<BendaharaDashboardScreen> createState() => _BendaharaDashboardScreenState();
}

class _BendaharaDashboardScreenState extends State<BendaharaDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data for Bendahara
    Future.microtask(() {
      context.read<FinanceController>().loadFinanceData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final financeController = context.watch<FinanceController>();
    final currentUser = context.read<AuthController>().currentUser;
    final summary = financeController.summary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Bendahara Dashboard',
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
      body: financeController.state == FinanceState.loading && summary == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: financeController.loadFinanceData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header & Welcome ---
                    _buildProfileHeader(currentUser?.name ?? 'Bendahara', currentUser?.subRole ?? AppStrings.subRoleBendahara),
                    SizedBox(height: 24),
                    
                    // --- Financial Summary Card ---
                    Text('Ringkasan Keuangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
                    SizedBox(height: 12),
                    if (summary != null)
                      _FinancialSummaryCard(summary: summary),
                    SizedBox(height: 32),

                    // --- Menu Manajemen ---
                    Text('Menu Keuangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
                    SizedBox(height: 12),

                    _AdminMenuButton(
                      icon: Icons.account_balance_wallet,
                      title: 'Kelola Uang & History',
                      subtitle: 'Atur pemasukan, pengeluaran, dan cek riwayat',
                      color: 0xFF10B981,
                      onTap: () => _navigateTo(BendaharaFinanceScreen()),
                    ),
                  ],
                ),
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
            child: Icon(Icons.monetization_on, size: 30, color: AppColors.primaryGreen),
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

// --- Helper Widgets (Disalin dari Admin Dashboard) ---
class _SummaryBox extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  const _SummaryBox({required this.title, required this.value, required this.color});

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
          Text(title, style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
          SizedBox(height: 4),
          Text(
            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(value),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
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
            Text('Saldo Bersih', style: TextStyle(fontSize: 14, color: AppColors.neutralDarkGray)),
            SizedBox(height: 4),
            Text(
              NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(summary.netBalance),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _SummaryBox(
                  title: 'Pemasukan',
                  value: summary.totalIncome,
                  color: AppColors.primaryGreen,
                )),
                SizedBox(width: 16),
                Expanded(child: _SummaryBox(
                  title: 'Pengeluaran',
                  value: summary.totalExpense,
                  color: AppColors.errorRed,
                )),
              ],
            ),
          ],
        ),
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