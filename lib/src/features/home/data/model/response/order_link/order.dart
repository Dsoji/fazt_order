class Order {
  String? id;
  String? orderNumber;
  String? status;
  double? total;
  String? paymentMethod;

  Order({
    this.id,
    this.orderNumber,
    this.status,
    this.total,
    this.paymentMethod,
  });

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, status: $status, total: $total, paymentMethod: $paymentMethod)';
  }

  factory Order.fromMap(Map<String, dynamic> map) => Order(
        id: map['id'] as String?,
        orderNumber: map['orderNumber'] as String?,
        status: map['status'] as String?,
        total: (map['total'] is num) ? (map['total'] as num).toDouble() : null,
        paymentMethod: map['paymentMethod'] as String?,
      );

  // Backwards-compatible alias.
  factory Order.fromJson(Map<String, dynamic> json) => Order.fromMap(json);

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderNumber': orderNumber,
        'status': status,
        'total': total,
        'paymentMethod': paymentMethod,
      };

  Order copyWith({
    String? id,
    String? orderNumber,
    String? status,
    double? total,
    String? paymentMethod,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
