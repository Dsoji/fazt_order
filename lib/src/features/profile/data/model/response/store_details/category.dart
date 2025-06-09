import 'dart:convert';

class Category {
  String? category;
  String? id;

  Category({this.category, this.id});

  @override
  String toString() => 'Category(category: $category, id: $id)';

  factory Category.fromMap(Map<String, dynamic> data) => Category(
        category: data['category'] as String?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'category': category,
        '_id': id,
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
    String? category,
    String? id,
  }) {
    return Category(
      category: category ?? this.category,
      id: id ?? this.id,
    );
  }
}
