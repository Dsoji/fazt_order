import 'dart:convert';

import 'meal.dart';
import 'shop.dart';

class SearchGlobal {
  List<Shop>? shops;
  List<Meal>? meals;

  SearchGlobal({this.shops, this.meals});

  @override
  String toString() => 'SearchGlobal(shops: $shops, meals: $meals)';

  factory SearchGlobal.fromMap(Map<String, dynamic> data) => SearchGlobal(
        shops: (data['shops'] as List<dynamic>?)
            ?.map((e) => Shop.fromMap(e as Map<String, dynamic>))
            .toList(),
        meals: (data['meals'] as List<dynamic>?)
            ?.map((e) => Meal.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'shops': shops?.map((e) => e.toMap()).toList(),
        'meals': meals?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [SearchGlobal].
  factory SearchGlobal.fromJson(String data) {
    return SearchGlobal.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [SearchGlobal] to a JSON string.
  String toJson() => json.encode(toMap());

  SearchGlobal copyWith({
    List<Shop>? shops,
    List<Meal>? meals,
  }) {
    return SearchGlobal(
      shops: shops ?? this.shops,
      meals: meals ?? this.meals,
    );
  }
}
