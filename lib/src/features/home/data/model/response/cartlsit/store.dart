import 'dart:convert';

class Store {
  String? id;
  String? storeDisplayImage;
  String? storeName;

  Store({this.id, this.storeDisplayImage, this.storeName});

  @override
  String toString() =>
      'Store(id: $id, storeDisplayImage: $storeDisplayImage, storeName: $storeName)';

  factory Store.fromMap(Map<String, dynamic> data) => Store(
        id: data['id'] as String?,
        storeDisplayImage: data['storeDisplayImage'] as String?,
        storeName: data['storeName'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'storeDisplayImage': storeDisplayImage,
        'storeName': storeName,
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
    String? storeDisplayImage,
    String? storeName,
  }) {
    return Store(
      id: id ?? this.id,
      storeDisplayImage: storeDisplayImage ?? this.storeDisplayImage,
      storeName: storeName ?? this.storeName,
    );
  }
}
