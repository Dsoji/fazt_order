import 'dart:collection' show MapView;

import 'package:flutter/foundation.dart' show immutable;

@immutable
class CourierPayload extends MapView<String, dynamic> {
  CourierPayload({
    String? deliveryAddress,
    String? pickUpAddress,
    String? parcelType,
    String? instructions,
    String? dispatchType,
    String? deliveryType,
    String? receiverName,
    String? receiverEmail,
    String? receiverPhone,
    String? senderName,
    String? senderEmail,
    String? senderPhone,
  }) : super({
          "deliveryAddress": deliveryAddress,
          "pickUpAddress": pickUpAddress,
          "parcelType": parcelType,
          "instructions": instructions,
          "receiverInfo": {
            "name": receiverName,
            "email": receiverEmail,
            "phone": receiverPhone
          },
          "senderInfo": {
            "name": senderName,
            "email": senderEmail,
            "phone": senderPhone
          },
          "dispatchType": dispatchType,
          "deliveryType": deliveryType
        });
}
