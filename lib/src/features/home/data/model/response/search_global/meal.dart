import 'dart:convert';

import 'package:fazt_order/src/features/home/data/model/response/search_global/mealls.dart';

import 'shop.dart';
import 'store.dart';

class Meal {
  Shop? shop;
  Store? store;
  List<MealsItem>? meals;

  Meal({this.shop, this.store, this.meals});

  @override
  String toString() => 'Meal(shop: $shop, store: $store, meals: $meals)';

  factory Meal.fromMap(Map<String, dynamic> data) => Meal(
        shop: data['shop'] == null
            ? null
            : Shop.fromMap(data['shop'] as Map<String, dynamic>),
        store: data['store'] == null
            ? null
            : Store.fromMap(data['store'] as Map<String, dynamic>),
        meals: (data['meals'] as List<dynamic>?)
            ?.map((e) => MealsItem.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'shop': shop?.toMap() ?? {},
        'store': store?.toMap() ?? {},
        'meals': meals?.map((e) => e.toMap()).toList() ?? [],
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
    Shop? shop,
    Store? store,
    List<MealsItem>? meals,
  }) {
    return Meal(
      shop: shop ?? this.shop,
      store: store ?? this.store,
      meals: meals ?? this.meals,
    );
  }
}
