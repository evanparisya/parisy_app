import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/controllers/auth_controller.dart'; 
import '../controllers/admin_controller.dart';
import '../models/admin_user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() {
      context.read<AdminController>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthController>().currentUser?.role; 
    final isFullAdmin = role == 'ADMIN'; 

    return Scaffold(
      backgroundColor: Color(AppColors.neutralWhite),
      appBar: AppBar(
        backgroundColor: Color(AppColors.primaryGreen),
        elevation: 0,
        title: Text(isFullAdmin ? 'Kelola Warga' : 'Data Warga (Read Only)'), 
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ProfileAppBarAction(),
        ],
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
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  context.read<AdminController>().searchUsers(value);
                } else {
                  context.read<AdminController>().loadUsers();
                }
              },
            ),
          ),

          // Users list
          Expanded(
            child: Consumer<AdminController>(
              builder: (context, adminController, _) {
                if (adminController.state == AdminState.loading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (adminController.users.isEmpty) {
                  return Center(child: Text('Tidak ada warga'));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: adminController.users.length,
                  itemBuilder: (context, index) {
                    final user = adminController.users[index];
                    return _UserCard(
                      user: user,
                      onEdit: () {
                        // Hanya panggil dialog jika Admin Penuh
                        if (isFullAdmin) { 
                          _showUserDialog(context, user);
                        }
                      },
                      onDelete: () {
                        // Hanya panggil dialog jika Admin Penuh
                        if (isFullAdmin) { 
                          _showDeleteDialog(context, user.id);
                        }
                      },
                      isReadOnly: !isFullAdmin, // [MODIFIED: Kirim flag Read Only]
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Tombol Tambah hanya untuk Admin Penuh
      floatingActionButton: isFullAdmin
          ? FloatingActionButton( 
              backgroundColor: Color(AppColors.primaryGreen),
              onPressed: () {
                _showUserDialog(context, null);
              },
              child: Icon(Icons.add),
            )
          : null, // [MODIFIED: Sembunyikan tombol]
    );
  }

  void _showUserDialog(BuildContext context, AdminUserModel? user) {
    showDialog(
      context: context,
      builder: (context) => _UserFormDialog(user: user),
    );
  }

  void _showDeleteDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Warga'),
        content: Text('Apakah Anda yakin ingin menghapus warga ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdminController>().deleteUser(userId);
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

class _UserCard extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isReadOnly; 

  const _UserCard({
    required this.user,
    required this.onEdit,
    required this.onDelete,
    this.isReadOnly = false,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.neutralBlack),
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(AppColors.neutralDarkGray),
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol Edit/Delete hanya ditampilkan jika tidak Read Only
              if (!isReadOnly) 
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Color(AppColors.primaryGreen),
                      ),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Color(AppColors.errorRed)),
                      onPressed: onDelete,
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.phone,
                size: 12,
                color: Color(AppColors.neutralDarkGray),
              ),
              SizedBox(width: 4),
              Text(
                user.phone,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(AppColors.neutralDarkGray),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 12,
                color: Color(AppColors.neutralDarkGray),
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  user.address,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(AppColors.neutralDarkGray),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final AdminUserModel? user;

  const _UserFormDialog({this.user});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _addressController = TextEditingController(
      text: widget.user?.address ?? '',
    );
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
    return AlertDialog(
      title: Text(widget.user == null ? 'Tambah Warga' : 'Edit Warga'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputField(
                label: 'Nama',
                hint: 'Masukkan nama',
                controller: _nameController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Nama harus diisi' : null,
              ),
              SizedBox(height: 12),
              InputField(
                label: 'Email',
                hint: 'Masukkan email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Email harus diisi' : null,
              ),
              SizedBox(height: 12),
              InputField(
                label: 'No. Telepon',
                hint: 'Masukkan nomor telepon',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Nomor telepon harus diisi' : null,
              ),
              SizedBox(height: 12),
              InputField(
                label: 'Alamat',
                hint: 'Masukkan alamat',
                controller: _addressController,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Alamat harus diisi' : null,
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
              final user = AdminUserModel(
                id:
                    widget.user?.id ??
                    'USER-${DateTime.now().millisecondsSinceEpoch}',
                name: _nameController.text,
                email: _emailController.text,
                phone: _phoneController.text,
                address: _addressController.text,
                createdAt: widget.user?.createdAt ?? DateTime.now(),
              );

              if (widget.user == null) {
                context.read<AdminController>().addUser(user);
              } else {
                context.read<AdminController>().updateUser(user);
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