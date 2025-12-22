// lib/features/admin/screens/admin_finance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/management/finance/controllers/finance_controller.dart';
import 'package:parisy_app/features/management/finance/models/cash_flow_model.dart';
import 'package:parisy_app/features/management/finance/models/financial_report_model.dart';
import 'package:intl/intl.dart';

class AdminFinanceScreen extends StatefulWidget {
  const AdminFinanceScreen({super.key});

  @override
  State<AdminFinanceScreen> createState() => _AdminFinanceScreenState();
}

class _AdminFinanceScreenState extends State<AdminFinanceScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FinanceController>().loadFinanceData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<FinanceController>(
        builder: (context, controller, child) {
          if (controller.state == FinanceState.loading &&
              controller.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = controller.summary;
          final history = controller.history;

          return RefreshIndicator(
            onRefresh: controller.loadFinanceData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (summary != null) _FinancialSummaryCard(summary: summary),
                  const SizedBox(height: 24),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Semua',
                          selected: _selectedStatus == null,
                          onSelected: () => _filterByStatus(context, null),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Selesai',
                          selected: _selectedStatus == 'completed',
                          onSelected: () =>
                              _filterByStatus(context, 'completed'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Pending',
                          selected: _selectedStatus == 'pending',
                          onSelected: () => _filterByStatus(context, 'pending'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Dibatalkan',
                          selected: _selectedStatus == 'cancelled',
                          onSelected: () =>
                              _filterByStatus(context, 'cancelled'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Riwayat Transaksi',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (controller.state == FinanceState.loading &&
                      summary != null)
                    const Center(
                      child: LinearProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),

                  if (history.isEmpty)
                    const EmptyStateWidget(
                      message: 'Belum ada riwayat transaksi.',
                    ),

                  ...history.map((entry) => _TransactionItemCard(entry: entry)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _filterByStatus(BuildContext context, String? status) {
    setState(() => _selectedStatus = status);
    context.read<FinanceController>().loadHistoryWithFilters(status: status);
  }
}

// --- Helper Widgets ---
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Chip(
        label: Text(label),
        backgroundColor: selected ? AppColors.primaryGreen : Colors.grey[200],
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.primaryBlack,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final int? count;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.color,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.neutralDarkGray,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(value),
            style: TextStyle(
              fontSize: 12,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pendapatan',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.neutralDarkGray,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${summary.totalTransactions} Transaksi',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp ',
              ).format(summary.totalIncome),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryBox(
                    title: 'Selesai',
                    value: summary.totalIncome,
                    color: AppColors.primaryGreen,
                    count: summary.completedCount,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryBox(
                    title: 'Pending',
                    value: summary.totalPending,
                    color: AppColors.accentYellow,
                    count: summary.pendingCount,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryBox(
                    title: 'Batal',
                    value: summary.totalCancelled,
                    color: AppColors.errorRed,
                    count: summary.cancelledCount,
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

class _TransactionItemCard extends StatelessWidget {
  final CashFlowEntry entry;
  const _TransactionItemCard({required this.entry});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.primaryGreen;
      case 'pending':
        return AppColors.accentYellow;
      case 'cancelled':
        return AppColors.errorRed;
      default:
        return AppColors.neutralDarkGray;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Selesai';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.access_time;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(entry.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutralGray),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(_getStatusIcon(entry.status), color: statusColor),
        ),
        title: Text(
          entry.code,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd MMM yyyy, HH:mm').format(entry.createdAt)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusText(entry.status),
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              NumberFormat.currency(
                locale: 'id',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(entry.amount),
              style: TextStyle(
                color: entry.status == 'completed'
                    ? AppColors.primaryGreen
                    : statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              entry.paymentMethod.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.neutralDarkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
