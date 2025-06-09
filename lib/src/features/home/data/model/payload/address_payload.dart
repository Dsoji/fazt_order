import 'dart:collection' show MapView;

import 'package:flutter/foundation.dart' show immutable;

@immutable
class AddressPayload extends MapView<String, dynamic> {
  AddressPayload({
    String? address,
    String? city,
    String? state,
    String? long,
    String? lat,
  }) : super({
          'location': {
            'address': address,
            'city': city,
            'state': state,
            'long': long,
            'lat': lat,
          },
        });
}
