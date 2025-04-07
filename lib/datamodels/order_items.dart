class OrderItem {
  final String name;
  int quantity;
  final num price;

  OrderItem({required this.name, required this.quantity, required this.price});
}

class OrderState {
  final List<OrderItem> items;
  final double deliveryFee;
  final double taxAndFees;
  final String deliveryAddress;
  final String restaurantName;

  OrderState({
    required this.items,
    required this.deliveryFee,
    required this.taxAndFees,
    required this.deliveryAddress,
    required this.restaurantName,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get total => subtotal + deliveryFee + taxAndFees;
}