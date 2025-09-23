import 'dart:convert';

class ParcelPaymentDetails {
  final OrderInfo? order;
  final PaymentInfo? payment;
  final bool? redirectRequired;
  final String? message;

  const ParcelPaymentDetails({
    this.order,
    this.payment,
    this.redirectRequired,
    this.message,
  });

  factory ParcelPaymentDetails.fromMap(Map<String, dynamic> data) =>
      ParcelPaymentDetails(
        order: data['order'] == null
            ? null
            : OrderInfo.fromMap(data['order'] as Map<String, dynamic>),
        payment: data['payment'] == null
            ? null
            : PaymentInfo.fromMap(data['payment'] as Map<String, dynamic>),
        redirectRequired: data['redirectRequired'] as bool?,
        message: data['message'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'order': order?.toMap(),
        'payment': payment?.toMap(),
        'redirectRequired': redirectRequired,
        'message': message,
      };

  factory ParcelPaymentDetails.fromJson(String data) =>
      ParcelPaymentDetails.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  ParcelPaymentDetails copyWith({
    OrderInfo? order,
    PaymentInfo? payment,
    bool? redirectRequired,
    String? message,
  }) =>
      ParcelPaymentDetails(
        order: order ?? this.order,
        payment: payment ?? this.payment,
        redirectRequired: redirectRequired ?? this.redirectRequired,
        message: message ?? this.message,
      );
}

class OrderInfo {
  final String? id;
  final String? orderNumber;
  final String? orderType;
  final String? status;
  final num? total;
  final String? paymentMethod;
  final String? parcelId;

  const OrderInfo({
    this.id,
    this.orderNumber,
    this.orderType,
    this.status,
    this.total,
    this.paymentMethod,
    this.parcelId,
  });

  factory OrderInfo.fromMap(Map<String, dynamic> data) => OrderInfo(
        id: (data['id'] ?? data['_id']) as String?,
        orderNumber: data['orderNumber'] as String?,
        orderType: data['orderType'] as String?,
        status: data['status'] as String?,
        total: data['total'] as num?,
        paymentMethod: data['paymentMethod'] as String?,
        parcelId: data['parcelId'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'orderNumber': orderNumber,
        'orderType': orderType,
        'status': status,
        'total': total,
        'paymentMethod': paymentMethod,
        'parcelId': parcelId,
      };

  factory OrderInfo.fromJson(String data) =>
      OrderInfo.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  OrderInfo copyWith({
    String? id,
    String? orderNumber,
    String? orderType,
    String? status,
    num? total,
    String? paymentMethod,
    String? parcelId,
  }) =>
      OrderInfo(
        id: id ?? this.id,
        orderNumber: orderNumber ?? this.orderNumber,
        orderType: orderType ?? this.orderType,
        status: status ?? this.status,
        total: total ?? this.total,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        parcelId: parcelId ?? this.parcelId,
      );
}

class PaymentInfo {
  final String? status;
  final String? paymentId;
  final String? paymentUrl;
  final String? reference;

  const PaymentInfo({
    this.status,
    this.paymentId,
    this.paymentUrl,
    this.reference,
  });

  factory PaymentInfo.fromMap(Map<String, dynamic> data) => PaymentInfo(
        status: data['status'] as String?,
        paymentId: data['paymentId'] as String?,
        paymentUrl: data['paymentUrl'] as String?,
        reference: data['reference'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'status': status,
        'paymentId': paymentId,
        'paymentUrl': paymentUrl,
        'reference': reference,
      };

  factory PaymentInfo.fromJson(String data) =>
      PaymentInfo.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  PaymentInfo copyWith({
    String? status,
    String? paymentId,
    String? paymentUrl,
    String? reference,
  }) =>
      PaymentInfo(
        status: status ?? this.status,
        paymentId: paymentId ?? this.paymentId,
        paymentUrl: paymentUrl ?? this.paymentUrl,
        reference: reference ?? this.reference,
      );
}
