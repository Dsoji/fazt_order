import 'dart:collection' show MapView;

import 'package:flutter/foundation.dart' show immutable;

@immutable
class ProfilePayload extends MapView<String, dynamic> {
  ProfilePayload({
    String? firstname,
    String? lastname,
    String? phone,
    String? pin,
    bool? biometric,
    bool? emailAlert,
    bool? pushAlert,
    String? theme,
  }) : super({
          'firstname': firstname,
          'lastname': lastname,
          'pin': pin,
          'phone': phone,
          'emailAlert': emailAlert,
          'pushAlert': pushAlert,
          'biometrics': biometric,
          'theme': theme,
        });
}
