import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  void _loadUserData() {
    final profileController = context.read<ProfileController>();
    if (profileController.user != null) {
      _nameController.text = profileController.user!.name;
      _phoneController.text = profileController.user!.phone ?? '';
      _addressController.text = profileController.user!.address ?? '';
      _emailController.text = profileController.user!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.neutralWhite),
      appBar: AppBar(
        backgroundColor: Color(AppColors.neutralWhite),
        elevation: 0,
        title: Text(
          'Profil',
          style: TextStyle(
            color: Color(AppColors.primaryBlack),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() => _isEditing = !_isEditing);
                },
                child: Icon(
                  _isEditing ? Icons.check : Icons.edit,
                  color: Color(AppColors.primaryGreen),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ProfileController>(
        builder: (context, profileController, _) {
          if (profileController.isLoading && profileController.user == null) {
            return LoadingWidget(message: 'Memuat profil...');
          }

          if (profileController.user == null) {
            return EmptyStateWidget(
              message: 'Profil tidak ditemukan',
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Section
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color(AppColors.primaryGreen),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            profileController.user!.name
                                .split(' ')
                                .map((word) => word[0])
                                .join()
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.neutralWhite),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Name
                    InputField(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama Anda',
                      controller: _nameController,
                      readOnly: !_isEditing,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Email (non-editable)
                    InputField(
                      label: 'Email',
                      hint: 'Email Anda',
                      controller: _emailController,
                      readOnly: true,
                      enabled: false,
                    ),
                    SizedBox(height: 16),

                    // Phone
                    InputField(
                      label: 'Nomor Telepon',
                      hint: 'Masukkan nomor telepon',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      readOnly: !_isEditing,
                      validator: (value) {
                        if ((value?.isEmpty ?? true) && _isEditing) {
                          return 'Nomor telepon tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Address
                    InputField(
                      label: 'Alamat',
                      hint: 'Masukkan alamat lengkap',
                      controller: _addressController,
                      readOnly: !_isEditing,
                      maxLines: 3,
                      validator: (value) {
                        if ((value?.isEmpty ?? true) && _isEditing) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Member Since
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(AppColors.neutralGray),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Color(AppColors.primaryGreen),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bergabung Sejak',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(AppColors.neutralDarkGray),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  profileController.user!.createdAt != null
                                      ? '${profileController.user!.createdAt!.day}/${profileController.user!.createdAt!.month}/${profileController.user!.createdAt!.year}'
                                      : 'N/A',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(AppColors.primaryBlack),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Action Buttons
                    if (_isEditing) ...[
                      PrimaryButton(
                        label: 'Simpan Perubahan',
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final success =
                                await profileController.updateProfile(
                              name: _nameController.text,
                              phone: _phoneController.text,
                              address: _addressController.text,
                            );

                            if (success && mounted) {
                              setState(() => _isEditing = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Profil berhasil diperbarui'),
                                  backgroundColor:
                                      Color(AppColors.successGreen),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      SizedBox(height: 12),
                    ],

                    // Logout Button
                    SecondaryButton(
                      label: 'Logout',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Konfirmasi Logout'),
                            content: Text('Apakah Anda yakin ingin logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await context
                                      .read<ProfileController>()
                                      .logout();
                                  if (mounted) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/login',
                                      (route) => false,
                                    );
                                  }
                                },
                                child: Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Color(AppColors.errorRed),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
