// class OrderItem {
//   final String name;
//   int quantity;
//   final int price;
//
//   OrderItem({required this.name, required this.quantity, required this.price});
// }
//
// class OrderState {
//   final List<OrderItem> items;
//   final double deliveryFee;
//   final double taxAndFees;
//   final String deliveryAddress;
//   final String restaurantName;
//
//   OrderState({
//     required this.items,
//     required this.deliveryFee,
//     required this.taxAndFees,
//     required this.deliveryAddress,
//     required this.restaurantName,
//   });
//
//   double get subtotal => items.fold(0, (sum, item) => sum + (item.price * item.quantity));
//   double get total => subtotal + deliveryFee + taxAndFees;
// }
class OrderItem {
  final String name;
  int quantity;
  final int price;
  final String tab;
  final String? orderId;
  final String? dateTime;
  final String? deliveryAddress;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.tab,
    this.orderId,
    this.dateTime,
    this.deliveryAddress,
  });
}