import 'dart:convert';

class Item {
  String? item;
  int? price;
  String? shop;
  bool? inStock;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  Item({
    this.item,
    this.price,
    this.shop,
    this.inStock,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  @override
  String toString() {
    return 'Item(item: $item, price: $price, shop: $shop, inStock: $inStock, createdAt: $createdAt, updatedAt: $updatedAt, id: $id)';
  }

  factory Item.fromMap(Map<String, dynamic> data) => Item(
        item: data['item'] as String?,
        price: data['price'] as int?,
        shop: data['shop'] as String?,
        inStock: data['inStock'] as bool?,
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.parse(data['updatedAt'] as String),
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'item': item,
        'price': price,
        'shop': shop,
        'inStock': inStock,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'id': id,
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
    String? item,
    int? price,
    String? shop,
    bool? inStock,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) {
    return Item(
      item: item ?? this.item,
      price: price ?? this.price,
      shop: shop ?? this.shop,
      inStock: inStock ?? this.inStock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
    );
  }
}
