import 'category_model.dart';

class Transaction {
  final int id;
  final int userId;
  final int categoryId;
  final double amount;
  final String type; // income or expense
  final String? description;
  final DateTime date;
  final Category? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      amount: double.parse(json['amount'].toString()),
      type: json['type'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
