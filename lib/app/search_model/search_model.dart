import 'dart:convert';

import 'meal.dart';
import 'shop.dart';

class SearchModel {
  List<Shop>? shops;
  List<Meal>? meals;

  SearchModel({this.shops, this.meals});

  @override
  String toString() => 'SearchModel(shops: $shops, meals: $meals)';

  factory SearchModel.fromMap(Map<String, dynamic> data) => SearchModel(
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
  /// Parses the string and returns the resulting Json object as [SearchModel].
  factory SearchModel.fromJson(String data) {
    return SearchModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [SearchModel] to a JSON string.
  String toJson() => json.encode(toMap());

  SearchModel copyWith({
    List<Shop>? shops,
    List<Meal>? meals,
  }) {
    return SearchModel(
      shops: shops ?? this.shops,
      meals: meals ?? this.meals,
    );
  }
}
