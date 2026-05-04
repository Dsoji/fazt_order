import 'dart:convert';

class Payment {
  int? subtotal;
  int? deliveryFee;
  int? serviceFee;
  int? total;
  int? discount;
  int? payableDeliveryFee;
  int? freeDeliverySubsidy;
  int? platformSubsidyAmount;
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
    this.discount,
    this.payableDeliveryFee,
    this.freeDeliverySubsidy,
    this.platformSubsidyAmount,
    this.paymentMethod,
    this.paymentStatus,
    this.initiatedAt,
    this.id,
    this.completedAt,
    this.paymentReference,
    this.transactionId,
  });

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return null;
  }

  @override
  String toString() {
    return 'Payment(subtotal: $subtotal, deliveryFee: $deliveryFee, serviceFee: $serviceFee, total: $total, discount: $discount, payableDeliveryFee: $payableDeliveryFee, freeDeliverySubsidy: $freeDeliverySubsidy, platformSubsidyAmount: $platformSubsidyAmount, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, initiatedAt: $initiatedAt, id: $id, completedAt: $completedAt, paymentReference: $paymentReference, transactionId: $transactionId)';
  }

  factory Payment.fromMap(Map<String, dynamic> data) => Payment(
        subtotal: _toInt(data['subtotal']),
        deliveryFee: _toInt(data['deliveryFee']),
        serviceFee: _toInt(data['serviceFee']),
        total: _toInt(data['total']),
        discount: _toInt(data['discount']),
        payableDeliveryFee: _toInt(data['payableDeliveryFee']),
        freeDeliverySubsidy: _toInt(data['freeDeliverySubsidy']),
        platformSubsidyAmount: _toInt(data['platformSubsidyAmount']),
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
        'discount': discount,
        'payableDeliveryFee': payableDeliveryFee,
        'freeDeliverySubsidy': freeDeliverySubsidy,
        'platformSubsidyAmount': platformSubsidyAmount,
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
    int? discount,
    int? payableDeliveryFee,
    int? freeDeliverySubsidy,
    int? platformSubsidyAmount,
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
      discount: discount ?? this.discount,
      payableDeliveryFee: payableDeliveryFee ?? this.payableDeliveryFee,
      freeDeliverySubsidy: freeDeliverySubsidy ?? this.freeDeliverySubsidy,
      platformSubsidyAmount:
          platformSubsidyAmount ?? this.platformSubsidyAmount,
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
