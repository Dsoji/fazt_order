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

  factory OrderLink.fromJson(Map<String, dynamic> json) => OrderLink(
        order: json['order'] == null
            ? null
            : Order.fromJson(json['order'] as Map<String, dynamic>),
        cartCleared: json['cartCleared'] as bool?,
        payment: json['payment'] == null
            ? null
            : Payment.fromJson(json['payment'] as Map<String, dynamic>),
        redirectRequired: json['redirectRequired'] as bool?,
        message: json['message'] as String?,
      );

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
