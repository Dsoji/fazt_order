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
  String? paymentReference;
  String? paymentUrl;
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
    this.paymentReference,
    this.paymentUrl,
    this.transactionId,
  });

  @override
  String toString() {
    return 'Payment(subtotal: $subtotal, deliveryFee: $deliveryFee, serviceFee: $serviceFee, total: $total, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, initiatedAt: $initiatedAt, id: $id, paymentReference: $paymentReference, paymentUrl: $paymentUrl, transactionId: $transactionId)';
  }

  factory Payment.fromMap(Map<String, dynamic> data) => Payment(
        subtotal: data['subtotal'] as int?,
        deliveryFee: data['deliveryFee'] as int?,
        serviceFee: data['serviceFee'] as int?,
        total: data['total'] as int?,
        paymentMethod: data['paymentMethod'] as String?,
        paymentStatus: data['paymentStatus'] as String?,
        initiatedAt: data['initiatedAt'] == null
            ? null
            : DateTime.parse(data['initiatedAt'] as String),
        id: data['_id'] as String?,
        paymentReference: data['paymentReference'] as String?,
        paymentUrl: data['paymentUrl'] as String?,
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
        'paymentReference': paymentReference,
        'paymentUrl': paymentUrl,
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
    String? paymentReference,
    String? paymentUrl,
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
      paymentReference: paymentReference ?? this.paymentReference,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}
