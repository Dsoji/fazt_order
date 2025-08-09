class Order {
  String? id;
  String? orderNumber;
  String? status;
  int? total;
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

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String?,
        orderNumber: json['orderNumber'] as String?,
        status: json['status'] as String?,
        total: json['total'] as int?,
        paymentMethod: json['paymentMethod'] as String?,
      );

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
    int? total,
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
