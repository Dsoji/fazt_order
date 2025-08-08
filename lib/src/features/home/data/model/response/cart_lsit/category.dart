import 'dart:convert';

class Category {
  String? categoryName;

  Category({this.categoryName});

  @override
  String toString() => 'Category(categoryName: $categoryName)';

  factory Category.fromMap(Map<String, dynamic> data) => Category(
        categoryName: data['categoryName'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'categoryName': categoryName,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Category].
  factory Category.fromJson(String data) {
    return Category.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Category] to a JSON string.
  String toJson() => json.encode(toMap());

  Category copyWith({
    String? categoryName,
  }) {
    return Category(
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
