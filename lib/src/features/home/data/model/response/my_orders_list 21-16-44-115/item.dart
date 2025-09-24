import 'dart:convert';

import 'meal_variant.dart';

class Item {
  MealVariant? mealVariant;
  int? mealQuantity;
  List<dynamic>? options;
  int? packNumber;
  int? itemPrice;
  int? cachedMealPrice;
  List<dynamic>? cachedOptionPrices;
  String? id;

  Item({
    this.mealVariant,
    this.mealQuantity,
    this.options,
    this.packNumber,
    this.itemPrice,
    this.cachedMealPrice,
    this.cachedOptionPrices,
    this.id,
  });

  @override
  String toString() {
    return 'Item(mealVariant: $mealVariant, mealQuantity: $mealQuantity, options: $options, packNumber: $packNumber, itemPrice: $itemPrice, cachedMealPrice: $cachedMealPrice, cachedOptionPrices: $cachedOptionPrices, id: $id)';
  }

  factory Item.fromMap(Map<String, dynamic> data) => Item(
        mealVariant: data['mealVariant'] == null
            ? null
            : MealVariant.fromMap(data['mealVariant'] as Map<String, dynamic>),
        mealQuantity: data['mealQuantity'] as int?,
        options: data['options'] as List<dynamic>?,
        packNumber: data['packNumber'] as int?,
        itemPrice: data['itemPrice'] as int?,
        cachedMealPrice: data['cachedMealPrice'] as int?,
        cachedOptionPrices: data['cachedOptionPrices'] as List<dynamic>?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'mealVariant': mealVariant?.toMap(),
        'mealQuantity': mealQuantity,
        'options': options,
        'packNumber': packNumber,
        'itemPrice': itemPrice,
        'cachedMealPrice': cachedMealPrice,
        'cachedOptionPrices': cachedOptionPrices,
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
    int? mealQuantity,
    List<dynamic>? options,
    int? packNumber,
    int? itemPrice,
    int? cachedMealPrice,
    List<dynamic>? cachedOptionPrices,
    String? id,
  }) {
    return Item(
      mealVariant: mealVariant ?? this.mealVariant,
      mealQuantity: mealQuantity ?? this.mealQuantity,
      options: options ?? this.options,
      packNumber: packNumber ?? this.packNumber,
      itemPrice: itemPrice ?? this.itemPrice,
      cachedMealPrice: cachedMealPrice ?? this.cachedMealPrice,
      cachedOptionPrices: cachedOptionPrices ?? this.cachedOptionPrices,
      id: id ?? this.id,
    );
  }
}
