import 'dart:convert';

import 'item.dart';
import 'shop.dart';

class Cart {
  String? user;
  Shop? shop;
  List<Item>? items;
  num? subtotal;
  num? deliveryFee;
  num? serviceFee;
  num? totalPrice;
  num? packCount;
  DateTime? lastUpdated;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  Cart({
    this.user,
    this.shop,
    this.items,
    this.subtotal,
    this.deliveryFee,
    this.serviceFee,
    this.totalPrice,
    this.packCount,
    this.lastUpdated,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  @override
  String toString() {
    return 'Cart(user: $user, shop: $shop, items: $items, subtotal: $subtotal, deliveryFee: $deliveryFee, serviceFee: $serviceFee, totalPrice: $totalPrice, packCount: $packCount, lastUpdated: $lastUpdated, createdAt: $createdAt, updatedAt: $updatedAt, id: $id)';
  }

  factory Cart.fromMap(Map<String, dynamic> data) => Cart(
        user: data['user'] as String?,
        shop: data['shop'] == null
            ? null
            : Shop.fromMap(data['shop'] as Map<String, dynamic>),
        items: (data['items'] as List<dynamic>?)
            ?.map((e) => Item.fromMap(e as Map<String, dynamic>))
            .toList(),
        subtotal: data['subtotal'] as num?,
        deliveryFee: data['deliveryFee'] as num?,
        serviceFee: data['serviceFee'] as num?,
        totalPrice: data['totalPrice'] as num?,
        packCount: data['packCount'] as num?,
        lastUpdated: data['lastUpdated'] == null
            ? null
            : DateTime.parse(data['lastUpdated'] as String),
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'user': user,
        'shop': shop?.toMap(),
        'items': items?.map((e) => e.toMap()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'serviceFee': serviceFee,
        'totalPrice': totalPrice,
        'packCount': packCount,
        'lastUpdated': lastUpdated?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Cart].
  factory Cart.fromJson(String data) {
    return Cart.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Cart] to a JSON string.
  String toJson() => json.encode(toMap());

  Cart copyWith({
    String? user,
    Shop? shop,
    List<Item>? items,
    num? subtotal,
    num? deliveryFee,
    num? serviceFee,
    num? totalPrice,
    num? packCount,
    DateTime? lastUpdated,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) {
    return Cart(
      user: user ?? this.user,
      shop: shop ?? this.shop,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      totalPrice: totalPrice ?? this.totalPrice,
      packCount: packCount ?? this.packCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
    );
  }
}
