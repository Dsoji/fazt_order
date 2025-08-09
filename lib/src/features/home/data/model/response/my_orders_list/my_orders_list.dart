import 'dart:convert';

import 'pagination.dart';
import 'result.dart';

class MyOrdersList {
  int? total;
  int? pageCount;
  Pagination? pagination;
  List<OrderResult>? results;

  MyOrdersList({this.total, this.pageCount, this.pagination, this.results});

  @override
  String toString() {
    return 'OrderList(total: $total, pageCount: $pageCount, pagination: $pagination, results: $results)';
  }

  factory MyOrdersList.fromMap(Map<String, dynamic> data) => MyOrdersList(
        total: data['total'] as int?,
        pageCount: data['page_count'] as int?,
        // pagination: data['pagination'] == null
        //     ? null
        //     : Pagination.fromMap(data['pagination'] as Map<String, dynamic>),
        results: (data['results'] as List<dynamic>?)
            ?.map((e) => OrderResult.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'total': total,
        'page_count': pageCount,
        // 'pagination': pagination?.toMap(),
        'results': results?.map((e) => e.toMap()).toList(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [OrderList].
  factory MyOrdersList.fromJson(String data) {
    return MyOrdersList.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [OrderList] to a JSON string.
  String toJson() => json.encode(toMap());

  MyOrdersList copyWith({
    int? total,
    int? pageCount,
    Pagination? pagination,
    List<OrderResult>? results,
  }) {
    return MyOrdersList(
      total: total ?? this.total,
      pageCount: pageCount ?? this.pageCount,
      pagination: pagination ?? this.pagination,
      results: results ?? this.results,
    );
  }
}
