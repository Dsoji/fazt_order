import 'dart:convert';

import 'location.dart';
import 'store.dart';

class Shop {
  Location? location;
  Store? store;
  String? id;

  Shop({this.location, this.store, this.id});

  @override
  String toString() => 'Shop(location: $location, store: $store, id: $id)';

  factory Shop.fromMap(Map<String, dynamic> data) => Shop(
        location: data['location'] == null
            ? null
            : Location.fromMap(data['location'] as Map<String, dynamic>),
        store: data['store'] == null
            ? null
            : Store.fromMap(data['store'] as Map<String, dynamic>),
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'location': location?.toMap(),
        'store': store?.toMap(),
        'id': id,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Shop].
  factory Shop.fromJson(String data) {
    return Shop.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Shop] to a JSON string.
  String toJson() => json.encode(toMap());

  Shop copyWith({
    Location? location,
    Store? store,
    String? id,
  }) {
    return Shop(
      location: location ?? this.location,
      store: store ?? this.store,
      id: id ?? this.id,
    );
  }
}
