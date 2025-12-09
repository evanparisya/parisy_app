// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/core/widgets/common_widgets.dart';
import 'package:parisy_app/core/constants/dummy_data.dart';
import '../controllers/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    // Dummy data untuk testing - gunakan salah satu user manajemen
    _emailController.text = DummyData.mockUsers.keys.firstWhere((k) => k == 'admin@gmail.com', orElse: () => 'warga@gmail.com');
    _passwordController.text = 'password';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                SizedBox(height: 40),
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selamat datang kembali',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.neutralDarkGray,
                  ),
                ),
                SizedBox(height: 40),
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
                SizedBox(height: 30),

                // Show error area only when state indicates an error.
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

                // Only the button should rebuild for loading state.
                Selector<AuthController, bool>(
                  selector: (_, ctrl) => ctrl.state == AuthState.loading,
                  builder: (context, isLoading, child) {
                    return PrimaryButton(
                      label: AppStrings.login,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthController>().login(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                        }
                      },
                      isLoading: isLoading,
                      // Warna tombol utama hitam sesuai desain (override default green)
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
                        AppStrings.dontHaveAccount,
                        style: TextStyle(
                          color: AppColors.neutralDarkGray,
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          context.read<AuthController>().clearError();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          AppStrings.register,
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