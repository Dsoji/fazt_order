import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../datamodels/menu_items.dart';
import '../datamodels/order_items.dart';
import '../datamodels/restaurant.dart';
import 'restaurant_provider.dart';

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

  double get subtotal => items
      .where((item) => item.tab == 'cart')
      .fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get total => subtotal + deliveryFee + taxAndFees;
}

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref ref;

  OrderNotifier(this.ref)
      : super(OrderState(
    items: [
      // Sample cart items
      OrderItem(name: "Jollof Rice", quantity: 2, price: 3000, tab: 'cart'),
      OrderItem(name: "Chicken Soup", quantity: 1, price: 2500, tab: 'cart'),
      // Sample ongoing items
      OrderItem(name: "Abacha", quantity: 3, price: 5000, tab: 'ongoing'),
      OrderItem(name: "Abacha", quantity: 3, price: 5000, tab: 'ongoing'),
      OrderItem(name: "Abacha", quantity: 3, price: 5000, tab: 'ongoing'),
      OrderItem(name: "Abacha", quantity: 3, price: 5000, tab: 'ongoing'),
      // Sample completed items
      OrderItem(
        name: "Abacha",
        quantity: 3,
        price: 5000,
        tab: 'completed',
        orderId: "1234567890asdf",
        dateTime: "6, Aug 2024, 1:00 pm",
        deliveryAddress: "Iya Alamala - Ajayi Estate",
      ),
      OrderItem(
        name: "Abacha",
        quantity: 3,
        price: 5000,
        tab: 'completed',
        orderId: "1234567890asdf",
        dateTime: "6, Aug 2024, 1:00 pm",
        deliveryAddress: "Delivery to Computer Village",
      ),
      OrderItem(
        name: "Abacha",
        quantity: 3,
        price: 5000,
        tab: 'completed',
        orderId: "1234567890asdf",
        dateTime: "6, Aug 2024, 1:00 pm",
        deliveryAddress: "Iya Alamala - Ajayi Estate",
      ),
      OrderItem(
        name: "Abacha",
        quantity: 3,
        price: 5000,
        tab: 'completed',
        orderId: "1234567890asdf",
        dateTime: "6, Aug 2024, 1:00 pm",
        deliveryAddress: "Delivery to Computer Village",
      ),
    ],
    deliveryFee: 1000,
    taxAndFees: 1000,
    deliveryAddress: "12, Oritshe street, Ikeja, Lagos State",
    restaurantName: "Unknown Restaurant",
  ));

  void addToCart(MenuItem item) {
    final restaurantName = ref.read(restaurantProvider).firstWhere(
          (restaurant) => restaurant.menuItems.contains(item),
      orElse: () => Restaurant(
        name: "Unknown Restaurant",
        location: "",
        imageUrl: "",
        menuItems: [],
        price: 0,
        rating: 0,
        reviewCount: 0,
        deliveryTime: "",
        openingHours: "",
        deliveryType: "",
        isFavorite: false,
        isAvailable: true,
      ),
    ).name;
    state = OrderState(
      items: [
        ...state.items,
        OrderItem(
          name: item.name,
          quantity: 1,
          price: item.price.toInt(),
          tab: 'cart',
        ),
      ],
      deliveryFee: state.deliveryFee,
      taxAndFees: state.taxAndFees,
      deliveryAddress: state.deliveryAddress,
      restaurantName: restaurantName,
    );
  }

  void updateQuantity(int index, int newQuantity, {required String tab}) {
    if (newQuantity >= 0) {
      final filteredItems = state.items.where((item) => item.tab == tab).toList();
      if (index < filteredItems.length) {
        final allItems = [...state.items];
        final targetItem = filteredItems[index];
        final targetIndex = allItems.indexWhere((item) =>
        item.name == targetItem.name &&
            item.quantity == targetItem.quantity &&
            item.price == targetItem.price &&
            item.tab == targetItem.tab);
        allItems[targetIndex] = OrderItem(
          name: targetItem.name,
          quantity: newQuantity,
          price: targetItem.price,
          tab: targetItem.tab,
        );
        state = OrderState(
          items: allItems,
          deliveryFee: state.deliveryFee,
          taxAndFees: state.taxAndFees,
          deliveryAddress: state.deliveryAddress,
          restaurantName: state.restaurantName,
        );
      }
    }
  }

  void addNewPack() {
    state = OrderState(
      items: [
        ...state.items,
        OrderItem(name: "New Pack", quantity: 1, price: 1000, tab: 'cart'),
      ],
      deliveryFee: state.deliveryFee,
      taxAndFees: state.taxAndFees,
      deliveryAddress: state.deliveryAddress,
      restaurantName: state.restaurantName,
    );
  }

  void deleteItem(int index, {required String tab}) {
    final filteredItems = state.items.where((item) => item.tab == tab).toList();
    if (index >= 0 && index < filteredItems.length) {
      final allItems = [...state.items];
      final targetItem = filteredItems[index];
      final targetIndex = allItems.indexWhere((item) =>
      item.name == targetItem.name &&
          item.quantity == targetItem.quantity &&
          item.price == targetItem.price &&
          item.tab == targetItem.tab);
      allItems.removeAt(targetIndex);
      state = OrderState(
        items: allItems,
        deliveryFee: state.deliveryFee,
        taxAndFees: state.taxAndFees,
        deliveryAddress: state.deliveryAddress,
        restaurantName: state.restaurantName,
      );
    }
  }

  void clearCartItems() {
    state = OrderState(
      items: state.items.where((item) => item.tab != 'cart').toList(),
      deliveryFee: state.deliveryFee,
      taxAndFees: state.taxAndFees,
      deliveryAddress: state.deliveryAddress,
      restaurantName: state.restaurantName,
    );
  }

  void clearOngoingItems() {
    state = OrderState(
      items: state.items.where((item) => item.tab != 'ongoing').toList(),
      deliveryFee: state.deliveryFee,
      taxAndFees: state.taxAndFees,
      deliveryAddress: state.deliveryAddress,
      restaurantName: state.restaurantName,
    );
  }

  void clearCompletedItems() {
    state = OrderState(
      items: state.items.where((item) => item.tab != 'completed').toList(),
      deliveryFee: state.deliveryFee,
      taxAndFees: state.taxAndFees,
      deliveryAddress: state.deliveryAddress,
      restaurantName: state.restaurantName,
    );
  }

  void updateDeliveryAddress(String newAddress) {
    state = OrderState(
      items: state.items,
      deliveryFee: state.deliveryFee,
      taxAndFees: state.taxAndFees,
      deliveryAddress: newAddress,
      restaurantName: state.restaurantName,
    );
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref);
});