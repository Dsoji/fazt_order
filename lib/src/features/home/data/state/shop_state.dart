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
  final int shopsPage;
  final bool shopsHasMore;
  final bool isLoadingMoreShops;
  final AsyncValue<StoreCategories> shopFoodCategory;
  final int shopFoodCategoryPage;
  final bool shopFoodCategoryHasMore;
  final bool isLoadingMoreShopFoodCategory;
  final AsyncValue<SearchGlobal> searchQuery;
  final AsyncValue<StoreMeals> storeMeals;
  final int storeMealsPage;
  final bool storeMealsHasMore;
  final bool isLoadingMoreStoreMeals;
  final AsyncValue<String> addToCart;
  final AsyncValue<CartLsit> fetchCart;
  final AsyncValue<String> removePackFromCart;
  final AsyncValue<OrderLink> makeOrders;
  final AsyncValue<MyOrdersList> myOrdersList;
  final int myOrdersListPage;
  final bool myOrdersListHasMore;
  final bool isLoadingMoreMyOrdersList;
  final AsyncValue<StoreMealVariant> storeMealVariant;
  final int storeMealVariantPage;
  final bool storeMealVariantHasMore;
  final bool isLoadingMoreStoreMealVariant;
  final AsyncValue<MealVariantMenu> mealVariantMenu;
  final int mealVariantMenuPage;
  final bool mealVariantMenuHasMore;
  final bool isLoadingMoreMealVariantMenu;
  final AsyncValue<String> addAddress;
  final AsyncValue<String> clearCart;
  final AsyncValue<ParcelRequest> bookCourier;
  final AsyncValue<ParcelPaymentDetails> makeParcelPayment;
  final AsyncValue<MealDetails> mealDetails;
  final AsyncValue<CourierListResponse> courierList;
  final int courierListPage;
  final bool courierListHasMore;
  final bool isLoadingMoreCourierList;
  final AsyncValue<String> cancelOrder;
  const ShopState({
    required this.courierList,
    required this.courierListPage,
    required this.courierListHasMore,
    required this.isLoadingMoreCourierList,
    required this.shops,
    required this.shopsPage,
    required this.shopsHasMore,
    required this.isLoadingMoreShops,
    required this.shopFoodCategory,
    required this.shopFoodCategoryPage,
    required this.shopFoodCategoryHasMore,
    required this.isLoadingMoreShopFoodCategory,
    required this.searchQuery,
    required this.storeMeals,
    required this.storeMealsPage,
    required this.storeMealsHasMore,
    required this.isLoadingMoreStoreMeals,
    required this.addToCart,
    required this.fetchCart,
    required this.removePackFromCart,
    required this.makeOrders,
    required this.myOrdersList,
    required this.myOrdersListPage,
    required this.myOrdersListHasMore,
    required this.isLoadingMoreMyOrdersList,
    required this.storeMealVariant,
    required this.storeMealVariantPage,
    required this.storeMealVariantHasMore,
    required this.isLoadingMoreStoreMealVariant,
    required this.mealVariantMenu,
    required this.mealVariantMenuPage,
    required this.mealVariantMenuHasMore,
    required this.isLoadingMoreMealVariantMenu,
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
      courierListPage: 1,
      courierListHasMore: true,
      isLoadingMoreCourierList: false,
      shops: AsyncValue.data(ShopsModel()),
      shopsPage: 1,
      shopsHasMore: true,
      isLoadingMoreShops: false,
      shopFoodCategory: AsyncValue.data(StoreCategories()),
      shopFoodCategoryPage: 1,
      shopFoodCategoryHasMore: true,
      isLoadingMoreShopFoodCategory: false,
      searchQuery: AsyncValue.data(SearchGlobal()),
      storeMeals: AsyncValue.data(StoreMeals()),
      storeMealsPage: 1,
      storeMealsHasMore: true,
      isLoadingMoreStoreMeals: false,
      addToCart: const AsyncValue.data(''),
      fetchCart: AsyncValue.data(CartLsit()),
      removePackFromCart: const AsyncValue.data(''),
      makeOrders: AsyncValue.data(OrderLink()),
      myOrdersList: AsyncValue.data(MyOrdersList()),
      myOrdersListPage: 1,
      myOrdersListHasMore: true,
      isLoadingMoreMyOrdersList: false,
      storeMealVariant: AsyncValue.data(StoreMealVariant()),
      storeMealVariantPage: 1,
      storeMealVariantHasMore: true,
      isLoadingMoreStoreMealVariant: false,
      mealVariantMenu: AsyncValue.data(MealVariantMenu()),
      mealVariantMenuPage: 1,
      mealVariantMenuHasMore: true,
      isLoadingMoreMealVariantMenu: false,
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
    int? courierListPage,
    bool? courierListHasMore,
    bool? isLoadingMoreCourierList,
    AsyncValue<ShopsModel>? shops,
    int? shopsPage,
    bool? shopsHasMore,
    bool? isLoadingMoreShops,
    AsyncValue<StoreCategories>? shopFoodCategory,
    int? shopFoodCategoryPage,
    bool? shopFoodCategoryHasMore,
    bool? isLoadingMoreShopFoodCategory,
    AsyncValue<SearchGlobal>? searchQuery,
    AsyncValue<StoreMeals>? storeMeals,
    int? storeMealsPage,
    bool? storeMealsHasMore,
    bool? isLoadingMoreStoreMeals,
    AsyncValue<String>? addToCart,
    AsyncValue<CartLsit>? fetchCart,
    AsyncValue<String>? removePackFromCart,
    AsyncValue<OrderLink>? makeOrders,
    AsyncValue<MyOrdersList>? myOrdersList,
    int? myOrdersListPage,
    bool? myOrdersListHasMore,
    bool? isLoadingMoreMyOrdersList,
    AsyncValue<StoreMealVariant>? storeMealVariant,
    int? storeMealVariantPage,
    bool? storeMealVariantHasMore,
    bool? isLoadingMoreStoreMealVariant,
    AsyncValue<MealVariantMenu>? mealVariantMenu,
    int? mealVariantMenuPage,
    bool? mealVariantMenuHasMore,
    bool? isLoadingMoreMealVariantMenu,
    AsyncValue<String>? addAddress,
    AsyncValue<String>? clearCart,
    AsyncValue<ParcelRequest>? bookCourier,
    AsyncValue<ParcelPaymentDetails>? makeParcelPayment,
    AsyncValue<MealDetails>? mealDetails,
    AsyncValue<String>? cancelOrder,
  }) {
    return ShopState(
      courierList: courierList ?? this.courierList,
      courierListPage: courierListPage ?? this.courierListPage,
      courierListHasMore: courierListHasMore ?? this.courierListHasMore,
      isLoadingMoreCourierList:
          isLoadingMoreCourierList ?? this.isLoadingMoreCourierList,
      shops: shops ?? this.shops,
      shopsPage: shopsPage ?? this.shopsPage,
      shopsHasMore: shopsHasMore ?? this.shopsHasMore,
      isLoadingMoreShops: isLoadingMoreShops ?? this.isLoadingMoreShops,
      shopFoodCategory: shopFoodCategory ?? this.shopFoodCategory,
      shopFoodCategoryPage: shopFoodCategoryPage ?? this.shopFoodCategoryPage,
      shopFoodCategoryHasMore:
          shopFoodCategoryHasMore ?? this.shopFoodCategoryHasMore,
      isLoadingMoreShopFoodCategory:
          isLoadingMoreShopFoodCategory ?? this.isLoadingMoreShopFoodCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      storeMeals: storeMeals ?? this.storeMeals,
      storeMealsPage: storeMealsPage ?? this.storeMealsPage,
      storeMealsHasMore: storeMealsHasMore ?? this.storeMealsHasMore,
      isLoadingMoreStoreMeals:
          isLoadingMoreStoreMeals ?? this.isLoadingMoreStoreMeals,
      addToCart: addToCart ?? this.addToCart,
      fetchCart: fetchCart ?? this.fetchCart,
      removePackFromCart: removePackFromCart ?? this.removePackFromCart,
      makeOrders: makeOrders ?? this.makeOrders,
      myOrdersList: myOrdersList ?? this.myOrdersList,
      myOrdersListPage: myOrdersListPage ?? this.myOrdersListPage,
      myOrdersListHasMore: myOrdersListHasMore ?? this.myOrdersListHasMore,
      isLoadingMoreMyOrdersList:
          isLoadingMoreMyOrdersList ?? this.isLoadingMoreMyOrdersList,
      storeMealVariant: storeMealVariant ?? this.storeMealVariant,
      storeMealVariantPage: storeMealVariantPage ?? this.storeMealVariantPage,
      storeMealVariantHasMore:
          storeMealVariantHasMore ?? this.storeMealVariantHasMore,
      isLoadingMoreStoreMealVariant:
          isLoadingMoreStoreMealVariant ?? this.isLoadingMoreStoreMealVariant,
      mealVariantMenu: mealVariantMenu ?? this.mealVariantMenu,
      mealVariantMenuPage: mealVariantMenuPage ?? this.mealVariantMenuPage,
      mealVariantMenuHasMore:
          mealVariantMenuHasMore ?? this.mealVariantMenuHasMore,
      isLoadingMoreMealVariantMenu:
          isLoadingMoreMealVariantMenu ?? this.isLoadingMoreMealVariantMenu,
      addAddress: addAddress ?? this.addAddress,
      clearCart: clearCart ?? this.clearCart,
      bookCourier: bookCourier ?? this.bookCourier,
      makeParcelPayment: makeParcelPayment ?? this.makeParcelPayment,
      mealDetails: mealDetails ?? this.mealDetails,
      cancelOrder: cancelOrder ?? this.cancelOrder,
    );
  }
}
