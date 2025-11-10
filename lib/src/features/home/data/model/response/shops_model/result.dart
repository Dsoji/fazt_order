import 'dart:convert';

import 'location.dart';
import 'store.dart';

class ShopResult {
  Location? location;
  int? numberOfFavorites;
  int? rating;
  int? deliveryFee;
  String? shopName;
  String? manager;
  String? phone;
  Store? store;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  bool? isLiked;
  bool? isOpen;

  ShopResult({
    this.location,
    this.numberOfFavorites,
    this.rating,
    this.deliveryFee,
    this.shopName,
    this.manager,
    this.phone,
    this.store,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.isLiked,
    this.isOpen,
  });

  @override
  String toString() {
    return 'Result(location: $location, numberOfFavorites: $numberOfFavorites, rating: $rating, deliveryFee: $deliveryFee, shopName: $shopName, manager: $manager, phone: $phone, store: $store, createdAt: $createdAt, updatedAt: $updatedAt, id: $id, isLiked: $isLiked, isOpen: $isOpen)';
  }

  factory ShopResult.fromMap(Map<String, dynamic> data) => ShopResult(
        location: data['location'] == null
            ? null
            : Location.fromMap(data['location'] as Map<String, dynamic>),
        numberOfFavorites:
            data['favoriteCount'] as int? ?? 0, // Provide default value
        rating: data['rating'] as int? ?? 0, // Provide default value
        deliveryFee: data['deliveryFee'] as int?,
        shopName: data['shopName'] as String?,
        manager: data['manager'] as String?,
        phone: data['phone'] as String?,
        store: data['store'] == null
            ? null
            : Store.fromMap(data['store'] as Map<String, dynamic>),
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
        id: data['id'] as String?,
        isLiked: data['isLiked'] as bool?,
        isOpen: data['isOpen'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'location': location?.toMap(),
        'numberOfFavorites': numberOfFavorites,
        'rating': rating,
        'deliveryFee': deliveryFee,
        'shopName': shopName,
        'manager': manager,
        'phone': phone,
        'store': store?.toMap(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'id': id,
        'isLiked': isLiked,
        'isOpen': isOpen,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Result].
  factory ShopResult.fromJson(String data) {
    return ShopResult.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Result] to a JSON string.
  String toJson() => json.encode(toMap());

  ShopResult copyWith({
    Location? location,
    int? numberOfFavorites,
    int? rating,
    int? deliveryFee,
    String? shopName,
    String? manager,
    String? phone,
    Store? store,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    bool? isLiked,
    bool? isOpen,
  }) {
    return ShopResult(
      location: location ?? this.location,
      numberOfFavorites: numberOfFavorites ?? this.numberOfFavorites,
      rating: rating ?? this.rating,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      shopName: shopName ?? this.shopName,
      manager: manager ?? this.manager,
      phone: phone ?? this.phone,
      store: store ?? this.store,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      isLiked: isLiked ?? this.isLiked,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}
