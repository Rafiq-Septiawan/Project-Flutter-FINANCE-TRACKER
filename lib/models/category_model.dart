class Category {
  final int id;
  final int userId;
  final String name;
  final String type; // income or expense
  final String? icon;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      type: json['type'],
      icon: json['icon'],
      color: json['color'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
