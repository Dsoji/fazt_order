import 'package:fazt_order/providers/restaurant_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../datamodels/menu_items.dart';
import '../datamodels/order_items.dart';
import '../datamodels/restaurant.dart';

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier(List<MenuItem> selectedItems, String restaurantName)
      : super(OrderState(
    items: selectedItems
        .map((item) => OrderItem(name: item.name, quantity: 1, price: item.price))
        .toList(),
    deliveryFee: 1000,
    taxAndFees: 1000,
    deliveryAddress: "12, Oritshe street, Ikeja, Lagos State",
    restaurantName: restaurantName,
  ));

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity >= 0) {
      state.items[index].quantity = newQuantity;
      state = OrderState(
        items: [...state.items],
        deliveryFee: state.deliveryFee,
        taxAndFees: state.taxAndFees,
        deliveryAddress: state.deliveryAddress,
        restaurantName: state.restaurantName,
      );
    }
  }

  void addNewPack() {
    state = OrderState(
      items: [
        ...state.items,
        OrderItem(name: "New Pack", quantity: 1, price: 1000),
      ],
      deliveryFee: state.deliveryFee,
      taxAndFees: state.taxAndFees,
      deliveryAddress: state.deliveryAddress,
      restaurantName: state.restaurantName,
    );
  }

  // Add this method to delete an item
  void deleteItem(int index) {
    if (index >= 0 && index < state.items.length) {
      final updatedItems = [...state.items]..removeAt(index);
      state = OrderState(
        items: updatedItems,
        deliveryFee: state.deliveryFee,
        taxAndFees: state.taxAndFees,
        deliveryAddress: state.deliveryAddress,
        restaurantName: state.restaurantName,
      );
    }
  }

}

final orderProvider = StateNotifierProvider.family<OrderNotifier, OrderState, List<MenuItem>>(
      (ref, selectedItems) {
    final restaurantName = ref.watch(restaurantProvider).firstWhere(
          (restaurant) => restaurant.menuItems.contains(selectedItems.first),
      orElse: () => Restaurant(name: "", location: "", imageUrl: "", menuItems: [], price: 0, rating: 0, reviewCount: 0, deliveryTime: "", openingHours: "", deliveryType: "", isFavorite: false, isAvailable: true),
    ).name;
    return OrderNotifier(selectedItems, restaurantName);
  },
);