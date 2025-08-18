import 'dart:convert';

class Category {
  String? id;
  String? categoryName;
  String? store;
  int? v;

  Category({this.id, this.categoryName, this.store, this.v});

  @override
  String toString() {
    return 'Category(id: $id, categoryName: $categoryName, store: $store, v: $v)';
  }

  factory Category.fromMap(Map<String, dynamic> data) => Category(
        id: data['_id'] as String?,
        categoryName: data['categoryName'] as String?,
        store: data['store'] as String?,
        v: data['__v'] as int?,
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'categoryName': categoryName,
        'store': store,
        '__v': v,
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
    String? store,
    int? v,
  }) {
    return Category(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      store: store ?? this.store,
      v: v ?? this.v,
    );
  }
}
