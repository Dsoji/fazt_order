import 'dart:convert';

import 'pagination.dart';
import 'result.dart';

class StoreMeals {
  int? total;
  int? pageCount;
  Pagination? pagination;
  List<Result>? results;

  StoreMeals({this.total, this.pageCount, this.pagination, this.results});

  @override
  String toString() {
    return 'StoreMeals(total: $total, pageCount: $pageCount, pagination: $pagination, results: $results)';
  }

  factory StoreMeals.fromMap(Map<String, dynamic> data) => StoreMeals(
        total: data['total'] as int?,
        pageCount: data['page_count'] as int?,
        results: (data['results'] as List<dynamic>?)
            ?.map((e) => Result.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'total': total,
        'page_count': pageCount,
        'results': results?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [StoreMeals].
  factory StoreMeals.fromJson(String data) {
    return StoreMeals.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [StoreMeals] to a JSON string.
  String toJson() => json.encode(toMap());

  StoreMeals copyWith({
    int? total,
    int? pageCount,
    Pagination? pagination,
    List<Result>? results,
  }) {
    return StoreMeals(
      total: total ?? this.total,
      pageCount: pageCount ?? this.pageCount,
      pagination: pagination ?? this.pagination,
      results: results ?? this.results,
    );
  }
}
