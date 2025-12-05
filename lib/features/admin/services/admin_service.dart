import '../models/admin_user_model.dart';
import '../models/admin_product_model.dart';
import '../models/admin_transaction_model.dart';

class AdminService {
  // Mock data for admin
  static const bool useMockAdmin = true;

  // Mock residents/users data
  static final List<AdminUserModel> _mockUsers = [
    AdminUserModel(
      id: 'USER-001',
      name: 'User Satu',
      email: 'user@gmail.com',
      phone: '081234567890',
      address: 'Jakarta, Indonesia',
      createdAt: DateTime(2024, 1, 15),
      role: 'resident',
    ),
    AdminUserModel(
      id: 'USER-002',
      name: 'Budi Santoso',
      email: 'budi@gmail.com',
      phone: '082345678901',
      address: 'Bandung, Indonesia',
      createdAt: DateTime(2024, 2, 10),
      role: 'seller',
    ),
    AdminUserModel(
      id: 'USER-003',
      name: 'Siti Nurhaliza',
      email: 'siti@gmail.com',
      phone: '083456789012',
      address: 'Surabaya, Indonesia',
      createdAt: DateTime(2024, 1, 20),
      role: 'resident',
    ),
  ];

  // Mock products data
  static final List<AdminProductModel> _mockProducts = [
    AdminProductModel(
      id: 'PROD-001',
      name: 'Smartphone Samsung',
      description: 'Samsung Galaxy A53, RAM 8GB',
      price: 4500000,
      stock: 10,
      category: 'Elektronik',
      imageUrl: 'https://via.placeholder.com/150',
      sellerEmail: 'budi@gmail.com',
      createdAt: DateTime(2024, 3, 1),
    ),
    AdminProductModel(
      id: 'PROD-002',
      name: 'Laptop Asus',
      description: 'Asus Vivobook 14, Intel i5, 512GB SSD',
      price: 8500000,
      stock: 5,
      category: 'Elektronik',
      imageUrl: 'https://via.placeholder.com/150',
      sellerEmail: 'budi@gmail.com',
      createdAt: DateTime(2024, 3, 5),
    ),
    AdminProductModel(
      id: 'PROD-003',
      name: 'Sepatu Olahraga',
      description: 'Nike Air Max, Size 42',
      price: 1200000,
      stock: 20,
      category: 'Fashion',
      imageUrl: 'https://via.placeholder.com/150',
      sellerEmail: 'siti@gmail.com',
      createdAt: DateTime(2024, 3, 10),
    ),
  ];

  // Mock transactions data
  static final List<AdminTransactionModel> _mockTransactions = [
    AdminTransactionModel(
      id: 'TRX-001',
      userId: 'USER-001',
      userName: 'User Satu',
      userEmail: 'user@gmail.com',
      amount: 4500000,
      type: 'purchase',
      status: 'completed',
      description: 'Pembelian Smartphone Samsung',
      createdAt: DateTime(2024, 3, 15),
      completedAt: DateTime(2024, 3, 15),
    ),
    AdminTransactionModel(
      id: 'TRX-002',
      userId: 'USER-003',
      userName: 'Siti Nurhaliza',
      userEmail: 'siti@gmail.com',
      amount: 1200000,
      type: 'purchase',
      status: 'completed',
      description: 'Pembelian Sepatu Olahraga',
      createdAt: DateTime(2024, 3, 18),
      completedAt: DateTime(2024, 3, 18),
    ),
    AdminTransactionModel(
      id: 'TRX-003',
      userId: 'USER-001',
      userName: 'User Satu',
      userEmail: 'user@gmail.com',
      amount: 100000,
      type: 'wallet_topup',
      status: 'completed',
      description: 'Top up saldo dompet',
      createdAt: DateTime(2024, 3, 20),
      completedAt: DateTime(2024, 3, 20),
    ),
  ];

  // Get all users/residents
  Future<List<AdminUserModel>> getAllUsers() async {
    if (useMockAdmin) {
      await Future.delayed(Duration(seconds: 1));
      return List.from(_mockUsers);
    }
    // Real API call would go here
    throw Exception('API not implemented');
  }

  // Search users by name or email
  Future<List<AdminUserModel>> searchUsers(String query) async {
    if (useMockAdmin) {
      await Future.delayed(Duration(milliseconds: 500));
      return _mockUsers
          .where(
            (user) =>
                user.name.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    throw Exception('API not implemented');
  }

  // Add user
  Future<AdminUserModel> addUser(AdminUserModel user) async {
    if (useMockAdmin) {
      await Future.delayed(Duration(seconds: 1));
      _mockUsers.add(user);
      return user;
    }
    throw Exception('API not implemented');
  }

  // Update user
  Future<AdminUserModel> updateUser(AdminUserModel user) async {
    if (useMockAdmin) {
      await Future.delayed(Duration(seconds: 1));
      final index = _mockUsers.indexWhere((u) => u.id == user.id);
      if (index >= 0) {
        _mockUsers[index] = user;
        return user;
      }
      throw Exception('User not found');
    }
    throw Exception('API not implemented');
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    if (useMockAdmin) {
      await Future.delayed(Duration(seconds: 1));
      _mockUsers.removeWhere((u) => u.id == userId);
    } else {
      throw Exception('API not implemented');
    }
  }

  // Get all products
  Future<List<AdminProductModel>> getAllProducts() async {
    if (useMockAdmin) {
      await Future.delayed(Duration(seconds: 1));
      return List.from(_mockProducts);
    }
    throw Exception('API not implemented');
  }

  // Search products
  Future<List<AdminProductModel>> searchProducts(String query) async {
    if (useMockAdmin) {
      await Future.delayed(Duration(milliseconds: 500));
      return _mockProducts
          .where(
            (product) =>
                product.name.toLowerCase().contains(query.toLowerCase()) ||
                product.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    throw Exception('API not implemented');
  }

  // Add product
  Future<AdminProductModel> addProduct(AdminProductModel product) async {
    if (useMockAdmin) {
      await Future.delayed(Duration(seconds: 1));
      _mockProducts.add(product);
      return product;
    }
    throw Exception('API not implemented');
  }

  // Update product
  Future<AdminProductModel> updateProduct(AdminProductModel product) async {
    if (useMockAdmin) {
      await Future.delayed(Duration(seconds: 1));
      final index = _mockProducts.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _mockProducts[index] = product;
        return product;
      }
      throw Exception('Product not found');
    }
    throw Exception('API not implemented');
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    if (useMockAdmin) {
      await Future.delayed(Duration(seconds: 1));
      _mockProducts.removeWhere((p) => p.id == productId);
    } else {
      throw Exception('API not implemented');
    }
  }

  // Get all transactions
  Future<List<AdminTransactionModel>> getAllTransactions() async {
    if (useMockAdmin) {
      await Future.delayed(Duration(seconds: 1));
      return List.from(_mockTransactions);
    }
    throw Exception('API not implemented');
  }

  // Get transactions for specific user
  Future<List<AdminTransactionModel>> getUserTransactions(String userId) async {
    if (useMockAdmin) {
      await Future.delayed(Duration(milliseconds: 500));
      return _mockTransactions.where((t) => t.userId == userId).toList();
    }
    throw Exception('API not implemented');
  }

  // Get transactions by type
  Future<List<AdminTransactionModel>> getTransactionsByType(String type) async {
    if (useMockAdmin) {
      await Future.delayed(Duration(milliseconds: 500));
      return _mockTransactions.where((t) => t.type == type).toList();
    }
    throw Exception('API not implemented');
  }

  // Get total transaction amount
  Future<double> getTotalTransactionAmount() async {
    if (useMockAdmin) {
      await Future.delayed(Duration(milliseconds: 300));
      double total = 0.0;
      for (var t in _mockTransactions) {
        total += t.amount;
      }
      return total;
    }
    throw Exception('API not implemented');
  }
}
