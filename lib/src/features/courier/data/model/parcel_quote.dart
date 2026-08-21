import 'dart:convert';

/// What a parcel delivery will actually cost, from `POST /parcels/quote`.
///
/// Priced before the user commits so the payable total can be shown up front,
/// promotion included. The same shape comes back alongside the created parcel
/// on `POST /parcels`, so a request always carries the exact price it was made
/// under.
class ParcelQuote {
  /// Kilometres between pickup and delivery. Computed server-side unless the
  /// client already knew it and sent it along.
  final num? distance;

  /// Delivery before any discount. [payableDeliveryFee] is what gets charged.
  final num? deliveryFee;
  final num? serviceFee;

  /// Total before any discount.
  final num? originalTotalPrice;
  final num? discount;
  final num? freeDeliverySubsidy;

  /// What is actually charged for delivery.
  final num? payableDeliveryFee;

  /// What is actually charged in total. This is the number to show as the
  /// amount payable and the one the backend re-verifies at payment time.
  final num? totalPrice;

  final String? promotionRuleId;
  final String? promotionScope;
  final bool hasPromotion;
  final String? promoCodeStatus;
  final String? appliedPromoCode;
  final String? promoCodeError;

  const ParcelQuote({
    this.distance,
    this.deliveryFee,
    this.serviceFee,
    this.originalTotalPrice,
    this.discount,
    this.freeDeliverySubsidy,
    this.payableDeliveryFee,
    this.totalPrice,
    this.promotionRuleId,
    this.promotionScope,
    this.hasPromotion = false,
    this.promoCodeStatus,
    this.appliedPromoCode,
    this.promoCodeError,
  });

  /// Whether there is a saving worth putting on screen — a struck-through
  /// original beside the payable total only makes sense when the two differ.
  bool get hasDiscount => (discount ?? 0) > 0;

  factory ParcelQuote.fromMap(Map<String, dynamic> data) => ParcelQuote(
        distance: data['distance'] as num?,
        deliveryFee: data['deliveryFee'] as num?,
        serviceFee: data['serviceFee'] as num?,
        originalTotalPrice: data['originalTotalPrice'] as num?,
        discount: data['discount'] as num?,
        freeDeliverySubsidy: data['freeDeliverySubsidy'] as num?,
        payableDeliveryFee: data['payableDeliveryFee'] as num?,
        totalPrice: data['totalPrice'] as num?,
        promotionRuleId: data['promotionRuleId'] as String?,
        promotionScope: data['promotionScope'] as String?,
        hasPromotion: data['hasPromotion'] as bool? ?? false,
        promoCodeStatus: data['promoCodeStatus'] as String?,
        appliedPromoCode: data['appliedPromoCode'] as String?,
        promoCodeError: data['promoCodeError'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'distance': distance,
        'deliveryFee': deliveryFee,
        'serviceFee': serviceFee,
        'originalTotalPrice': originalTotalPrice,
        'discount': discount,
        'freeDeliverySubsidy': freeDeliverySubsidy,
        'payableDeliveryFee': payableDeliveryFee,
        'totalPrice': totalPrice,
        'promotionRuleId': promotionRuleId,
        'promotionScope': promotionScope,
        'hasPromotion': hasPromotion,
        'promoCodeStatus': promoCodeStatus,
        'appliedPromoCode': appliedPromoCode,
        'promoCodeError': promoCodeError,
      };

  factory ParcelQuote.fromJson(String data) =>
      ParcelQuote.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  ParcelQuote copyWith({
    num? distance,
    num? deliveryFee,
    num? serviceFee,
    num? originalTotalPrice,
    num? discount,
    num? freeDeliverySubsidy,
    num? payableDeliveryFee,
    num? totalPrice,
    String? promotionRuleId,
    String? promotionScope,
    bool? hasPromotion,
    String? promoCodeStatus,
    String? appliedPromoCode,
    String? promoCodeError,
  }) =>
      ParcelQuote(
        distance: distance ?? this.distance,
        deliveryFee: deliveryFee ?? this.deliveryFee,
        serviceFee: serviceFee ?? this.serviceFee,
        originalTotalPrice: originalTotalPrice ?? this.originalTotalPrice,
        discount: discount ?? this.discount,
        freeDeliverySubsidy: freeDeliverySubsidy ?? this.freeDeliverySubsidy,
        payableDeliveryFee: payableDeliveryFee ?? this.payableDeliveryFee,
        totalPrice: totalPrice ?? this.totalPrice,
        promotionRuleId: promotionRuleId ?? this.promotionRuleId,
        promotionScope: promotionScope ?? this.promotionScope,
        hasPromotion: hasPromotion ?? this.hasPromotion,
        promoCodeStatus: promoCodeStatus ?? this.promoCodeStatus,
        appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
        promoCodeError: promoCodeError ?? this.promoCodeError,
      );

  @override
  String toString() => 'ParcelQuote(totalPrice: $totalPrice, discount: '
      '$discount, hasPromotion: $hasPromotion)';
}

/// The Courier section's promotion badge, from `GET /parcels/promotion` and
/// carried alongside every quote.
///
/// [tag] arrives pre-formatted — `"20% OFF"`, `"₦1,000 OFF"`, `"FREE DELIVERY"`
/// — and is rendered as-is.
///
/// **Never price from this.** It is display-only and cannot move money; the
/// charged amount always comes from the quote, and is re-verified server-side
/// at payment time.
class ParcelPromotion {
  final bool hasActivePromotion;
  final String? tag;

  const ParcelPromotion({this.hasActivePromotion = false, this.tag});

  static const ParcelPromotion none = ParcelPromotion();

  /// Whether the badge has anything to render. An active promotion with no tag
  /// text is nothing to show.
  bool get hasBadge => hasActivePromotion && (tag ?? '').trim().isNotEmpty;

  factory ParcelPromotion.fromMap(Map<String, dynamic> data) => ParcelPromotion(
        hasActivePromotion: data['hasActivePromotion'] as bool? ?? false,
        tag: data['tag'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'hasActivePromotion': hasActivePromotion,
        'tag': tag,
      };

  factory ParcelPromotion.fromJson(String data) =>
      ParcelPromotion.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  ParcelPromotion copyWith({bool? hasActivePromotion, String? tag}) =>
      ParcelPromotion(
        hasActivePromotion: hasActivePromotion ?? this.hasActivePromotion,
        tag: tag ?? this.tag,
      );

  @override
  String toString() =>
      'ParcelPromotion(hasActivePromotion: $hasActivePromotion, tag: $tag)';
}

/// `POST /parcels/quote` — a price plus the badge that explains it.
class ParcelQuoteResponse {
  final ParcelQuote? quote;
  final ParcelPromotion? promotion;

  const ParcelQuoteResponse({this.quote, this.promotion});

  factory ParcelQuoteResponse.fromMap(Map<String, dynamic> data) =>
      ParcelQuoteResponse(
        quote: data['quote'] is Map<String, dynamic>
            ? ParcelQuote.fromMap(data['quote'] as Map<String, dynamic>)
            : null,
        promotion: data['promotion'] is Map<String, dynamic>
            ? ParcelPromotion.fromMap(
                data['promotion'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'quote': quote?.toMap(),
        'promotion': promotion?.toMap(),
      };

  factory ParcelQuoteResponse.fromJson(String data) =>
      ParcelQuoteResponse.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  ParcelQuoteResponse copyWith({
    ParcelQuote? quote,
    ParcelPromotion? promotion,
  }) =>
      ParcelQuoteResponse(
        quote: quote ?? this.quote,
        promotion: promotion ?? this.promotion,
      );
}
