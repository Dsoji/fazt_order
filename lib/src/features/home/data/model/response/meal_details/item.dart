import 'dart:convert';

import 'variant.dart';

class Item {
  String? id;
  String? item;
  int? price;
  Variant? variant;

  Item({this.id, this.item, this.price, this.variant});

  @override
  String toString() {
    return 'Item(id: $id, item: $item, price: $price, variant: $variant)';
  }

  factory Item.fromMap(Map<String, dynamic> data) => Item(
        id: data['id'] as String?,
        item: data['item'] as String?,
        price: data['price'] as int?,
        variant: data['variant'] == null
            ? null
            : Variant.fromMap(data['variant'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'item': item,
        'price': price,
        'variant': variant?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Item].
  factory Item.fromJson(String data) {
    return Item.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Item] to a JSON string.
  String toJson() => json.encode(toMap());

  Item copyWith({
    String? id,
    String? item,
    int? price,
    Variant? variant,
  }) {
    return Item(
      id: id ?? this.id,
      item: item ?? this.item,
      price: price ?? this.price,
      variant: variant ?? this.variant,
    );
  }
}
