import 'dart:convert';

import 'category.dart';
import 'option_group.dart';

class Meal {
  String? id;
  String? mealName;
  String? mealDescription;
  String? mealImage;
  int? price;
  String? priceDescription;
  Category? category;
  List<OptionGroup>? optionGroup;

  Meal({
    this.id,
    this.mealName,
    this.mealDescription,
    this.mealImage,
    this.price,
    this.priceDescription,
    this.category,
    this.optionGroup,
  });

  @override
  String toString() {
    return 'Meal(id: $id, mealName: $mealName, mealDescription: $mealDescription, mealImage: $mealImage, price: $price, priceDescription: $priceDescription, category: $category, optionGroup: $optionGroup)';
  }

  factory Meal.fromMap(Map<String, dynamic> data) => Meal(
        id: data['id'] as String?,
        mealName: data['mealName'] as String?,
        mealDescription: data['mealDescription'] as String?,
        mealImage: data['mealImage'] as String?,
        price: data['price'] as int?,
        priceDescription: data['priceDescription'] as String?,
        category: data['category'] == null
            ? null
            : Category.fromMap(data['category'] as Map<String, dynamic>),
        optionGroup: (data['optionGroup'] as List<dynamic>?)
            ?.map((e) => OptionGroup.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'mealName': mealName,
        'mealDescription': mealDescription,
        'mealImage': mealImage,
        'price': price,
        'priceDescription': priceDescription,
        'category': category?.toMap(),
        'optionGroup': optionGroup?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Meal].
  factory Meal.fromJson(String data) {
    return Meal.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Meal] to a JSON string.
  String toJson() => json.encode(toMap());

  Meal copyWith({
    String? id,
    String? mealName,
    String? mealDescription,
    String? mealImage,
    int? price,
    String? priceDescription,
    Category? category,
    List<OptionGroup>? optionGroup,
  }) {
    return Meal(
      id: id ?? this.id,
      mealName: mealName ?? this.mealName,
      mealDescription: mealDescription ?? this.mealDescription,
      mealImage: mealImage ?? this.mealImage,
      price: price ?? this.price,
      priceDescription: priceDescription ?? this.priceDescription,
      category: category ?? this.category,
      optionGroup: optionGroup ?? this.optionGroup,
    );
  }
}
