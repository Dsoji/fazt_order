import 'dart:convert';

class Category {
  String? categoryName;
  String? id;

  Category({this.categoryName, this.id});

  @override
  String toString() => 'Category(categoryName: $categoryName, id: $id)';

  factory Category.fromMap(Map<String, dynamic> data) => Category(
        categoryName: data['categoryName'] as String?,
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'categoryName': categoryName,
        'id': id,
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
    String? id,
  }) {
    return Category(
      categoryName: categoryName ?? this.categoryName,
      id: id ?? this.id,
    );
  }
}
