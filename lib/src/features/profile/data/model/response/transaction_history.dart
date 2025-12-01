import 'dart:convert';

import 'package:fazt_order/src/features/home/data/model/response/search_global/location.dart'
    as common_location;

class TransactionHistoryResponse {
  int? total;
  int? pageCount;
  Map<String, dynamic>? pagination;
  List<TransactionRecord>? results;

  TransactionHistoryResponse({
    this.total,
    this.pageCount,
    this.pagination,
    this.results,
  });

  @override
  String toString() {
    return 'TransactionHistoryResponse(total: $total, pageCount: $pageCount, pagination: $pagination, results: $results)';
  }

  factory TransactionHistoryResponse.fromMap(Map<String, dynamic> data) =>
      TransactionHistoryResponse(
        total: (data['total'] as num?)?.toInt(),
        pageCount: (data['page_count'] as num?)?.toInt(),
        pagination: data['pagination'] == null
            ? null
            : Map<String, dynamic>.from(
                data['pagination'] as Map<String, dynamic>,
              ),
        results: (data['results'] as List<dynamic>?)
            ?.map((e) => TransactionRecord.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        'total': total,
        'page_count': pageCount,
        'pagination': pagination,
        'results': results?.map((e) => e.toMap()).toList(),
      };

  factory TransactionHistoryResponse.fromJson(String data) {
    return TransactionHistoryResponse.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  TransactionHistoryResponse copyWith({
    int? total,
    int? pageCount,
    Map<String, dynamic>? pagination,
    List<TransactionRecord>? results,
  }) {
    return TransactionHistoryResponse(
      total: total ?? this.total,
      pageCount: pageCount ?? this.pageCount,
      pagination: pagination ?? this.pagination,
      results: results ?? this.results,
    );
  }
}

class TransactionRecord {
  bool? isDeleted;
  String? order;
  String? user;
  double? amount;
  String? currency;
  String? method;
  String? status;
  String? type;
  String? reference;
  TransactionMetadata? metadata;
  List<dynamic>? attempts;
  String? source;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? id;

  TransactionRecord({
    this.isDeleted,
    this.order,
    this.user,
    this.amount,
    this.currency,
    this.method,
    this.status,
    this.type,
    this.reference,
    this.metadata,
    this.attempts,
    this.source,
    this.createdAt,
    this.updatedAt,
    this.id,
  });

  @override
  String toString() {
    return 'TransactionRecord(isDeleted: $isDeleted, order: $order, user: $user, amount: $amount, currency: $currency, method: $method, status: $status, type: $type, reference: $reference, metadata: $metadata, attempts: $attempts, source: $source, createdAt: $createdAt, updatedAt: $updatedAt, id: $id)';
  }

  factory TransactionRecord.fromMap(Map<String, dynamic> data) =>
      TransactionRecord(
        isDeleted: data['isDeleted'] as bool?,
        order: data['order'] as String?,
        user: data['user'] as String?,
        amount: (data['amount'] as num?)?.toDouble(),
        currency: data['currency'] as String?,
        method: data['method'] as String?,
        status: data['status'] as String?,
        type: data['type'] as String?,
        reference: data['reference'] as String?,
        metadata: data['metadata'] == null
            ? null
            : TransactionMetadata.fromMap(
                data['metadata'] as Map<String, dynamic>,
              ),
        attempts: data['attempts'] == null
            ? null
            : List<dynamic>.from(data['attempts'] as List<dynamic>),
        source: data['source'] as String?,
        createdAt: data['createdAt'] == null
            ? null
            : DateTime.tryParse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null
            ? null
            : DateTime.tryParse(data['updatedAt'] as String),
        id: data['id'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'isDeleted': isDeleted,
        'order': order,
        'user': user,
        'amount': amount,
        'currency': currency,
        'method': method,
        'status': status,
        'type': type,
        'reference': reference,
        'metadata': metadata?.toMap(),
        'attempts': attempts,
        'source': source,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'id': id,
      };

  factory TransactionRecord.fromJson(String data) {
    return TransactionRecord.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  TransactionRecord copyWith({
    bool? isDeleted,
    String? order,
    String? user,
    double? amount,
    String? currency,
    String? method,
    String? status,
    String? type,
    String? reference,
    TransactionMetadata? metadata,
    List<dynamic>? attempts,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) {
    return TransactionRecord(
      isDeleted: isDeleted ?? this.isDeleted,
      order: order ?? this.order,
      user: user ?? this.user,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      status: status ?? this.status,
      type: type ?? this.type,
      reference: reference ?? this.reference,
      metadata: metadata ?? this.metadata,
      attempts: attempts ?? this.attempts,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
    );
  }
}

class TransactionMetadata {
  String? email;
  String? phone;
  String? shopId;
  common_location.Location? userLocation;
  String? orderNumber;

  TransactionMetadata({
    this.email,
    this.phone,
    this.shopId,
    this.userLocation,
    this.orderNumber,
  });

  @override
  String toString() {
    return 'TransactionMetadata(email: $email, phone: $phone, shopId: $shopId, userLocation: $userLocation, orderNumber: $orderNumber)';
  }

  factory TransactionMetadata.fromMap(Map<String, dynamic> data) =>
      TransactionMetadata(
        email: data['email'] as String?,
        phone: data['phone'] as String?,
        shopId: data['shopId'] as String?,
        userLocation: data['userLocation'] == null
            ? null
            : common_location.Location.fromMap(
                data['userLocation'] as Map<String, dynamic>,
              ),
        orderNumber: data['orderNumber'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'email': email,
        'phone': phone,
        'shopId': shopId,
        'userLocation': userLocation?.toMap(),
        'orderNumber': orderNumber,
      };

  factory TransactionMetadata.fromJson(String data) {
    return TransactionMetadata.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  TransactionMetadata copyWith({
    String? email,
    String? phone,
    String? shopId,
    common_location.Location? userLocation,
    String? orderNumber,
  }) {
    return TransactionMetadata(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      shopId: shopId ?? this.shopId,
      userLocation: userLocation ?? this.userLocation,
      orderNumber: orderNumber ?? this.orderNumber,
    );
  }
}
