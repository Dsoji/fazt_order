import 'dart:convert';

import 'package:fazt_order/src/features/home/data/model/response/search_global/location.dart'
    as common_location;

class CourierListResponse {
  int? total;
  int? pageCount;
  Map<String, dynamic>? pagination;
  List<CourierOrder>? results;

  CourierListResponse({
    this.total,
    this.pageCount,
    this.pagination,
    this.results,
  });

  @override
  String toString() {
    return 'CourierListResponse(total: $total, pageCount: $pageCount, pagination: $pagination, results: $results)';
  }

  factory CourierListResponse.fromMap(Map<String, dynamic> data) =>
      CourierListResponse(
        total: (data['total'] as num?)?.toInt(),
        pageCount: (data['page_count'] as num?)?.toInt(),
        pagination: data['pagination'] == null
            ? null
            : Map<String, dynamic>.from(
                data['pagination'] as Map<String, dynamic>,
              ),
        results: (data['results'] as List<dynamic>?)
            ?.map((e) => CourierOrder.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'total': total,
        'page_count': pageCount,
        'pagination': pagination,
        'results': results?.map((e) => e.toMap()).toList(),
      };

  factory CourierListResponse.fromJson(String data) {
    return CourierListResponse.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  CourierListResponse copyWith({
    int? total,
    int? pageCount,
    Map<String, dynamic>? pagination,
    List<CourierOrder>? results,
  }) {
    return CourierListResponse(
      total: total ?? this.total,
      pageCount: pageCount ?? this.pageCount,
      pagination: pagination ?? this.pagination,
      results: results ?? this.results,
    );
  }
}

class CourierOrder {
  AddressField? pickUpAddress;
  AddressField? deliveryAddress;
  String? user;
  String? parcelType;
  String? deliveryType;
  String? instructions;
  String? dispatchType;
  PersonInfo? receiverInfo;
  PersonInfo? senderInfo;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  CourierOrder({
    this.pickUpAddress,
    this.deliveryAddress,
    this.user,
    this.parcelType,
    this.deliveryType,
    this.instructions,
    this.dispatchType,
    this.receiverInfo,
    this.senderInfo,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  @override
  String toString() {
    return 'CourierOrder(pickUpAddress: $pickUpAddress, deliveryAddress: $deliveryAddress, user: $user, parcelType: $parcelType, deliveryType: $deliveryType, instructions: $instructions, dispatchType: $dispatchType, receiverInfo: $receiverInfo, senderInfo: $senderInfo, isDeleted: $isDeleted, createdAt: $createdAt, updatedAt: $updatedAt, id: $id)';
  }

  factory CourierOrder.fromMap(Map<String, dynamic> data) => CourierOrder(
        pickUpAddress: AddressField.fromDynamic(data['pickUpAddress']),
        deliveryAddress: AddressField.fromDynamic(data['deliveryAddress']),
        user: data['user'] as String?,
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
        isDeleted: data['isDeleted'] as bool?,
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.tryParse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.tryParse(data['updatedAt'] as String),
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'pickUpAddress': pickUpAddress?.toDynamic(),
        'deliveryAddress': deliveryAddress?.toDynamic(),
        'user': user,
        'parcelType': parcelType,
        'deliveryType': deliveryType,
        'instructions': instructions,
        'dispatchType': dispatchType,
        'receiverInfo': receiverInfo?.toMap(),
        'senderInfo': senderInfo?.toMap(),
        'isDeleted': isDeleted,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'id': id,
      };

  factory CourierOrder.fromJson(String data) {
    return CourierOrder.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  CourierOrder copyWith({
    AddressField? pickUpAddress,
    AddressField? deliveryAddress,
    String? user,
    String? parcelType,
    String? deliveryType,
    String? instructions,
    String? dispatchType,
    PersonInfo? receiverInfo,
    PersonInfo? senderInfo,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) {
    return CourierOrder(
      pickUpAddress: pickUpAddress ?? this.pickUpAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      user: user ?? this.user,
      parcelType: parcelType ?? this.parcelType,
      deliveryType: deliveryType ?? this.deliveryType,
      instructions: instructions ?? this.instructions,
      dispatchType: dispatchType ?? this.dispatchType,
      receiverInfo: receiverInfo ?? this.receiverInfo,
      senderInfo: senderInfo ?? this.senderInfo,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
    );
  }
}

class PersonInfo {
  String? name;
  String? phone;
  String? email;
  String? id;

  PersonInfo({
    this.name,
    this.phone,
    this.email,
    this.id,
  });

  @override
  String toString() {
    return 'PersonInfo(name: $name, phone: $phone, email: $email, id: $id)';
  }

  factory PersonInfo.fromMap(Map<String, dynamic> data) => PersonInfo(
        name: data['name'] as String?,
        phone: data['phone'] as String?,
        email: data['email'] as String?,
        id: (data['_id'] ?? data['id']) as String?,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'email': email,
        '_id': id,
      };

  factory PersonInfo.fromJson(String data) {
    return PersonInfo.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  PersonInfo copyWith({
    String? name,
    String? phone,
    String? email,
    String? id,
  }) {
    return PersonInfo(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      id: id ?? this.id,
    );
  }
}

/// Represents an address field that can be either a GeoJSON-like object
/// (mapped to [common_location.Location]) or a plain string.
class AddressField {
  final common_location.Location? location;
  final String? text;

  const AddressField._({this.location, this.text});

  factory AddressField.fromDynamic(dynamic value) {
    if (value == null) return const AddressField._();
    if (value is String) return AddressField._(text: value);
    if (value is Map<String, dynamic>) {
      return AddressField._(
        location: common_location.Location.fromMap(value),
      );
    }
    // Fallback to string representation
    return AddressField._(text: value.toString());
  }

  /// Returns a JSON-serializable representation matching the original type.
  dynamic toDynamic() {
    if (location != null) return location!.toMap();
    return text;
  }

  @override
  String toString() => location?.toString() ?? (text ?? '');

  AddressField copyWith({
    common_location.Location? location,
    String? text,
  }) {
    return AddressField._(
      location: location ?? this.location,
      text: text ?? this.text,
    );
  }
}
