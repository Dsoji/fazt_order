import 'dart:convert';

import 'category.dart';
import 'option_group.dart';

class Result {
  Category? category;
  String? mealName;
  String? mealDescription;
  String? mealImage;
  int? price;
  String? priceDescription;
  List<OptionGroup>? optionGroup;
  String? store;
  String? shop;
  int? numberOfFavorites;
  bool? inStock;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  Result({
    this.category,
    this.mealName,
    this.mealDescription,
    this.mealImage,
    this.price,
    this.priceDescription,
    this.optionGroup,
    this.store,
    this.shop,
    this.numberOfFavorites,
    this.inStock,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  @override
  String toString() {
    return 'Result(category: $category, mealName: $mealName, mealDescription: $mealDescription, mealImage: $mealImage, price: $price, priceDescription: $priceDescription, optionGroup: $optionGroup, store: $store, shop: $shop, numberOfFavorites: $numberOfFavorites, inStock: $inStock, createdAt: $createdAt, updatedAt: $updatedAt, id: $id)';
  }

  factory Result.fromMap(Map<String, dynamic> data) => Result(
        category: data['category'] == null
            ? null
            : Category.fromMap(data['category'] as Map<String, dynamic>),
        mealName: data['mealName'] as String?,
        mealDescription: data['mealDescription'] as String?,
        mealImage: data['mealImage'] as String?,
        price: data['price'] as int?,
        priceDescription: data['priceDescription'] as String?,
        optionGroup: (data['optionGroup'] as List<dynamic>?)
            ?.map((e) => OptionGroup.fromMap(e as Map<String, dynamic>))
            .toList(),
        store: data['store'] as String?,
        shop: data['shop'] as String?,
        numberOfFavorites: data['numberOfFavorites'] as int?,
        inStock: data['inStock'] as bool?,
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'category': category?.toMap(),
        'mealName': mealName,
        'mealDescription': mealDescription,
        'mealImage': mealImage,
        'price': price,
        'priceDescription': priceDescription,
        'optionGroup': optionGroup?.map((e) => e.toMap()).toList(),
        'store': store,
        'shop': shop,
        'numberOfFavorites': numberOfFavorites,
        'inStock': inStock,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'id': id,
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
    Category? category,
    String? mealName,
    String? mealDescription,
    String? mealImage,
    int? price,
    String? priceDescription,
    List<OptionGroup>? optionGroup,
    String? store,
    String? shop,
    int? numberOfFavorites,
    bool? inStock,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) {
    return Result(
      category: category ?? this.category,
      mealName: mealName ?? this.mealName,
      mealDescription: mealDescription ?? this.mealDescription,
      mealImage: mealImage ?? this.mealImage,
      price: price ?? this.price,
      priceDescription: priceDescription ?? this.priceDescription,
      optionGroup: optionGroup ?? this.optionGroup,
      store: store ?? this.store,
      shop: shop ?? this.shop,
      numberOfFavorites: numberOfFavorites ?? this.numberOfFavorites,
      inStock: inStock ?? this.inStock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
    );
  }
}
