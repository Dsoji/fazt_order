import 'dart:convert';

import 'meal.dart';
import 'shop.dart';

class Result {
  Shop? shop;
  Meal? meal;
  bool? inStock;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;
  String? lastUpdatedBy;

  Result({
    this.shop,
    this.meal,
    this.inStock,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.id,
    this.lastUpdatedBy,
  });

  @override
  String toString() {
    return 'Result(shop: $shop, meal: $meal, inStock: $inStock, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, id: $id, lastUpdatedBy: $lastUpdatedBy)';
  }

  factory Result.fromMap(Map<String, dynamic> data) => Result(
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
        id: data['id'] as String?,
        lastUpdatedBy: data['lastUpdatedBy'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'shop': shop?.toMap(),
        'meal': meal?.toMap(),
        'inStock': inStock,
        'notes': notes,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'id': id,
        'lastUpdatedBy': lastUpdatedBy,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Result].
  factory Result.fromJson(String data) {
    return Result.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Result] to a JSON string.
  String toJson() => json.encode(toMap());

  Result copyWith({
    Shop? shop,
    Meal? meal,
    bool? inStock,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
    String? lastUpdatedBy,
  }) {
    return Result(
      shop: shop ?? this.shop,
      meal: meal ?? this.meal,
      inStock: inStock ?? this.inStock,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
    );
  }
}
