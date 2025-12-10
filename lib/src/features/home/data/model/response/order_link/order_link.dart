import 'order.dart';
import 'payment.dart';

class OrderLink {
  Order? order;
  bool? cartCleared;
  Payment? payment;
  bool? redirectRequired;
  String? message;

  OrderLink({
    this.order,
    this.cartCleared,
    this.payment,
    this.redirectRequired,
    this.message,
  });

  @override
  String toString() {
    return 'OrderLink(order: $order, cartCleared: $cartCleared, payment: $payment, redirectRequired: $redirectRequired, message: $message)';
  }

  factory OrderLink.fromMap(Map<String, dynamic> map) => OrderLink(
        order: map['order'] == null
            ? null
            : Order.fromMap(map['order'] as Map<String, dynamic>),
        cartCleared: map['cartCleared'] as bool?,
        payment: map['payment'] == null
            ? null
            : Payment.fromMap(map['payment'] as Map<String, dynamic>),
        redirectRequired: map['redirectRequired'] as bool?,
        message: map['message'] as String?,
      );

  // Backwards-compatible alias for any older usages.
  factory OrderLink.fromJson(Map<String, dynamic> json) =>
      OrderLink.fromMap(json);

  Map<String, dynamic> toJson() => {
        'order': order?.toJson(),
        'cartCleared': cartCleared,
        'payment': payment?.toJson(),
        'redirectRequired': redirectRequired,
        'message': message,
      };

  OrderLink copyWith({
    Order? order,
    bool? cartCleared,
    Payment? payment,
    bool? redirectRequired,
    String? message,
  }) {
    return OrderLink(
      order: order ?? this.order,
      cartCleared: cartCleared ?? this.cartCleared,
      payment: payment ?? this.payment,
      redirectRequired: redirectRequired ?? this.redirectRequired,
      message: message ?? this.message,
    );
  }
}
