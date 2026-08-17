import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/user_location_provider.dart';
import '../../../courier/data/model/courier_list.dart';
import '../../../courier/data/model/parcel_actions.dart';
import '../../../courier/data/model/parcel_quote.dart';
import '../../../courier/data/model/parcel_request.dart';
import '../model/payload/courier_payload.dart';
import '../model/response/cartlsit/cart_quantity_result.dart';
import '../model/response/cartlsit/item.dart';
import '../model/response/cartlsit/item_options.dart';
import '../model/response/cartlsit/remove_cart_item_result.dart';
import '../model/response/meal_variant_menu/meal_variant_menu.dart';
import '../model/response/my_orders_list/my_orders_list.dart';
import '../model/response/pack_add_options/pack_add_options.dart';
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

/// How an edit made in the meal customization sheet ended up.
enum CartItemEditOutcome {
  /// Nothing about the line changed, so nothing was sent.
  unchanged,

  /// The cart now holds what the customer asked for.
  saved,

  /// The replacement line went in but the original could not be taken out, so
  /// the pack is holding both. Only the customer can say which to drop.
  duplicated,

  /// Nothing, or only part of the edit, landed. The cart has been refetched,
  /// so the screen shows what the server actually holds.
  failed,
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

  /// Read at request time rather than captured, so a fetch always carries the
  /// most recent fix — including the one that landed while an earlier,
  /// unlocated request was still in flight.
  Coordinates? get _coordinates => ref.read(effectiveCoordinatesProvider);

  Future<bool> revalidateShops() async {
    final cached = _authenticationRepository.readCachedShops();
    if (cached != null) {
      state = state.copyWith(shops: AsyncValue.data(cached));
    }
    final coordinates = _coordinates;
    // Fetch fresh data in background, do not set loading so cached remains visible
    final result = await _authenticationRepository.fetchShops(
      forceRefresh: true,
      page: 1,
      limit: _shopsPageSize,
      lat: coordinates?.lat,
      lng: coordinates?.lng,
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
    final coordinates = _coordinates;
    final result = await _authenticationRepository.fetchShops(
      forceRefresh: forceRefresh,
      page: 1,
      limit: _shopsPageSize,
      lat: coordinates?.lat,
      lng: coordinates?.lng,
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
    final coordinates = _coordinates;
    final result = await _authenticationRepository.fetchShops(
      forceRefresh: true,
      page: nextPage,
      limit: _shopsPageSize,
      lat: coordinates?.lat,
      lng: coordinates?.lng,
    );

    return result.when(
      (error) {
        state = state.copyWith(isLoadingMoreShops: false);
        return false;
      },
      (success) {
        final current = state.shops.valueOrNull ?? ShopsModel();
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
        final current = state.storeMeals.valueOrNull ?? StoreMeals();
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
        debugPrint('[fetchCart] ${success.toJson()}');
        state = state.copyWith(fetchCart: AsyncValue.data(success));
        return true;
      },
    );
  }

  /// Loads what may be added to [packNumber] of [cartId].
  ///
  /// Called when the customer taps "Add to This Pack", so the picker shows only
  /// what the backend will actually accept. On failure the state falls back to
  /// [PackAddOptions.none], which offers nothing — better than offering an add
  /// that is rejected after the customer has chosen it.
  Future<bool> fetchPackAddOptions(String cartId, int packNumber) async {
    state = state.copyWith(packAddOptions: const AsyncValue.loading());
    final result =
        await _authenticationRepository.fetchPackAddOptions(cartId, packNumber);

    return result.when(
      (error) {
        state = state.copyWith(
            packAddOptions: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(packAddOptions: AsyncValue.data(success));
        return true;
      },
    );
  }

  /// Takes one item out of its pack, leaving the rest of the pack alone.
  ///
  /// Returns the server's answer so the caller can act on `packEmptied` — the
  /// remaining packs are renumbered when a pack empties — or null when the
  /// remove failed.
  Future<RemoveCartItemResult?> removeItemFromCart(
    String cartId,
    String cartItemId,
  ) async {
    state = state.copyWith(removeItemFromCart: const AsyncValue.loading());
    final result =
        await _authenticationRepository.removeItemFromCart(cartId, cartItemId);

    return result.when(
      (error) {
        state = state.copyWith(
            removeItemFromCart: AsyncValue.error(error, StackTrace.current));
        return null;
      },
      (success) {
        state = state.copyWith(removeItemFromCart: AsyncValue.data(success));
        return success;
      },
    );
  }

  /// Change how many of the meal a cart item holds, 1–10.
  ///
  /// Dropping to none is a delete, not a quantity: send that through
  /// [removeItemFromCart] so the pack-resequencing it already handles stays on
  /// one path.
  Future<CartQuantityResult?> updateMealQuantity(
    String cartId,
    String cartItemId,
    String mealVariantId,
    int quantity,
  ) async {
    state = state.copyWith(updateCartQuantity: const AsyncValue.loading());
    final result = await _authenticationRepository.updateMealQuantity(
      cartId,
      cartItemId,
      mealVariantId,
      quantity,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            updateCartQuantity: AsyncValue.error(error, StackTrace.current));
        return null;
      },
      (success) {
        state = state.copyWith(updateCartQuantity: AsyncValue.data(success));
        return success;
      },
    );
  }

  /// Change how many of one option inside a cart item, counted apart from the
  /// meal's own quantity. `0` takes that option off and leaves the rest of the
  /// item alone.
  Future<CartQuantityResult?> updateOptionQuantity(
    String cartId,
    String cartItemId,
    String optionItemVariantId,
    int quantity,
  ) async {
    state = state.copyWith(updateCartQuantity: const AsyncValue.loading());
    final result = await _authenticationRepository.updateOptionQuantity(
      cartId,
      cartItemId,
      optionItemVariantId,
      quantity,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            updateCartQuantity: AsyncValue.error(error, StackTrace.current));
        return null;
      },
      (success) {
        state = state.copyWith(updateCartQuantity: AsyncValue.data(success));
        return success;
      },
    );
  }

  /// Applies an edit made in the meal customization sheet to a line that is
  /// already in the cart.
  ///
  /// The cart API has no "replace this line" call, so there are two paths:
  ///
  /// * Quantities only — the meal's, an option's, or an option dropped to `0`
  ///   — go through the quantity endpoint. The line keeps its id and its place
  ///   in the pack.
  /// * An option the line does not already carry cannot be patched onto it, so
  ///   the line is rebuilt: the replacement is added to the same pack first and
  ///   the original removed after. Adding first means a failure leaves the cart
  ///   as it was rather than a hole where the meal used to be.
  ///
  /// The cart is refetched before returning either way — including on a partial
  /// failure, where the screen would otherwise keep showing an edit that only
  /// half landed.
  Future<CartItemEditOutcome> editCartItem({
    required String cartId,
    required Item item,
    required int mealQuantity,
    required List<Map<String, dynamic>> options,
  }) async {
    final itemId = item.id ?? '';
    final mealVariantId = item.mealVariant?.id ?? '';
    if (cartId.isEmpty || itemId.isEmpty || mealVariantId.isEmpty) {
      return CartItemEditOutcome.failed;
    }

    final current = <String, int>{
      for (final option in item.options ?? const <ItemOption>[])
        if ((option.optionItemVariant?.id ?? '').isNotEmpty)
          option.optionItemVariant!.id!: option.quantity ?? 0,
    };
    final desired = <String, int>{
      for (final option in options)
        if (((option['optionItemVariant'] as String?) ?? '').isNotEmpty)
          option['optionItemVariant']! as String:
              (option['quantity'] as num?)?.toInt() ?? 0,
    };

    final quantityChanged = (item.mealQuantity ?? 1).toInt() != mealQuantity;
    final addsOption = desired.keys.any((id) => !current.containsKey(id));
    final optionsChanged = addsOption ||
        current.keys.any((id) => (desired[id] ?? 0) != current[id]);

    if (!quantityChanged && !optionsChanged) {
      return CartItemEditOutcome.unchanged;
    }

    if (addsOption) {
      final added = await addToCart(
        mealVariantId,
        mealQuantity,
        options,
        packNumber: item.packNumber?.toInt(),
      );
      if (!added) return CartItemEditOutcome.failed;

      final removed = await removeItemFromCart(cartId, itemId);
      await fetchCart();
      return removed == null
          ? CartItemEditOutcome.duplicated
          : CartItemEditOutcome.saved;
    }

    var applied = true;
    if (quantityChanged) {
      applied = await updateMealQuantity(
            cartId,
            itemId,
            mealVariantId,
            mealQuantity,
          ) !=
          null;
    }
    if (applied) {
      // Only the options the line already carries are walked: a new one would
      // have taken the rebuild path above, and `0` is how the rest come off.
      for (final entry in current.entries) {
        final target = desired[entry.key] ?? 0;
        if (target == entry.value) continue;
        final updated =
            await updateOptionQuantity(cartId, itemId, entry.key, target);
        if (updated == null) {
          applied = false;
          break;
        }
      }
    }

    await fetchCart();
    return applied ? CartItemEditOutcome.saved : CartItemEditOutcome.failed;
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
    // Kept over the previous value so a pull-to-refresh doesn't blank the list
    // it is attached to: every orders screen renders the skeleton on a bare
    // loading state, and the rows the user just pulled on would flicker out
    // and back. A first load has no previous value, so it still shows one.
    state = state.copyWith(
      myOrdersList: const AsyncValue<MyOrdersList>.loading().copyWithPrevious(
        state.myOrdersList,
      ),
    );
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
        final current = state.myOrdersList.valueOrNull ?? MyOrdersList();
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

  /// Dismisses the "removed from your cart" notices and refetches the cart.
  Future<bool> dismissUnavailableItems(String cartId) async {
    final result =
        await _authenticationRepository.dismissUnavailableItems(cartId);
    final ok = result.when((error) => false, (success) => true);
    if (ok) await fetchCart();
    return ok;
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

  /// Prices the delivery the Courier form currently describes.
  ///
  /// Called as soon as both endpoints of the journey are known, so the payable
  /// total is on screen before the user commits rather than appearing for the
  /// first time on the confirm screen.
  Future<bool> quoteParcel({
    required String pickUpAddress,
    required num pickUpLat,
    required num pickUpLong,
    required String deliveryAddress,
    required num deliveryLat,
    required num deliveryLong,
    String? promoCode,
  }) async {
    state = state.copyWith(parcelQuote: const AsyncValue.loading());
    final result = await _authenticationRepository.quoteParcel(
      pickUpAddress: pickUpAddress,
      pickUpLat: pickUpLat,
      pickUpLong: pickUpLong,
      deliveryAddress: deliveryAddress,
      deliveryLat: deliveryLat,
      deliveryLong: deliveryLong,
      promoCode: promoCode,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            parcelQuote: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(parcelQuote: AsyncValue.data(success));
        return true;
      },
    );
  }

  /// Drops the current parcel quote.
  ///
  /// A price belongs to the pair of addresses it was quoted for — once those
  /// are cleared, leaving the old figure on screen would price a journey that
  /// no longer exists.
  void clearParcelQuote() {
    state = state.copyWith(
        parcelQuote: const AsyncValue.data(ParcelQuoteResponse()));
  }

  Future<bool> applyCartPromoCode(String cartId, String code) async {
    final result = await _authenticationRepository.applyCartPromoCode(cartId, code);
    return result.when(
      (error) => false,
      (success) => true,
    );
  }

  Future<bool> removeCartPromoCode(String cartId) async {
    final result = await _authenticationRepository.removeCartPromoCode(cartId);
    return result.when(
      (error) => false,
      (success) => true,
    );
  }

  Future<bool> applyParcelPromoCode(String parcelId, String code) async {
    final result = await _authenticationRepository.applyParcelPromoCode(parcelId, code);
    return result.when(
      (error) => false,
      (success) => true,
    );
  }

  Future<bool> removeParcelPromoCode(String parcelId) async {
    final result = await _authenticationRepository.removeParcelPromoCode(parcelId);
    return result.when(
      (error) => false,
      (success) => true,
    );
  }

  /// Loads the Courier promotion badge. Never fails loudly — no badge is a
  /// legitimate outcome, and one that can't be told apart from a config that
  /// was never created.
  Future<void> fetchParcelPromotion() async {
    final result = await _authenticationRepository.fetchParcelPromotion();
    result.when(
      (_) => state = state.copyWith(
          parcelPromotion: const AsyncValue.data(ParcelPromotion.none)),
      (success) =>
          state = state.copyWith(parcelPromotion: AsyncValue.data(success)),
    );
  }

  /// What the caller may do with [parcelId] right now.
  ///
  /// Refetch after anything that could move the parcel on — a cancel, a pull to
  /// refresh, a push notification — because the available actions change with
  /// the status and the app holds no copy of those rules.
  Future<bool> fetchParcelActions(String parcelId) async {
    // Kept over the previous value: a refetch after paying or cancelling would
    // otherwise empty the action area for the length of the request, and the
    // buttons the user was just looking at would flicker out.
    state = state.copyWith(
      parcelActions:
          const AsyncValue<ParcelActions>.loading().copyWithPrevious(
        state.parcelActions,
      ),
    );
    final result =
        await _authenticationRepository.fetchParcelActions(parcelId);

    return result.when(
      (error) {
        state = state.copyWith(
            parcelActions: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(parcelActions: AsyncValue.data(success));
        return true;
      },
    );
  }

  /// The parcel behind [parcelId], from `GET /parcels/:id`.
  ///
  /// Fetched for one thing the orders feed cannot supply: `pickupOTP`, which
  /// the backend releases only to the parcel's own sender. Refetch it alongside
  /// the actions after anything that moves the parcel on.
  ///
  /// Handed straight back to the caller instead of parked in state. A single
  /// shared slot holds whichever parcel was asked about last, and telling
  /// whether it was answering for *this* screen meant matching on an id the
  /// payload does not always carry — so the code it was fetched for went
  /// missing on the one screen that exists to show it. A screen that wants the
  /// parcel now holds its own.
  ///
  /// Failure is quiet on purpose, and comes back as null. The details screen
  /// has a full parcel from the feed already and this call only adds a code to
  /// it, so a 404 — which is also what a parcel that isn't the caller's returns
  /// — should hide the code block, not put an error over a screen that is
  /// otherwise fine.
  Future<Parcel?> loadParcel(String parcelId) async {
    final result = await _authenticationRepository.fetchParcel(parcelId);
    return result.when((_) => null, (parcel) => parcel);
  }

  /// Cancels a parcel, refreshing the actions afterwards so the screen reflects
  /// what is left to do.
  ///
  /// A paid parcel is refunded to the sender's wallet as part of this call.
  Future<bool> cancelParcel(String parcelId, {String? reason}) async {
    state = state.copyWith(cancelParcel: const AsyncValue.loading());
    final result = await _authenticationRepository.cancelParcel(
      parcelId,
      reason: reason,
    );

    return result.when(
      (error) {
        state = state.copyWith(
            cancelParcel: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(cancelParcel: AsyncValue.data(success));
        unawaited(fetchParcelActions(parcelId));
        return true;
      },
    );
  }

  /// Edits a parcel that is still `pending`. Editing an address re-quotes, so
  /// the refreshed request replaces the one the confirm screen is showing.
  Future<bool> updateParcel(
    String parcelId,
    Map<String, dynamic> changes,
  ) async {
    state = state.copyWith(bookCourier: const AsyncValue.loading());
    final result =
        await _authenticationRepository.updateParcel(parcelId, changes);

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

  /// Homepage "Discount Meals" rail. Empty results are normal — the section
  /// simply hides itself.
  ///
  /// When [background] is true (e.g. pull-to-refresh) the currently visible
  /// rail is preserved: no loading shimmer, and a failed refresh keeps the
  /// existing data instead of collapsing the section.
  Future<bool> fetchDiscountedMeals({
    required num lat,
    required num lng,
    num maxDistance = 10,
    String? categories,
    int limit = 50,
    bool background = false,
  }) async {
    if (!background) {
      state = state.copyWith(discountedMeals: const AsyncValue.loading());
    }
    final result = await _authenticationRepository.fetchDiscountedMeals(
      lat: lat,
      lng: lng,
      maxDistance: maxDistance,
      categories: categories,
      limit: limit,
    );

    return result.when(
      (error) {
        // Keep showing current data on a background refresh failure.
        if (!background) {
          state = state.copyWith(
              discountedMeals: AsyncValue.error(error, StackTrace.current));
        }
        return false;
      },
      (success) {
        state = state.copyWith(discountedMeals: AsyncValue.data(success));
        return true;
      },
    );
  }

  /// Homepage "Featured Restaurants" rail. Empty results are normal — the
  /// section simply hides itself.
  ///
  /// When [background] is true (e.g. pull-to-refresh) the currently visible
  /// rail is preserved: no loading shimmer, and a failed refresh keeps the
  /// existing data instead of collapsing the section.
  Future<bool> fetchFeaturedStores({
    required num lat,
    required num lng,
    num maxDistanceKm = 10,
    int limit = 20,
    bool background = false,
  }) async {
    if (!background) {
      state = state.copyWith(featuredStores: const AsyncValue.loading());
    }
    final result = await _authenticationRepository.fetchFeaturedStores(
      lat: lat,
      lng: lng,
      maxDistanceKm: maxDistanceKm,
      limit: limit,
    );

    return result.when(
      (error) {
        // Keep showing current data on a background refresh failure.
        if (!background) {
          state = state.copyWith(
              featuredStores: AsyncValue.error(error, StackTrace.current));
        }
        return false;
      },
      (success) {
        state = state.copyWith(featuredStores: AsyncValue.data(success));
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
