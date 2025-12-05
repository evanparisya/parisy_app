# 🚀 QUICK START - Testing Login Sekarang Juga!

## 1️⃣ Login Credentials (Sudah Pre-Filled)
```
Email:    admin@gmail.com
Password: password
```

## 2️⃣ Tap "Masuk"
- Loading... (2 detik simulated)
- ✅ Login berhasil!

## 3️⃣ Jelajahi Aplikasi
- Marketplace: Lihat produk dummy
- Cart: Tambah produk
- Orders: Lihat order history
- Accounts yang bisa di-test:
  - `user@example.com` / `password123`
  - `seller@example.com` / `seller123`

---

## Bagaimana ini bisa bekerja tanpa backend?

**Mock Authentication Mode** diaktifkan secara default:
- File: `lib/features/auth/services/auth_service.dart`
- Setting: `static const bool useMockAuth = true;`

Ini memungkinkan:
- ✅ Testing tanpa backend setup
- ✅ Development lebih cepat
- ✅ Easy switch ke API real nanti

---

## Kapan di-switch ke Real Backend?

Ketika Flask backend sudah siap (lihat `BACKEND_SETUP.md`):

```dart
// auth_service.dart - Ubah ini:
static const bool useMockAuth = false;  // ← Change to false
```

Selesai! Login akan langsung connect ke API real.

---

## Support Multiple Accounts

Semua akun ini bisa login dengan mock mode:

| Email | Password | Status |
|-------|----------|--------|
| admin@gmail.com | password | Pre-filled ✨ |
| user@example.com | password123 | Testing |
| seller@example.com | seller123 | Testing |

Atau modifikasi di `_mockLogin()` method untuk tambah akun baru.

---

## File Dokumentasi Lengkap

- 📄 `SOLUTION_SUMMARY.md` - Ringkasan solusi
- 📄 `DUMMY_DATA.md` - Data dummy explanation
- 📄 `BACKEND_SETUP.md` - Backend setup guide
- 📄 `README.md` - Project overview (kalau ada)

---

## Troubleshooting Cepat

| Problem | Solusi |
|---------|--------|
| Login masih error | Tunggu 2 detik, atau hard-refresh app |
| Ingin pakai API real | Setup backend, ubah useMockAuth = false |
| Mau tambahanakun | Edit DummyData class atau _mockLogin() method |
| Nggak bisa kelanjut ke marketplace | Pastikan login berhasil dulu (check snackbar) |

---

**Siap testing?** 🎉 Buka app dan tap "Masuk"!
