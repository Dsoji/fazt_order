import 'dart:convert';

class Category {
  String? id;
  String? categoryName;

  Category({this.id, this.categoryName});

  @override
  String toString() => 'Category(id: $id, categoryName: $categoryName)';

  factory Category.fromMap(Map<String, dynamic> data) => Category(
        id: data['id'] as String?,
        categoryName: data['categoryName'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
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
    String? id,
    String? categoryName,
  }) {
    return Category(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}
