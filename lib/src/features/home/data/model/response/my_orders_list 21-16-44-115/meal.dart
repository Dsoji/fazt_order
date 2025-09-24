import 'dart:convert';

import 'category.dart';

class Meal {
  Category? category;
  String? mealName;
  String? mealDescription;
  String? mealImage;
  int? price;
  String? priceDescription;
  List<dynamic>? optionGroup;
  String? store;
  int? numberOfFavorites;
  String? id;

  Meal({
    this.category,
    this.mealName,
    this.mealDescription,
    this.mealImage,
    this.price,
    this.priceDescription,
    this.optionGroup,
    this.store,
    this.numberOfFavorites,
    this.id,
  });

  @override
  String toString() {
    return 'Meal(category: $category, mealName: $mealName, mealDescription: $mealDescription, mealImage: $mealImage, price: $price, priceDescription: $priceDescription, optionGroup: $optionGroup, store: $store, numberOfFavorites: $numberOfFavorites, id: $id)';
  }

  factory Meal.fromMap(Map<String, dynamic> data) => Meal(
        category: data['category'] == null
            ? null
            : Category.fromMap(data['category'] as Map<String, dynamic>),
        mealName: data['mealName'] as String?,
        mealDescription: data['mealDescription'] as String?,
        mealImage: data['mealImage'] as String?,
        price: data['price'] as int?,
        priceDescription: data['priceDescription'] as String?,
        optionGroup: data['optionGroup'] as List<dynamic>?,
        store: data['store'] as String?,
        numberOfFavorites: data['numberOfFavorites'] as int?,
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'category': category?.toMap(),
        'mealName': mealName,
        'mealDescription': mealDescription,
        'mealImage': mealImage,
        'price': price,
        'priceDescription': priceDescription,
        'optionGroup': optionGroup,
        'store': store,
        'numberOfFavorites': numberOfFavorites,
        'id': id,
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
    Category? category,
    String? mealName,
    String? mealDescription,
    String? mealImage,
    int? price,
    String? priceDescription,
    List<dynamic>? optionGroup,
    String? store,
    int? numberOfFavorites,
    String? id,
  }) {
    return Meal(
      category: category ?? this.category,
      mealName: mealName ?? this.mealName,
      mealDescription: mealDescription ?? this.mealDescription,
      mealImage: mealImage ?? this.mealImage,
      price: price ?? this.price,
      priceDescription: priceDescription ?? this.priceDescription,
      optionGroup: optionGroup ?? this.optionGroup,
      store: store ?? this.store,
      numberOfFavorites: numberOfFavorites ?? this.numberOfFavorites,
      id: id ?? this.id,
    );
  }
}
