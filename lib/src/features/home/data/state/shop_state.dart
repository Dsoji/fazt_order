import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/response/shops_model/shops_model.dart';

class ShopState {
  final AsyncValue<ShopsModel> shops;

  const ShopState({
    required this.shops,
  });

  factory ShopState.initial() {
    return ShopState(
      shops: AsyncValue.data(ShopsModel()),
    );
  }

  ShopState copyWith({
    AsyncValue<ShopsModel>? shops,
  }) {
    return ShopState(
      shops: shops ?? this.shops,
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
