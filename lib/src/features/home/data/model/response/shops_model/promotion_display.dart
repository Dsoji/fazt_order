import 'dart:convert';

class PromotionDisplay {
  bool? hasActivePromotion;
  bool? freeDelivery;
  num? discountPercent;
  num? maxDiscountAmount;

  PromotionDisplay({
    this.hasActivePromotion,
    this.freeDelivery,
    this.discountPercent,
    this.maxDiscountAmount,
  });

  @override
  String toString() {
    return 'PromotionDisplay(hasActivePromotion: $hasActivePromotion, freeDelivery: $freeDelivery, discountPercent: $discountPercent, maxDiscountAmount: $maxDiscountAmount)';
  }

  factory PromotionDisplay.fromMap(Map<String, dynamic> data) =>
      PromotionDisplay(
        hasActivePromotion: data['hasActivePromotion'] as bool?,
        freeDelivery: data['freeDelivery'] as bool?,
        discountPercent: data['discountPercent'] as num?,
        maxDiscountAmount: data['maxDiscountAmount'] as num?,
      );

  Map<String, dynamic> toMap() => {
        'hasActivePromotion': hasActivePromotion,
        'freeDelivery': freeDelivery,
        'discountPercent': discountPercent,
        'maxDiscountAmount': maxDiscountAmount,
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
  }) {
    return PromotionDisplay(
      hasActivePromotion: hasActivePromotion ?? this.hasActivePromotion,
      freeDelivery: freeDelivery ?? this.freeDelivery,
      discountPercent: discountPercent ?? this.discountPercent,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
    );
  }
}
