import 'dart:convert';

import 'sales_operation.dart';

class Store {
  String? storeDisplayImage;
  String? storeName;
  String? id;
  SalesOperation? salesOperation;

  Store({this.storeDisplayImage, this.storeName, this.id, this.salesOperation});

  @override
  String toString() {
    return 'Store(storeDisplayImage: $storeDisplayImage, storeName: $storeName, id: $id, salesOperation: $salesOperation)';
  }

  factory Store.fromMap(Map<String, dynamic> data) => Store(
        storeDisplayImage: data['storeDisplayImage'] as String?,
        storeName: data['storeName'] as String?,
        id: data['id'] as String?,
        salesOperation: data['salesOperation'] == null
            ? null
            : SalesOperation.fromMap(
                data['salesOperation'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toMap() => {
        'storeDisplayImage': storeDisplayImage,
        'storeName': storeName,
        'id': id,
        'salesOperation': salesOperation?.toMap(),
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Store].
  factory Store.fromJson(String data) {
    return Store.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Store] to a JSON string.
  String toJson() => json.encode(toMap());

  Store copyWith({
    String? storeDisplayImage,
    String? storeName,
    String? id,
    SalesOperation? salesOperation,
  }) {
    return Store(
      storeDisplayImage: storeDisplayImage ?? this.storeDisplayImage,
      storeName: storeName ?? this.storeName,
      id: id ?? this.id,
      salesOperation: salesOperation ?? this.salesOperation,
    );
  }
}
