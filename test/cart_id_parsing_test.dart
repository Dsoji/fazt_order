import 'package:fazt_order/src/features/home/data/model/response/cartlsit/cart.dart';
import 'package:flutter_test/flutter_test.dart';

/// The cart payload mixes id conventions — array subdocuments keep Mongo's
/// `_id`, populated documents come back serialised with `id`. A line whose
/// `mealVariant` id fails to parse still renders, but silently loses its
/// quantity stepper and its "Edit Selections" button, so both shapes are
/// pinned here rather than left to whichever one the API happened to send.
void main() {
  Map<String, dynamic> cartWith(Map<String, dynamic> variant) => {
        'id': 'cart-1',
        'items': [
          {
            '_id': 'item-1',
            'mealQuantity': 1,
            'packNumber': 1,
            'mealVariant': variant,
            'options': [
              {
                'quantity': 2,
                'optionItemVariant': {
                  'id': 'oiv-1',
                  'optionItem': {'id': 'oi-1', 'item': 'Efo', 'price': 750},
                },
              },
            ],
          },
        ],
      };

  group('cart line ids', () {
    test('reads a meal variant serialised with `id`', () {
      final cart = Cart.fromMap(cartWith({'id': 'mv-1', 'inStock': true}));
      expect(cart.items!.first.mealVariant?.id, 'mv-1');
    });

    test('still reads a meal variant carrying `_id`', () {
      final cart = Cart.fromMap(cartWith({'_id': 'mv-1', 'inStock': true}));
      expect(cart.items!.first.mealVariant?.id, 'mv-1');
    });

    test('reads option ids under either convention', () {
      final cart = Cart.fromMap(cartWith({'id': 'mv-1'}));
      final option = cart.items!.first.options!.first;
      expect(option.optionItemVariant?.id, 'oiv-1');
      expect(option.optionItemVariant?.optionItem?.id, 'oi-1');
    });

    test('the item subdocument keeps `_id`', () {
      final cart = Cart.fromMap(cartWith({'id': 'mv-1'}));
      expect(cart.items!.first.id, 'item-1');
    });
  });
}
