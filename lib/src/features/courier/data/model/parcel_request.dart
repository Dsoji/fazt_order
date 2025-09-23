import 'dart:convert';

import 'package:fazt_order/src/features/home/data/model/response/search_global/location.dart'
    as common_location;

import 'courier_list.dart' show PersonInfo; // Reuse existing PersonInfo model

class ParcelRequest {
  final Parcel? parcel;

  const ParcelRequest({this.parcel});

  factory ParcelRequest.fromMap(Map<String, dynamic> data) => ParcelRequest(
        parcel: data['parcel'] == null
            ? null
            : Parcel.fromMap(data['parcel'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'parcel': parcel?.toMap(),
      };

  factory ParcelRequest.fromJson(String data) =>
      ParcelRequest.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  ParcelRequest copyWith({Parcel? parcel}) => ParcelRequest(
        parcel: parcel ?? this.parcel,
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
  final int? riderOTP;
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
    this.riderOTP,
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
        riderOTP: (data['riderOTP'] as num?)?.toInt(),
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
        'riderOTP': riderOTP,
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
    int? riderOTP,
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
        riderOTP: riderOTP ?? this.riderOTP,
        isDeleted: isDeleted ?? this.isDeleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
      );
}
