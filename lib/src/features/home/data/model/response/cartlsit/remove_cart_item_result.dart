import 'dart:convert';

import 'cart.dart';
import 'item.dart';

/// `DELETE /carts/:cartId/items/:cartItemId` — one item taken out, the rest of
/// its pack left in place.
///
/// Only [packEmptied] is really acted on: when the removed item was the last
/// one in its pack, that pack is gone and the remaining packs are renumbered,
/// so any pack number the app was holding on to now means a different pack.
/// The rest is kept because the response carries it and it makes the result
/// readable in logs.
class RemoveCartItemResult {
  final Cart? cart;
  final int? packCount;
  final bool packEmptied;
  final Item? removedItem;

  const RemoveCartItemResult({
    this.cart,
    this.packCount,
    this.packEmptied = false,
    this.removedItem,
  });

  /// What a response the app couldn't read means: assume the pack layout
  /// shifted, so the caller re-reads the cart instead of trusting a stale
  /// pack number.
  static const RemoveCartItemResult unknown =
      RemoveCartItemResult(packEmptied: true);

  factory RemoveCartItemResult.fromMap(Map<String, dynamic> data) =>
      RemoveCartItemResult(
        cart: data['cart'] is Map<String, dynamic>
            ? Cart.fromMap(data['cart'] as Map<String, dynamic>)
            : null,
        packCount: (data['packCount'] as num?)?.toInt(),
        packEmptied: data['packEmptied'] as bool? ?? false,
        removedItem: data['removedItem'] is Map<String, dynamic>
            ? Item.fromMap(data['removedItem'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'cart': cart?.toMap(),
        'packCount': packCount,
        'packEmptied': packEmptied,
        'removedItem': removedItem?.toMap(),
      };

  factory RemoveCartItemResult.fromJson(String data) =>
      RemoveCartItemResult.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'RemoveCartItemResult(packCount: $packCount, '
      'packEmptied: $packEmptied)';
}
