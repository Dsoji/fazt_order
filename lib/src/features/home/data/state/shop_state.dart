import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/response/search_global/search_global.dart';
import '../model/response/shops_model/shops_model.dart';
import '../model/response/store_categories/store_categories.dart';
import '../model/response/store_meals/store_meals.dart';

class ShopState {
  final AsyncValue<ShopsModel> shops;
  final AsyncValue<StoreCategories> shopFoodCategory;
  final AsyncValue<SearchGlobal> searchQuery;
  final AsyncValue<StoreMeals> storeMeals;

  const ShopState({
    required this.shops,
    required this.shopFoodCategory,
    required this.searchQuery,
    required this.storeMeals,
  });

  factory ShopState.initial() {
    return ShopState(
      shops: AsyncValue.data(ShopsModel()),
      shopFoodCategory: AsyncValue.data(StoreCategories()),
      searchQuery: AsyncValue.data(SearchGlobal()),
      storeMeals: AsyncValue.data(StoreMeals()),
    );
  }

  ShopState copyWith({
    AsyncValue<ShopsModel>? shops,
    AsyncValue<StoreCategories>? shopFoodCategory,
    AsyncValue<SearchGlobal>? searchQuery,
    AsyncValue<StoreMeals>? storeMeals,
  }) {
    return ShopState(
      shops: shops ?? this.shops,
      shopFoodCategory: shopFoodCategory ?? this.shopFoodCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      storeMeals: storeMeals ?? this.storeMeals,
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
