import 'dart:convert';

class DiscountMealCategory {
  String? id;
  String? categoryName;

  DiscountMealCategory({this.id, this.categoryName});

  @override
  String toString() {
    return 'DiscountMealCategory(id: $id, categoryName: $categoryName)';
  }

  factory DiscountMealCategory.fromMap(Map<String, dynamic> data) =>
      DiscountMealCategory(
        id: (data['id'] ?? data['_id']) as String?,
        categoryName: data['categoryName'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'categoryName': categoryName,
      };

  factory DiscountMealCategory.fromJson(String data) {
    return DiscountMealCategory.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  DiscountMealCategory copyWith({
    String? id,
    String? categoryName,
  }) {
    return DiscountMealCategory(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
