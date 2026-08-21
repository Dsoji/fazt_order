import 'dart:convert';

import 'cart.dart';

/// `PATCH /carts/:cartId/items/:cartItemId/quantity` — the cart as it stands
/// after a meal's or an option's quantity changed.
///
/// Every price on the cart is recomputed server-side on each change (promo
/// pricing included), so [cart] is the whole document rather than a delta and
/// the screen re-renders from it instead of adjusting its own totals.
class CartQuantityResult {
  final Cart? cart;
  final int? packCount;

  const CartQuantityResult({this.cart, this.packCount});

  /// What a response the app couldn't read means: nothing to re-render from,
  /// so the caller falls back to refetching the cart.
  static const CartQuantityResult unknown = CartQuantityResult();

  factory CartQuantityResult.fromMap(Map<String, dynamic> data) =>
      CartQuantityResult(
        cart: data['cart'] is Map<String, dynamic>
            ? Cart.fromMap(data['cart'] as Map<String, dynamic>)
            : null,
        packCount: (data['packCount'] as num?)?.toInt(),
      );

  Map<String, dynamic> toMap() => {
        'cart': cart?.toMap(),
        'packCount': packCount,
      };

  factory CartQuantityResult.fromJson(String data) =>
      CartQuantityResult.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'CartQuantityResult(packCount: $packCount)';
}
