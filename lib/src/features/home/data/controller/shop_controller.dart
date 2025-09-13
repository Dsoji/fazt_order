import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/payload/courier_payload.dart';
import '../repository/shop_repository.dart';
import '../state/shop_state.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

final shopControllerProvider =
    StateNotifierProvider<ShopController, ShopState>((ref) {
  final authenticationRepository = ref.watch(shopRepositoryProvider);
  return ShopController(
    authenticationRepository: authenticationRepository,
    ref: ref,
  );
});

class ShopController extends StateNotifier<ShopState> {
  ShopController({
    required ShopRepository authenticationRepository,
    required this.ref,
  })  : _authenticationRepository = authenticationRepository,
        super(
          ShopState.initial(),
        ) {
    // geAuthCredential();
  }

  final ShopRepository _authenticationRepository;
  final Ref ref;

  Future<bool> fetchShops() async {
    state = state.copyWith(shops: const AsyncValue.loading());
    final result = await _authenticationRepository.fetchShops();

    return result.when(
      (error) {
        state =
            state.copyWith(shops: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(shops: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> fetchShopFoodCategory(String shopId) async {
    state = state.copyWith(shopFoodCategory: const AsyncValue.loading());
    final result =
        await _authenticationRepository.fetchShopFoodCategory(shopId);

    return result.when(
      (error) {
        state = state.copyWith(
            shopFoodCategory: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(shopFoodCategory: AsyncValue.data(success));
        return true;
      },
    );
  }

  final debouncer = Debouncer(milliseconds: 350);

  Future<bool> globalSearch(
      String searchQuery, String latitude, String longitude) async {
    debouncer.run(() async {
      state = state.copyWith(searchQuery: const AsyncValue.loading());
      final result = await _authenticationRepository.globalSearch(
          searchQuery, latitude, longitude);

      result.when(
        (error) {
          state = state.copyWith(
              searchQuery: AsyncValue.error(error, StackTrace.current));
        },
        (success) {
          state = state.copyWith(searchQuery: AsyncValue.data(success));
        },
      );
    });
    return true; // This return is to satisfy the function signature, but it's not actually used in this context.
  }

  Future<bool> fetchShopFood(String storeId, String categoryId) async {
    state = state.copyWith(storeMeals: const AsyncValue.loading());
    final result =
        await _authenticationRepository.fetchShopFood(storeId, categoryId);

    return result.when(
      (error) {
        state = state.copyWith(
            storeMeals: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(storeMeals: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> addToCart(
    String mealId,
    int quantity,
    List<Map<String, dynamic>> options, {
    int? packNumber,
  }) async {
    state = state.copyWith(addToCart: const AsyncValue.loading());
    final result = await _authenticationRepository.addToCart(
      mealId,
      quantity,
      options,
      packNumber: packNumber,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            addToCart: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(addToCart: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> fetchCart() async {
    state = state.copyWith(fetchCart: const AsyncValue.loading());
    final result = await _authenticationRepository.fetchCart();

    return result.when(
      (error) {
        state = state.copyWith(
            fetchCart: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(fetchCart: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> removePackFromCart(String cartId, int packNumber) async {
    state = state.copyWith(removePackFromCart: const AsyncValue.loading());
    final result =
        await _authenticationRepository.removePackFromCart(cartId, packNumber);

    return result.when(
      (error) {
        state = state.copyWith(
            removePackFromCart: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(removePackFromCart: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> makeOrder(
    String cartId,
    String address,
    String city,
    String stateLocation,
    String long,
    String lat,
    String storeMessage,
    String riderMessage,
    String paymentMethod,
  ) async {
    state = state.copyWith(makeOrders: const AsyncValue.loading());
    final result = await _authenticationRepository.makeOrder(
      cartId,
      address,
      city,
      stateLocation,
      long,
      lat,
      storeMessage,
      riderMessage,
      paymentMethod,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            makeOrders: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(makeOrders: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> fetchMyOrdersList() async {
    state = state.copyWith(myOrdersList: const AsyncValue.loading());
    final result = await _authenticationRepository.fetchMyOrdersList();

    return result.when(
      (error) {
        state = state.copyWith(
            myOrdersList: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(myOrdersList: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> fetchStoreMealVariant(String shopId) async {
    state = state.copyWith(storeMealVariant: const AsyncValue.loading());
    final result =
        await _authenticationRepository.fetchStoreMealVariant(shopId);

    return result.when(
      (error) {
        state = state.copyWith(
            storeMealVariant: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(storeMealVariant: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> fetchMealVariantMenu({
    String? categoryId,
    String? shopId,
  }) async {
    state = state.copyWith(mealVariantMenu: const AsyncValue.loading());
    final result = await _authenticationRepository.fetchMealVariantMenu(
      categoryId: categoryId,
      shopId: shopId,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            mealVariantMenu: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(mealVariantMenu: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> addAddress(
    String address,
    String city,
    String states,
    String long,
    String lat,
  ) async {
    state = state.copyWith(addAddress: const AsyncValue.loading());
    final result = await _authenticationRepository.addAddress(
      address,
      city,
      states,
      long,
      lat,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            addAddress: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(addAddress: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> clearCart(String cartId) async {
    state = state.copyWith(clearCart: const AsyncValue.loading());
    final result = await _authenticationRepository.clearCart(cartId);

    return result.when(
      (error) {
        state = state.copyWith(
            clearCart: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(clearCart: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> bookCourier(CourierPayload payload) async {
    state = state.copyWith(bookCourier: const AsyncValue.loading());
    final result = await _authenticationRepository.bookCourier(payload);

    return result.when(
      (error) {
        state = state.copyWith(
            bookCourier: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(bookCourier: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> fetchMealDetails(String mealId) async {
    state = state.copyWith(mealDetails: const AsyncValue.loading());
    final result = await _authenticationRepository.fetchMealDetails(mealId);

    return result.when(
      (error) {
        state = state.copyWith(
            mealDetails: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(mealDetails: AsyncValue.data(success));
        return true;
      },
    );
  }
}
