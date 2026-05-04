import 'dart:convert';

class PromotionState {
  int? freeDeliveryRemaining;
  int? discountRemaining;
  bool? freeDeliveryEnabled;
  num? percentDiscount;
  num? maxDiscountAmount;

  PromotionState({
    this.freeDeliveryRemaining,
    this.discountRemaining,
    this.freeDeliveryEnabled,
    this.percentDiscount,
    this.maxDiscountAmount,
  });

  @override
  String toString() {
    return 'PromotionState(freeDeliveryRemaining: $freeDeliveryRemaining, discountRemaining: $discountRemaining, freeDeliveryEnabled: $freeDeliveryEnabled, percentDiscount: $percentDiscount, maxDiscountAmount: $maxDiscountAmount)';
  }

  factory PromotionState.fromMap(Map<String, dynamic> data) => PromotionState(
        freeDeliveryRemaining: (data['freeDeliveryRemaining'] as num?)?.toInt(),
        discountRemaining: (data['discountRemaining'] as num?)?.toInt(),
        freeDeliveryEnabled: data['freeDeliveryEnabled'] as bool?,
        percentDiscount: data['percentDiscount'] as num?,
        maxDiscountAmount: data['maxDiscountAmount'] as num?,
      );

  Map<String, dynamic> toMap() => {
        'freeDeliveryRemaining': freeDeliveryRemaining,
        'discountRemaining': discountRemaining,
        'freeDeliveryEnabled': freeDeliveryEnabled,
        'percentDiscount': percentDiscount,
        'maxDiscountAmount': maxDiscountAmount,
      };

  factory PromotionState.fromJson(String data) {
    return PromotionState.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  PromotionState copyWith({
    int? freeDeliveryRemaining,
    int? discountRemaining,
    bool? freeDeliveryEnabled,
    num? percentDiscount,
    num? maxDiscountAmount,
  }) {
    return PromotionState(
      freeDeliveryRemaining:
          freeDeliveryRemaining ?? this.freeDeliveryRemaining,
      discountRemaining: discountRemaining ?? this.discountRemaining,
      freeDeliveryEnabled: freeDeliveryEnabled ?? this.freeDeliveryEnabled,
      percentDiscount: percentDiscount ?? this.percentDiscount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
    );
  }
}
