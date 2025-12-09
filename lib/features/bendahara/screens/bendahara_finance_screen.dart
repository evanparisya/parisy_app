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
  const BendaharaFinanceScreen({Key? key}) : super(key: key);

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
        title: Text('Kelola Uang & History', style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
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
          if (controller.state == FinanceState.loading && controller.summary == null) {
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
                  if (summary != null)
                    _FinancialSummaryCard(summary: summary),
                  SizedBox(height: 24),

                  // --- Cash Flow History ---
                  Text('History Arus Kas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
                  SizedBox(height: 12),
                  
                  if (controller.state == FinanceState.loading && summary != null)
                    Center(child: LinearProgressIndicator(color: AppColors.primaryGreen)),

                  if (history.isEmpty)
                    EmptyStateWidget(message: 'Belum ada riwayat arus kas.'),

                  ...history.map((entry) => _CashFlowItemCard(entry: entry)).toList(),
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
}

// --- Helper Widgets (Diambil dari Admin Finance untuk konsistensi) ---

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

class _CashFlowItemCard extends StatelessWidget {
  final CashFlowEntry entry;
  const _CashFlowItemCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.type == 'IN';
    final color = isIncome ? AppColors.primaryGreen : AppColors.errorRed;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.neutralGray)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(isIncome ? Icons.add : Icons.remove, color: color),
        ),
        title: Text(entry.description, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('dd MMM yyyy').format(entry.date)),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${isIncome ? '+' : '-'} ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(entry.amount)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            Text(entry.sourceOrDestination, style: TextStyle(fontSize: 10, color: AppColors.neutralDarkGray)),
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
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.entry?.description ?? '');
    _amountController = TextEditingController(text: widget.entry?.amount.toString() ?? '');
    _sourceController = TextEditingController(text: widget.entry?.sourceOrDestination ?? '');
    _selectedType = widget.entry?.type ?? 'IN';
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
                decoration: InputDecoration(labelText: 'Tipe'),
                value: _selectedType,
                items: ['IN', 'OUT'].map((t) => DropdownMenuItem(value: t, child: Text(t == 'IN' ? 'Pemasukan' : 'Pengeluaran'))).toList(),
                onChanged: (value) => setState(() => _selectedType = value),
              ),
              SizedBox(height: 12),
              InputField(label: 'Deskripsi', hint: 'Misal: Penjualan sayur', controller: _descController),
              SizedBox(height: 12),
              InputField(label: 'Jumlah (Rp)', hint: 'Jumlah uang', controller: _amountController, keyboardType: TextInputType.number),
              SizedBox(height: 12),
              InputField(label: 'Sumber/Tujuan', hint: 'Misal: Marketplace / Kas Umum', controller: _sourceController),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
        TextButton(onPressed: () {
          if (_formKey.currentState!.validate()) {
            final entry = CashFlowEntry(
              id: widget.entry?.id ?? 0,
              description: _descController.text,
              amount: double.tryParse(_amountController.text) ?? 0.0,
              type: _selectedType!,
              date: widget.entry?.date ?? DateTime.now(),
              sourceOrDestination: _sourceController.text,
            );

            context.read<FinanceController>().saveCashFlow(entry);
            Navigator.pop(context);
          }
        }, child: Text('Simpan')),
      ],
    );
  }
}