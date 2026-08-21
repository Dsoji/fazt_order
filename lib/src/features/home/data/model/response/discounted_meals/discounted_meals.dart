import 'dart:convert';

import 'discounted_meal.dart';

/// `data` of `GET /v1/enhanced-meals/discounted`.
class DiscountedMeals {
  List<DiscountedMeal>? meals;
  int? total;
  Map<String, dynamic>? filters;

  DiscountedMeals({this.meals, this.total, this.filters});

  @override
  String toString() {
    return 'DiscountedMeals(meals: $meals, total: $total, filters: $filters)';
  }

  factory DiscountedMeals.fromMap(Map<String, dynamic> data) => DiscountedMeals(
        meals: (data['meals'] as List<dynamic>?)
            ?.map((e) => DiscountedMeal.fromMap(e as Map<String, dynamic>))
            .toList(),
        total: data['total'] as int?,
        filters: data['filters'] as Map<String, dynamic>?,
      );

  Map<String, dynamic> toMap() => {
        'meals': meals?.map((e) => e.toMap()).toList(),
        'total': total,
        'filters': filters,
      };

  factory DiscountedMeals.fromJson(String data) {
    return DiscountedMeals.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  DiscountedMeals copyWith({
    List<DiscountedMeal>? meals,
    int? total,
    Map<String, dynamic>? filters,
  }) {
    return DiscountedMeals(
      meals: meals ?? this.meals,
      total: total ?? this.total,
      filters: filters ?? this.filters,
    );
  }
}
