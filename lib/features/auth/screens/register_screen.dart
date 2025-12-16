import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    // final previousState = authController.state; // Baris ini tidak lagi diperlukan

    // Panggil fungsi register. State akan berubah dari initial/unauthenticated -> loading -> initial (sukses) atau error (gagal)
    await authController.register(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      address: _addressController.text,
      phone: _phoneController.text,
      role: 'user',
      subRole: 'warga',
    );

    // Cek jika registrasi berhasil:
    // 1. Widget masih terpasang (mounted)
    // 2. State akhir dari controller adalah AuthState.initial (yang disetel saat sukses)
    if (mounted && authController.state == AuthState.initial) {

      // REGISTRASI BERHASIL: Navigasi ke halaman login
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));

      // Tampilkan pesan sukses (pop-up)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: AppColors.successGreen,
          duration: Duration(seconds: 3),
        ),
      );
    }
    // Jika gagal (authController.state == AuthState.error), pesan error akan ditampilkan 
    // secara otomatis oleh widget Selector di bagian bawah build().
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    context.read<AuthController>().clearError();
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back, color: AppColors.primaryBlack),
                ),
                SizedBox(height: 30),
                Text(
                  'Buat Akun',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Daftar untuk memulai berbelanja',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.neutralDarkGray,
                  ),
                ),
                SizedBox(height: 30),
                InputField(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama Anda',
                  controller: _nameController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                InputField(
                  label: AppStrings.email,
                  hint: 'Masukkan email Anda',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value!)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                InputField(
                  label: 'Alamat',
                  hint: 'Masukkan alamat Anda',
                  controller: _addressController,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Alamat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                InputField(
                  label: 'Nomor Telepon',
                  hint: 'Masukkan nomor telepon Anda',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Nomor telepon tidak boleh kosong';
                    }
                    if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value!)) {
                      return 'Format nomor telepon tidak valid';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                InputField(
                  label: AppStrings.password,
                  hint: 'Masukkan kata sandi',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Kata sandi tidak boleh kosong';
                    }
                    if ((value?.length ?? 0) < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                InputField(
                  label: AppStrings.confirmPassword,
                  hint: 'Konfirmasi kata sandi',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Konfirmasi kata sandi tidak boleh kosong';
                    }
                    if (value != _passwordController.text) {
                      return 'Kata sandi tidak cocok';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),

                // Area untuk menampilkan pesan error (termasuk "Email sudah terdaftar")
                Selector<AuthController, AuthState>(
                  selector: (_, ctrl) => ctrl.state,
                  builder: (context, state, child) {
                    if (state != AuthState.error) return SizedBox.shrink();
                    final msg = context.read<AuthController>().errorMessage;
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.errorRed,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  // Menampilkan pesan error spesifik dari controller/API
                                  msg ?? 'Terjadi kesalahan', 
                                  style: TextStyle(
                                    color: AppColors.errorRed,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    );
                  },
                ),

                // Tombol Register
                Selector<AuthController, bool>(
                  selector: (_, ctrl) => ctrl.state == AuthState.loading,
                  builder: (context, isLoading, child) {
                    return PrimaryButton(
                      label: AppStrings.register,
                      onPressed: () {
                        if (!isLoading) {
                          _handleRegister();
                        }
                      },
                      isLoading: isLoading,
                      backgroundColor: AppColors.primaryBlack,
                    );
                  },
                ),

                SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: TextStyle(color: AppColors.neutralDarkGray),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          context.read<AuthController>().clearError();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          AppStrings.login,
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}