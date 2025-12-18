// lib/features/admin/screens/admin_products_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/utils/category_helper.dart';
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                if (controller.state == MarketplaceState.loading &&
                    controller.products.isEmpty) {
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
                      onDelete: () =>
                          _showDeleteDialog(context, product.id, product.name),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<MarketplaceController>().deleteProduct(id);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.errorRed),
            ),
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
  bool _isPredicting = false;
  String? _selectedCategory;
  String? _predictedCategory;
  final List<String> _categories = CategoryHelper.categories;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
    _selectedCategory = widget.product?.category;
  }

  Future<void> _takePicture() async {
    final controller = context.read<MarketplaceController>();
    final img = await controller.pickImageFromCamera();

    if (img != null) {
      setState(() {
        _pickedImage = img;
        _isPredicting = true;
      });

      try {
        // Prediksi kategori secara otomatis - AI selalu return kategori
        final predictedCat = await controller.predictCategory(img);

        if (mounted) {
          setState(() {
            _isPredicting = false;
            _predictedCategory = predictedCat;
            _selectedCategory = predictedCat; // Set otomatis ke dropdown
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${CategoryHelper.getEmoji(predictedCat)} Kategori: ${CategoryHelper.toDisplayFormat(predictedCat)}',
              ),
              backgroundColor: AppColors.primaryGreen,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isPredicting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memprediksi kategori: ${e.toString()}'),
              backgroundColor: AppColors.errorRed,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
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
                onTap: _isPredicting ? null : _takePicture,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: _isPredicting
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Memprediksi kategori...',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        )
                      : _pickedImage != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_pickedImage!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            if (_predictedCategory != null)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        CategoryHelper.getEmoji(
                                          _predictedCategory!,
                                        ),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        CategoryHelper.toDisplayFormat(
                                          _predictedCategory!,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // Tombol untuk ambil foto ulang
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlack.withOpacity(
                                    0.7,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: _takePicture,
                                  tooltip: 'Ambil foto ulang',
                                ),
                              ),
                            ),
                          ],
                        )
                      : widget.product != null
                      ? Stack(
                          children: [
                            // Tampilkan gambar dari database (base64)
                            widget.product!.imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      base64Decode(widget.product!.imageUrl),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.image_outlined,
                                                    size: 50,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Gagal memuat gambar',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[700],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_outlined,
                                          size: 50,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Gambar Produk',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          widget.product!.name,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: _takePicture,
                                  tooltip: 'Ambil foto baru',
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: AppColors.primaryGreen,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Ambil Foto",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "AI akan prediksi otomatis",
                              style: TextStyle(fontSize: 9, color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Nama Barang',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama barang harus diisi';
                  }
                  if (value.trim().length < 3) {
                    return 'Nama barang minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              InputField(
                label: 'Deskripsi',
                hint: 'Deskripsi',
                controller: _descController,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Harga',
                  hintText: 'Harga (Rp)',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga harus diisi';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Harga harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: 'Stok',
                  hintText: 'Jumlah Stok',
                  suffixText: 'pcs',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok harus diisi';
                  }
                  final stock = int.tryParse(value);
                  if (stock == null || stock < 0) {
                    return 'Stok tidak boleh negatif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    hintText: 'Pilih kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _predictedCategory != null
                        ? Icon(
                            Icons.auto_awesome,
                            color: AppColors.primaryGreen,
                          )
                        : null,
                  ),
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(CategoryHelper.getDisplayWithEmoji(cat)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _predictedCategory != null
                    ? 'Kategori diprediksi AI, Anda masih bisa mengubahnya'
                    : 'Ambil foto produk untuk prediksi kategori otomatis',
                style: TextStyle(
                  fontSize: 11,
                  color: _predictedCategory != null
                      ? AppColors.primaryGreen
                      : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        PrimaryButton(
          label: 'Simpan',
          width: 100,
          isLoading: _isLoading,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Validasi foto - hanya wajib untuk produk baru
              if (_pickedImage == null && widget.product == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Harap ambil foto produk terlebih dahulu!"),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
                return;
              }

              // Validasi kategori
              if (_selectedCategory == null || _selectedCategory!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Kategori harus diisi! Ambil foto untuk prediksi otomatis atau pilih manual.",
                    ),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
                return;
              }

              // Validasi harga
              final price = double.tryParse(_priceController.text);
              if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Harga harus lebih dari 0!"),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
                return;
              }

              // Validasi stok
              final stock = int.tryParse(_stockController.text);
              if (stock == null || stock < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Stok tidak boleh negatif!"),
                    backgroundColor: AppColors.errorRed,
                  ),
                );
                return;
              }

              setState(() => _isLoading = true);

              final controller = context.read<MarketplaceController>();

              // Jika edit dan ada foto baru, atau tambah baru
              bool success;
              if (widget.product == null) {
                // Mode tambah - wajib ada foto
                success = await controller.addProductWithCamera(
                  name: _nameController.text.trim(),
                  description: _descController.text.trim(),
                  price: price,
                  stock: stock,
                  image: _pickedImage!,
                  category: _selectedCategory,
                );
              } else {
                // Mode edit
                if (_pickedImage != null) {
                  // Ada foto baru, update dengan foto baru
                  success = await controller.updateProductWithNewImage(
                    id: widget.product!.id,
                    name: _nameController.text.trim(),
                    description: _descController.text.trim(),
                    price: price,
                    stock: stock,
                    image: _pickedImage!,
                    category: _selectedCategory,
                  );
                } else {
                  // Tidak ada foto baru, update tanpa foto
                  success = await controller.updateProductWithoutImage(
                    id: widget.product!.id,
                    name: _nameController.text.trim(),
                    description: _descController.text.trim(),
                    price: price,
                    stock: stock,
                    category: _selectedCategory!,
                  );
                }
              }

              if (success && mounted) {
                Navigator.pop(context);
                // Tampilkan pesan sukses
                final categoryDisplay = _selectedCategory != null
                    ? CategoryHelper.getDisplayWithEmoji(_selectedCategory!)
                    : '';
                final actionText = widget.product == null
                    ? 'ditambahkan'
                    : 'diupdate';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _predictedCategory != null && widget.product == null
                          ? '✅ Produk berhasil $actionText!\nKategori: $categoryDisplay'
                          : '✅ Produk berhasil $actionText!',
                    ),
                    backgroundColor: AppColors.primaryGreen,
                    duration: const Duration(seconds: 3),
                  ),
                );
                controller.clearError();
              } else if (mounted) {
                // Tampilkan error message dengan detail
                final errorMsg =
                    controller.errorMessage ?? 'Gagal menyimpan produk';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMsg),
                    backgroundColor: AppColors.errorRed,
                    duration: const Duration(seconds: 4),
                    action: SnackBarAction(
                      label: 'Tutup',
                      textColor: Colors.white,
                      onPressed: () {},
                    ),
                  ),
                );
              }

              if (mounted) {
                setState(() => _isLoading = false);
              }
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
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.fastfood),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Rp ${product.price.toStringAsFixed(0)} | Stok: ${product.stock}\nKategori: ${product.category}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
