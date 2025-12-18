// lib/features/admin/screens/admin_products_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/user/marketplace/models/product_model.dart';
import 'package:parisy_app/features/user/marketplace/controllers/marketplace_controller.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() {
      if (mounted) {
        context.read<MarketplaceController>().loadAdminProducts();
      }
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Barang',
                prefixIcon: const Icon(Icons.search),
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
          Expanded(
            child: Consumer<MarketplaceController>(
              builder: (context, controller, _) {
                if (controller.state == MarketplaceState.loading && controller.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.products.isEmpty) {
                  return const Center(child: Text('Tidak ada barang tersedia'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.products.length,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return _ProductManagementCard(
                      product: product,
                      onEdit: () => _showProductDialog(context, product),
                      onDelete: () => _showDeleteDialog(context, product.id, product.name),
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
        child: const Icon(Icons.add, color: AppColors.neutralWhite),
      ),
    );
  }

  void _showProductDialog(BuildContext context, ProductModel? product) {
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(product: product),
    );
  }

  void _showDeleteDialog(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<MarketplaceController>().deleteProduct(id);
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  final ProductModel? product;
  const _ProductFormDialog({this.product});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  XFile? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
  }

  Future<void> _takePicture() async {
    final img = await context.read<MarketplaceController>().pickImageFromCamera();
    if (img != null) {
      setState(() => _pickedImage = img);
    }
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
              GestureDetector(
                onTap: _takePicture,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 40, color: AppColors.primaryGreen),
                            Text("Ambil Foto (AI Prediksi)", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              InputField(label: 'Nama', hint: 'Nama Barang', controller: _nameController),
              const SizedBox(height: 12),
              InputField(label: 'Deskripsi', hint: 'Deskripsi', controller: _descController, maxLines: 2),
              const SizedBox(height: 12),
              InputField(label: 'Harga', hint: 'Harga', controller: _priceController, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              InputField(label: 'Stok', hint: 'Stok', controller: _stockController, keyboardType: TextInputType.number),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        PrimaryButton(
          label: 'Simpan',
          width: 100,
          isLoading: _isLoading,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (_pickedImage == null && widget.product == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Harap ambil foto produk!")),
                );
                return;
              }
              setState(() => _isLoading = true);
              final success = await context.read<MarketplaceController>().addProductWithCamera(
                name: _nameController.text,
                description: _descController.text,
                price: double.tryParse(_priceController.text) ?? 0.0,
                stock: int.tryParse(_stockController.text) ?? 0,
                image: _pickedImage!,
              );
              if (success && mounted) Navigator.pop(context);
              setState(() => _isLoading = false);
            }
          },
        ),
      ],
    );
  }
}

class _ProductManagementCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductManagementCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.fastfood),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Rp ${product.price.toStringAsFixed(0)} | Stok: ${product.stock}\nKategori: ${product.category}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}