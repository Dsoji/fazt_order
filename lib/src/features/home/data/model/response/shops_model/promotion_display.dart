import 'dart:convert';

class PromotionDisplay {
  bool? hasActivePromotion;
  bool? freeDelivery;
  num? discountPercent;
  num? maxDiscountAmount;

  /// Ready-made badge text, e.g. `20% OFF + FREE DELIVERY`.
  /// Only returned by the discounted meals endpoint.
  String? tag;

  PromotionDisplay({
    this.hasActivePromotion,
    this.freeDelivery,
    this.discountPercent,
    this.maxDiscountAmount,
    this.tag,
  });

  @override
  String toString() {
    return 'PromotionDisplay(hasActivePromotion: $hasActivePromotion, freeDelivery: $freeDelivery, discountPercent: $discountPercent, maxDiscountAmount: $maxDiscountAmount, tag: $tag)';
  }

  factory PromotionDisplay.fromMap(Map<String, dynamic> data) =>
      PromotionDisplay(
        hasActivePromotion: data['hasActivePromotion'] as bool?,
        freeDelivery: data['freeDelivery'] as bool?,
        discountPercent: data['discountPercent'] as num?,
        maxDiscountAmount: data['maxDiscountAmount'] as num?,
        tag: data['tag'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'hasActivePromotion': hasActivePromotion,
        'freeDelivery': freeDelivery,
        'discountPercent': discountPercent,
        'maxDiscountAmount': maxDiscountAmount,
        'tag': tag,
      };

  factory PromotionDisplay.fromJson(String data) {
    return PromotionDisplay.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  PromotionDisplay copyWith({
    bool? hasActivePromotion,
    bool? freeDelivery,
    num? discountPercent,
    num? maxDiscountAmount,
    String? tag,
  }) {
    return PromotionDisplay(
      hasActivePromotion: hasActivePromotion ?? this.hasActivePromotion,
      freeDelivery: freeDelivery ?? this.freeDelivery,
      discountPercent: discountPercent ?? this.discountPercent,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      tag: tag ?? this.tag,
    );
  }
}
