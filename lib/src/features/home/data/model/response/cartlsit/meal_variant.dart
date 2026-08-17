import 'dart:convert';

import 'meal.dart';
import 'shop.dart';

class MealVariant {
  Shop? shop;
  Meal? meal;
  bool? inStock;
  String? notes;

  /// The variant's own id, which a quantity change sends back so the backend
  /// can check it still matches the cart item before writing to it.
  String? id;

  MealVariant({this.shop, this.meal, this.inStock, this.notes, this.id});

  @override
  String toString() {
    return 'MealVariant(shop: $shop, meal: $meal, inStock: $inStock, notes: $notes, id: $id)';
  }

  factory MealVariant.fromMap(Map<String, dynamic> data) => MealVariant(
        shop: data['shop'] == null
            ? null
            : Shop.fromMap(data['shop'] as Map<String, dynamic>),
        meal: data['meal'] == null
            ? null
            : Meal.fromMap(data['meal'] as Map<String, dynamic>),
        inStock: data['inStock'] as bool?,
        notes: data['notes'] as String?,
        // The cart payload mixes conventions: subdocuments keep Mongo's
        // `_id` while populated documents are serialised with `id`. Accepting
        // either is what keeps a line addressable — without this id the row
        // loses its stepper and its way back into the meal's options.
        id: (data['_id'] ?? data['id']) as String?,
      );

  Map<String, dynamic> toMap() => {
        'shop': shop?.toMap(),
        'meal': meal?.toMap(),
        'inStock': inStock,
        'notes': notes,
        '_id': id,
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
    Shop? shop,
    Meal? meal,
    bool? inStock,
    String? notes,
    String? id,
  }) {
    return MealVariant(
      shop: shop ?? this.shop,
      meal: meal ?? this.meal,
      inStock: inStock ?? this.inStock,
      notes: notes ?? this.notes,
      id: id ?? this.id,
    );
  }
}
