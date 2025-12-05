class AdminTransactionModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final double amount;
  final String type; // purchase, refund, wallet_topup
  final String status; // pending, completed, cancelled
  final String? description;
  final DateTime createdAt;
  final DateTime? completedAt;

  AdminTransactionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    required this.createdAt,
    this.completedAt,
  });

  factory AdminTransactionModel.fromJson(Map<String, dynamic> json) {
    return AdminTransactionModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userEmail: json['userEmail'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      status: json['status'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'amount': amount,
      'type': type,
      'status': status,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
