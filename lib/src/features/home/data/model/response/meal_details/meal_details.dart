import 'dart:convert';

import 'meal_variant.dart';

class MealDetails {
  MealVariant? mealVariant;

  MealDetails({this.mealVariant});

  @override
  String toString() => 'MealDetails(mealVariant: $mealVariant)';

  factory MealDetails.fromMap(Map<String, dynamic> data) => MealDetails(
        mealVariant: data['mealVariant'] == null
            ? null
            : MealVariant.fromMap(data['mealVariant'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'mealVariant': mealVariant?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [MealDetails].
  factory MealDetails.fromJson(String data) {
    return MealDetails.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [MealDetails] to a JSON string.
  String toJson() => json.encode(toMap());

  MealDetails copyWith({
    MealVariant? mealVariant,
  }) {
    return MealDetails(
      mealVariant: mealVariant ?? this.mealVariant,
    );
  }
}
