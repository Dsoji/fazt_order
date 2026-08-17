import 'dart:convert';

import 'package:fazt_order/src/features/home/data/model/response/search_global/location.dart'
    as common_location;

import 'courier_list.dart' show PersonInfo; // Reuse existing PersonInfo model
import 'parcel_quote.dart';

/// `POST /parcels` — the created request, plus the exact price it was made
/// under.
///
/// The quote travels with the parcel deliberately: the confirm screen shows the
/// same numbers the request was priced at, rather than re-quoting and risking a
/// figure that drifts between review and payment.
class ParcelRequest {
  final Parcel? parcel;
  final ParcelQuote? quote;
  final ParcelPromotion? promotion;

  const ParcelRequest({this.parcel, this.quote, this.promotion});

  factory ParcelRequest.fromMap(Map<String, dynamic> data) => ParcelRequest(
        parcel: data['parcel'] == null
            ? null
            : Parcel.fromMap(data['parcel'] as Map<String, dynamic>),
        quote: data['quote'] is Map<String, dynamic>
            ? ParcelQuote.fromMap(data['quote'] as Map<String, dynamic>)
            : null,
        promotion: data['promotion'] is Map<String, dynamic>
            ? ParcelPromotion.fromMap(
                data['promotion'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'parcel': parcel?.toMap(),
        'quote': quote?.toMap(),
        'promotion': promotion?.toMap(),
      };

  factory ParcelRequest.fromJson(String data) =>
      ParcelRequest.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  ParcelRequest copyWith({
    Parcel? parcel,
    ParcelQuote? quote,
    ParcelPromotion? promotion,
  }) =>
      ParcelRequest(
        parcel: parcel ?? this.parcel,
        quote: quote ?? this.quote,
        promotion: promotion ?? this.promotion,
      );
}

class Parcel {
  final String? user;
  final common_location.Location? pickUpAddress;
  final common_location.Location? deliveryAddress;
  final String? parcelType;
  final String? deliveryType;
  final String? instructions;
  final String? dispatchType;
  final PersonInfo? receiverInfo;
  final PersonInfo? senderInfo;
  final String? status;
  final num? deliveryFee;
  final num? serviceFee;
  final String? promoCode;
  final String? promoCodeRuleId;
  final String? promoCodeError;

  /// The code the **receiver** quotes to the rider at the door, unlocking
  /// `delivered`.
  ///
  /// Read it from the order, not from here, wherever an order is at hand: the
  /// parcel record and its paying order each used to mint their own value and
  /// only the order's was ever checked at delivery. The backend now copies the
  /// parcel's onto the order, so the two agree — but an app that reads this
  /// field is the one that was showing the wrong number before that fix.
  final int? riderOTP;

  /// The code the **sender** reads to the rider at collection, unlocking
  /// `in_transit`.
  ///
  /// Only ever sent to the parcel's own sender, and only by `GET /parcels/:id`
  /// — a parcel arriving from anywhere else carries no such field. Null on
  /// parcels created before pickup codes existed; those were never issued one,
  /// and the backend lets them through collection unverified. A null means
  /// "no code", never "code not loaded yet", so hide the block rather than
  /// render a placeholder.
  final int? pickupOTP;

  final bool? isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? id;

  const Parcel({
    this.user,
    this.pickUpAddress,
    this.deliveryAddress,
    this.parcelType,
    this.deliveryType,
    this.instructions,
    this.dispatchType,
    this.receiverInfo,
    this.senderInfo,
    this.status,
    this.deliveryFee,
    this.serviceFee,
    this.promoCode,
    this.promoCodeRuleId,
    this.promoCodeError,
    this.riderOTP,
    this.pickupOTP,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  factory Parcel.fromMap(Map<String, dynamic> data) => Parcel(
        user: data['user'] as String?,
        pickUpAddress: data['pickUpAddress'] == null
            ? null
            : common_location.Location.fromMap(
                data['pickUpAddress'] as Map<String, dynamic>,
              ),
        deliveryAddress: data['deliveryAddress'] == null
            ? null
            : common_location.Location.fromMap(
                data['deliveryAddress'] as Map<String, dynamic>,
              ),
        parcelType: data['parcelType'] as String?,
        deliveryType: data['deliveryType'] as String?,
        instructions: data['instructions'] as String?,
        dispatchType: data['dispatchType'] as String?,
        receiverInfo: data['receiverInfo'] == null
            ? null
            : PersonInfo.fromMap(data['receiverInfo'] as Map<String, dynamic>),
        senderInfo: data['senderInfo'] == null
            ? null
            : PersonInfo.fromMap(data['senderInfo'] as Map<String, dynamic>),
        status: data['status'] as String?,
        deliveryFee: data['deliveryFee'] as num?,
        serviceFee: data['serviceFee'] as num?,
        promoCode: data['promoCode'] as String?,
        promoCodeRuleId: data['promoCodeRuleId'] as String?,
        promoCodeError: data['promoCodeError'] as String?,
        riderOTP: _otp(data['riderOTP']),
        pickupOTP: _otp(data['pickupOTP']),
        isDeleted: data['isDeleted'] as bool?,
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.tryParse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.tryParse(data['updatedAt'] as String),
        id: (data['id'] ?? data['_id']) as String?,
      );

  Map<String, dynamic> toMap() => {
        'user': user,
        'pickUpAddress': pickUpAddress?.toMap(),
        'deliveryAddress': deliveryAddress?.toMap(),
        'parcelType': parcelType,
        'deliveryType': deliveryType,
        'instructions': instructions,
        'dispatchType': dispatchType,
        'receiverInfo': receiverInfo?.toMap(),
        'senderInfo': senderInfo?.toMap(),
        'status': status,
        'deliveryFee': deliveryFee,
        'serviceFee': serviceFee,
        'promoCode': promoCode,
        'promoCodeRuleId': promoCodeRuleId,
        'promoCodeError': promoCodeError,
        'riderOTP': riderOTP,
        'pickupOTP': pickupOTP,
        'isDeleted': isDeleted,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'id': id,
      };

  factory Parcel.fromJson(String data) =>
      Parcel.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  Parcel copyWith({
    String? user,
    common_location.Location? pickUpAddress,
    common_location.Location? deliveryAddress,
    String? parcelType,
    String? deliveryType,
    String? instructions,
    String? dispatchType,
    PersonInfo? receiverInfo,
    PersonInfo? senderInfo,
    String? status,
    num? deliveryFee,
    num? serviceFee,
    String? promoCode,
    String? promoCodeRuleId,
    String? promoCodeError,
    int? riderOTP,
    int? pickupOTP,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) =>
      Parcel(
        user: user ?? this.user,
        pickUpAddress: pickUpAddress ?? this.pickUpAddress,
        deliveryAddress: deliveryAddress ?? this.deliveryAddress,
        parcelType: parcelType ?? this.parcelType,
        deliveryType: deliveryType ?? this.deliveryType,
        instructions: instructions ?? this.instructions,
        dispatchType: dispatchType ?? this.dispatchType,
        receiverInfo: receiverInfo ?? this.receiverInfo,
        senderInfo: senderInfo ?? this.senderInfo,
        status: status ?? this.status,
        deliveryFee: deliveryFee ?? this.deliveryFee,
        serviceFee: serviceFee ?? this.serviceFee,
        promoCode: promoCode ?? this.promoCode,
        promoCodeRuleId: promoCodeRuleId ?? this.promoCodeRuleId,
        promoCodeError: promoCodeError ?? this.promoCodeError,
        riderOTP: riderOTP ?? this.riderOTP,
        pickupOTP: pickupOTP ?? this.pickupOTP,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
      );

  /// A 4-digit code as the backend may send it.
  ///
  /// Documented as a number, but the same endpoints accept one as a string on
  /// the way in, so don't let a quoted `"4821"` cast-fail the whole parcel and
  /// take the details screen down with it.
  static int? _otp(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}
