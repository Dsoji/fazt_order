import 'dart:convert';

import 'pagination.dart';
import 'result.dart';

class StoreCategories {
  int? total;
  int? pageCount;
  Pagination? pagination;
  List<Result>? results;

  StoreCategories({
    this.total,
    this.pageCount,
    this.pagination,
    this.results,
  });

  @override
  String toString() {
    return 'StoreCategories(total: $total, pageCount: $pageCount, pagination: $pagination, results: $results)';
  }

  factory StoreCategories.fromMap(Map<String, dynamic> data) {
    return StoreCategories(
      total: data['total'] as int?,
      pageCount: data['page_count'] as int?,
      results: (data['results'] as List<dynamic>?)
          ?.map((e) => Result.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'total': total,
        'page_count': pageCount,
        'results': results?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [StoreCategories].
  factory StoreCategories.fromJson(String data) {
    return StoreCategories.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [StoreCategories] to a JSON string.
  String toJson() => json.encode(toMap());

  StoreCategories copyWith({
    int? total,
    int? pageCount,
    Pagination? pagination,
    List<Result>? results,
  }) {
    return StoreCategories(
      total: total ?? this.total,
      pageCount: pageCount ?? this.pageCount,
      pagination: pagination ?? this.pagination,
      results: results ?? this.results,
    );
  }
}
