import 'dart:convert';

import 'location.dart';
import 'store.dart';

class Shop {
  Location? location;
  String? shopName;
  Store? store;
  int? rating;
  int? deliveryFee;
  String? id;

  Shop({
    this.location,
    this.shopName,
    this.store,
    this.rating,
    this.deliveryFee,
    this.id,
  });

  @override
  String toString() {
    return 'Shop(location: $location, shopName: $shopName, store: $store, rating: $rating, deliveryFee: $deliveryFee, id: $id)';
  }

  factory Shop.fromMap(Map<String, dynamic> data) => Shop(
        location: data['location'] == null
            ? null
            : Location.fromMap(data['location'] as Map<String, dynamic>),
        shopName: data['shopName'] as String?,
        store: data['store'] == null
            ? null
            : Store.fromMap(data['store'] as Map<String, dynamic>),
        rating: data['rating'] as int?,
        deliveryFee: data['deliveryFee'] as int?,
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'location': location?.toMap(),
        'shopName': shopName,
        'store': store?.toMap(),
        'rating': rating,
        'deliveryFee': deliveryFee,
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
    Location? location,
    String? shopName,
    Store? store,
    int? rating,
    int? deliveryFee,
    String? id,
  }) {
    return Shop(
      location: location ?? this.location,
      shopName: shopName ?? this.shopName,
      store: store ?? this.store,
      rating: rating ?? this.rating,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      id: id ?? this.id,
    );
  }
}
