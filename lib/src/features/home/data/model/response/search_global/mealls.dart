import 'dart:convert';

class MealsItem {
  String? id;
  String? mealName;
  num? price;
  String? mealImage;
  bool? inStock;
  String? variantId;

  MealsItem({
    this.id,
    this.mealName,
    this.price,
    this.mealImage,
    this.inStock,
    this.variantId,
  });

  @override
  String toString() =>
      'MealsItem(id: $id, mealName: $mealName, price: $price, mealImage: $mealImage, inStock: $inStock, variantId: $variantId)';

  factory MealsItem.fromMap(Map<String, dynamic> data) => MealsItem(
        id: data['_id'] as String?,
        mealName: data['mealName'] as String?,
        price: data['price'] as num?,
        mealImage: data['mealImage'] as String?,
        inStock: data['inStock'] as bool?,
        variantId: data['variantId'] as String?,
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'mealName': mealName,
        'price': price,
        'mealImage': mealImage,
        'inStock': inStock,
        'variantId': variantId,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [MealsItem].
  factory MealsItem.fromJson(String data) {
    return MealsItem.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [MealsItem] to a JSON string.
  String toJson() => json.encode(toMap());

  MealsItem copyWith({
    String? id,
    String? mealName,
    num? price,
    String? mealImage,
    bool? inStock,
    String? variantId,
  }) {
    return MealsItem(
      id: id ?? this.id,
      mealName: mealName ?? this.mealName,
      price: price ?? this.price,
      mealImage: mealImage ?? this.mealImage,
      inStock: inStock ?? this.inStock,
      variantId: variantId ?? this.variantId,
    );
  }
}
