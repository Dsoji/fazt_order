import 'dart:convert';

class Payment {
  int? subtotal;
  int? deliveryFee;
  int? serviceFee;
  int? total;
  String? paymentMethod;
  String? paymentStatus;
  DateTime? initiatedAt;
  String? id;
  DateTime? completedAt;
  String? paymentReference;
  String? transactionId;

  Payment({
    this.subtotal,
    this.deliveryFee,
    this.serviceFee,
    this.total,
    this.paymentMethod,
    this.paymentStatus,
    this.initiatedAt,
    this.id,
    this.completedAt,
    this.paymentReference,
    this.transactionId,
  });

  @override
  String toString() {
    return 'Payment(subtotal: $subtotal, deliveryFee: $deliveryFee, serviceFee: $serviceFee, total: $total, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, initiatedAt: $initiatedAt, id: $id, completedAt: $completedAt, paymentReference: $paymentReference, transactionId: $transactionId)';
  }

  factory Payment.fromMap(Map<String, dynamic> data) => Payment(
        subtotal: data['subtotal'] != null
            ? (data['subtotal'] is double
                ? (data['subtotal'] as double).toInt()
                : data['subtotal'] as int)
            : null,
        deliveryFee: data['deliveryFee'] != null
            ? (data['deliveryFee'] is double
                ? (data['deliveryFee'] as double).toInt()
                : data['deliveryFee'] as int)
            : null,
        serviceFee: data['serviceFee'] != null
            ? (data['serviceFee'] is double
                ? (data['serviceFee'] as double).toInt()
                : data['serviceFee'] as int)
            : null,
        total: data['total'] != null
            ? (data['total'] is double
                ? (data['total'] as double).toInt()
                : data['total'] as int)
            : null,
        paymentMethod: data['paymentMethod'] as String?,
        paymentStatus: data['paymentStatus'] as String?,
        initiatedAt: data['initiatedAt'] == null
            ? null
            : DateTime.parse(data['initiatedAt'] as String),
        id: data['_id'] as String?,
        completedAt: data['completedAt'] == null
            ? null
            : DateTime.parse(data['completedAt'] as String),
        paymentReference: data['paymentReference'] as String?,
        transactionId: data['transactionId'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'serviceFee': serviceFee,
        'total': total,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'initiatedAt': initiatedAt?.toIso8601String(),
        '_id': id,
        'completedAt': completedAt?.toIso8601String(),
        'paymentReference': paymentReference,
        'transactionId': transactionId,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Payment].
  factory Payment.fromJson(String data) {
    return Payment.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Payment] to a JSON string.
  String toJson() => json.encode(toMap());

  Payment copyWith({
    int? subtotal,
    int? deliveryFee,
    int? serviceFee,
    int? total,
    String? paymentMethod,
    String? paymentStatus,
    DateTime? initiatedAt,
    String? id,
    DateTime? completedAt,
    String? paymentReference,
    String? transactionId,
  }) {
    return Payment(
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      serviceFee: serviceFee ?? this.serviceFee,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      initiatedAt: initiatedAt ?? this.initiatedAt,
      id: id ?? this.id,
      completedAt: completedAt ?? this.completedAt,
      paymentReference: paymentReference ?? this.paymentReference,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}
