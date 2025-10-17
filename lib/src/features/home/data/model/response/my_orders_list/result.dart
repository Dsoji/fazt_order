import 'dart:convert';

import 'package:fazt_order/src/features/home/data/model/response/my_orders_list/user.dart';

import 'delivery_location.dart';
import 'item.dart';
import 'payment.dart';
import 'shop.dart';
import 'status_history.dart';

class OrderResult {
  DeliveryLocation? deliveryLocation;
  String? orderNumber;
  String? orderType;
  String? orderStatus;
  User? user;
  Shop? shop;
  String? store; // Changed back to String? since API returns string
  List<Item>? items;
  int? packCount;
  String? deliveryType;
  String? storeMessage;
  String? status;
  List<StatusHistory>? statusHistory;
  Payment? payment;
  DateTime? orderPlacedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  OrderResult({
    this.deliveryLocation,
    this.orderNumber,
    this.orderType,
    this.user,
    this.shop,
    this.store,
    this.items,
    this.packCount,
    this.deliveryType,
    this.storeMessage,
    this.status,
    this.statusHistory,
    this.payment,
    this.orderPlacedAt,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  @override
  String toString() {
    return 'Result(deliveryLocation: $deliveryLocation, orderNumber: $orderNumber, user: $user, shop: $shop, store: $store, items: $items, packCount: $packCount, deliveryType: $deliveryType, storeMessage: $storeMessage, status: $status, statusHistory: $statusHistory, payment: $payment, orderPlacedAt: $orderPlacedAt, createdAt: $createdAt, updatedAt: $updatedAt, id: $id)';
  }

  factory OrderResult.fromMap(Map<String, dynamic> data) => OrderResult(
        deliveryLocation: data['deliveryLocation'] == null
            ? null
            : DeliveryLocation.fromMap(
                data['deliveryLocation'] as Map<String, dynamic>),
        orderNumber: data['orderNumber'] as String?,
        orderType: data['orderType'] as String?,
        user: data['user'] == null
            ? null
            : User.fromMap(data['user'] as Map<String, dynamic>),
        shop: data['shop'] == null
            ? null
            : Shop.fromMap(data['shop'] as Map<String, dynamic>),
        store: data['store'] as String?, // Changed back to String?
        items: (data['items'] as List<dynamic>?)
            ?.map((e) => Item.fromMap(e as Map<String, dynamic>))
            .toList(),
        packCount: data['packCount'] as int?,
        deliveryType: data['deliveryType'] as String?,
        storeMessage: data['storeMessage'] as String?,
        status: data['status'] as String?,
        statusHistory: (data['statusHistory'] as List<dynamic>?)
            ?.map((e) => StatusHistory.fromMap(e as Map<String, dynamic>))
            .toList(),
        payment: data['payment'] == null
            ? null
            : Payment.fromMap(data['payment'] as Map<String, dynamic>),
        orderPlacedAt: data['orderPlacedAt'] == null
            ? null
            : DateTime.parse(data['orderPlacedAt'] as String),
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'deliveryLocation': deliveryLocation?.toMap(),
        'orderNumber': orderNumber,
        'orderType': orderType,
        'user': user?.toMap(),
        'shop': shop?.toMap(),
        'store': store, // Changed back to just store (not store?.toMap())
        'items': items?.map((e) => e.toMap()).toList(),
        'packCount': packCount,
        'deliveryType': deliveryType,
        'storeMessage': storeMessage,
        'status': status,
        'statusHistory': statusHistory?.map((e) => e.toJson()).toList(),
        'payment': payment?.toMap(),
        'orderPlacedAt': orderPlacedAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Result].
  factory OrderResult.fromJson(String data) {
    return OrderResult.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Result] to a JSON string.
  String toJson() => json.encode(toMap());

  OrderResult copyWith({
    DeliveryLocation? deliveryLocation,
    String? orderNumber,
    String? orderType,
    User? user,
    Shop? shop,
    String? store, // Changed back to String?
    List<Item>? items,
    int? packCount,
    String? deliveryType,
    String? storeMessage,
    String? status,
    List<StatusHistory>? statusHistory,
    Payment? payment,
    DateTime? orderPlacedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) {
    return OrderResult(
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      orderNumber: orderNumber ?? this.orderNumber,
      user: user ?? this.user,
      shop: shop ?? this.shop,
      orderType: orderType ?? this.orderType,
      store: store ?? this.store,
      items: items ?? this.items,
      packCount: packCount ?? this.packCount,
      deliveryType: deliveryType ?? this.deliveryType,
      storeMessage: storeMessage ?? this.storeMessage,
      status: status ?? this.status,
      statusHistory: statusHistory ?? this.statusHistory,
      payment: payment ?? this.payment,
      orderPlacedAt: orderPlacedAt ?? this.orderPlacedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
    );
  }
}
