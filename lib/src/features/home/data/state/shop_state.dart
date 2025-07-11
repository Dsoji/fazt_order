import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/response/shops_model/shops_model.dart';

class ShopState {
  final AsyncValue<ShopsModel> shops;
  final AsyncValue<ShopsModel> shopFoodCategory;

  const ShopState({
    required this.shops,
    required this.shopFoodCategory,
  });

  factory ShopState.initial() {
    return ShopState(
      shops: AsyncValue.data(ShopsModel()),
      shopFoodCategory: AsyncValue.data(ShopsModel()),
    );
  }

  ShopState copyWith({
    AsyncValue<ShopsModel>? shops,
    AsyncValue<ShopsModel>? shopFoodCategory,
  }) {
    return ShopState(
      shops: shops ?? this.shops,
      shopFoodCategory: shopFoodCategory ?? this.shopFoodCategory,
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
