import 'dart:convert';

import 'store.dart';

class Shop {
  String? shopName;
  Store? store;
  String? id;

  Shop({this.shopName, this.store, this.id});

  @override
  String toString() => 'Shop(shopName: $shopName, store: $store, id: $id)';

  factory Shop.fromMap(Map<String, dynamic> data) => Shop(
        shopName: data['shopName'] as String?,
        store: data['store'] == null
            ? null
            : Store.fromMap(data['store'] as Map<String, dynamic>),
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'shopName': shopName,
        'store': store?.toMap(),
        'id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Shop].
  factory Shop.fromJson(String data) {
    return Shop.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Shop] to a JSON string.
  String toJson() => json.encode(toMap());

  Shop copyWith({
    String? shopName,
    Store? store,
    String? id,
  }) {
    return Shop(
      shopName: shopName ?? this.shopName,
      store: store ?? this.store,
      id: id ?? this.id,
    );
  }
}
