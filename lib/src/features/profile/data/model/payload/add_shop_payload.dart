import 'dart:collection' show MapView;
import 'dart:collection';

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/foundation.dart';

@immutable
class AddShopPayload extends MapView<String, dynamic> {
  AddShopPayload({
    required String shopName,
    required String phone,
    required String manager,
    required double lat,
    required double long,
    required String address,
    required String state,
    required String city,
  }) : super({
          'shopName': shopName,
          'phone': phone,
          'manager': manager,
          'location': {
            'lat': lat,
            'long': long,
            'address': address,
            'state': state,
            'city': city,
          },
        });
}
