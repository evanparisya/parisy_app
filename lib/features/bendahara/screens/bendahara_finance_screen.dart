// lib/features/bendahara/screens/bendahara_finance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/management/finance/controllers/finance_controller.dart';
import 'package:parisy_app/features/management/finance/models/cash_flow_model.dart';
import 'package:parisy_app/features/management/finance/models/financial_report_model.dart';
import 'package:intl/intl.dart';

class BendaharaFinanceScreen extends StatefulWidget {
  const BendaharaFinanceScreen({super.key});

  @override
  State<BendaharaFinanceScreen> createState() => _BendaharaFinanceScreenState();
}

class _BendaharaFinanceScreenState extends State<BendaharaFinanceScreen> {
  String? _selectedStatus;
  DateTimeRange? _dateRange;

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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlack),
        title: const Text(
          'Laporan Keuangan',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Filter button
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _selectedStatus != null || _dateRange != null
                  ? AppColors.primaryGreen
                  : AppColors.primaryBlack,
            ),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
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
                  // --- Financial Summary Card ---
                  if (summary != null) _FinancialSummaryCard(summary: summary),
                  const SizedBox(height: 24),

                  // --- Filter indicator ---
                  if (_selectedStatus != null || _dateRange != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_alt,
                            size: 16,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getFilterText(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _clearFilters,
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // --- Transaction History ---
                  const Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
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

  String _getFilterText() {
    List<String> parts = [];
    if (_selectedStatus != null) {
      parts.add('Status: ${_getStatusText(_selectedStatus!)}');
    }
    if (_dateRange != null) {
      parts.add(
        '${DateFormat('dd/MM/yy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yy').format(_dateRange!.end)}',
      );
    }
    return parts.join(' • ');
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

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _dateRange = null;
    });
    context.read<FinanceController>().clearFilters();
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String? tempStatus = _selectedStatus;
        DateTimeRange? tempDateRange = _dateRange;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Transaksi'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _FilterChip(
                          label: 'Semua',
                          selected: tempStatus == null,
                          onSelected: () =>
                              setDialogState(() => tempStatus = null),
                        ),
                        _FilterChip(
                          label: 'Selesai',
                          selected: tempStatus == 'completed',
                          onSelected: () =>
                              setDialogState(() => tempStatus = 'completed'),
                        ),
                        _FilterChip(
                          label: 'Pending',
                          selected: tempStatus == 'pending',
                          onSelected: () =>
                              setDialogState(() => tempStatus = 'pending'),
                        ),
                        _FilterChip(
                          label: 'Dibatalkan',
                          selected: tempStatus == 'cancelled',
                          onSelected: () =>
                              setDialogState(() => tempStatus = 'cancelled'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Rentang Tanggal',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: tempDateRange,
                        );
                        if (picked != null) {
                          setDialogState(() => tempDateRange = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        tempDateRange != null
                            ? '${DateFormat('dd/MM/yy').format(tempDateRange!.start)} - ${DateFormat('dd/MM/yy').format(tempDateRange!.end)}'
                            : 'Pilih Tanggal',
                      ),
                    ),
                    if (tempDateRange != null)
                      TextButton(
                        onPressed: () =>
                            setDialogState(() => tempDateRange = null),
                        child: const Text('Hapus tanggal'),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    setState(() {
                      _selectedStatus = tempStatus;
                      _dateRange = tempDateRange;
                    });
                    context.read<FinanceController>().loadHistoryWithFilters(
                      status: tempStatus,
                      startDate: tempDateRange?.start,
                      endDate: tempDateRange?.end,
                    );
                  },
                  child: const Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
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
