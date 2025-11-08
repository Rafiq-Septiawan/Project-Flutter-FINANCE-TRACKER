import 'category_model.dart';

class Budget {
  final int id;
  final int userId;
  final int categoryId;
  final double amount;
  final int month;
  final int year;
  final Category? category;
  final double? spent;
  final double? remaining;
  final double? percentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
    this.category,
    this.spent,
    this.remaining,
    this.percentage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      amount: double.parse(json['amount'].toString()),
      month: json['month'],
      year: json['year'],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      spent:
          json['spent'] != null ? double.parse(json['spent'].toString()) : null,
      remaining: json['remaining'] != null
          ? double.parse(json['remaining'].toString())
          : null,
      percentage: json['percentage'] != null
          ? double.parse(json['percentage'].toString())
          : null,
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
      'month': month,
      'year': year,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
