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
        iconTheme: IconThemeData(color: AppColors.primaryBlack),
        title: Text(
          'Kelola Uang & History',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Tombol Add diaktifkan di sini
          IconButton(
            icon: Icon(Icons.add, color: AppColors.primaryBlack),
            onPressed: () => _showCashFlowFormDialog(context, null),
          ),
        ],
      ),
      body: Consumer<FinanceController>(
        builder: (context, controller, child) {
          if (controller.state == FinanceState.loading &&
              controller.summary == null) {
            return Center(child: CircularProgressIndicator());
          }

          final summary = controller.summary;
          final history = controller.history;

          return RefreshIndicator(
            onRefresh: controller.loadFinanceData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Financial Summary Card ---
                  if (summary != null) _FinancialSummaryCard(summary: summary),
                  SizedBox(height: 24),

                  // --- Cash Flow History ---
                  Text(
                    'History Arus Kas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  SizedBox(height: 12),

                  if (controller.state == FinanceState.loading &&
                      summary != null)
                    Center(
                      child: LinearProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),

                  if (history.isEmpty)
                    EmptyStateWidget(message: 'Belum ada riwayat arus kas.'),

                  ...history.map(
                    (entry) => _CashFlowItemCard(
                      entry: entry,
                      onEdit: () => _showCashFlowFormDialog(context, entry),
                      onDelete: () => _showDeleteConfirmDialog(context, entry),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCashFlowFormDialog(BuildContext context, CashFlowEntry? entry) {
    showDialog(
      context: context,
      builder: (context) => _CashFlowFormDialog(entry: entry),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, CashFlowEntry entry) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${entry.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final controller = context.read<FinanceController>();
              final success = await controller.deleteCashFlow(entry.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Data berhasil dihapus'
                          : (controller.errorMessage ?? 'Gagal menghapus data'),
                    ),
                    backgroundColor: success
                        ? AppColors.primaryGreen
                        : AppColors.errorRed,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// --- Helper Widgets (Diambil dari Admin Finance untuk konsistensi) ---

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

class _CashFlowItemCard extends StatelessWidget {
  final CashFlowEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _CashFlowItemCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.type == 'IN';
    final color = isIncome ? AppColors.primaryGreen : AppColors.errorRed;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutralGray),
      ),
      child: ListTile(
        onTap: onEdit,
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(isIncome ? Icons.add : Icons.remove, color: color),
        ),
        title: Text(
          entry.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(DateFormat('dd MMM yyyy').format(entry.date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${isIncome ? '+' : '-'} ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(entry.amount)}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
                Text(
                  entry.sourceOrDestination,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.neutralDarkGray,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.neutralDarkGray,
              ),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppColors.errorRed),
                      SizedBox(width: 8),
                      Text(
                        'Hapus',
                        style: TextStyle(color: AppColors.errorRed),
                      ),
                    ],
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

class _CashFlowFormDialog extends StatefulWidget {
  final CashFlowEntry? entry;
  const _CashFlowFormDialog({this.entry});

  @override
  State<_CashFlowFormDialog> createState() => _CashFlowFormDialogState();
}

class _CashFlowFormDialogState extends State<_CashFlowFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descController;
  late TextEditingController _amountController;
  late TextEditingController _sourceController;
  String _selectedType = 'IN';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(
      text: widget.entry?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.entry?.amount.toStringAsFixed(0) ?? '',
    );
    _sourceController = TextEditingController(
      text: widget.entry?.sourceOrDestination ?? '',
    );
    _selectedType = widget.entry?.type ?? 'IN';
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.entry == null;
    return AlertDialog(
      title: Text('${isNew ? 'Tambah' : 'Edit'} Arus Kas'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipe'),
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'IN', child: Text('Pemasukan')),
                  DropdownMenuItem(value: 'OUT', child: Text('Pengeluaran')),
                ],
                onChanged: (value) =>
                    setState(() => _selectedType = value ?? 'IN'),
              ),
              const SizedBox(height: 12),
              InputField(
                label: 'Deskripsi',
                hint: 'Misal: Penjualan sayur',
                controller: _descController,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              InputField(
                label: 'Jumlah (Rp)',
                hint: 'Jumlah uang',
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Jumlah wajib diisi';
                  if (double.tryParse(v) == null)
                    return 'Masukkan angka yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InputField(
                label: 'Sumber/Tujuan',
                hint: 'Misal: Marketplace / Kas Umum',
                controller: _sourceController,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Sumber/Tujuan wajib diisi'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _saveForm,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final entry = CashFlowEntry(
      id: widget.entry?.id ?? 0,
      description: _descController.text.trim(),
      amount: double.tryParse(_amountController.text) ?? 0.0,
      type: _selectedType,
      date: widget.entry?.date ?? DateTime.now(),
      sourceOrDestination: _sourceController.text.trim(),
    );

    final controller = context.read<FinanceController>();
    bool success;

    if (widget.entry == null) {
      success = await controller.createCashFlow(entry);
    } else {
      success = await controller.updateCashFlow(entry);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Data berhasil disimpan'
                : (controller.errorMessage ?? 'Gagal menyimpan data'),
          ),
          backgroundColor: success
              ? AppColors.primaryGreen
              : AppColors.errorRed,
        ),
      );
    }
  }
}
