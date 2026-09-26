import 'package:flutter_test/flutter_test.dart';
import 'package:fazt_order/src/features/courier/data/model/parcel_quote.dart';
import 'package:fazt_order/src/features/home/data/model/response/cartlsit/cart.dart';

void main() {
  group('promo code contract', () {
    test('cart model preserves promo code metadata', () {
      final cart = Cart.fromMap({
        'id': 'cart-1',
        'promoCode': 'SAVE20',
        'promoCodeRuleId': 'rule-123',
        'promoCodeError': 'expired',
        'totalPrice': 4800,
      });

      expect(cart.promoCode, 'SAVE20');
      expect(cart.promoCodeRuleId, 'rule-123');
      expect(cart.promoCodeError, 'expired');
    });

    test('parcel quote model preserves promo code status metadata', () {
      final quote = ParcelQuote.fromMap({
        'totalPrice': 2500,
        'discount': 500,
        'promoCodeStatus': 'valid_but_lost',
        'appliedPromoCode': 'SAVE20',
        'promoCodeError': null,
      });

      expect(quote.promoCodeStatus, 'valid_but_lost');
      expect(quote.appliedPromoCode, 'SAVE20');
      expect(quote.promoCodeError, isNull);
    });
  });
}
