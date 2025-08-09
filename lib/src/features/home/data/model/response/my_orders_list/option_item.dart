import 'dart:convert';

class OptionItem {
  String? item;
  int? price;
  String? id;

  OptionItem({this.item, this.price, this.id});

  @override
  String toString() => 'OptionItem(item: $item, price: $price, id: $id)';

  factory OptionItem.fromMap(Map<String, dynamic> data) => OptionItem(
        item: data['item'] as String?,
        price: data['price'] as int?,
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'item': item,
        'price': price,
        'id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [OptionItem].
  factory OptionItem.fromJson(String data) {
    return OptionItem.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [OptionItem] to a JSON string.
  String toJson() => json.encode(toMap());

  OptionItem copyWith({
    String? item,
    int? price,
    String? id,
  }) {
    return OptionItem(
      item: item ?? this.item,
      price: price ?? this.price,
      id: id ?? this.id,
    );
  }
}
