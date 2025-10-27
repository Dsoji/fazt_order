import 'package:fazt_order/src/features/courier/data/model/courier_list.dart';
import 'package:fazt_order/src/features/courier/data/model/parcel_payment_details.dart';
import 'package:fazt_order/src/features/courier/data/model/parcel_request.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/response/cartlsit/cartlsit.dart';
import '../model/response/meal_details/meal_details.dart';
import '../model/response/meal_variant_menu/meal_variant_menu.dart';
import '../model/response/my_orders_list/my_orders_list.dart';
import '../model/response/order_link/order_link.dart';
import '../model/response/search_global/search_global.dart';
import '../model/response/shops_model/shops_model.dart';
import '../model/response/store_categories/store_categories.dart';
import '../model/response/store_meal_variant/store_meal_variant.dart';
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
  final AsyncValue<StoreMealVariant> storeMealVariant;
  final AsyncValue<MealVariantMenu> mealVariantMenu;
  final AsyncValue<String> addAddress;
  final AsyncValue<String> clearCart;
  final AsyncValue<ParcelRequest> bookCourier;
  final AsyncValue<ParcelPaymentDetails> makeParcelPayment;
  final AsyncValue<MealDetails> mealDetails;
  final AsyncValue<CourierListResponse> courierList;
  final AsyncValue<String> cancelOrder;
  const ShopState({
    required this.courierList,
    required this.shops,
    required this.shopFoodCategory,
    required this.searchQuery,
    required this.storeMeals,
    required this.addToCart,
    required this.fetchCart,
    required this.removePackFromCart,
    required this.makeOrders,
    required this.myOrdersList,
    required this.storeMealVariant,
    required this.mealVariantMenu,
    required this.addAddress,
    required this.clearCart,
    required this.bookCourier,
    required this.makeParcelPayment,
    required this.mealDetails,
    required this.cancelOrder,
  });

  factory ShopState.initial() {
    return ShopState(
      courierList: AsyncValue.data(CourierListResponse()),
      shops: AsyncValue.data(ShopsModel()),
      shopFoodCategory: AsyncValue.data(StoreCategories()),
      searchQuery: AsyncValue.data(SearchGlobal()),
      storeMeals: AsyncValue.data(StoreMeals()),
      addToCart: const AsyncValue.data(''),
      fetchCart: AsyncValue.data(CartLsit()),
      removePackFromCart: const AsyncValue.data(''),
      makeOrders: AsyncValue.data(OrderLink()),
      myOrdersList: AsyncValue.data(MyOrdersList()),
      storeMealVariant: AsyncValue.data(StoreMealVariant()),
      mealVariantMenu: AsyncValue.data(MealVariantMenu()),
      addAddress: const AsyncValue.data(''),
      clearCart: const AsyncValue.data(''),
      bookCourier: const AsyncValue.data(ParcelRequest()),
      makeParcelPayment: const AsyncValue.data(ParcelPaymentDetails()),
      mealDetails: AsyncValue.data(MealDetails()),
      cancelOrder: const AsyncValue.data(''),
    );
  }

  ShopState copyWith({
    AsyncValue<CourierListResponse>? courierList,
    AsyncValue<ShopsModel>? shops,
    AsyncValue<StoreCategories>? shopFoodCategory,
    AsyncValue<SearchGlobal>? searchQuery,
    AsyncValue<StoreMeals>? storeMeals,
    AsyncValue<String>? addToCart,
    AsyncValue<CartLsit>? fetchCart,
    AsyncValue<String>? removePackFromCart,
    AsyncValue<OrderLink>? makeOrders,
    AsyncValue<MyOrdersList>? myOrdersList,
    AsyncValue<StoreMealVariant>? storeMealVariant,
    AsyncValue<MealVariantMenu>? mealVariantMenu,
    AsyncValue<String>? addAddress,
    AsyncValue<String>? clearCart,
    AsyncValue<ParcelRequest>? bookCourier,
    AsyncValue<ParcelPaymentDetails>? makeParcelPayment,
    AsyncValue<MealDetails>? mealDetails,
    AsyncValue<String>? cancelOrder,
  }) {
    return ShopState(
      courierList: courierList ?? this.courierList,
      shops: shops ?? this.shops,
      shopFoodCategory: shopFoodCategory ?? this.shopFoodCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      storeMeals: storeMeals ?? this.storeMeals,
      addToCart: addToCart ?? this.addToCart,
      fetchCart: fetchCart ?? this.fetchCart,
      removePackFromCart: removePackFromCart ?? this.removePackFromCart,
      makeOrders: makeOrders ?? this.makeOrders,
      myOrdersList: myOrdersList ?? this.myOrdersList,
      storeMealVariant: storeMealVariant ?? this.storeMealVariant,
      mealVariantMenu: mealVariantMenu ?? this.mealVariantMenu,
      addAddress: addAddress ?? this.addAddress,
      clearCart: clearCart ?? this.clearCart,
      bookCourier: bookCourier ?? this.bookCourier,
      makeParcelPayment: makeParcelPayment ?? this.makeParcelPayment,
      mealDetails: mealDetails ?? this.mealDetails,
      cancelOrder: cancelOrder ?? this.cancelOrder,
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
