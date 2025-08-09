import 'dart:convert';

import 'option_item.dart';

class Option {
  OptionItem? optionItem;
  int? quantity;
  String? id;

  Option({this.optionItem, this.quantity, this.id});

  @override
  String toString() {
    return 'Option(optionItem: $optionItem, quantity: $quantity, id: $id)';
  }

  factory Option.fromMap(Map<String, dynamic> data) => Option(
        optionItem: data['optionItem'] == null
            ? null
            : OptionItem.fromMap(data['optionItem'] as Map<String, dynamic>),
        quantity: data['quantity'] as int?,
        id: data['_id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'optionItem': optionItem?.toMap(),
        'quantity': quantity,
        '_id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Option].
  factory Option.fromJson(String data) {
    return Option.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Option] to a JSON string.
  String toJson() => json.encode(toMap());

  Option copyWith({
    OptionItem? optionItem,
    int? quantity,
    String? id,
  }) {
    return Option(
      optionItem: optionItem ?? this.optionItem,
      quantity: quantity ?? this.quantity,
      id: id ?? this.id,
    );
  }
}
