// lib/features/rt/screens/rt_products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/user/marketplace/models/product_model.dart';
import 'package:parisy_app/features/user/marketplace/controllers/marketplace_controller.dart'; 

class RtProductsScreen extends StatefulWidget {
  const RtProductsScreen({Key? key}) : super(key: key);

  @override
  State<RtProductsScreen> createState() => _RtProductsScreenState();
}

class _RtProductsScreenState extends State<RtProductsScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() {
      context.read<MarketplaceController>().loadInitialData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryBlack),
        title: Text('Kelola Barang Jual Beli (CRU)', style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Barang',
                hintText: 'Cari nama atau deskripsi',
                prefixIcon: Icon(Icons.search, color: AppColors.neutralDarkGray),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  context.read<MarketplaceController>().searchProducts(value);
                } else {
                  context.read<MarketplaceController>().resetFilters();
                }
              },
            ),
          ),

          // Products list
          Expanded(
            child: Consumer<MarketplaceController>(
              builder: (context, controller, _) {
                if (controller.state == MarketplaceState.loading && controller.products.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.products.isEmpty) {
                  return Center(child: Text('Tidak ada barang jual beli'));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return _ProductManagementCard(
                      product: product,
                      onEdit: () => _showProductDialog(context, product),
                      onDelete: () { /* Delete is removed for CRU */ },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlack,
        onPressed: () => _showProductDialog(context, null),
        child: Icon(Icons.add, color: AppColors.neutralWhite),
      ),
    );
  }

  void _showProductDialog(BuildContext context, ProductModel? product) {
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(product: product, isCru: true), // Kirim flag CRU
    );
  }
}

// --- Helper Widgets (Diambil dari Admin Products) ---
class _ProductManagementCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isCru;

  const _ProductManagementCard({required this.product, required this.onEdit, required this.onDelete, this.isCru = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.neutralGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.fastfood, color: AppColors.neutralDarkGray),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
                  Text('Rp ${product.price.toStringAsFixed(0)} | Stok: ${product.stock}', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
                  SizedBox(height: 4),
                  Text('Kategori: ${product.category}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryGreen)),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(icon: Icon(Icons.edit, color: AppColors.primaryBlack, size: 20), onPressed: onEdit),
                if (!isCru) // Jika bukan CRU (yaitu CRUD), tampilkan Delete
                  IconButton(icon: Icon(Icons.delete, color: AppColors.errorRed, size: 20), onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  final ProductModel? product;
  final bool isCru; // Flag CRU/CRUD
  const _ProductFormDialog({this.product, this.isCru = false});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  String? _selectedCategory;
  
  final List<String> _categories = ['daun', 'akar', 'bunga', 'buah'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _selectedCategory = widget.product?.category;
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Tambah Barang' : 'Edit Barang'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputField(label: 'Nama', hint: 'Nama Barang', controller: _nameController),
              SizedBox(height: 12),
              InputField(label: 'Deskripsi', hint: 'Deskripsi Barang', controller: _descController, maxLines: 2),
              SizedBox(height: 12),
              InputField(label: 'Harga', hint: 'Harga Jual', controller: _priceController, keyboardType: TextInputType.number),
              SizedBox(height: 12),
              InputField(label: 'Stok', hint: 'Stok Tersedia', controller: _stockController, keyboardType: TextInputType.number),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Kategori'),
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
              SizedBox(height: 12),
              Text('Image URL/Upload diabaikan untuk demo ini', style: TextStyle(fontSize: 10, color: AppColors.errorRed)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
        TextButton(onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Logika save: Asumsi MarketplaceController menangani C/R/U untuk Vegetable Model
            Navigator.pop(context);
          }
        }, child: Text('Simpan')),
      ],
    );
  }
}