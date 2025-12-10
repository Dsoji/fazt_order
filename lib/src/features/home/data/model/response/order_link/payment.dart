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

  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
        status: map['status'] as String?,
        paymentId: map['paymentId'] as String?,
        paymentUrl: map['paymentUrl'] as String?,
        reference: map['reference'] as String?,
      );

  // Backwards-compatible alias.
  factory Payment.fromJson(Map<String, dynamic> json) => Payment.fromMap(json);

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
