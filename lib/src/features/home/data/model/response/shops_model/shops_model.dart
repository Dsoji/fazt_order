import 'dart:convert';

import 'result.dart';

class ShopsModel {
  int? total;
  int? pageCount;
  List<ShopResult>? results;

  ShopsModel({this.total, this.pageCount, this.results});

  @override
  String toString() {
    return 'ShopsModel(total: $total, pageCount: $pageCount, results: $results)';
  }

  factory ShopsModel.fromMap(Map<String, dynamic> data) => ShopsModel(
        total: data['total'] as int?,
        pageCount: data['page_count'] as int?,
        results: (data['results'] as List<dynamic>?)
            ?.map((e) => ShopResult.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'total': total,
        'page_count': pageCount,
        'results': results?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [ShopsModel].
  factory ShopsModel.fromJson(String data) {
    return ShopsModel.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [ShopsModel] to a JSON string.
  String toJson() => json.encode(toMap());

  ShopsModel copyWith({
    int? total,
    int? pageCount,
    List<ShopResult>? results,
  }) {
    return ShopsModel(
      total: total ?? this.total,
      pageCount: pageCount ?? this.pageCount,
      results: results ?? this.results,
    );
  }
}
