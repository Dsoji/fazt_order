import 'dart:convert';

import 'item_options.dart';
import 'meal_variant.dart';

class Item {
  MealVariant? mealVariant;
  num? mealQuantity;
  List<ItemOption>? options;
  num? packNumber;

  /// This line's share of the packaging charge — the meal's pack price times
  /// its quantity, worked out server-side. `0` (or absent, on carts written
  /// before packaging existed) means this line is never charged for packaging:
  /// a meal with option items prices its packaging into the meal.
  num? packagingFee;
  String? id;

  /// `false` when the meal variant or any option is out of stock. Absent on
  /// older payloads, which reads as available.
  bool? isAvailable;

  bool get available => isAvailable != false;

  Item({
    this.mealVariant,
    this.mealQuantity,
    this.options,
    this.packNumber,
    this.packagingFee,
    this.id,
    this.isAvailable,
  });

  @override
  String toString() {
    return 'Item(mealVariant: $mealVariant, mealQuantity: $mealQuantity, options: $options, packNumber: $packNumber, packagingFee: $packagingFee, id: $id)';
  }

  factory Item.fromMap(Map<String, dynamic> data) => Item(
        // Right after an add-to-cart this can be a bare id, not populated.
        mealVariant: data['mealVariant'] is Map<String, dynamic>
            ? MealVariant.fromMap(data['mealVariant'] as Map<String, dynamic>)
            : null,
        mealQuantity: data['mealQuantity'] as num?,
        options: (data['options'] as List<dynamic>?)
            ?.map((e) => ItemOption.fromMap(e as Map<String, dynamic>))
            .toList(),
        packNumber: data['packNumber'] as num?,
        packagingFee: data['packagingFee'] as num?,
        // The cart payload mixes conventions: subdocuments keep Mongo's
        // `_id` while populated documents are serialised with `id`. Accepting
        // either is what keeps a line addressable — without this id the row
        // loses its stepper and its way back into the meal's options.
        id: (data['_id'] ?? data['id']) as String?,
        isAvailable: data['isAvailable'] as bool?,
      );

  Map<String, dynamic> toMap() => {
        'mealVariant': mealVariant?.toMap(),
        'mealQuantity': mealQuantity,
        'options': options?.map((e) => e.toMap()).toList(),
        'packNumber': packNumber,
        'packagingFee': packagingFee,
        '_id': id,
        'isAvailable': isAvailable,
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
    num? packagingFee,
    String? id,
    bool? isAvailable,
  }) {
    return Item(
      mealVariant: mealVariant ?? this.mealVariant,
      mealQuantity: mealQuantity ?? this.mealQuantity,
      options: options ?? this.options,
      packNumber: packNumber ?? this.packNumber,
      packagingFee: packagingFee ?? this.packagingFee,
      id: id ?? this.id,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
