import 'dart:convert';

class Result {
  String? categoryName;
  String? store;
  String? id;

  Result({this.categoryName, this.store, this.id});

  @override
  String toString() {
    return 'Result(categoryName: $categoryName, store: $store, id: $id)';
  }

  factory Result.fromMap(Map<String, dynamic> data) => Result(
        categoryName: data['categoryName'] as String?,
        store: data['store'] as String?,
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'categoryName': categoryName,
        'store': store,
        'id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Result].
  factory Result.fromJson(String data) {
    return Result.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Result] to a JSON string.
  String toJson() => json.encode(toMap());

  Result copyWith({
    String? categoryName,
    String? store,
    String? id,
  }) {
    return Result(
      categoryName: categoryName ?? this.categoryName,
      store: store ?? this.store,
      id: id ?? this.id,
    );
  }
}
