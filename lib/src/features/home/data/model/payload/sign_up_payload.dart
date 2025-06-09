import 'dart:collection' show MapView;

import 'package:flutter/foundation.dart' show immutable;

@immutable
class SignUpPayload extends MapView<String, dynamic> {
  SignUpPayload({
    String? firstname,
    String? lastname,
    String? country,
    String? phone,
    String? email,
    String? password,
    String? referral,
    String? device,
    dynamic fcmToken,
  }) : super({
          'firstname': firstname,
          'lastname': lastname,
          'country': country,
          'phone': phone,
          'email': email,
          'password': password,
          'referral': referral,
          'device': device,
          'fcmToken': fcmToken,
        });
}
