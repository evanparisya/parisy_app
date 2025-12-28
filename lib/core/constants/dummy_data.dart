// lib/core/constants/dummy_data.dart
import 'package:parisy_app/core/constants/app_constants.dart';
import 'package:parisy_app/features/auth/models/user_model.dart';
import 'package:parisy_app/features/user/marketplace/models/product_model.dart';

class DummyData {
  // Mapping Role dari DBML: Role + Sub_Role
  static const String roleAdmin = AppStrings.roleAdmin;
  static const String roleUser = AppStrings.roleUser;

  static const String subAdmin = AppStrings.subRoleAdmin;
  static const String subRT = AppStrings.subRoleRT;
  static const String subRW = AppStrings.subRoleRW;
  static const String subBendahara = AppStrings.subRoleBendahara;
  static const String subSekretaris = AppStrings.subRoleSekretaris;
  static const String subWarga = AppStrings.subRoleWarga;

  // --- Mock User Data (Sesuai skema DBML users) ---
  static final Map<String, UserModel> mockUsers = {
    'admin@gmail.com': UserModel(
      id: 1, name: 'Admin Utama', email: 'admin@gmail.com', role: roleAdmin, subRole: subAdmin,
      address: 'Kantor Pusat Admin', phone: '0800111222', createdAt: DateTime.now(),
    ),
    'rt@gmail.com': UserModel(
      id: 2, name: 'Ketua RT 01', email: 'rt@gmail.com', role: roleUser, subRole: subRT,
      address: 'Jalan Kenanga No 1', phone: '081230001', createdAt: DateTime.now(),
    ),
    'rw@gmail.com': UserModel(
      id: 3, name: 'Ketua RW 05', email: 'rw@gmail.com', role: roleUser, subRole: subRW,
      address: 'Jalan Mawar Raya 5', phone: '081230002', createdAt: DateTime.now(),
    ),
    'bendahara@gmail.com': UserModel(
      id: 4, name: 'Bendahara Umum', email: 'bendahara@gmail.com', role: roleUser, subRole: subBendahara,
      address: 'Kantor Bendahara', phone: '081230003', createdAt: DateTime.now(),
    ),
    'sekretaris@gmail.com': UserModel(
      id: 5, name: 'Sekretaris Rapat', email: 'sekretaris@gmail.com', role: roleUser, subRole: subSekretaris,
      address: 'Kantor Sekretaris', phone: '081230004', createdAt: DateTime.now(),
    ),
    'warga@gmail.com': UserModel(
      id: 6, name: 'Warga Biasa', email: 'warga@gmail.com', role: roleUser, subRole: subWarga,
      address: 'Jalan Buntu No 7', phone: '081230005', createdAt: DateTime.now(),
    ),
  };

  // --- Mock Vegetable Data (Sesuai skema DBML vegetables) ---
  // FIX: Parameter 'status' ditambahkan (default: 'available')
  static final List<ProductModel> mockProducts = [
    ProductModel(
      id: 101, name: 'Bayam Merah Organik', description: 'Bayam segar untuk dimasak',
      price: 15000, stock: 50, imageUrl: 'https://via.placeholder.com/300?text=Bayam',
      category: 'daun', createdBy: 1, status: 'available', // <-- FIX
    ),
    ProductModel(
      id: 102, name: 'Wortel Jumbo', description: 'Wortel impor berkualitas',
      price: 22000, stock: 15, imageUrl: 'https://via.placeholder.com/300?text=Wortel',
      category: 'akar', createdBy: 2, status: 'available', // <-- FIX
    ),
    ProductModel(
      id: 103, name: 'Tomat Cherry Manis', description: 'Cocok untuk salad',
      price: 18000, stock: 100, imageUrl: 'https://via.placeholder.com/300?text=Tomat',
      category: 'buah', createdBy: 6, status: 'available', // <-- FIX
    ),
  ];
}