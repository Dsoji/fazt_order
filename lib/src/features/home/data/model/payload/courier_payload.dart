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
    String? deliveryAddressCity,
    String? deliveryAddressState,
    String? deliveryAddressLong,
    String? deliveryAddressLat,
    String? pickUpAddressCity,
    String? pickUpAddressState,
    String? pickUpAddressLong,
    String? pickUpAddressLat,
  }) : super({
          "deliveryAddress": {
            "address": deliveryAddress,
            "city": deliveryAddressCity,
            "state": deliveryAddressState,
            "long": deliveryAddressLong,
            "lat": deliveryAddressLat
          },
          "pickUpAddress": {
            "address": pickUpAddress,
            "city": pickUpAddressCity,
            "state": pickUpAddressState,
            "long": pickUpAddressLong,
            "lat": pickUpAddressLat
          },
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
