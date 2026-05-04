import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../courier/data/model/courier_list.dart';
import '../model/payload/courier_payload.dart';
import '../model/response/meal_variant_menu/meal_variant_menu.dart';
import '../model/response/my_orders_list/my_orders_list.dart';
import '../model/response/shops_model/shops_model.dart';
import '../model/response/store_categories/store_categories.dart';
import '../model/response/store_meal_variant/store_meal_variant.dart';
import '../model/response/store_meals/store_meals.dart';
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

  static const int _shopsPageSize = 20;

  Future<bool> revalidateShops() async {
    final cached = _authenticationRepository.readCachedShops();
    if (cached != null) {
      state = state.copyWith(shops: AsyncValue.data(cached));
    }
    // Fetch fresh data in background, do not set loading so cached remains visible
    final result = await _authenticationRepository.fetchShops(
      forceRefresh: true,
      page: 1,
      limit: _shopsPageSize,
    );
    return result.when(
      (error) {
        // Keep showing cached data on error
        if (!state.shops.hasValue) {
          state = state.copyWith(
              shops: AsyncValue.error(error, StackTrace.current));
        }
        return false;
      },
      (success) {
        state = state.copyWith(
          shops: AsyncValue.data(success),
          shopsPage: 1,
          shopsHasMore: _hasMore(1, success.pageCount),
        );
        return true;
      },
    );
  }

  Future<bool> fetchShops({bool forceRefresh = false}) async {
    state = state.copyWith(shops: const AsyncValue.loading());
    final result = await _authenticationRepository.fetchShops(
      forceRefresh: forceRefresh,
      page: 1,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state =
            state.copyWith(shops: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(
          shops: AsyncValue.data(success),
          shopsPage: 1,
          shopsHasMore: _hasMore(1, success.pageCount),
        );
        return true;
      },
    );
  }

  Future<bool> loadMoreShops() async {
    if (state.isLoadingMoreShops || !state.shopsHasMore) return false;
    if (!state.shops.hasValue) return false;

    state = state.copyWith(isLoadingMoreShops: true);
    final nextPage = state.shopsPage + 1;
    final result = await _authenticationRepository.fetchShops(
      forceRefresh: true,
      page: nextPage,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(isLoadingMoreShops: false);
        return false;
      },
      (success) {
        final current = state.shops.value ?? ShopsModel();
        final merged = current.copyWith(
          total: success.total ?? current.total,
          pageCount: success.pageCount ?? current.pageCount,
          results: [
            ...?current.results,
            ...?success.results,
          ],
        );
        state = state.copyWith(
          shops: AsyncValue.data(merged),
          shopsPage: nextPage,
          shopsHasMore: _hasMore(nextPage, merged.pageCount),
          isLoadingMoreShops: false,
        );
        return true;
      },
    );
  }

  bool _hasMore(int currentPage, int? pageCount) {
    if (pageCount == null) return false;
    return currentPage < pageCount;
  }

  Future<bool> fetchShopFoodCategory(String shopId) async {
    state = state.copyWith(shopFoodCategory: const AsyncValue.loading());
    final result = await _authenticationRepository.fetchShopFoodCategory(
      shopId,
      page: 1,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            shopFoodCategory: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(
          shopFoodCategory: AsyncValue.data(success),
          shopFoodCategoryPage: 1,
          shopFoodCategoryHasMore: _hasMore(1, success.pageCount),
        );
        return true;
      },
    );
  }

  Future<bool> loadMoreShopFoodCategory(String shopId) async {
    if (state.isLoadingMoreShopFoodCategory ||
        !state.shopFoodCategoryHasMore) {
      return false;
    }
    if (!state.shopFoodCategory.hasValue) return false;

    state = state.copyWith(isLoadingMoreShopFoodCategory: true);
    final nextPage = state.shopFoodCategoryPage + 1;
    final result = await _authenticationRepository.fetchShopFoodCategory(
      shopId,
      page: nextPage,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(isLoadingMoreShopFoodCategory: false);
        return false;
      },
      (success) {
        final current = state.shopFoodCategory.value ?? StoreCategories();
        final merged = current.copyWith(
          total: success.total ?? current.total,
          pageCount: success.pageCount ?? current.pageCount,
          results: [
            ...?current.results,
            ...?success.results,
          ],
        );
        state = state.copyWith(
          shopFoodCategory: AsyncValue.data(merged),
          shopFoodCategoryPage: nextPage,
          shopFoodCategoryHasMore: _hasMore(nextPage, merged.pageCount),
          isLoadingMoreShopFoodCategory: false,
        );
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
    final result = await _authenticationRepository.fetchShopFood(
      storeId,
      categoryId,
      page: 1,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            storeMeals: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(
          storeMeals: AsyncValue.data(success),
          storeMealsPage: 1,
          storeMealsHasMore: _hasMore(1, success.pageCount),
        );
        return true;
      },
    );
  }

  Future<bool> loadMoreShopFood(String storeId, String categoryId) async {
    if (state.isLoadingMoreStoreMeals || !state.storeMealsHasMore) return false;
    if (!state.storeMeals.hasValue) return false;

    state = state.copyWith(isLoadingMoreStoreMeals: true);
    final nextPage = state.storeMealsPage + 1;
    final result = await _authenticationRepository.fetchShopFood(
      storeId,
      categoryId,
      page: nextPage,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(isLoadingMoreStoreMeals: false);
        return false;
      },
      (success) {
        final current = state.storeMeals.value ?? StoreMeals();
        final merged = current.copyWith(
          total: success.total ?? current.total,
          pageCount: success.pageCount ?? current.pageCount,
          results: [
            ...?current.results,
            ...?success.results,
          ],
        );
        state = state.copyWith(
          storeMeals: AsyncValue.data(merged),
          storeMealsPage: nextPage,
          storeMealsHasMore: _hasMore(nextPage, merged.pageCount),
          isLoadingMoreStoreMeals: false,
        );
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
    final result = await _authenticationRepository.fetchMyOrdersList(
      page: 1,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            myOrdersList: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(
          myOrdersList: AsyncValue.data(success),
          myOrdersListPage: 1,
          myOrdersListHasMore: _hasMore(1, success.pageCount),
        );
        return true;
      },
    );
  }

  Future<bool> loadMoreMyOrdersList() async {
    if (state.isLoadingMoreMyOrdersList || !state.myOrdersListHasMore) {
      return false;
    }
    if (!state.myOrdersList.hasValue) return false;

    state = state.copyWith(isLoadingMoreMyOrdersList: true);
    final nextPage = state.myOrdersListPage + 1;
    final result = await _authenticationRepository.fetchMyOrdersList(
      page: nextPage,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(isLoadingMoreMyOrdersList: false);
        return false;
      },
      (success) {
        final current = state.myOrdersList.value ?? MyOrdersList();
        final merged = current.copyWith(
          total: success.total ?? current.total,
          pageCount: success.pageCount ?? current.pageCount,
          results: [
            ...?current.results,
            ...?success.results,
          ],
        );
        state = state.copyWith(
          myOrdersList: AsyncValue.data(merged),
          myOrdersListPage: nextPage,
          myOrdersListHasMore: _hasMore(nextPage, merged.pageCount),
          isLoadingMoreMyOrdersList: false,
        );
        return true;
      },
    );
  }

  Future<bool> cancelOrder(String orderId) async {
    state = state.copyWith(cancelOrder: const AsyncValue.loading());
    final result = await _authenticationRepository.cancelOrder(orderId);

    return result.when(
      (error) {
        state = state.copyWith(
            cancelOrder: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(cancelOrder: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> fetchStoreMealVariant(String shopId) async {
    state = state.copyWith(storeMealVariant: const AsyncValue.loading());
    final result = await _authenticationRepository.fetchStoreMealVariant(
      shopId,
      page: 1,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            storeMealVariant: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(
          storeMealVariant: AsyncValue.data(success),
          storeMealVariantPage: 1,
          storeMealVariantHasMore: _hasMore(1, success.pageCount),
        );
        return true;
      },
    );
  }

  Future<bool> loadMoreStoreMealVariant(String shopId) async {
    if (state.isLoadingMoreStoreMealVariant ||
        !state.storeMealVariantHasMore) {
      return false;
    }
    if (!state.storeMealVariant.hasValue) return false;

    state = state.copyWith(isLoadingMoreStoreMealVariant: true);
    final nextPage = state.storeMealVariantPage + 1;
    final result = await _authenticationRepository.fetchStoreMealVariant(
      shopId,
      page: nextPage,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(isLoadingMoreStoreMealVariant: false);
        return false;
      },
      (success) {
        final current = state.storeMealVariant.value ?? StoreMealVariant();
        final merged = current.copyWith(
          total: success.total ?? current.total,
          pageCount: success.pageCount ?? current.pageCount,
          results: [
            ...?current.results,
            ...?success.results,
          ],
        );
        state = state.copyWith(
          storeMealVariant: AsyncValue.data(merged),
          storeMealVariantPage: nextPage,
          storeMealVariantHasMore: _hasMore(nextPage, merged.pageCount),
          isLoadingMoreStoreMealVariant: false,
        );
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
      page: 1,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            mealVariantMenu: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(
          mealVariantMenu: AsyncValue.data(success),
          mealVariantMenuPage: 1,
          mealVariantMenuHasMore: _hasMore(1, success.pageCount),
        );
        return true;
      },
    );
  }

  Future<bool> loadMoreMealVariantMenu({
    String? categoryId,
    String? shopId,
  }) async {
    if (state.isLoadingMoreMealVariantMenu ||
        !state.mealVariantMenuHasMore) {
      return false;
    }
    if (!state.mealVariantMenu.hasValue) return false;

    state = state.copyWith(isLoadingMoreMealVariantMenu: true);
    final nextPage = state.mealVariantMenuPage + 1;
    final result = await _authenticationRepository.fetchMealVariantMenu(
      categoryId: categoryId,
      shopId: shopId,
      page: nextPage,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(isLoadingMoreMealVariantMenu: false);
        return false;
      },
      (success) {
        final current = state.mealVariantMenu.value ?? MealVariantMenu();
        final merged = current.copyWith(
          total: success.total ?? current.total,
          pageCount: success.pageCount ?? current.pageCount,
          results: [
            ...?current.results,
            ...?success.results,
          ],
        );
        state = state.copyWith(
          mealVariantMenu: AsyncValue.data(merged),
          mealVariantMenuPage: nextPage,
          mealVariantMenuHasMore: _hasMore(nextPage, merged.pageCount),
          isLoadingMoreMealVariantMenu: false,
        );
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

  Future<bool> fetchCourierList() async {
    state = state.copyWith(courierList: const AsyncValue.loading());
    final result = await _authenticationRepository.fetchCourierList(
      page: 1,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            courierList: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(
          courierList: AsyncValue.data(success),
          courierListPage: 1,
          courierListHasMore: _hasMore(1, success.pageCount),
        );
        return true;
      },
    );
  }

  Future<bool> loadMoreCourierList() async {
    if (state.isLoadingMoreCourierList || !state.courierListHasMore) {
      return false;
    }
    if (!state.courierList.hasValue) return false;

    state = state.copyWith(isLoadingMoreCourierList: true);
    final nextPage = state.courierListPage + 1;
    final result = await _authenticationRepository.fetchCourierList(
      page: nextPage,
      limit: _shopsPageSize,
    );

    return result.when(
      (error) {
        state = state.copyWith(isLoadingMoreCourierList: false);
        return false;
      },
      (success) {
        final current = state.courierList.value ?? CourierListResponse();
        final merged = current.copyWith(
          total: success.total ?? current.total,
          pageCount: success.pageCount ?? current.pageCount,
          results: [
            ...?current.results,
            ...?success.results,
          ],
        );
        state = state.copyWith(
          courierList: AsyncValue.data(merged),
          courierListPage: nextPage,
          courierListHasMore: _hasMore(nextPage, merged.pageCount),
          isLoadingMoreCourierList: false,
        );
        return true;
      },
    );
  }

  Future<bool> makeParcelPayment(
      String parcelId, String paymentMethod, String deliveryType) async {
    state = state.copyWith(makeParcelPayment: const AsyncValue.loading());
    final result = await _authenticationRepository.makeParcelPayment(
        parcelId, paymentMethod, deliveryType);

    return result.when(
      (error) {
        state = state.copyWith(
            makeParcelPayment: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(makeParcelPayment: AsyncValue.data(success));
        return true;
      },
    );
  }
}
