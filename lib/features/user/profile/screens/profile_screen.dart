// lib/features/user/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/features/user/profile/controllers/profile_controller.dart';
import 'package:parisy_app/features/auth/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryBlack),
        title: Text('Profile', style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ProfileController>(
        builder: (context, controller, _) {
          if (controller.isLoading || controller.user == null) {
            return LoadingWidget(message: 'Memuat profil...');
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                // --- Profile Header (Screen 1 style) ---
                _ProfileHeader(user: controller.user!),
                SizedBox(height: 30),

                // --- Menu List (Screen 1 style) ---
                _ProfileMenuItem(
                  title: 'Personal Information',
                  icon: Icons.person_outline,
                  onTap: () => _navigateToEditProfile(context, controller.user!),
                ),
                _ProfileMenuItem(title: 'My Orders', icon: Icons.shopping_bag_outlined, onTap: () { /* Navigate to Order History */ }),
                _ProfileMenuItem(title: 'Addresses', icon: Icons.location_on_outlined, onTap: () { /* Navigate to Addresses */ }),
                _ProfileMenuItem(title: 'Payment Methods', icon: Icons.credit_card, onTap: () { /* Navigate to Payments */ }),
                _ProfileMenuItem(title: 'Settings', icon: Icons.settings_outlined, onTap: () { /* Navigate to Settings */ }),
                _ProfileMenuItem(title: 'Help & Support', icon: Icons.help_outline, onTap: () { /* Navigate to Help */ }),
                _ProfileMenuItem(
                  title: 'Logout',
                  icon: Icons.logout,
                  color: AppColors.errorRed,
                  onTap: () => controller.logout(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context, UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ProfileEditScreen(user: user),
      ),
    );
  }
}

// --- Component: Profile Header (Screen 1 style) ---
class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Placeholder image (Simulasi: Sophia Williams)
        CircleAvatar(
          radius: 40,
          // Menggunakan Icon sebagai placeholder
          child: Icon(Icons.person, size: 40, color: AppColors.primaryGreen),
          backgroundColor: AppColors.neutralGray,
        ),
        SizedBox(height: 10),
        Text(
          user.name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
        ),
        Text(
          user.email,
          style: TextStyle(fontSize: 14, color: AppColors.neutralDarkGray),
        ),
      ],
    );
  }
}

// --- Component: Menu Item (Screen 1 style) ---
class _ProfileMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ProfileMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.color = AppColors.primaryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, color: AppColors.neutralDarkGray, size: 16),
      onTap: onTap,
    );
  }
}

// --- Component: Profile Edit Screen (Screen 3 style) ---
class _ProfileEditScreen extends StatefulWidget {
  final UserModel user;
  const _ProfileEditScreen({required this.user});

  @override
  State<_ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<_ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _aboutController = TextEditingController(text: 'Tulis sesuatu tentang diri Anda...'); 
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primaryBlack),
        title: Text('Personal Information', style: TextStyle(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Profile Photo Edit ---
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40, color: AppColors.primaryGreen),
                      backgroundColor: AppColors.neutralGray,
                    ),
                    SizedBox(height: 10),
                    Text('Change your photo', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // --- Form Fields ---
              _EditFieldLabel(label: 'Name'),
              InputField(label: '', hint: 'Nama Lengkap', controller: _nameController),
              SizedBox(height: 20),
              
              _EditFieldLabel(label: 'Email'),
              InputField(label: '', hint: 'Email Anda', controller: _emailController, readOnly: true, enabled: false),
              SizedBox(height: 20),

              _EditFieldLabel(label: 'Phone Number'),
              InputField(label: '', hint: 'Nomor Telepon', controller: _phoneController, keyboardType: TextInputType.phone),
              SizedBox(height: 20),

              _EditFieldLabel(label: 'Delivery Address'),
              InputField(label: '', hint: 'Alamat Anda', controller: _addressController),
              SizedBox(height: 20),

              _EditFieldLabel(label: 'About Me'),
              InputField(label: '', hint: 'Tulis sesuatu tentang diri Anda', controller: _aboutController, maxLines: 3),
              SizedBox(height: 40),

              // --- Save Changes Button (Screen 3 style) ---
              PrimaryButton(
                label: 'Save Changes',
                isLoading: controller.isLoading,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await controller.updateProfile(
                      name: _nameController.text,
                      phone: _phoneController.text,
                      address: _addressController.text,
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(controller.errorMessage ?? 'Profil diperbarui!')),
                    );
                    if (controller.errorMessage == null) {
                      Navigator.pop(context); // Kembali ke tampilan profile
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper untuk label di form edit yang lebih minimalis
class _EditFieldLabel extends StatelessWidget {
  final String label;
  const _EditFieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlack,
        ),
      ),
    );
  }
}