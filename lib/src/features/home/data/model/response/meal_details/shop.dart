import 'dart:convert';

import 'location.dart';

class Shop {
  String? id;
  String? shopName;
  Location? location;
  int? deliveryFee;

  Shop({this.id, this.shopName, this.location, this.deliveryFee});

  @override
  String toString() {
    return 'Shop(id: $id, shopName: $shopName, location: $location, deliveryFee: $deliveryFee)';
  }

  factory Shop.fromMap(Map<String, dynamic> data) => Shop(
        id: data['id'] as String?,
        shopName: data['shopName'] as String?,
        location: data['location'] == null
            ? null
            : Location.fromMap(data['location'] as Map<String, dynamic>),
        deliveryFee: data['deliveryFee'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'shopName': shopName,
        'location': location?.toMap(),
        'deliveryFee': deliveryFee,
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
    String? id,
    String? shopName,
    Location? location,
    int? deliveryFee,
  }) {
    return Shop(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      location: location ?? this.location,
      deliveryFee: deliveryFee ?? this.deliveryFee,
    );
  }
}
