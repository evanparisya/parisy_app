class AppConstants {
  // API Configuration
  static const String baseUrl =
      'http://localhost:5000/api'; // Sesuaikan dengan Flask API
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';

  // Local Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String cartKey = 'cart_items';
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

  // Marketplace
  static const String marketplace = 'Marketplace';
  static const String search = 'Cari produk...';
  static const String products = 'Produk';
  static const String price = 'Harga';
  static const String addToCart = 'Tambah ke Keranjang';

  // Cart
  static const String cart = 'Keranjang';
  static const String checkout = 'Checkout';
  static const String totalPrice = 'Total Harga';
  static const String emptyCart = 'Keranjang Kosong';

  // Orders
  static const String orders = 'Pesanan';
  static const String orderStatus = 'Status Pesanan';
  static const String orderHistory = 'Riwayat Pesanan';
  static const String tracking = 'Pelacakan';

  // Camera
  static const String camera = 'Kamera';
  static const String takePhoto = 'Ambil Foto';
  static const String uploadImage = 'Unggah Gambar';
}

class AppColors {
  // Primary Colors
  static const int primaryGreen = 0xFF10B981;
  static const int primaryGreenDark = 0xFF059669;
  static const int primaryBlack = 0xFF121212;

  // Secondary Colors
  static const int accentOrange = 0xFFF59E0B;
  static const int accentBlue = 0xFF3B82F6;
  static const int accentYellow = 0xFFFCD34D;
  static const int accentNeon = 0xFF06B6D4;

  // Neutral Colors
  static const int neutralWhite = 0xFFFFFFFF;
  static const int neutralGray = 0xFFF3F4F6;
  static const int neutralLightGray = 0xFFE5E7EB;
  static const int neutralDarkGray = 0xFF6B7280;
  static const int neutralBlack = 0xFF1F2937;

  // Status Colors
  static const int successGreen = 0xFF10B981;
  static const int errorRed = 0xFFEF4444;
  static const int warningYellow = 0xFFFCD34D;
  static const int infoBlue = 0xFF3B82F6;

  // Order Status Colors
  static const int statusPending = 0xFFFFC107; // Amber/Warning
  static const int statusProcessing = 0xFF2196F3; // Blue/Info
  static const int statusShipped = 0xFF4CAF50; // Green/Success
  static const int statusDelivered = 0xFF00E676; // Light Green/Success
  static const int statusCancelled = 0xFFF44336; // Red/Error
}
