import 'package:fazt_order/src/features/home/data/model/response/cartlsit/cart.dart';
import 'package:fazt_order/src/features/home/data/model/response/cartlsit/item.dart';
import 'package:fazt_order/src/features/home/data/model/response/cartlsit/remove_cart_item_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('packagingFee parsing', () {
    test('reads the per-item and cart-level charge', () {
      final cart = Cart.fromMap({
        'items': [
          {'mealQuantity': 2, 'packNumber': 1, 'packagingFee': 400, '_id': 'a'},
          {'mealQuantity': 1, 'packNumber': 1, 'packagingFee': 500, '_id': 'b'},
        ],
        'packagingFee': 900,
        'totalPrice': 6425,
      });

      expect(cart.packagingFee, 900);
      expect(cart.items?.map((e) => e.packagingFee), [400, 500]);
      // The item fees always sum to the cart's, so the UI renders one or the
      // other and never both added together.
      expect(
        cart.items!.fold<num>(0, (sum, item) => sum + (item.packagingFee ?? 0)),
        cart.packagingFee,
      );
    });

    test('a cart written before packaging existed reads null, not a bad value',
        () {
      final cart = Cart.fromMap({
        'items': [
          {'mealQuantity': 1, 'packNumber': 1, '_id': 'a'}
        ],
      });

      expect(cart.packagingFee, isNull);
      expect(cart.items?.first.packagingFee, isNull);
    });

    test('survives a round trip through toMap', () {
      final item = Item(mealQuantity: 3, packNumber: 2, packagingFee: 600);
      expect(Item.fromMap(item.toMap()).packagingFee, 600);
    });
  });

  group('RemoveCartItemResult', () {
    test('reads packEmptied and the repriced cart', () {
      final result = RemoveCartItemResult.fromMap({
        'cart': {'packagingFee': 500, 'totalPrice': 3000},
        'packCount': 2,
        'packEmptied': false,
        'removedItem': {'mealQuantity': 1, 'packNumber': 1},
      });

      expect(result.packEmptied, isFalse);
      expect(result.packCount, 2);
      expect(result.cart?.totalPrice, 3000);
      expect(result.removedItem?.packNumber, 1);
    });

    test('defaults packEmptied to false when the field is absent', () {
      expect(RemoveCartItemResult.fromMap(const {}).packEmptied, isFalse);
    });

    test('an unreadable response assumes the pack layout shifted', () {
      // Pack numbers resequence when a pack empties, so the safe assumption is
      // that a remembered pack target is now stale.
      expect(RemoveCartItemResult.unknown.packEmptied, isTrue);
    });
  });
}
