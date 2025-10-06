import 'dart:convert';

class ItemOption {
  OptionItemVariant? optionItemVariant;
  int? quantity;

  ItemOption({
    this.optionItemVariant,
    this.quantity,
  });

  @override
  String toString() {
    return 'ItemOption(optionItemVariant: $optionItemVariant, quantity: $quantity)';
  }

  factory ItemOption.fromMap(Map<String, dynamic> data) => ItemOption(
        optionItemVariant: data['optionItemVariant'] == null
            ? null
            : OptionItemVariant.fromMap(
                data['optionItemVariant'] as Map<String, dynamic>),
        quantity: data['quantity'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'optionItemVariant': optionItemVariant?.toMap(),
        'quantity': quantity,
      };

  factory ItemOption.fromJson(String data) {
    return ItemOption.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  ItemOption copyWith({
    OptionItemVariant? optionItemVariant,
    int? quantity,
  }) {
    return ItemOption(
      optionItemVariant: optionItemVariant ?? this.optionItemVariant,
      quantity: quantity ?? this.quantity,
    );
  }
}

class OptionItemVariant {
  OptionItem? optionItem;
  bool? inStock;
  String? notes;
  String? id;

  OptionItemVariant({
    this.optionItem,
    this.inStock,
    this.notes,
    this.id,
  });

  @override
  String toString() {
    return 'OptionItemVariant(optionItem: $optionItem, inStock: $inStock, notes: $notes, id: $id)';
  }

  factory OptionItemVariant.fromMap(Map<String, dynamic> data) =>
      OptionItemVariant(
        optionItem: data['optionItem'] == null
            ? null
            : OptionItem.fromMap(data['optionItem'] as Map<String, dynamic>),
        inStock: data['inStock'] as bool?,
        notes: data['notes'] as String?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'optionItem': optionItem?.toMap(),
        'inStock': inStock,
        'notes': notes,
        '_id': id,
      };

  factory OptionItemVariant.fromJson(String data) {
    return OptionItemVariant.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  OptionItemVariant copyWith({
    OptionItem? optionItem,
    bool? inStock,
    String? notes,
    String? id,
  }) {
    return OptionItemVariant(
      optionItem: optionItem ?? this.optionItem,
      inStock: inStock ?? this.inStock,
      notes: notes ?? this.notes,
      id: id ?? this.id,
    );
  }
}

class OptionItem {
  String? item;
  int? price;
  String? store;
  String? id;

  OptionItem({
    this.item,
    this.price,
    this.store,
    this.id,
  });

  @override
  String toString() {
    return 'OptionItem(item: $item, price: $price, store: $store, id: $id)';
  }

  factory OptionItem.fromMap(Map<String, dynamic> data) => OptionItem(
        item: data['item'] as String?,
        price: data['price'] as int?,
        store: data['store'] as String?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'item': item,
        'price': price,
        'store': store,
        '_id': id,
      };

  factory OptionItem.fromJson(String data) {
    return OptionItem.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  OptionItem copyWith({
    String? item,
    int? price,
    String? store,
    String? id,
  }) {
    return OptionItem(
      item: item ?? this.item,
      price: price ?? this.price,
      store: store ?? this.store,
      id: id ?? this.id,
    );
  }
}
