import 'dart:convert';

import 'result.dart';

class StoreMealVariant {
  int? total;
  int? pageCount;
  // Pagination? pagination;
  List<Result>? results;

  StoreMealVariant({
    this.total,
    this.pageCount,
    // this.pagination,
    this.results,
  });

  @override
  String toString() {
    return 'StoreMealVariant(total: $total, pageCount: $pageCount, results: $results)';
  }

  factory StoreMealVariant.fromMap(Map<String, dynamic> data) {
    return StoreMealVariant(
      total: data['total'] as int?,
      pageCount: data['page_count'] as int?,
      // pagination: data['pagination'] == null
      //     ? null
      //     : Pagination.fromMap(data['pagination'] as Map<String, dynamic>),
      results: (data['results'] as List<dynamic>?)
          ?.map((e) => Result.fromMap(e as Map<String, dynamic>))
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
  /// Parses the string and returns the resulting Json object as [StoreMealVariant].
  factory StoreMealVariant.fromJson(String data) {
    return StoreMealVariant.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [StoreMealVariant] to a JSON string.
  String toJson() => json.encode(toMap());

  StoreMealVariant copyWith({
    int? total,
    int? pageCount,
    // Pagination? pagination,
    List<Result>? results,
  }) {
    return StoreMealVariant(
      total: total ?? this.total,
      pageCount: pageCount ?? this.pageCount,
      // pagination: pagination ?? this.pagination,
      results: results ?? this.results,
    );
  }
}
