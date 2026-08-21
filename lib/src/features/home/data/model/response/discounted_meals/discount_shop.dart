import 'dart:convert';

import '../shops_model/location.dart';

/// The shop selling a discounted meal.
class DiscountShop {
  /// Not documented in the handoff, but parsed when present so the card can
  /// deep-link into the restaurant.
  String? id;
  String? shopName;
  Location? location;
  num? deliveryFee;
  num? deliveryTime;

  /// The vendor's "Accepting orders" switch, so the promo rail cannot send a
  /// customer into a restaurant that has paused orders.
  bool? isOpen;

  DiscountShop({
    this.id,
    this.shopName,
    this.location,
    this.deliveryFee,
    this.deliveryTime,
    this.isOpen,
  });

  @override
  String toString() {
    return 'DiscountShop(id: $id, shopName: $shopName, location: $location, deliveryFee: $deliveryFee, deliveryTime: $deliveryTime, isOpen: $isOpen)';
  }

  factory DiscountShop.fromMap(Map<String, dynamic> data) => DiscountShop(
        id: (data['id'] ?? data['_id']) as String?,
        shopName: data['shopName'] as String?,
        location: data['location'] == null
            ? null
            : Location.fromMap(data['location'] as Map<String, dynamic>),
        deliveryFee: data['deliveryFee'] as num?,
        deliveryTime: data['deliveryTime'] as num?,
        isOpen: data['isOpen'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'shopName': shopName,
        'location': location?.toMap(),
        'deliveryFee': deliveryFee,
        'deliveryTime': deliveryTime,
        'isOpen': isOpen,
      };

  factory DiscountShop.fromJson(String data) {
    return DiscountShop.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  DiscountShop copyWith({
    String? id,
    String? shopName,
    Location? location,
    num? deliveryFee,
    num? deliveryTime,
    bool? isOpen,
  }) {
    return DiscountShop(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      location: location ?? this.location,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}
