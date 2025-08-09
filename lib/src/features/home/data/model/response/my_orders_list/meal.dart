import 'dart:convert';

import 'category.dart';

class Meal {
  Category? category;
  String? mealName;
  String? mealImage;
  int? price;
  String? id;

  Meal({this.category, this.mealName, this.mealImage, this.price, this.id});

  @override
  String toString() {
    return 'Meal(category: $category, mealName: $mealName, mealImage: $mealImage, price: $price, id: $id)';
  }

  factory Meal.fromMap(Map<String, dynamic> data) => Meal(
        category: data['category'] == null
            ? null
            : Category.fromMap(data['category'] as Map<String, dynamic>),
        mealName: data['mealName'] as String?,
        mealImage: data['mealImage'] as String?,
        price: data['price'] as int?,
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'category': category?.toMap(),
        'mealName': mealName,
        'mealImage': mealImage,
        'price': price,
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
    String? mealImage,
    int? price,
    String? id,
  }) {
    return Meal(
      category: category ?? this.category,
      mealName: mealName ?? this.mealName,
      mealImage: mealImage ?? this.mealImage,
      price: price ?? this.price,
      id: id ?? this.id,
    );
  }
}
