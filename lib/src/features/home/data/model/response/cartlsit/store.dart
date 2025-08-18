import 'dart:convert';

class Store {
  String? id;

  Store({this.id});

  @override
  String toString() => 'Store(id: $id)';

  factory Store.fromMap(Map<String, dynamic> data) => Store(
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Store].
  factory Store.fromJson(String data) {
    return Store.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Store] to a JSON string.
  String toJson() => json.encode(toMap());

  Store copyWith({
    String? id,
  }) {
    return Store(
      id: id ?? this.id,
    );
  }
}
