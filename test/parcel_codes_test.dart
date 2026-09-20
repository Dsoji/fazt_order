import 'package:fazt_order/src/features/courier/data/model/parcel_request.dart';
import 'package:flutter_test/flutter_test.dart';

/// A parcel now carries two 4-digit codes held by two different people:
/// `pickupOTP`, which the sender reads to the rider at collection, and
/// `riderOTP`, which the receiver gives at the door. Both are optional — the
/// pickup code is absent on every parcel created before it existed — and the
/// screens hide the block rather than render a placeholder, so "absent" has to
/// survive parsing as null and not as 0.
void main() {
  Map<String, dynamic> parcelWith(Map<String, dynamic> codes) => {
        'id': 'parcel-1',
        'status': 'accepted',
        ...codes,
      };

  group('Parcel codes', () {
    test('reads both codes as sent', () {
      final parcel = Parcel.fromMap(
        parcelWith({'pickupOTP': 4821, 'riderOTP': 9137}),
      );

      expect(parcel.pickupOTP, 4821);
      expect(parcel.riderOTP, 9137);
    });

    test('a pre-release parcel has no pickup code, not a zero', () {
      final parcel = Parcel.fromMap(parcelWith({'riderOTP': 9137}));

      expect(parcel.pickupOTP, isNull);
      expect(parcel.riderOTP, 9137);
    });

    test('a quoted code still parses', () {
      final parcel = Parcel.fromMap(
        parcelWith({'pickupOTP': '4821', 'riderOTP': '9137'}),
      );

      expect(parcel.pickupOTP, 4821);
      expect(parcel.riderOTP, 9137);
    });

    test('an unparseable code is absent rather than fatal', () {
      final parcel = Parcel.fromMap(parcelWith({'pickupOTP': 'nope'}));

      expect(parcel.pickupOTP, isNull);
      expect(parcel.id, 'parcel-1');
    });

    test('both codes survive a round trip through the map', () {
      final parcel = Parcel.fromMap(
        parcelWith({'pickupOTP': 4821, 'riderOTP': 9137}),
      );

      final restored = Parcel.fromMap(parcel.toMap());

      expect(restored.pickupOTP, 4821);
      expect(restored.riderOTP, 9137);
    });
  });
}
