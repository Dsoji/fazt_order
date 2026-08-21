import 'dart:convert';

import '../shops_model/promotion_display.dart';

/// A store running a store-wide promotion.
class FeaturedStore {
  /// Store id — note the API returns it as `_id` here, not `id`.
  String? id;
  String? businessName;
  String? storeName;
  String? storeDisplayImage;
  num? rating;
  PromotionDisplay? promotionDisplay;

  /// Ready-made badge text, e.g. `20% OFF + FREE DELIVERY`.
  String? promotionTag;

  FeaturedStore({
    this.id,
    this.businessName,
    this.storeName,
    this.storeDisplayImage,
    this.rating,
    this.promotionDisplay,
    this.promotionTag,
  });

  @override
  String toString() {
    return 'FeaturedStore(id: $id, businessName: $businessName, storeName: $storeName, storeDisplayImage: $storeDisplayImage, rating: $rating, promotionDisplay: $promotionDisplay, promotionTag: $promotionTag)';
  }

  factory FeaturedStore.fromMap(Map<String, dynamic> data) => FeaturedStore(
        id: (data['_id'] ?? data['id']) as String?,
        businessName: data['businessName'] as String?,
        storeName: data['storeName'] as String?,
        storeDisplayImage: data['storeDisplayImage'] as String?,
        rating: data['rating'] as num?,
        promotionDisplay: data['promotionDisplay'] == null
            ? null
            : PromotionDisplay.fromMap(
                data['promotionDisplay'] as Map<String, dynamic>),
        promotionTag: data['promotionTag'] as String?,
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'businessName': businessName,
        'storeName': storeName,
        'storeDisplayImage': storeDisplayImage,
        'rating': rating,
        'promotionDisplay': promotionDisplay?.toMap(),
        'promotionTag': promotionTag,
      };

  factory FeaturedStore.fromJson(String data) {
    return FeaturedStore.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  FeaturedStore copyWith({
    String? id,
    String? businessName,
    String? storeName,
    String? storeDisplayImage,
    num? rating,
    PromotionDisplay? promotionDisplay,
    String? promotionTag,
  }) {
    return FeaturedStore(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      storeName: storeName ?? this.storeName,
      storeDisplayImage: storeDisplayImage ?? this.storeDisplayImage,
      rating: rating ?? this.rating,
      promotionDisplay: promotionDisplay ?? this.promotionDisplay,
      promotionTag: promotionTag ?? this.promotionTag,
    );
  }
}
