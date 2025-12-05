# Data Dummy untuk Testing Parisy App

## ⚠️ SOLUSI ERROR KONEKSI

### Masalah
```
Exception: Login error: The connection errored: The XMLHttpRequest onError callback was called.
```

### Penyebab
- Backend Flask tidak berjalan
- URL API tidak sesuai
- Mode production/web tidak support localhost

### Solusi ✅
**Mock mode sudah diaktifkan!** (`useMockAuth = true` di AuthService)
- Login akan menggunakan data dummy tanpa perlu backend
- Ketika backend siap, ubah `useMockAuth = false` untuk menggunakan API real

---

## Akun Login yang Tersedia

### Akun Utama (Pre-filled)
```
Email: admin@gmail.com
Password: password
```

### Akun Testing Lainnya
```
Email: user@example.com
Password: password123

---

## Petunjuk Testing Lengkap

### Step 1: Login dengan Mock Data
Klik tombol login dengan data yang sudah pre-filled:
- ✅ Akan berhasil dengan simulated delay 2 detik
- ✅ Tidak perlu backend running

### Step 2: Testing Marketplace & Orders
Setelah login, semua fitur bisa di-test dengan mock data:
- Lihat daftar produk dummy
- Tambah ke keranjang
- Lihat order history
- etc

### Step 3: Ketika Backend Ready
1. Setup Flask backend di `http://localhost:5000`
2. Buat endpoint `/api/auth/login`
3. Ubah kode di `auth_service.dart`:
   ```dart
   static const bool useMockAuth = false;  // Disable mock mode
   ```
4. Login akan menggunakan API real

---

## Konfigurasi API Backend

Jika sudah setup Flask backend, pastikan:

### Endpoint Login
```
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "admin@gmail.com",
  "password": "password"
}
```

### Response Expected
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "user": {
      "id": "USER-001",
      "name": "Admin User",
      "email": "admin@gmail.com",
      "phone": "081234567890",
      "address": "Jakarta"
    },
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

---

## Data Dummy Produk Marketplace

### Kategori Produk
- Elektronik
- Fashion
- Makanan & Minuman
- Peralatan Rumah Tangga
- Olahraga & Outdoor

### Produk Contoh
1. **Laptop Gaming Terbaik**
   - Harga: Rp 15.000.000
   - Stok: 5
   - Rating: 4.8/5

2. **Kemeja Premium**
   - Harga: Rp 250.000
   - Stok: 20
   - Rating: 4.5/5

3. **Kopi Specialty**
   - Harga: Rp 85.000
   - Stok: 100
   - Rating: 4.7/5

---

## Data Dummy Pesanan (Order)

### Status Pesanan
- MENUNGGU (Pending) - Baru di-order
- DIPROSES (Processing) - Sedang disiapkan
- DIKIRIM (Shipped) - Dalam perjalanan
- TERKIRIM (Delivered) - Sudah diterima
- DIBATALKAN (Cancelled) - Pesanan dibatalkan

### Contoh Pesanan
```json
{
  "orderId": "ORD-2025-001",
  "customerId": "USER-001",
  "totalPrice": 500000,
  "status": "delivered",
  "items": [
    {
      "productId": "PROD-001",
      "productName": "Laptop Gaming",
      "quantity": 1,
      "price": 15000000
    }
  ],
  "address": "Jl. Merdeka No. 123, Jakarta",
  "phone": "081234567890",
  "createdAt": "2025-01-15",
  "shippedAt": "2025-01-16",
  "deliveredAt": "2025-01-20"
}
```

---

## Petunjuk Testing

### 1. Testing Login
- Gunakan akun customer di atas untuk login
- Data dummy sudah pre-filled di login screen

### 2. Testing Marketplace
- Setelah login, akan ditampilkan produk-produk dummy
- Klik produk untuk melihat detail
- Tambahkan produk ke keranjang

### 3. Testing Cart
- Lihat keranjang di bottom navigation
- Update quantity produk
- Lakukan checkout

### 4. Testing Order History
- Lihat riwayat pesanan yang sudah dibuat
- Lihat detail pesanan dan tracking status

---

## API Testing (Jika menggunakan Flask Backend)

### Endpoint Login
```
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### Response Success
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "userId": "USER-001",
    "email": "user@example.com",
    "name": "John Doe",
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

---

**Catatan**: Data dummy ini hanya untuk keperluan testing dan development. Pastikan untuk menghapus atau menggantinya dengan data real sebelum production deployment.
