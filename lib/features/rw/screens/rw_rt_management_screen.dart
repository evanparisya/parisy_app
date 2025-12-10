// lib/features/rw/screens/rw_rt_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/management/users/controllers/user_management_controller.dart';
import 'package:parisy_app/features/management/users/models/rt_model.dart';
import 'package:parisy_app/features/management/users/models/warga_model.dart';

class RwRtManagementScreen extends StatefulWidget {
  const RwRtManagementScreen({super.key});

  @override
  State<RwRtManagementScreen> createState() => _RwRtManagementScreenState();
}

class _RwRtManagementScreenState extends State<RwRtManagementScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Load data Ketua RT
    Future.microtask(() {
      context.read<UserManagementController>().loadAllRT();
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
        title: Text('Kelola Data Ketua RT', style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Ketua RT',
                hintText: 'Cari nama atau email',
                prefixIcon: Icon(Icons.search, color: AppColors.neutralDarkGray),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                // Implementasi search RT di controller jika diperlukan
                context.read<UserManagementController>().loadAllRT();
              },
            ),
          ),

          // Users list
          Expanded(
            child: Consumer<UserManagementController>(
              builder: (context, controller, _) {
                if (controller.state == UserManagementState.loading && controller.rtList.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (controller.rtList.isEmpty) {
                  return EmptyStateWidget(message: 'Tidak ada data Ketua RT.');
                }
                
                final filteredList = controller.rtList.where((rt) {
                  final query = _searchController.text.toLowerCase();
                  return rt.name.toLowerCase().contains(query) || rt.email.toLowerCase().contains(query);
                }).toList();

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final rt = filteredList[index];
                    return _RtRwCard(
                      warga: rt,
                      onEdit: () => _showRtFormDialog(context, rt),
                      onDelete: () => _showDeleteDialog(context, rt.id, rt.name),
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
        onPressed: () => _showRtFormDialog(context, null),
        child: Icon(Icons.add, color: AppColors.neutralWhite),
      ),
    );
  }
  
  void _showRtFormDialog(BuildContext context, RtModel? rt) {
    showDialog(
      context: context,
      builder: (context) => _RtRwFormDialog(warga: rt),
    );
  }

  void _showDeleteDialog(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Ketua RT'),
        content: Text('Apakah Anda yakin ingin menghapus $name sebagai Ketua RT?'),
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

// --- Helper Card (Digunakan untuk menampilkan Ketua RT/RW) ---
class _RtRwCard extends StatelessWidget {
  final WargaModel warga;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RtRwCard({required this.warga, required this.onEdit, required this.onDelete});

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
              child: Icon(Icons.vpn_key, size: 20, color: AppColors.primaryGreen),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(warga.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
                  Text(warga.email, style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray)),
                  SizedBox(height: 8),
                  Text('Peran: ${warga.subRole.toUpperCase()}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryGreen)),
                  Text('Alamat: ${warga.address}', style: TextStyle(fontSize: 12, color: AppColors.neutralDarkGray), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
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

// --- Helper Dialog untuk CRUD Ketua RT/RW ---
class _RtRwFormDialog extends StatefulWidget {
  final WargaModel? warga;

  const _RtRwFormDialog({this.warga});

  @override
  State<_RtRwFormDialog> createState() => _RtRwFormDialogState();
}

class _RtRwFormDialogState extends State<_RtRwFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.warga?.name ?? '');
    _emailController = TextEditingController(text: widget.warga?.email ?? '');
    _phoneController = TextEditingController(text: widget.warga?.phone ?? '');
    _addressController = TextEditingController(text: widget.warga?.address ?? '');
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
    final roleText = widget.warga?.subRole.toUpperCase() ?? 'RT';

    return AlertDialog(
      title: Text('${isNew ? 'Tambah' : 'Edit'} Ketua $roleText'),
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
              subRole: widget.warga?.subRole ?? AppStrings.subRoleRT, 
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