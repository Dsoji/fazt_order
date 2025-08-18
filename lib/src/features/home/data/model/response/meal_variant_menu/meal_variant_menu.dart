import 'dart:convert';

import 'result.dart';

class MealVariantMenu {
  int? total;
  int? pageCount;
  // Pagination? pagination;
  List<MealVariantMenuResult>? results;

  MealVariantMenu({
    this.total,
    this.pageCount,
    // this.pagination,
    this.results,
  });

  @override
  String toString() {
    return 'MealVariantMenu(total: $total, pageCount: $pageCount, results: $results)';
  }

  factory MealVariantMenu.fromMap(Map<String, dynamic> data) {
    return MealVariantMenu(
      total: data['total'] as int?,
      pageCount: data['page_count'] as int?,
      // pagination: data['pagination'] == null
      //     ? null
      //     : Pagination.fromMap(data['pagination'] as Map<String, dynamic>),
      results: (data['results'] as List<dynamic>?)
          ?.map((e) => MealVariantMenuResult.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'total': total,
        'page_count': pageCount,
        // 'pagination': pagination?.toMap(),
        'results': results?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [MealVariantMenu].
  factory MealVariantMenu.fromJson(String data) {
    return MealVariantMenu.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [MealVariantMenu] to a JSON string.
  String toJson() => json.encode(toMap());

  MealVariantMenu copyWith({
    int? total,
    int? pageCount,
    // Pagination? pagination,
    List<MealVariantMenuResult>? results,
  }) {
    return MealVariantMenu(
      total: total ?? this.total,
      pageCount: pageCount ?? this.pageCount,
      // pagination: pagination ?? this.pagination,
      results: results ?? this.results,
    );
  }
}
