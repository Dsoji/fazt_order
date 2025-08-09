import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/response/cart_lsit/cart_lsit.dart';
import '../model/response/my_orders_list/my_orders_list.dart';
import '../model/response/order_link/order_link.dart';
import '../model/response/search_global/search_global.dart';
import '../model/response/shops_model/shops_model.dart';
import '../model/response/store_categories/store_categories.dart';
import '../model/response/store_meals/store_meals.dart';

class ShopState {
  final AsyncValue<ShopsModel> shops;
  final AsyncValue<StoreCategories> shopFoodCategory;
  final AsyncValue<SearchGlobal> searchQuery;
  final AsyncValue<StoreMeals> storeMeals;
  final AsyncValue<String> addToCart;
  final AsyncValue<CartLsit> fetchCart;
  final AsyncValue<String> removePackFromCart;
  final AsyncValue<OrderLink> makeOrders;
  final AsyncValue<MyOrdersList> myOrdersList;
  const ShopState({
    required this.shops,
    required this.shopFoodCategory,
    required this.searchQuery,
    required this.storeMeals,
    required this.addToCart,
    required this.fetchCart,
    required this.removePackFromCart,
    required this.makeOrders,
    required this.myOrdersList,
  });

  factory ShopState.initial() {
    return ShopState(
      shops: AsyncValue.data(ShopsModel()),
      shopFoodCategory: AsyncValue.data(StoreCategories()),
      searchQuery: AsyncValue.data(SearchGlobal()),
      storeMeals: AsyncValue.data(StoreMeals()),
      addToCart: const AsyncValue.data(''),
      fetchCart: AsyncValue.data(CartLsit()),
      removePackFromCart: const AsyncValue.data(''),
      makeOrders: AsyncValue.data(OrderLink()),
      myOrdersList: AsyncValue.data(MyOrdersList()),
    );
  }

  ShopState copyWith({
    AsyncValue<ShopsModel>? shops,
    AsyncValue<StoreCategories>? shopFoodCategory,
    AsyncValue<SearchGlobal>? searchQuery,
    AsyncValue<StoreMeals>? storeMeals,
    AsyncValue<String>? addToCart,
    AsyncValue<CartLsit>? fetchCart,
    AsyncValue<String>? removePackFromCart,
    AsyncValue<OrderLink>? makeOrders,
    AsyncValue<MyOrdersList>? myOrdersList,
  }) {
    return ShopState(
      shops: shops ?? this.shops,
      shopFoodCategory: shopFoodCategory ?? this.shopFoodCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      storeMeals: storeMeals ?? this.storeMeals,
      addToCart: addToCart ?? this.addToCart,
      fetchCart: fetchCart ?? this.fetchCart,
      removePackFromCart: removePackFromCart ?? this.removePackFromCart,
      makeOrders: makeOrders ?? this.makeOrders,
      myOrdersList: myOrdersList ?? this.myOrdersList,
    );
  }

  // @override
  // String toString() {
  //   return 'AuthenticationState(login: $login, )';
  // }

  // @override
  // bool operator ==(covariant ShopState other) {
  //   if (identical(this, other)) return true;

  //   return;
  // }

  // @override
  // int get hashCode {
  //   return login.hashCode ^ signUp.hashCode ^ status.hashCode;
  // }
}
