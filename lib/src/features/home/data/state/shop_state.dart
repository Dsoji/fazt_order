import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/response/search_global/search_global.dart';
import '../model/response/shops_model/shops_model.dart';

class ShopState {
  final AsyncValue<ShopsModel> shops;
  final AsyncValue<ShopsModel> shopFoodCategory;
  final AsyncValue<SearchGlobal> searchQuery;

  const ShopState({
    required this.shops,
    required this.shopFoodCategory,
    required this.searchQuery,
  });

  factory ShopState.initial() {
    return ShopState(
      shops: AsyncValue.data(ShopsModel()),
      shopFoodCategory: AsyncValue.data(ShopsModel()),
      searchQuery: AsyncValue.data(SearchGlobal()),
    );
  }

  ShopState copyWith({
    AsyncValue<ShopsModel>? shops,
    AsyncValue<ShopsModel>? shopFoodCategory,
    AsyncValue<SearchGlobal>? searchQuery,
  }) {
    return ShopState(
      shops: shops ?? this.shops,
      shopFoodCategory: shopFoodCategory ?? this.shopFoodCategory,
      searchQuery: searchQuery ?? this.searchQuery,
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
