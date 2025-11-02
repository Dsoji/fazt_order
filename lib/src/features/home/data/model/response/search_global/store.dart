import 'dart:convert';

class Store {
  String? storeDisplayImage;
  String? storeName;
  String? id;

  Store({this.storeDisplayImage, this.storeName, this.id});

  @override
  String toString() {
    return 'Store(storeDisplayImage: $storeDisplayImage, storeName: $storeName, id: $id)';
  }

  factory Store.fromMap(Map<String, dynamic> data) => Store(
        storeDisplayImage: data['storeDisplayImage'] as String?,
        storeName: data['storeName'] as String?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'storeDisplayImage': storeDisplayImage,
        'storeName': storeName,
        '_id': id,
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
    String? storeDisplayImage,
    String? storeName,
    String? id,
  }) {
    return Store(
      storeDisplayImage: storeDisplayImage ?? this.storeDisplayImage,
      storeName: storeName ?? this.storeName,
      id: id ?? this.id,
    );
  }
}
