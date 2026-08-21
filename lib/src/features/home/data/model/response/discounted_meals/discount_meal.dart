import 'dart:convert';

import '../shops_model/promotion_display.dart';
import 'discount_meal_category.dart';

/// The meal (recipe) a discounted meal-variant points at.
class DiscountMeal {
  String? id;
  String? mealName;
  String? mealImage;
  num? price;
  String? priceDescription;
  DiscountMealCategory? category;
  PromotionDisplay? promotionDisplay;

  DiscountMeal({
    this.id,
    this.mealName,
    this.mealImage,
    this.price,
    this.priceDescription,
    this.category,
    this.promotionDisplay,
  });

  @override
  String toString() {
    return 'DiscountMeal(id: $id, mealName: $mealName, mealImage: $mealImage, price: $price, priceDescription: $priceDescription, category: $category, promotionDisplay: $promotionDisplay)';
  }

  factory DiscountMeal.fromMap(Map<String, dynamic> data) => DiscountMeal(
        id: (data['id'] ?? data['_id']) as String?,
        mealName: data['mealName'] as String?,
        mealImage: data['mealImage'] as String?,
        price: data['price'] as num?,
        priceDescription: data['priceDescription'] as String?,
        category: data['category'] == null
            ? null
            : DiscountMealCategory.fromMap(
                data['category'] as Map<String, dynamic>),
        promotionDisplay: data['promotionDisplay'] == null
            ? null
            : PromotionDisplay.fromMap(
                data['promotionDisplay'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'mealName': mealName,
        'mealImage': mealImage,
        'price': price,
        'priceDescription': priceDescription,
        'category': category?.toMap(),
        'promotionDisplay': promotionDisplay?.toMap(),
      };

  factory DiscountMeal.fromJson(String data) {
    return DiscountMeal.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  DiscountMeal copyWith({
    String? id,
    String? mealName,
    String? mealImage,
    num? price,
    String? priceDescription,
    DiscountMealCategory? category,
    PromotionDisplay? promotionDisplay,
  }) {
    return DiscountMeal(
      id: id ?? this.id,
      mealName: mealName ?? this.mealName,
      mealImage: mealImage ?? this.mealImage,
      price: price ?? this.price,
      priceDescription: priceDescription ?? this.priceDescription,
      category: category ?? this.category,
      promotionDisplay: promotionDisplay ?? this.promotionDisplay,
    );
  }
}
