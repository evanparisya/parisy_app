# Parisy App - Marketplace Produk Pertanian

Aplikasi Flutter untuk marketplace produk pertanian dengan fitur pencarian menggunakan kamera, keranjang belanja, dan tracking pesanan real-time.

## 🎯 Fitur Utama

### 1. **Authentication (Login & Register)**
- Login dengan email dan password
  #### admin 
  - usn : admin@gmail.com
  - pw  : password
  #### user
  - usn : user@gmail.com
  - pw  : password
  
- Register akun baru
- Token-based authentication
- Session management

### 2. **Marketplace**
- Daftar produk dengan pagination
- Pencarian produk
- Filter berdasarkan kategori
- Deteksi produk melalui kamera (AI/ML integration)
- Rating dan review produk

### 3. **Keranjang Belanja**
- Tambah/hapus produk
- Update quantity
- Hitung total harga
- Checkout dengan informasi pengiriman

### 4. **Tracking Pesanan**
- Lihat riwayat pesanan
- Real-time status update (Stream/WebSocket)
- Detail pesanan lengkap
- Pembatalan pesanan

## 📁 Struktur Folder

```
lib/
├── core/                       # Folder global
│   ├── api/
│   │   └── api_client.dart     # Konfigurasi Dio HTTP client
│   ├── constants/
│   │   └── app_constants.dart  # Color, URL API, Strings
│   └── widgets/
│       └── common_widgets.dart # Reusable widgets
│
├── features/
│   ├── auth/                   # Login & Register
│   │   ├── models/
│   │   │   └── user_model.dart
│   │   ├── services/
│   │   │   └── auth_service.dart
│   │   ├── controllers/
│   │   │   └── auth_controller.dart
│   │   └── screens/
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   │
│   ├── marketplace/            # Produk & Search
│   │   ├── models/
│   │   │   └── product_model.dart
│   │   ├── services/
│   │   │   └── marketplace_service.dart
│   │   ├── controllers/
│   │   │   └── marketplace_controller.dart
│   │   ├── screens/
│   │   │   └── marketplace_screen.dart
│   │   └── widgets/
│   │       └── product_card.dart
│   │
│   ├── cart/                   # Keranjang
│   │   ├── models/
│   │   │   └── cart_item_model.dart
│   │   ├── services/
│   │   │   └── cart_service.dart
│   │   ├── controllers/
│   │   │   └── cart_controller.dart
│   │   └── screens/
│   │       └── cart_screen.dart
│   │
│   └── orders/                 # Pesanan
│       ├── models/
│       │   └── order_model.dart
│       ├── services/
│       │   └── order_service.dart
│       ├── controllers/
│       │   └── order_controller.dart
│       └── screens/
│           └── order_history_screen.dart
│
├── injection_container.dart    # Dependency Injection
└── main.dart                   # Entry point
```

## 🚀 Cara Menggunakan

### 1. Setup Environment

```bash
# Clone repository
git clone <repository-url>
cd parisy_app

# Install dependencies
flutter pub get

# Setup Firebase (optional)
flutterfire configure
```

### 2. Konfigurasi API

Edit `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'http://your-flask-api.com/api';
```

### 3. Run Application

```bash
# Development
flutter run

# Release
flutter run --release

# Web
flutter run -d chrome

# Mobile
flutter run -d emulator-5554  # Android
flutter run -d device-name    # iOS
```

## 🔧 Architecture

### State Management: Provider

```dart
// Menggunakan Provider untuk state management
Consumer<AuthController>(
  builder: (context, authController, child) {
    // UI code
  },
)
```

### API Integration: Dio

```dart
// HTTP Client configuration
final dio = Dio(BaseOptions(
  baseUrl: AppConstants.baseUrl,
  connectTimeout: Duration(milliseconds: 30000),
  receiveTimeout: Duration(milliseconds: 30000),
));
```

### Dependency Injection

```dart
// Di main.dart
MultiProvider(
  providers: InjectionContainer.provideProviders(),
  child: MyApp(),
)
```

## 📚 API Endpoints

### Authentication
- `POST /auth/login` - Login
- `POST /auth/register` - Register
- `POST /auth/logout` - Logout
- `GET /auth/verify` - Verify token

### Marketplace
- `GET /marketplace/products` - Daftar produk
- `GET /marketplace/products/{id}` - Detail produk
- `GET /marketplace/search` - Search produk
- `POST /marketplace/detect` - Deteksi produk dari gambar
- `GET /marketplace/categories` - Daftar kategori

### Cart
- `POST /cart/checkout` - Checkout
- `GET /cart/items` - Daftar item cart

### Orders
- `GET /orders` - Riwayat pesanan
- `GET /orders/{id}` - Detail pesanan
- `POST /orders/{id}/cancel` - Batalkan pesanan
- `WS /orders/{id}/status` - Stream status (WebSocket)

## 🎨 Design System

### Colors
- **Primary Green**: `0xFF10B981`
- **Primary Green Dark**: `0xFF059669`
- **Accent Orange**: `0xFFF59E0B`
- **Accent Blue**: `0xFF3B82F6`
- **Error Red**: `0xFFEF4444`
- **Success Green**: `0xFF10B981`

### Typography
- **Font Family**: Poppins
- **Heading**: 32px, Bold
- **Title**: 18px, Bold
- **Body**: 14px, Regular

## 📦 Dependencies

```yaml
# State Management
provider: ^6.1.0

# HTTP Client
dio: ^5.4.0

# Local Storage
shared_preferences: ^2.2.2

# Image & Camera
image_picker: ^1.0.4
camera: ^0.10.5+5

# JSON
json_serializable: ^6.7.1
json_annotation: ^4.8.1

# Date
intl: ^0.19.0
```

## 🔐 Security

- Token-based authentication
- Secure token storage di local device
- HTTPS only API calls
- Input validation & sanitization
- Error handling & logging

## 🧪 Testing (Optional)

```bash
# Run unit tests
flutter test

# Run widget tests
flutter test test/widget_test.dart

# Run integration tests
flutter test integration_test/
```

## 🐛 Troubleshooting

### Build Error
```bash
flutter clean
flutter pub get
flutter run
```

### Dependency Conflict
```bash
flutter pub upgrade
flutter pub get
```

### API Connection Error
- Pastikan baseUrl di `app_constants.dart` sesuai
- Cek koneksi internet
- Verify API endpoint di Postman/Insomnia

## 📝 Future Enhancements

- [ ] Payment Gateway Integration (Midtrans, Stripe)
- [ ] Push Notifications
- [ ] Product Reviews & Ratings
- [ ] Wishlist/Favorites
- [ ] Advanced Analytics
- [ ] Multiple Language Support
- [ ] Dark Mode
- [ ] Offline Support

## 📄 License

MIT License - Feel free to use this project for educational purposes

## 👨‍💻 Author

Parisy Team - Universitas 

## 💬 Support

Untuk masalah atau saran, silahkan buka GitHub Issue

---

**Happy Coding! 🚀**

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
