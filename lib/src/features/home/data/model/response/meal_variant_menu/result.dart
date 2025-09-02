import 'dart:convert';

import 'meal.dart';
import 'shop.dart';

class MealVariantMenuResult {
  String? id;
  Shop? shop;
  Meal? meal;
  bool? inStock;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;

  MealVariantMenuResult({
    this.id,
    this.shop,
    this.meal,
    this.inStock,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  @override
  String toString() {
    return 'Result(id: $id, shop: $shop, meal: $meal, inStock: $inStock, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  factory MealVariantMenuResult.fromMap(Map<String, dynamic> data) =>
      MealVariantMenuResult(
        id: data['id'] as String?,
        shop: data['shop'] == null
            ? null
            : Shop.fromMap(data['shop'] as Map<String, dynamic>),
        meal: data['meal'] == null
            ? null
            : Meal.fromMap(data['meal'] as Map<String, dynamic>),
        inStock: data['inStock'] as bool?,
        notes: data['notes'] as String?,
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'shop': shop?.toMap(),
        'meal': meal?.toMap(),
        'inStock': inStock,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Result].
  factory MealVariantMenuResult.fromJson(String data) {
    return MealVariantMenuResult.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Result] to a JSON string.
  String toJson() => json.encode(toMap());

  MealVariantMenuResult copyWith({
    String? id,
    Shop? shop,
    Meal? meal,
    bool? inStock,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MealVariantMenuResult(
      id: id ?? this.id,
      shop: shop ?? this.shop,
      meal: meal ?? this.meal,
      inStock: inStock ?? this.inStock,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
