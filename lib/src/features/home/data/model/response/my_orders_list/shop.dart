import 'dart:convert';

import 'location.dart';
import 'store.dart';

class Shop {
  Location? location;
  String? shopName;
  String? manager;
  String? phone;
  Store? store;
  int? numberOfFavorites;
  int? rating;
  int? deliveryFee;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  Shop({
    this.location,
    this.shopName,
    this.manager,
    this.phone,
    this.store,
    this.numberOfFavorites,
    this.rating,
    this.deliveryFee,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  @override
  String toString() {
    return 'Shop(location: $location, shopName: $shopName, manager: $manager, phone: $phone, store: $store, numberOfFavorites: $numberOfFavorites, rating: $rating, deliveryFee: $deliveryFee, createdAt: $createdAt, updatedAt: $updatedAt, id: $id)';
  }

  factory Shop.fromMap(Map<String, dynamic> data) => Shop(
        location: data['location'] == null
            ? null
            : Location.fromMap(data['location'] as Map<String, dynamic>),
        shopName: data['shopName'] as String?,
        manager: data['manager'] as String?,
        phone: data['phone'] as String?,
        store: data['store'] == null
            ? null
            : Store.fromMap(data['store'] as Map<String, dynamic>),
        numberOfFavorites: data['numberOfFavorites'] as int?,
        rating: data['rating'] as int?,
        deliveryFee: data['deliveryFee'] as int?,
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'location': location?.toMap(),
        'shopName': shopName,
        'manager': manager,
        'phone': phone,
        'store': store?.toMap(),
        'numberOfFavorites': numberOfFavorites,
        'rating': rating,
        'deliveryFee': deliveryFee,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
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
    String? manager,
    String? phone,
    Store? store,
    int? numberOfFavorites,
    int? rating,
    int? deliveryFee,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) {
    return Shop(
      location: location ?? this.location,
      shopName: shopName ?? this.shopName,
      manager: manager ?? this.manager,
      phone: phone ?? this.phone,
      store: store ?? this.store,
      numberOfFavorites: numberOfFavorites ?? this.numberOfFavorites,
      rating: rating ?? this.rating,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
    );
  }
}
