import 'dart:convert';

import 'item_options.dart';
import 'meal_variant.dart';

class Item {
  MealVariant? mealVariant;
  num? mealQuantity;
  List<ItemOption>? options;
  num? packNumber;
  String? id;

  Item({
    this.mealVariant,
    this.mealQuantity,
    this.options,
    this.packNumber,
    this.id,
  });

  @override
  String toString() {
    return 'Item(mealVariant: $mealVariant, mealQuantity: $mealQuantity, options: $options, packNumber: $packNumber, id: $id)';
  }

  factory Item.fromMap(Map<String, dynamic> data) => Item(
        mealVariant: data['mealVariant'] == null
            ? null
            : MealVariant.fromMap(data['mealVariant'] as Map<String, dynamic>),
        mealQuantity: data['mealQuantity'] as num?,
        options: (data['options'] as List<dynamic>?)
            ?.map((e) => ItemOption.fromMap(e as Map<String, dynamic>))
            .toList(),
        packNumber: data['packNumber'] as num?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'mealVariant': mealVariant?.toMap(),
        'mealQuantity': mealQuantity,
        'options': options?.map((e) => e.toMap()).toList(),
        'packNumber': packNumber,
        '_id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Item].
  factory Item.fromJson(String data) {
    return Item.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Item] to a JSON string.
  String toJson() => json.encode(toMap());

  Item copyWith({
    MealVariant? mealVariant,
    num? mealQuantity,
    List<ItemOption>? options,
    num? packNumber,
    String? id,
  }) {
    return Item(
      mealVariant: mealVariant ?? this.mealVariant,
      mealQuantity: mealQuantity ?? this.mealQuantity,
      options: options ?? this.options,
      packNumber: packNumber ?? this.packNumber,
      id: id ?? this.id,
    );
  }
}
