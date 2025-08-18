import 'dart:convert';

class Store {
  String? id;
  String? storeName;
  String? storeDisplayImage;

  Store({this.id, this.storeName, this.storeDisplayImage});

  @override
  String toString() =>
      'Store(id: $id, storeName: $storeName, storeDisplayImage: $storeDisplayImage)';

  factory Store.fromMap(Map<String, dynamic> data) => Store(
        id: data['id'] as String?,
        storeName: data['storeName'] as String?,
        storeDisplayImage: data['storeDisplayImage'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'storeName': storeName,
        'storeDisplayImage': storeDisplayImage,
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
    String? storeName,
    String? storeDisplayImage,
  }) {
    return Store(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      storeDisplayImage: storeDisplayImage ?? this.storeDisplayImage,
    );
  }
}
