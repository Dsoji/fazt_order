import 'dart:convert';

import 'featured_store.dart';

/// `data` of `GET /v1/stores/featured`.
class FeaturedStores {
  List<FeaturedStore>? stores;
  int? total;

  FeaturedStores({this.stores, this.total});

  @override
  String toString() {
    return 'FeaturedStores(stores: $stores, total: $total)';
  }

  factory FeaturedStores.fromMap(Map<String, dynamic> data) => FeaturedStores(
        stores: (data['stores'] as List<dynamic>?)
            ?.map((e) => FeaturedStore.fromMap(e as Map<String, dynamic>))
            .toList(),
        total: data['total'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'stores': stores?.map((e) => e.toMap()).toList(),
        'total': total,
      };

  factory FeaturedStores.fromJson(String data) {
    return FeaturedStores.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  FeaturedStores copyWith({
    List<FeaturedStore>? stores,
    int? total,
  }) {
    return FeaturedStores(
      stores: stores ?? this.stores,
      total: total ?? this.total,
    );
  }
}
