import 'dart:convert';

import 'item.dart';
import 'shop.dart';
import 'unavailable_item.dart';

class Cart {
  String? user;
  Shop? shop;
  List<Item>? items;
  num? subtotal;
  num? deliveryFee;
  num? payableDeliveryFee;
  num? discount;
  num? serviceFee;
  String? promoCode;
  String? promoCodeRuleId;
  String? promoCodeError;

  /// Takeaway/packaging for the whole cart. Always the sum of the items'
  /// [Item.packagingFee], and already inside [totalPrice] — render one or the
  /// other, never both added together.
  num? packagingFee;
  num? totalPrice;
  num? packCount;
  DateTime? lastUpdated;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  /// Any line with `isAvailable: false` (out of stock). Blocks checkout.
  bool? hasUnavailableItems;

  /// Lines the server removed because their meal or an add-on was deleted.
  /// Empty when there is nothing to show; can be non-empty on an empty cart.
  List<UnavailableItem>? unavailableItems;

  Cart({
    this.user,
    this.shop,
    this.items,
    this.subtotal,
    this.deliveryFee,
    this.payableDeliveryFee,
    this.discount,
    this.serviceFee,
    this.promoCode,
    this.promoCodeRuleId,
    this.promoCodeError,
    this.packagingFee,
    this.totalPrice,
    this.packCount,
    this.lastUpdated,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.hasUnavailableItems,
    this.unavailableItems,
  });

  @override
  String toString() {
    return 'Cart(user: $user, shop: $shop, items: $items, subtotal: $subtotal, deliveryFee: $deliveryFee, payableDeliveryFee: $payableDeliveryFee, discount: $discount, serviceFee: $serviceFee, packagingFee: $packagingFee, totalPrice: $totalPrice, packCount: $packCount, lastUpdated: $lastUpdated, createdAt: $createdAt, updatedAt: $updatedAt, id: $id)';
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
        payableDeliveryFee: data['payableDeliveryFee'] as num?,
        discount: data['discount'] as num?,
        serviceFee: data['serviceFee'] as num?,
        promoCode: data['promoCode'] as String?,
        promoCodeRuleId: data['promoCodeRuleId'] as String?,
        promoCodeError: data['promoCodeError'] as String?,
        packagingFee: data['packagingFee'] as num?,
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
        hasUnavailableItems: data['hasUnavailableItems'] as bool?,
        unavailableItems: (data['unavailableItems'] as List<dynamic>?)
            ?.map((e) => UnavailableItem.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'user': user,
        'shop': shop?.toMap(),
        'items': items?.map((e) => e.toMap()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'payableDeliveryFee': payableDeliveryFee,
        'discount': discount,
        'serviceFee': serviceFee,
        'promoCode': promoCode,
        'promoCodeRuleId': promoCodeRuleId,
        'promoCodeError': promoCodeError,
        'packagingFee': packagingFee,
        'totalPrice': totalPrice,
        'packCount': packCount,
        'lastUpdated': lastUpdated?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'id': id,
        'hasUnavailableItems': hasUnavailableItems,
        'unavailableItems': unavailableItems?.map((e) => e.toMap()).toList(),
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
    num? payableDeliveryFee,
    num? discount,
    num? serviceFee,
    String? promoCode,
    String? promoCodeRuleId,
    String? promoCodeError,
    num? packagingFee,
    num? totalPrice,
    num? packCount,
    DateTime? lastUpdated,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    bool? hasUnavailableItems,
    List<UnavailableItem>? unavailableItems,
  }) {
    return Cart(
      user: user ?? this.user,
      shop: shop ?? this.shop,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      payableDeliveryFee: payableDeliveryFee ?? this.payableDeliveryFee,
      discount: discount ?? this.discount,
      serviceFee: serviceFee ?? this.serviceFee,
      promoCode: promoCode ?? this.promoCode,
      promoCodeRuleId: promoCodeRuleId ?? this.promoCodeRuleId,
      promoCodeError: promoCodeError ?? this.promoCodeError,
      packagingFee: packagingFee ?? this.packagingFee,
      totalPrice: totalPrice ?? this.totalPrice,
      packCount: packCount ?? this.packCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      hasUnavailableItems: hasUnavailableItems ?? this.hasUnavailableItems,
      unavailableItems: unavailableItems ?? this.unavailableItems,
    );
  }
}
