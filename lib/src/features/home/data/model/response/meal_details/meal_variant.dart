import 'dart:convert';

import 'meal.dart';
import 'shop.dart';

class MealVariant {
  String? id;
  bool? inStock;
  String? notes;
  Shop? shop;
  Meal? meal;

  MealVariant({this.id, this.inStock, this.notes, this.shop, this.meal});

  @override
  String toString() {
    return 'MealVariant(id: $id, inStock: $inStock, notes: $notes, shop: $shop, meal: $meal)';
  }

  factory MealVariant.fromMap(Map<String, dynamic> data) => MealVariant(
        id: data['id'] as String?,
        inStock: data['inStock'] as bool?,
        notes: data['notes'] as String?,
        shop: data['shop'] == null
            ? null
            : Shop.fromMap(data['shop'] as Map<String, dynamic>),
        meal: data['meal'] == null
            ? null
            : Meal.fromMap(data['meal'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'inStock': inStock,
        'notes': notes,
        'shop': shop?.toMap(),
        'meal': meal?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [MealVariant].
  factory MealVariant.fromJson(String data) {
    return MealVariant.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [MealVariant] to a JSON string.
  String toJson() => json.encode(toMap());

  MealVariant copyWith({
    String? id,
    bool? inStock,
    String? notes,
    Shop? shop,
    Meal? meal,
  }) {
    return MealVariant(
      id: id ?? this.id,
      inStock: inStock ?? this.inStock,
      notes: notes ?? this.notes,
      shop: shop ?? this.shop,
      meal: meal ?? this.meal,
    );
  }
}
