// lib/features/admin/screens/admin_warga_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/management/users/controllers/user_management_controller.dart';
import 'package:parisy_app/features/management/users/models/warga_model.dart';

class AdminWargaScreen extends StatefulWidget {
  const AdminWargaScreen({Key? key}) : super(key: key);

  @override
  State<AdminWargaScreen> createState() => _AdminWargaScreenState();
}

class _AdminWargaScreenState extends State<AdminWargaScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() {
      context.read<UserManagementController>().loadAllWarga();
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
        title: Text('CRUD Data Warga', style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Warga',
                hintText: 'Cari nama atau email',
                prefixIcon: Icon(Icons.search, color: AppColors.neutralDarkGray),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                context.read<UserManagementController>().loadAllWarga();
              },
            ),
          ),

          // Users list
          Expanded(
            child: Consumer<UserManagementController>(
              builder: (context, controller, _) {
                if (controller.state == UserManagementState.loading && controller.wargaList.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.wargaList.isEmpty) {
                  return EmptyStateWidget(message: 'Tidak ada data warga.');
                }
                
                final filteredList = controller.wargaList.where((w) {
                  final query = _searchController.text.toLowerCase();
                  return w.name.toLowerCase().contains(query) || w.email.toLowerCase().contains(query);
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final warga = filteredList[index];
                    return _WargaCard(
                      warga: warga,
                      isReadOnly: false, 
                      onEdit: () => _showWargaFormDialog(context, warga),
                      onDelete: () => _showDeleteDialog(context, warga.id, warga.name),
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
        onPressed: () => _showWargaFormDialog(context, null),
        child: Icon(Icons.add, color: AppColors.neutralWhite),
      ),
    );
  }

  void _showWargaFormDialog(BuildContext context, WargaModel? warga) {
    showDialog(
      context: context,
      builder: (context) => _WargaFormDialog(warga: warga),
    );
  }

  void _showDeleteDialog(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Warga'),
        content: Text('Apakah Anda yakin ingin menghapus $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<UserManagementController>().deleteWarga(id);
            },
            child: Text('Hapus', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}

// --- Helper Card untuk Warga ---
class _WargaCard extends StatelessWidget {
  final WargaModel warga;
  final bool isReadOnly; 
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _WargaCard({
    required this.warga, 
    required this.isReadOnly,
    this.onEdit,
    this.onDelete,
  });

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
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              child: Text(warga.subRole.substring(0, 1).toUpperCase(), style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(warga.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
                  Text(warga.email, style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
                  SizedBox(height: 8),
                  Text('Role: ${warga.subRole.toUpperCase()}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryGreen)),
                  Text('Telp: ${warga.phone}', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
                  Text('Alamat: ${warga.address}', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (!isReadOnly)
              Row(
                children: [
                  IconButton(icon: Icon(Icons.edit, color: AppColors.primaryBlack, size: 20), onPressed: onEdit),
                  IconButton(icon: Icon(Icons.delete, color: AppColors.errorRed, size: 20), onPressed: onDelete),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Dialog untuk CRUD Warga ---
class _WargaFormDialog extends StatefulWidget {
  final WargaModel? warga;

  const _WargaFormDialog({this.warga});

  @override
  State<_WargaFormDialog> createState() => _WargaFormDialogState();
}

class _WargaFormDialogState extends State<_WargaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  String? _selectedSubRole;

  final List<String> _managementRoles = [
    AppStrings.subRoleWarga, 
    AppStrings.subRoleRT, 
    AppStrings.subRoleRW, 
    AppStrings.subRoleBendahara, 
    AppStrings.subRoleSekretaris
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.warga?.name ?? '');
    _emailController = TextEditingController(text: widget.warga?.email ?? '');
    _phoneController = TextEditingController(text: widget.warga?.phone ?? '');
    _addressController = TextEditingController(text: widget.warga?.address ?? '');
    _selectedSubRole = widget.warga?.subRole ?? AppStrings.subRoleWarga;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isNew = widget.warga == null;

    return AlertDialog(
      title: Text('${isNew ? 'Tambah' : 'Edit'} Warga'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputField(label: 'Nama', hint: 'Nama Lengkap', controller: _nameController),
              SizedBox(height: 12),
              InputField(label: 'Email', hint: 'Email', controller: _emailController, readOnly: !isNew),
              SizedBox(height: 12),
              InputField(label: 'No. Telepon', hint: 'Nomor Telepon', controller: _phoneController, keyboardType: TextInputType.phone),
              SizedBox(height: 12),
              InputField(label: 'Alamat', hint: 'Alamat Tinggal', controller: _addressController),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Peran Manajemen (Sub-Role)'),
                value: _selectedSubRole,
                items: _managementRoles.map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase()))).toList(),
                onChanged: (value) => setState(() => _selectedSubRole = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
        TextButton(onPressed: () {
          if (_formKey.currentState!.validate()) {
            final newWarga = WargaModel(
              id: widget.warga?.id ?? 0,
              name: _nameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              address: _addressController.text,
              subRole: _selectedSubRole!,
              createdAt: widget.warga?.createdAt ?? DateTime.now(),
            );

            final controller = context.read<UserManagementController>();
            if (isNew) {
              controller.addWarga(newWarga); 
            } else {
              controller.updateWarga(newWarga); 
            }
            Navigator.pop(context);
          }
        }, child: Text('Simpan')),
      ],
    );
  }
}