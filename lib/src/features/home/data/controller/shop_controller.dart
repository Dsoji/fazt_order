import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    String quantity,
    List<String> optionItem,
  ) async {
    state = state.copyWith(addToCart: const AsyncValue.loading());
    final result = await _authenticationRepository.addToCart(
      mealId,
      quantity,
      optionItem,
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
}
