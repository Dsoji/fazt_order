import 'package:fazt_order/src/features/courier/data/model/parcel_payment_details.dart';
import 'package:fazt_order/src/features/courier/data/model/parcel_actions.dart';
import 'package:fazt_order/src/features/courier/data/model/parcel_quote.dart';
import 'package:fazt_order/src/features/courier/data/model/parcel_request.dart';
import 'package:fazt_order/src/features/home/data/model/response/store_meals/store_meals.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/utils/failures.dart';
import '../../../../common/utils/multiple_results.dart';
import '../../../courier/data/model/courier_list.dart';
import '../model/payload/courier_payload.dart';
import '../model/response/cartlsit/cart_quantity_result.dart';
import '../model/response/cartlsit/cartlsit.dart';
import '../model/response/cartlsit/remove_cart_item_result.dart';
import '../model/response/discounted_meals/discounted_meals.dart';
import '../model/response/featured_stores/featured_stores.dart';
import '../model/response/meal_details/meal_details.dart';
import '../model/response/meal_variant_menu/meal_variant_menu.dart';
import '../model/response/my_orders_list/my_orders_list.dart';
import '../model/response/order_link/order_link.dart';
import '../model/response/pack_add_options/pack_add_options.dart';
import '../model/response/search_global/search_global.dart';
import '../model/response/shops_model/shops_model.dart';
import '../model/response/store_categories/store_categories.dart';
import '../model/response/store_meal_variant/store_meal_variant.dart';
import '../service/shop_service.dart';

final shopRepositoryProvider = Provider((ref) {
  final authenticationService = ref.watch(shopServiceProvider);
  return ShopRepository(
    authenticationService,
  );
});

class ShopRepository {
  ShopRepository(
    this.authService,
  );
  final ShopService authService;

  ShopsModel? readCachedShops() {
    final box = Hive.box('data');
    final cachedData = box.get('shops');
    if (cachedData == null) return null;
    return ShopsModel.fromJson(cachedData);
  }

  Future<Result<FailureHandler, ShopsModel>> fetchShops({
    bool forceRefresh = false,
    int page = 1,
    int limit = 20,
    num? lat,
    num? lng,
  }) async {
    try {
      final box = Hive.box('data');
      final isFirstPage = page == 1;
      final cachedData =
          (forceRefresh || !isFirstPage) ? null : box.get('shops');

      if (cachedData != null) {
        return Success(ShopsModel.fromJson(cachedData));
      }

      final data = await authService.fetchShops(
        page: page,
        limit: limit,
        lat: lat,
        lng: lng,
      );

      if (data.isSuccess) {
        final shopsData = data.value ?? ShopsModel();
        if (isFirstPage) {
          await box.put('shops', shopsData.toJson());
        }
        return Success(shopsData);
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch shops',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch shops'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, StoreCategories>> fetchShopFoodCategory(
    String shopId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await authService.fetchShopFoodCategory(shopId,
          page: page, limit: limit);

      if (data.isSuccess) {
        return Success(data.value ?? StoreCategories());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch shop food category',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch shop food category'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, SearchGlobal>> globalSearch(
      String searchQuery, String latitude, String longitude) async {
    try {
      final data =
          await authService.globalSearch(searchQuery, latitude, longitude);

      if (data.isSuccess) {
        return Success(data.value ?? SearchGlobal());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to perform global search',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to perform global search'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, StoreMeals>> fetchShopFood(
    String storeId,
    String categoryId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await authService.fetchShopFood(storeId, categoryId,
          page: page, limit: limit);

      if (data.isSuccess) {
        return Success(data.value ?? StoreMeals());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch shop food',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch shop food'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> addToCart(
    String mealId,
    int quantity,
    List<Map<String, dynamic>> options, {
    int? packNumber,
  }) async {
    try {
      final data = await authService.addToCart(
        mealId,
        quantity,
        options,
        packNumber: packNumber,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to add item to cart',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to add item to cart'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, CartLsit>> fetchCart() async {
    try {
      final data = await authService.fetchCart();

      if (data.isSuccess) {
        return Success(data.value ?? CartLsit());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch cart',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch cart'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, Map<String, dynamic>>> applyCartPromoCode(
    String cartId,
    String code,
  ) async {
    try {
      final data = await authService.applyCartPromoCode(cartId, code);
      if (data.isSuccess) {
        return Success(data.value ?? <String, dynamic>{});
      }
      return Error(
        data.error ??
            FailureHandler(
              message: 'Failed to apply cart promo code',
              stackTrace: StackTrace.current,
              exception: Exception('Failed to apply cart promo code'),
            ),
      );
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, Map<String, dynamic>>> removeCartPromoCode(
    String cartId,
  ) async {
    try {
      final data = await authService.removeCartPromoCode(cartId);
      if (data.isSuccess) {
        return Success(data.value ?? <String, dynamic>{});
      }
      return Error(
        data.error ??
            FailureHandler(
              message: 'Failed to remove cart promo code',
              stackTrace: StackTrace.current,
              exception: Exception('Failed to remove cart promo code'),
            ),
      );
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, Map<String, dynamic>>> applyParcelPromoCode(
    String parcelId,
    String code,
  ) async {
    try {
      final data = await authService.applyParcelPromoCode(parcelId, code);
      if (data.isSuccess) {
        return Success(data.value ?? <String, dynamic>{});
      }
      return Error(
        data.error ??
            FailureHandler(
              message: 'Failed to apply parcel promo code',
              stackTrace: StackTrace.current,
              exception: Exception('Failed to apply parcel promo code'),
            ),
      );
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, Map<String, dynamic>>> removeParcelPromoCode(
    String parcelId,
  ) async {
    try {
      final data = await authService.removeParcelPromoCode(parcelId);
      if (data.isSuccess) {
        return Success(data.value ?? <String, dynamic>{});
      }
      return Error(
        data.error ??
            FailureHandler(
              message: 'Failed to remove parcel promo code',
              stackTrace: StackTrace.current,
              exception: Exception('Failed to remove parcel promo code'),
            ),
      );
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> removePackFromCart(
      String cartId, int packNumber) async {
    try {
      final data = await authService.removePackFromCart(cartId, packNumber);

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to remove pack from cart',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to remove pack from cart'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, RemoveCartItemResult>> removeItemFromCart(
    String cartId,
    String cartItemId,
  ) async {
    try {
      final data = await authService.removeItemFromCart(cartId, cartItemId);

      if (data.isSuccess) {
        return Success(data.value ?? RemoveCartItemResult.unknown);
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to remove item from cart',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to remove item from cart'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, CartQuantityResult>> updateMealQuantity(
    String cartId,
    String cartItemId,
    String mealVariantId,
    int quantity,
  ) async {
    try {
      final data = await authService.updateMealQuantity(
        cartId,
        cartItemId,
        mealVariantId,
        quantity,
      );

      if (data.isSuccess) {
        return Success(data.value ?? CartQuantityResult.unknown);
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update quantity',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update quantity'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, CartQuantityResult>> updateOptionQuantity(
    String cartId,
    String cartItemId,
    String optionItemVariantId,
    int quantity,
  ) async {
    try {
      final data = await authService.updateOptionQuantity(
        cartId,
        cartItemId,
        optionItemVariantId,
        quantity,
      );

      if (data.isSuccess) {
        return Success(data.value ?? CartQuantityResult.unknown);
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update quantity',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update quantity'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, PackAddOptions>> fetchPackAddOptions(
    String cartId,
    int packNumber,
  ) async {
    try {
      final data = await authService.fetchPackAddOptions(cartId, packNumber);

      if (data.isSuccess) {
        return Success(data.value ?? PackAddOptions.none);
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to load what can be added to this pack',
                stackTrace: StackTrace.current,
                exception:
                    Exception('Failed to load what can be added to this pack'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, OrderLink>> makeOrder(
    String cartId,
    String address,
    String city,
    String state,
    String long,
    String lat,
    String storeMessage,
    String riderMessage,
    String paymentMethod,
  ) async {
    try {
      final data = await authService.makeOrder(
        cartId,
        address,
        city,
        state,
        long,
        lat,
        storeMessage,
        riderMessage,
        paymentMethod,
      );

      if (data.isSuccess) {
        return Success(data.value ?? OrderLink());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to make order, check your balance',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to make order'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, MyOrdersList>> fetchMyOrdersList({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data =
          await authService.fetchMyOrdersList(page: page, limit: limit);

      if (data.isSuccess) {
        return Success(data.value ?? MyOrdersList());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch orders list',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch orders list'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> cancelOrder(String orderId) async {
    try {
      final data = await authService.cancelOrder(orderId);

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to cancel order',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to cancel order'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, StoreMealVariant>> fetchStoreMealVariant(
    String shopId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await authService.fetchStoreMealVariant(shopId,
          page: page, limit: limit);

      if (data.isSuccess) {
        return Success(data.value ?? StoreMealVariant());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch store meal variant',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch store meal variant'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, MealVariantMenu>> fetchMealVariantMenu({
    String? categoryId,
    String? shopId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data = await authService.fetchMealVariantMenu(
        categoryId: categoryId,
        shopId: shopId,
        page: page,
        limit: limit,
      );

      if (data.isSuccess) {
        return Success(data.value ?? MealVariantMenu());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch meal variant menu',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch meal variant menu'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> addAddress(
    String address,
    String city,
    String state,
    String long,
    String lat,
  ) async {
    try {
      final data = await authService.addAddress(
        address,
        city,
        state,
        long,
        lat,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to add address',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to add address'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> dismissUnavailableItems(
      String cartId) async {
    try {
      final data = await authService.dismissUnavailableItems(cartId);

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to dismiss notice',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to dismiss notice'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> clearCart(String cartId) async {
    try {
      final data = await authService.clearCart(cartId);

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to clear cart',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to clear cart'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, ParcelRequest>> bookCourier(
      CourierPayload payload) async {
    try {
      final data = await authService.bookCourier(payload);

      if (data.isSuccess) {
        return Success(data.value ?? const ParcelRequest());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to book courier',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to book courier'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, ParcelQuoteResponse>> quoteParcel({
    required String pickUpAddress,
    required num pickUpLat,
    required num pickUpLong,
    required String deliveryAddress,
    required num deliveryLat,
    required num deliveryLong,
    String? promoCode,
  }) async {
    try {
      final data = await authService.quoteParcel(
        pickUpAddress: pickUpAddress,
        pickUpLat: pickUpLat,
        pickUpLong: pickUpLong,
        deliveryAddress: deliveryAddress,
        deliveryLat: deliveryLat,
        deliveryLong: deliveryLong,
        promoCode: promoCode,
      );

      if (data.isSuccess) {
        return Success(data.value ?? const ParcelQuoteResponse());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to price this delivery',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to price this delivery'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  /// The Courier badge. A failure resolves to "no promotion" rather than an
  /// error: the badge is decoration, and a missing one is indistinguishable
  /// from none being configured.
  Future<Result<FailureHandler, ParcelPromotion>> fetchParcelPromotion() async {
    try {
      final data = await authService.fetchParcelPromotion();
      return Success(data.value ?? ParcelPromotion.none);
    } on FailureHandler catch (_) {
      return const Success(ParcelPromotion.none);
    }
  }

  Future<Result<FailureHandler, ParcelActions>> fetchParcelActions(
      String parcelId) async {
    try {
      final data = await authService.fetchParcelActions(parcelId);

      if (data.isSuccess) {
        return Success(data.value ?? ParcelActions.none);
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to load parcel actions',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to load parcel actions'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, Parcel>> fetchParcel(String parcelId) async {
    try {
      final data = await authService.fetchParcel(parcelId);

      if (data.isSuccess) {
        return Success(data.value ?? const Parcel());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to load parcel',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to load parcel'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  /// Cancels a parcel. The backend's own message is preserved on failure — it
  /// explains *why* far better than anything generic ("the rider has already
  /// collected it. Please contact support.").
  Future<Result<FailureHandler, String>> cancelParcel(
    String parcelId, {
    String? reason,
  }) async {
    try {
      final data = await authService.cancelParcel(parcelId, reason: reason);

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to cancel this delivery',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to cancel this delivery'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, ParcelRequest>> updateParcel(
    String parcelId,
    Map<String, dynamic> changes,
  ) async {
    try {
      final data = await authService.updateParcel(parcelId, changes);

      if (data.isSuccess) {
        return Success(data.value ?? const ParcelRequest());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update this delivery',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update this delivery'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, MealDetails>> fetchMealDetails(
      String mealId) async {
    try {
      final data = await authService.fetchMealDetails(mealId);

      if (data.isSuccess) {
        return Success(data.value ?? MealDetails());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch meal details',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch meal details'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, DiscountedMeals>> fetchDiscountedMeals({
    required num lat,
    required num lng,
    num maxDistance = 10,
    String? categories,
    int limit = 50,
  }) async {
    try {
      final data = await authService.fetchDiscountedMeals(
        lat: lat,
        lng: lng,
        maxDistance: maxDistance,
        categories: categories,
        limit: limit,
      );

      if (data.isSuccess) {
        return Success(data.value ?? DiscountedMeals());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch discounted meals',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch discounted meals'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, FeaturedStores>> fetchFeaturedStores({
    required num lat,
    required num lng,
    num maxDistanceKm = 10,
    int limit = 20,
  }) async {
    try {
      final data = await authService.fetchFeaturedStores(
        lat: lat,
        lng: lng,
        maxDistanceKm: maxDistanceKm,
        limit: limit,
      );

      if (data.isSuccess) {
        return Success(data.value ?? FeaturedStores());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch featured restaurants',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch featured restaurants'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, CourierListResponse>> fetchCourierList({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final data =
          await authService.fetchCourierList(page: page, limit: limit);

      if (data.isSuccess) {
        return Success(data.value ?? CourierListResponse());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch courier list',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch courier list'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, ParcelPaymentDetails>> makeParcelPayment(
      String parcelId, String paymentMethod, String deliveryType) async {
    try {
      final data = await authService.makeParcelPayment(
          parcelId, paymentMethod, deliveryType);

      if (data.isSuccess) {
        return Success(data.value ?? const ParcelPaymentDetails());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to make parcel payment',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to make parcel payment'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }
}
