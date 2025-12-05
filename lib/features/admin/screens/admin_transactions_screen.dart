import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/admin_controller.dart';
import '../models/admin_transaction_model.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  String _selectedFilter = 'all'; // all, purchase, refund, wallet_topup

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AdminController>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.neutralWhite),
      appBar: AppBar(
        backgroundColor: Color(AppColors.primaryGreen),
        elevation: 0,
        title: Text('Kelola Transaksi'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Summary section
          Consumer<AdminController>(
            builder: (context, adminController, _) {
              return Container(
                padding: EdgeInsets.all(16),
                color: Color(AppColors.primaryGreen),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Transaksi',
                      style: TextStyle(
                        color: Color(AppColors.neutralWhite),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rp ${adminController.totalTransactions.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Color(AppColors.neutralWhite),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${adminController.transactions.length} transaksi',
                      style: TextStyle(
                        color: Color(AppColors.neutralWhite),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Filter buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterButton(
                    label: 'Semua',
                    isSelected: _selectedFilter == 'all',
                    onTap: () {
                      setState(() => _selectedFilter = 'all');
                      context.read<AdminController>().loadTransactions();
                    },
                  ),
                  SizedBox(width: 8),
                  _FilterButton(
                    label: 'Pembelian',
                    isSelected: _selectedFilter == 'purchase',
                    onTap: () {
                      setState(() => _selectedFilter = 'purchase');
                      context.read<AdminController>().getTransactionsByType('purchase');
                    },
                  ),
                  SizedBox(width: 8),
                  _FilterButton(
                    label: 'Top Up',
                    isSelected: _selectedFilter == 'wallet_topup',
                    onTap: () {
                      setState(() => _selectedFilter = 'wallet_topup');
                      context.read<AdminController>().getTransactionsByType('wallet_topup');
                    },
                  ),
                  SizedBox(width: 8),
                  _FilterButton(
                    label: 'Refund',
                    isSelected: _selectedFilter == 'refund',
                    onTap: () {
                      setState(() => _selectedFilter = 'refund');
                      context.read<AdminController>().getTransactionsByType('refund');
                    },
                  ),
                ],
              ),
            ),
          ),

          // Transactions list
          Expanded(
            child: Consumer<AdminController>(
              builder: (context, adminController, _) {
                if (adminController.state == AdminState.loading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (adminController.transactions.isEmpty) {
                  return Center(
                    child: Text('Tidak ada transaksi'),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: adminController.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = adminController.transactions[index];
                    return _TransactionCard(
                      transaction: transaction,
                      onTap: () {
                        _showTransactionDetail(context, transaction);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(BuildContext context, AdminTransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Transaksi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow('ID Transaksi', transaction.id),
              _DetailRow('Pengguna', transaction.userName),
              _DetailRow('Email', transaction.userEmail),
              _DetailRow('Tipe', transaction.type),
              _DetailRow('Status', transaction.status),
              _DetailRow('Jumlah', 'Rp ${transaction.amount.toStringAsFixed(0)}'),
              _DetailRow('Tanggal', transaction.createdAt.toString().split('.')[0]),
              if (transaction.description != null)
                _DetailRow('Deskripsi', transaction.description!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Color(AppColors.primaryGreen) : Color(AppColors.neutralGray),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
                color: isSelected ? Color(AppColors.primaryGreen) : Color(AppColors.neutralGray),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Color(AppColors.neutralWhite) : Color(AppColors.neutralDarkGray),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final AdminTransactionModel transaction;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(AppColors.neutralWhite),
          borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color(AppColors.neutralGray),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getTypeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTypeIcon(),
                color: _getTypeColor(),
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transaction.userName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.neutralBlack),
                        ),
                      ),
                      Text(
                        'Rp ${transaction.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _getTypeColor(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    transaction.description ?? _getTypeLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(AppColors.neutralDarkGray),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transaction.createdAt.toString().split(' ')[0],
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(AppColors.neutralDarkGray),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          transaction.status,
                          style: TextStyle(
                            fontSize: 10,
                            color: _getStatusColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (transaction.type) {
      case 'purchase':
        return Color(0xFFEC4899);
      case 'wallet_topup':
        return Color(0xFF10B981);
      case 'refund':
        return Color(0xFF8B5CF6);
      default:
        return Color(AppColors.neutralDarkGray);
    }
  }

  IconData _getTypeIcon() {
    switch (transaction.type) {
      case 'purchase':
        return Icons.shopping_cart;
      case 'wallet_topup':
        return Icons.wallet;
      case 'refund':
        return Icons.undo;
      default:
        return Icons.receipt;
    }
  }

  String _getTypeLabel() {
    switch (transaction.type) {
      case 'purchase':
        return 'Pembelian Barang';
      case 'wallet_topup':
        return 'Top Up Saldo';
      case 'refund':
        return 'Pengembalian Dana';
      default:
        return 'Transaksi';
    }
  }

  Color _getStatusColor() {
    switch (transaction.status) {
      case 'completed':
        return Color(0xFF10B981);
      case 'pending':
        return Color(0xFFF59E0B);
      case 'cancelled':
        return Color(AppColors.errorRed);
      default:
        return Color(AppColors.neutralDarkGray);
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Color(AppColors.neutralDarkGray),
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(AppColors.neutralBlack),
            ),
          ),
        ],
      ),
    );
  }
}
