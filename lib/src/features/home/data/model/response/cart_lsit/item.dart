import 'dart:convert';

import 'meal.dart';

class Item {
  Meal? meal;
  int? mealQuantity;
  List<dynamic>? options;
  int? packNumber;
  String? id;

  Item({
    this.meal,
    this.mealQuantity,
    this.options,
    this.packNumber,
    this.id,
  });

  @override
  String toString() {
    return 'Item(meal: $meal, mealQuantity: $mealQuantity, options: $options, packNumber: $packNumber, id: $id)';
  }

  factory Item.fromMap(Map<String, dynamic> data) => Item(
        meal: data['meal'] == null
            ? null
            : Meal.fromMap(data['meal'] as Map<String, dynamic>),
        mealQuantity: data['mealQuantity'] as int?,
        options: data['options'] as List<dynamic>?,
        packNumber: data['packNumber'] as int?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'meal': meal?.toMap(),
        'mealQuantity': mealQuantity,
        'options': options,
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
    Meal? meal,
    int? mealQuantity,
    List<dynamic>? options,
    int? packNumber,
    String? id,
  }) {
    return Item(
      meal: meal ?? this.meal,
      mealQuantity: mealQuantity ?? this.mealQuantity,
      options: options ?? this.options,
      packNumber: packNumber ?? this.packNumber,
      id: id ?? this.id,
    );
  }
}
