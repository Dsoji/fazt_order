import 'dart:convert';

import 'cart.dart';

class CartLsit {
  List<Cart>? carts;
  num? totalCarts;
  num? availableCarts;

  CartLsit({this.carts, this.totalCarts, this.availableCarts});

  @override
  String toString() =>
      'CartLsit(carts: $carts, totalCarts: $totalCarts, availableCarts: $availableCarts)';

  factory CartLsit.fromMap(Map<String, dynamic> data) => CartLsit(
        carts: (data['carts'] as List<dynamic>?)
            ?.map((e) => Cart.fromMap(e as Map<String, dynamic>))
            .toList(),
        totalCarts: data['totalCarts'] as num?,
        availableCarts: data['availableCarts'] as num?,
      );

  Map<String, dynamic> toMap() => {
        'carts': carts?.map((e) => e.toMap()).toList(),
        'totalCarts': totalCarts,
        'availableCarts': availableCarts,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Cartlsit].
  factory CartLsit.fromJson(String data) {
    return CartLsit.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Cartlsit] to a JSON string.
  String toJson() => json.encode(toMap());

  CartLsit copyWith({
    List<Cart>? carts,
    num? totalCarts,
    num? availableCarts,
  }) {
    return CartLsit(
      carts: carts ?? this.carts,
      totalCarts: totalCarts ?? this.totalCarts,
      availableCarts: availableCarts ?? this.availableCarts,
    );
  }
}
