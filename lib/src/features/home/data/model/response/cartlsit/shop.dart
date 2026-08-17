import 'dart:convert';

import 'location.dart';
import 'store.dart';

class Shop {
  String? shopName;
  Store? store;
  String? id;
  Location? location;

  /// The vendor's "Accepting orders" switch. Carried on the cart so checkout
  /// can stop an order for a restaurant that went unavailable after the items
  /// were added.
  bool? isOpen;

  Shop({this.shopName, this.store, this.id, this.location, this.isOpen});

  @override
  String toString() =>
      'Shop(shopName: $shopName, store: $store, id: $id, location: $location, isOpen: $isOpen)';

  factory Shop.fromMap(Map<String, dynamic> data) => Shop(
        shopName: data['shopName'] as String?,
        store: data['store'] == null
            ? null
            : Store.fromMap(data['store'] as Map<String, dynamic>),
        id: data['id'] as String?,
        location: data['location'] == null
            ? null
            : Location.fromMap(data['location'] as Map<String, dynamic>),
        isOpen: data['isOpen'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'shopName': shopName,
        'store': store?.toMap(),
        'id': id,
        'location': location?.toMap(),
        'isOpen': isOpen,
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
    Location? location,
    bool? isOpen,
  }) {
    return Shop(
      shopName: shopName ?? this.shopName,
      store: store ?? this.store,
      id: id ?? this.id,
      location: location ?? this.location,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}
