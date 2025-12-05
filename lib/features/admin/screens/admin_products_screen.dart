import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../controllers/admin_controller.dart';
import '../models/admin_product_model.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

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
      context.read<AdminController>().loadProducts();
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
      backgroundColor: Color(AppColors.neutralWhite),
      appBar: AppBar(
        backgroundColor: Color(AppColors.primaryGreen),
        elevation: 0,
        title: Text('Kelola Barang'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  context.read<AdminController>().searchProducts(value);
                } else {
                  context.read<AdminController>().loadProducts();
                }
              },
            ),
          ),

          // Products list
          Expanded(
            child: Consumer<AdminController>(
              builder: (context, adminController, _) {
                if (adminController.state == AdminState.loading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (adminController.products.isEmpty) {
                  return Center(child: Text('Tidak ada barang'));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: adminController.products.length,
                  itemBuilder: (context, index) {
                    final product = adminController.products[index];
                    return _ProductCard(
                      product: product,
                      onEdit: () {
                        _showProductDialog(context, product);
                      },
                      onDelete: () {
                        _showDeleteDialog(context, product.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(AppColors.primaryGreen),
        onPressed: () {
          _showProductDialog(context, null);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showProductDialog(BuildContext context, AdminProductModel? product) {
    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(product: product),
    );
  }

  void _showDeleteDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminController>().deleteProduct(productId);
              Navigator.pop(context);
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Color(AppColors.errorRed)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final AdminProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(AppColors.neutralWhite),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(AppColors.neutralGray), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(AppColors.neutralGray),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.image,
                  color: Color(AppColors.neutralDarkGray),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.neutralBlack),
                      ),
                    ),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 12,
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
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.primaryGreen),
                          ),
                        ),
                        Text(
                          'Stok: ${product.stock}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(AppColors.neutralDarkGray),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.category,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(AppColors.neutralDarkGray),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Color(AppColors.primaryGreen),
                    ),
                    onPressed: onEdit,
                    iconSize: 18,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Color(AppColors.errorRed)),
                    onPressed: onDelete,
                    iconSize: 18,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  final AdminProductModel? product;

  const _ProductFormDialog({this.product});

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;
  late TextEditingController _sellerEmailController;
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.product?.category ?? '',
    );
    _sellerEmailController = TextEditingController(
      text: widget.product?.sellerEmail ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _sellerEmailController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _takePhotoFromCamera() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih Sumber Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Ambil Foto dengan Kamera'),
              onTap: () {
                Navigator.pop(context);
                _takePhotoFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
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
              // Image Preview
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Color(AppColors.neutralGray),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(AppColors.neutralGray),
                    width: 2,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            color: Color(AppColors.neutralDarkGray),
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tidak ada foto',
                            style: TextStyle(
                              color: Color(AppColors.neutralDarkGray),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 12),

              // Upload Image Button
              ElevatedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: Icon(Icons.photo_camera),
                label: Text('Pilih Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(AppColors.primaryGreen),
                  foregroundColor: Color(AppColors.neutralWhite),
                  minimumSize: Size(double.infinity, 40),
                ),
              ),
              SizedBox(height: 16),

              // Form Fields
              InputField(
                label: 'Nama Barang',
                hint: 'Masukkan nama barang',
                controller: _nameController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Nama harus diisi' : null,
              ),
              SizedBox(height: 12),
              InputField(
                label: 'Deskripsi',
                hint: 'Masukkan deskripsi',
                controller: _descriptionController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Deskripsi harus diisi' : null,
              ),
              SizedBox(height: 12),
              InputField(
                label: 'Harga',
                hint: 'Masukkan harga',
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Harga harus diisi' : null,
              ),
              SizedBox(height: 12),
              InputField(
                label: 'Stok',
                hint: 'Masukkan stok',
                controller: _stockController,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Stok harus diisi' : null,
              ),
              SizedBox(height: 12),
              InputField(
                label: 'Kategori',
                hint: 'Masukkan kategori',
                controller: _categoryController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Kategori harus diisi' : null,
              ),
              SizedBox(height: 12),
              InputField(
                label: 'Email Penjual',
                hint: 'Masukkan email penjual',
                controller: _sellerEmailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Email penjual harus diisi' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final product = AdminProductModel(
                id:
                    widget.product?.id ??
                    'PROD-${DateTime.now().millisecondsSinceEpoch}',
                name: _nameController.text,
                description: _descriptionController.text,
                price: double.parse(_priceController.text),
                stock: int.parse(_stockController.text),
                category: _categoryController.text,
                sellerEmail: _sellerEmailController.text,
                imageUrl: _selectedImage?.path,
                createdAt: widget.product?.createdAt ?? DateTime.now(),
              );

              if (widget.product == null) {
                context.read<AdminController>().addProduct(product);
              } else {
                context.read<AdminController>().updateProduct(product);
              }

              Navigator.pop(context);
            }
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}
