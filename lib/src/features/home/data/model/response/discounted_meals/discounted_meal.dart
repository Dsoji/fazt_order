import 'dart:convert';

import 'discount_meal.dart';
import 'discount_shop.dart';

/// A meal-variant (a meal as sold by one shop) that currently has an
/// active promotion.
class DiscountedMeal {
  /// Meal-variant id — this is what the cart/meal-details endpoints expect.
  String? id;
  bool? inStock;
  String? notes;
  DiscountMeal? meal;
  DiscountShop? shop;

  DiscountedMeal({
    this.id,
    this.inStock,
    this.notes,
    this.meal,
    this.shop,
  });

  @override
  String toString() {
    return 'DiscountedMeal(id: $id, inStock: $inStock, notes: $notes, meal: $meal, shop: $shop)';
  }

  factory DiscountedMeal.fromMap(Map<String, dynamic> data) => DiscountedMeal(
        id: (data['_id'] ?? data['id']) as String?,
        inStock: data['inStock'] as bool?,
        notes: data['notes'] as String?,
        meal: data['meal'] == null
            ? null
            : DiscountMeal.fromMap(data['meal'] as Map<String, dynamic>),
        shop: data['shop'] == null
            ? null
            : DiscountShop.fromMap(data['shop'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'inStock': inStock,
        'notes': notes,
        'meal': meal?.toMap(),
        'shop': shop?.toMap(),
      };

  factory DiscountedMeal.fromJson(String data) {
    return DiscountedMeal.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  DiscountedMeal copyWith({
    String? id,
    bool? inStock,
    String? notes,
    DiscountMeal? meal,
    DiscountShop? shop,
  }) {
    return DiscountedMeal(
      id: id ?? this.id,
      inStock: inStock ?? this.inStock,
      notes: notes ?? this.notes,
      meal: meal ?? this.meal,
      shop: shop ?? this.shop,
    );
  }
}
