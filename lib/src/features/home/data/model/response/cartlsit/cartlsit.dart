import 'dart:convert';

import 'cart.dart';

class CartLsit {
  List<Cart>? carts;
  int? totalCarts;

  CartLsit({this.carts, this.totalCarts});

  @override
  String toString() => 'CartLsit(carts: $carts, totalCarts: $totalCarts)';

  factory CartLsit.fromMap(Map<String, dynamic> data) => CartLsit(
        carts: (data['carts'] as List<dynamic>?)
            ?.map((e) => Cart.fromMap(e as Map<String, dynamic>))
            .toList(),
        totalCarts: data['totalCarts'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'carts': carts?.map((e) => e.toMap()).toList(),
        'totalCarts': totalCarts,
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
    int? totalCarts,
  }) {
    return CartLsit(
      carts: carts ?? this.carts,
      totalCarts: totalCarts ?? this.totalCarts,
    );
  }
}
