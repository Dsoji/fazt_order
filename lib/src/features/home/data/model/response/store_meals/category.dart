import 'dart:convert';

class Category {
  String? id;

  Category({this.id});

  @override
  String toString() => 'Category(id: $id)';

  factory Category.fromMap(Map<String, dynamic> data) => Category(
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
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
    String? id,
  }) {
    return Category(
      id: id ?? this.id,
    );
  }
}
