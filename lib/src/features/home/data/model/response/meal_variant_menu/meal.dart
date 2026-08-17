import 'dart:convert';

import '../shops_model/promotion_display.dart';
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
  String? store;

  /// Only present while the meal is running a promotion; null otherwise.
  PromotionDisplay? promotionDisplay;

  Meal({
    this.id,
    this.mealName,
    this.mealDescription,
    this.mealImage,
    this.price,
    this.priceDescription,
    this.category,
    this.optionGroup,
    this.store,
    this.promotionDisplay,
  });

  @override
  String toString() {
    return 'Meal(id: $id, mealName: $mealName, mealDescription: $mealDescription, mealImage: $mealImage, price: $price, priceDescription: $priceDescription, category: $category, optionGroup: $optionGroup, store: $store, promotionDisplay: $promotionDisplay)';
  }

  /// Endpoints disagree on how deeply a meal is populated: the menu returns
  /// `category` and `optionGroup` as full documents, while others (the pack
  /// add-options endpoint, for one) leave them as bare id strings. Both shapes
  /// are read here so a thinner payload degrades to an id instead of throwing.
  factory Meal.fromMap(Map<String, dynamic> data) => Meal(
        id: (data['id'] ?? data['_id']) as String?,
        mealName: data['mealName'] as String?,
        mealDescription: data['mealDescription'] as String?,
        mealImage: data['mealImage'] as String?,
        price: (data['price'] as num?)?.toInt(),
        priceDescription: data['priceDescription'] as String?,
        category: _categoryFrom(data['category']),
        optionGroup: data['optionGroup'] is List
            ? (data['optionGroup'] as List<dynamic>)
                .map(_optionGroupFrom)
                .whereType<OptionGroup>()
                .toList()
            : null,
        store: data['store'] as String?,
        promotionDisplay: data['promotionDisplay'] is Map<String, dynamic>
            ? PromotionDisplay.fromMap(
                data['promotionDisplay'] as Map<String, dynamic>)
            : null,
      );

  static Category? _categoryFrom(dynamic value) => switch (value) {
        Map<String, dynamic> map => Category.fromMap(map),
        String id => Category(id: id),
        _ => null,
      };

  static OptionGroup? _optionGroupFrom(dynamic value) => switch (value) {
        Map<String, dynamic> map => OptionGroup.fromMap(map),
        String id => OptionGroup(id: id),
        _ => null,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'mealName': mealName,
        'mealDescription': mealDescription,
        'mealImage': mealImage,
        'price': price,
        'priceDescription': priceDescription,
        'category': category?.toMap(),
        'optionGroup': optionGroup,
        'store': store,
        'promotionDisplay': promotionDisplay?.toMap(),
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
    String? store,
    PromotionDisplay? promotionDisplay,
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
      store: store ?? this.store,
      promotionDisplay: promotionDisplay ?? this.promotionDisplay,
    );
  }
}
