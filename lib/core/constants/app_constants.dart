// lib/core/constants/app_constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://nitroir.pythonanywhere.com';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Local Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}

class AppStrings {
  // General
  static const String appName = 'ParisyAPP';
  static const String loading = 'Memuat...';
  static const String error = 'Terjadi Kesalahan';
  static const String success = 'Berhasil';
  static const String retry = 'Coba Lagi';

  // Auth
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String email = 'Email';
  static const String password = 'Kata Sandi';
  static const String confirmPassword = 'Konfirmasi Kata Sandi';
  static const String dontHaveAccount = 'Belum punya akun?';
  static const String alreadyHaveAccount = 'Sudah punya akun?';
  static const String loginSuccess = 'Login berhasil';
  static const String registerSuccess = 'Daftar berhasil';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  static const String subRoleAdmin = 'admin';
  static const String subRoleRT = 'rt';
  static const String subRoleRW = 'rw';
  static const String subRoleBendahara = 'bendahara';
  static const String subRoleSekretaris = 'sekretaris';
  static const String subRoleWarga = 'warga';
}

class AppColors {
  // Warna Utama (diambil dari AppColors lama, disesuaikan ke Material Color)
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color primaryBlack = Color(0xFF1F2937);

  // Neutral Colors (untuk background dan teks)
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralGray = Color(0xFFF3F4F6);
  static const Color neutralDarkGray = Color(0xFF6B7280);

  // Status Colors
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);
  static const Color accentYellow = Color(0xFFFCD34D);

  // Untuk UI yang lebih modern/flat seperti desain
  static const Color background = Color(0xFFFFFFFF); // Background putih
  static const Color primaryIcon = Color(0xFF1F2937); // Icon hitam
  static const Color secondaryButtonBg = Color(0xFF000000); // Tombol hitam
}
