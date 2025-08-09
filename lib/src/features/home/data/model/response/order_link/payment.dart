class Payment {
  String? status;
  String? paymentId;
  String? paymentUrl;
  String? reference;

  Payment({this.status, this.paymentId, this.paymentUrl, this.reference});

  @override
  String toString() {
    return 'Payment(status: $status, paymentId: $paymentId, paymentUrl: $paymentUrl, reference: $reference)';
  }

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        status: json['status'] as String?,
        paymentId: json['paymentId'] as String?,
        paymentUrl: json['paymentUrl'] as String?,
        reference: json['reference'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'paymentId': paymentId,
        'paymentUrl': paymentUrl,
        'reference': reference,
      };

  Payment copyWith({
    String? status,
    String? paymentId,
    String? paymentUrl,
    String? reference,
  }) {
    return Payment(
      status: status ?? this.status,
      paymentId: paymentId ?? this.paymentId,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      reference: reference ?? this.reference,
    );
  }
}
