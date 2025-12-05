// Dummy data constants untuk testing
// File ini dapat dihapus saat production

class DummyData {
  // Dummy User Accounts
  static const String dummyUserEmail = 'user@example.com';
  static const String dummyUserPassword = 'password123';
  static const String dummyUserId = 'USER-001';
  static const String dummyUserName = 'John Doe';

  static const String dummySellerEmail = 'seller@example.com';
  static const String dummySellerPassword = 'seller123';
  static const String dummySellerId = 'SELLER-001';
  static const String dummySellerName = 'Toko Elektronik ABC';

  static const String dummyAdminEmail = 'admin@example.com';
  static const String dummyAdminPassword = 'admin123';
  static const String dummyAdminId = 'ADMIN-001';

  // Dummy Products
  static final List<Map<String, dynamic>> dummyProducts = [
    {
      'id': 'PROD-001',
      'name': 'Laptop Gaming ASUS ROG',
      'price': 15000000.0,
      'imageUrl': 'https://via.placeholder.com/300x300?text=Laptop+Gaming',
      'description': 'Laptop gaming dengan processor Intel i7 dan RTX 3060',
      'stock': 5,
      'rating': 4.8,
      'reviews': 128,
    },
    {
      'id': 'PROD-002',
      'name': 'Smartphone Flagship',
      'price': 8999000.0,
      'imageUrl': 'https://via.placeholder.com/300x300?text=Smartphone',
      'description': 'Smartphone dengan camera 108MP dan 5G support',
      'stock': 12,
      'rating': 4.7,
      'reviews': 256,
    },
    {
      'id': 'PROD-003',
      'name': 'Earbuds Wireless Premium',
      'price': 1200000.0,
      'imageUrl': 'https://via.placeholder.com/300x300?text=Earbuds',
      'description': 'Earbuds dengan noise cancellation aktif',
      'stock': 50,
      'rating': 4.5,
      'reviews': 412,
    },
    {
      'id': 'PROD-004',
      'name': 'Kemeja Premium Cotton',
      'price': 250000.0,
      'imageUrl': 'https://via.placeholder.com/300x300?text=Kemeja',
      'description': 'Kemeja premium dari bahan cotton berkualitas tinggi',
      'stock': 30,
      'rating': 4.6,
      'reviews': 89,
    },
    {
      'id': 'PROD-005',
      'name': 'Kopi Specialty Arabica',
      'price': 85000.0,
      'imageUrl': 'https://via.placeholder.com/300x300?text=Kopi',
      'description': 'Kopi specialty arabica dengan cita rasa yang kaya',
      'stock': 100,
      'rating': 4.9,
      'reviews': 342,
    },
  ];

  // Dummy Orders
  static final List<Map<String, dynamic>> dummyOrders = [
    {
      'orderId': 'ORD-2025-001',
      'customerId': 'USER-001',
      'totalPrice': 15000000.0,
      'status': 'delivered',
      'items': [
        {
          'productId': 'PROD-001',
          'productName': 'Laptop Gaming ASUS ROG',
          'quantity': 1,
          'price': 15000000.0,
        },
      ],
      'address': 'Jl. Merdeka No. 123, Jakarta Pusat',
      'phone': '081234567890',
      'createdAt': '2025-01-15T10:30:00Z',
      'shippedAt': '2025-01-16T14:20:00Z',
      'deliveredAt': '2025-01-20T16:45:00Z',
    },
    {
      'orderId': 'ORD-2025-002',
      'customerId': 'USER-001',
      'totalPrice': 9247000.0,
      'status': 'processing',
      'items': [
        {
          'productId': 'PROD-002',
          'productName': 'Smartphone Flagship',
          'quantity': 1,
          'price': 8999000.0,
        },
        {
          'productId': 'PROD-003',
          'productName': 'Earbuds Wireless Premium',
          'quantity': 1,
          'price': 1200000.0,
        },
      ],
      'address': 'Jl. Gatot Subroto No. 456, Jakarta Selatan',
      'phone': '081234567891',
      'createdAt': '2025-01-22T09:15:00Z',
      'shippedAt': null,
      'deliveredAt': null,
    },
    {
      'orderId': 'ORD-2025-003',
      'customerId': 'USER-001',
      'totalPrice': 335000.0,
      'status': 'shipped',
      'items': [
        {
          'productId': 'PROD-004',
          'productName': 'Kemeja Premium Cotton',
          'quantity': 1,
          'price': 250000.0,
        },
        {
          'productId': 'PROD-005',
          'productName': 'Kopi Specialty Arabica',
          'quantity': 1,
          'price': 85000.0,
        },
      ],
      'address': 'Jl. Sudirman No. 789, Jakarta Pusat',
      'phone': '081234567892',
      'createdAt': '2025-01-23T11:20:00Z',
      'shippedAt': '2025-01-24T08:00:00Z',
      'deliveredAt': null,
    },
  ];

  // Dummy Cart Items
  static final List<Map<String, dynamic>> dummyCartItems = [
    {
      'id': 'CART-001',
      'productId': 'PROD-001',
      'name': 'Laptop Gaming ASUS ROG',
      'price': 15000000.0,
      'quantity': 1,
      'imageUrl': 'https://via.placeholder.com/300x300?text=Laptop+Gaming',
    },
  ];
}
