import 'package:fazt_order/src/features/courier/data/model/courier_list.dart';
import 'package:fazt_order/src/features/courier/data/model/parcel_payment_details.dart';
import 'package:fazt_order/src/features/courier/data/model/parcel_actions.dart';
import 'package:fazt_order/src/features/courier/data/model/parcel_quote.dart';
import 'package:fazt_order/src/features/courier/data/model/parcel_request.dart';
import 'package:fazt_order/src/features/home/data/model/response/meal_details/meal_details.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../common/api/api_client.dart';
import '../../../../common/api/api_request_helper.dart';
import '../../../../common/api/dio_api_client.dart';
import '../../../../common/utils/utils.dart';
import '../model/payload/courier_payload.dart';
import '../model/response/cartlsit/cart_quantity_result.dart';
import '../model/response/cartlsit/cartlsit.dart';
import '../model/response/cartlsit/remove_cart_item_result.dart';
import '../model/response/discounted_meals/discounted_meals.dart';
import '../model/response/featured_stores/featured_stores.dart';
import '../model/response/meal_variant_menu/meal_variant_menu.dart';
import '../model/response/my_orders_list/my_orders_list.dart';
import '../model/response/order_link/order_link.dart';
import '../model/response/pack_add_options/pack_add_options.dart';
import '../model/response/search_global/search_global.dart';
import '../model/response/shops_model/shops_model.dart';
import '../model/response/store_categories/store_categories.dart';
import '../model/response/store_meal_variant/store_meal_variant.dart';
import '../model/response/store_meals/store_meals.dart';

final logger = Logger();
final shopServiceProvider = Provider<ShopService>((ref) {
  final dioApiClient = ref.watch(dioApiClientProvider);
  final apiRequestHelper = ref.watch(apiRequestHelperProvider);
  return ShopService(
    apiClient: dioApiClient,
    apiRequestHelper: apiRequestHelper,
  );
});

var box = Hive.box('data');
String? deviceId = box.get('device_id');
String storedToken = box.get('fcm_token');
String? accessToken = box.get('accessToken');

class ShopService {
  final IApiClient apiClient;
  final ApiRequestHelper apiRequestHelper;

  ShopService({
    required this.apiClient,
    required this.apiRequestHelper,
  });

  /// The homepage restaurant feed.
  ///
  /// [lat]/[lng] are omitted entirely when the user's position is not known
  /// yet — a half-specified pair would be worse than none — so the very first
  /// request after a cold start can go out unlocated and get replaced as soon
  /// as coordinates land.
  Future<ResultValue<ShopsModel>> fetchShops({
    int page = 1,
    int limit = 20,
    num? lat,
    num? lng,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'shops',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        queryParameters: {
          'page': page,
          'limit': limit,
          if (lat != null && lng != null) ...{
            'lat': lat,
            'lng': lng,
          },
        },
      ),
      parser: (data) => ShopsModel.fromMap(data),
    );
  }

  Future<ResultValue<StoreCategories>> fetchShopFoodCategory(
    String shopId, {
    int page = 1,
    int limit = 20,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'categories',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        queryParameters: {
          'store': shopId,
          'page': page,
          'limit': limit,
        },
      ),
      parser: (data) => StoreCategories.fromMap(data),
    );
  }

  Future<ResultValue<SearchGlobal>> globalSearch(
      String searchQuery, String latitude, String longitude) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'meals/search?',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        queryParameters: {
          'keyword': searchQuery,
          'long': longitude,
          'lat': latitude,
          'limit': 50,
          'radius': 10000,
        },
      ),
      parser: (data) {
        logger.d(data);
        return SearchGlobal.fromMap(data);
      },
    );
  }

  Future<ResultValue<StoreMeals>> fetchShopFood(
    String storeId,
    String categoryId, {
    int page = 1,
    int limit = 20,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'meals',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        queryParameters: {
          'store': storeId,
          if (categoryId.isNotEmpty) 'category': categoryId,
          'page': page,
          'limit': limit,
        },
      ),
      parser: (data) => StoreMeals.fromMap(data),
    );
  }

  Future<ResultValue<String>> addToCart(
    String mealId,
    int quantity,
    List<Map<String, dynamic>> options, // Changed to match the new structure
    {
    int? packNumber,
  } // Optional parameter
      ) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'carts',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: {
          "mealVariant": mealId,
          "mealQuantity": quantity,
          "options": options,
          if (packNumber != null) "packNumber": packNumber,
        },
      ),
      parser: (data) => BaseModel.toRawString(data),
    );
  }

  Future<ResultValue<CartLsit>> fetchCart() async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'carts',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
      parser: (data) => CartLsit.fromMap(data),
    );
  }

  Future<ResultValue<Map<String, dynamic>>> applyCartPromoCode(
    String cartId,
    String code,
  ) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'carts/$cartId/promo-code',
        header: {'Authorization': 'Bearer $accessToken'},
        data: {'code': code.trim()},
      ),
      parser: (data) => data is Map<String, dynamic> ? data : <String, dynamic>{},
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<Map<String, dynamic>>> removeCartPromoCode(
    String cartId,
  ) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.delete(
        'carts/$cartId/promo-code',
        header: {'Authorization': 'Bearer $accessToken'},
      ),
      parser: (data) => data is Map<String, dynamic> ? data : <String, dynamic>{},
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<Map<String, dynamic>>> applyParcelPromoCode(
    String parcelId,
    String code,
  ) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'parcels/$parcelId/promo-code',
        header: {'Authorization': 'Bearer $accessToken'},
        data: {'code': code.trim()},
      ),
      parser: (data) => data is Map<String, dynamic> ? data : <String, dynamic>{},
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<Map<String, dynamic>>> removeParcelPromoCode(
    String parcelId,
  ) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.delete(
        'parcels/$parcelId/promo-code',
        header: {'Authorization': 'Bearer $accessToken'},
      ),
      parser: (data) => data is Map<String, dynamic> ? data : <String, dynamic>{},
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<String>> removePackFromCart(
      String cartId, int packNumber) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.patch(
        'carts/$cartId/pack/$packNumber',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
      parser: (data) => BaseModel.toRawString(data),
    );
  }

  /// `DELETE /carts/:cartId/items/:cartItemId` — take one item out and leave
  /// the rest of its pack in place.
  ///
  /// The pack-level [removePackFromCart] takes every item in the pack with it,
  /// so this is the only way to drop a single meal from a pack the customer
  /// wants to keep. An unknown item id comes back `404` rather than a silent
  /// no-op.
  Future<ResultValue<RemoveCartItemResult>> removeItemFromCart(
    String cartId,
    String cartItemId,
  ) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.delete(
        'carts/$cartId/items/$cartItemId',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
      parser: (data) => data is Map<String, dynamic>
          ? RemoveCartItemResult.fromMap(data)
          : RemoveCartItemResult.unknown,
    );
  }

  /// `PATCH /carts/:cartId/items/:cartItemId/quantity` — how many of the meal
  /// this item holds.
  ///
  /// [mealVariantId] is the variant already on that cart item. The backend
  /// checks it against the item rather than trusting the number alone, which
  /// is what catches a screen built from a cart that has since moved on, so
  /// read it off the item being edited instead of remembering it from earlier.
  ///
  /// [quantity] runs 1–10. `0` is the backend's spelling of "delete the whole
  /// item", which [removeItemFromCart] already says outright — send deletes
  /// there so a real delete never arrives looking like a stepper that ran one
  /// step too far.
  Future<ResultValue<CartQuantityResult>> updateMealQuantity(
    String cartId,
    String cartItemId,
    String mealVariantId,
    int quantity,
  ) {
    assert(quantity >= 1 && quantity <= 10,
        'Meal quantity is 1-10; use removeItemFromCart to delete the item.');
    return _updateCartItemQuantity(cartId, cartItemId, {
      'mealVariantId': mealVariantId,
      'mealQuantity': quantity,
    });
  }

  /// `PATCH /carts/:cartId/items/:cartItemId/quantity` — how many of one
  /// option inside the item.
  ///
  /// An option counts on its own, apart from the meal's quantity: one burger
  /// with three extra cheese is `mealQuantity: 1` and this option at `3`.
  ///
  /// [quantity] has no ceiling, and `0` takes just this option off the item
  /// and leaves the meal and the item's other options in place — a real value
  /// here, unlike the meal case above.
  Future<ResultValue<CartQuantityResult>> updateOptionQuantity(
    String cartId,
    String cartItemId,
    String optionItemVariantId,
    int quantity,
  ) {
    assert(quantity >= 0, 'Option quantity cannot be negative.');
    return _updateCartItemQuantity(cartId, cartItemId, {
      'optionItemVariantId': optionItemVariantId,
      'optionQuantity': quantity,
    });
  }

  /// One route serves both quantity changes and rejects a body carrying both
  /// pairs, so each caller above builds the pair it means and this only sends
  /// it — there is no combined signature for a caller to fill in wrongly.
  Future<ResultValue<CartQuantityResult>> _updateCartItemQuantity(
    String cartId,
    String cartItemId,
    Map<String, dynamic> body,
  ) {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.patch(
        'carts/$cartId/items/$cartItemId/quantity',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: body,
      ),
      parser: (data) => data is Map<String, dynamic>
          ? CartQuantityResult.fromMap(data)
          : CartQuantityResult.unknown,
    );
  }

  /// `GET /carts/:cartId/pack/:packNumber/add-options` — what may be added to
  /// an existing pack.
  ///
  /// The combination rules live on the backend: a pack of option-free meals
  /// takes any other option-free meal, while a pack holding a meal with options
  /// takes only more of that same meal. Asking is what keeps the picker from
  /// offering something that comes back rejected.
  Future<ResultValue<PackAddOptions>> fetchPackAddOptions(
    String cartId,
    int packNumber,
  ) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'carts/$cartId/pack/$packNumber/add-options',
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
      parser: (data) => data is Map<String, dynamic>
          ? PackAddOptions.fromMap(data)
          : PackAddOptions.none,
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<OrderLink>> makeOrder(
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
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'orders',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: {
          "cartId": cartId,
          "storeMessage": storeMessage,
          "riderMessage": riderMessage,
          "paymentMethod": paymentMethod, // card, paystack, wallet
          "location": {
            "address": address,
            "city": city,
            "state": state,
            "long": long,
            "lat": lat
          }
        },
      ),
      parser: (data) {
        logger.d('order link data: $data');
        return OrderLink.fromMap(data);
      },
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<MyOrdersList>> fetchMyOrdersList({
    int page = 1,
    int limit = 20,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'orders',
        headers: {'Authorization': 'Bearer $accessToken'},
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      ),
      parser: (data) => MyOrdersList.fromMap(data),
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<String>> cancelOrder(String orderId) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.put(
        'orders/$orderId/status',
        header: {'Authorization': 'Bearer $accessToken'},
        data: {
          "status": "cancelled",
        },
      ),
      parser: (data) => BaseModel.toRawString(data),
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<StoreMealVariant>> fetchStoreMealVariant(
    String shopId, {
    int page = 1,
    int limit = 20,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'meal-variants',
        headers: {'Authorization': 'Bearer $accessToken'},
        queryParameters: {
          'shop': shopId,
          'page': page,
          'limit': limit,
        },
      ),
      parser: (data) => StoreMealVariant.fromMap(data),
    );
  }

  Future<ResultValue<MealVariantMenu>> fetchMealVariantMenu({
    String? categoryId,
    String? shopId,
    int page = 1,
    int limit = 20,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'meal-variants/menu',
        headers: {'Authorization': 'Bearer $accessToken'},
        queryParameters: {
          'category': categoryId,
          'shop': shopId,
          'inStock': true,
          'page': page,
          'limit': limit,
        },
      ),
      parser: (data) => MealVariantMenu.fromMap(data),
    );
  }

  Future<ResultValue<String>> addAddress(
    String address,
    String city,
    String state,
    String long,
    String lat,
  ) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'addresses',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: {
          "location": {
            "address": address,
            "city": city,
            "state": state,
            "long": long,
            "lat": lat,
          }
        },
      ),
      parser: (data) => BaseModel.toRawString(data),
    );
  }

  /// `DELETE /carts/:cartId/unavailable-items` — the customer has seen the
  /// notices about lines the server removed; clear them from the cart.
  Future<ResultValue<String>> dismissUnavailableItems(String cartId) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.delete(
        'carts/$cartId/unavailable-items',
        header: {'Authorization': 'Bearer $accessToken'},
      ),
      parser: (data) => BaseModel.toRawString(data),
      showErrorToast: true,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<String>> clearCart(String cartId) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.patch(
        'carts/$cartId/clear',
        header: {'Authorization': 'Bearer $accessToken'},
      ),
      parser: (data) => BaseModel.toRawString(data),
      showErrorToast: true,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<ParcelRequest>> bookCourier(CourierPayload payload) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'parcels/',
        header: {'Authorization': 'Bearer $accessToken'},
        data: payload,
      ),
      parser: (data) => ParcelRequest.fromMap(data),
      showErrorToast: true,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<ParcelPaymentDetails>> makeParcelPayment(
      String parcelId, String paymentMethod, String deliveryType) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'orders/parcel',
        header: {'Authorization': 'Bearer $accessToken'},
        data: {
          'parcelId': parcelId,
          "paymentMethod": paymentMethod,
          "deliveryType": deliveryType,
        },
      ),
      parser: (data) => ParcelPaymentDetails.fromMap(data),
      showErrorToast: true,
      showSuccessToast: false,
    );
  }

  /// `POST /parcels/quote` — what the delivery will cost, promotion included,
  /// before the user commits to it.
  ///
  /// `distance` is deliberately not sent: the backend computes it, and it is
  /// only an input at all for clients that already know it. Letting the server
  /// work it out keeps one source of truth for the number the price is derived
  /// from.
  Future<ResultValue<ParcelQuoteResponse>> quoteParcel({
    required String pickUpAddress,
    required num pickUpLat,
    required num pickUpLong,
    required String deliveryAddress,
    required num deliveryLat,
    required num deliveryLong,
    String? promoCode,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'parcels/quote',
        header: {'Authorization': 'Bearer $accessToken'},
        data: {
          'pickUpAddress': {
            'address': pickUpAddress,
            'lat': pickUpLat,
            'long': pickUpLong,
          },
          'deliveryAddress': {
            'address': deliveryAddress,
            'lat': deliveryLat,
            'long': deliveryLong,
          },
          if ((promoCode ?? '').trim().isNotEmpty) 'promoCode': promoCode!.trim(),
        },
      ),
      parser: (data) => ParcelQuoteResponse.fromMap(data),
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  /// `GET /parcels/promotion` — the Courier section's badge.
  ///
  /// Display only. The tag is pre-formatted and rendered as-is, and it never
  /// participates in pricing: what gets charged comes from the quote, which the
  /// backend re-verifies at payment time.
  Future<ResultValue<ParcelPromotion>> fetchParcelPromotion() async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'parcels/promotion',
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
      parser: (data) {
        final promotion = data is Map<String, dynamic> ? data['promotion'] : null;
        return promotion is Map<String, dynamic>
            ? ParcelPromotion.fromMap(promotion)
            : ParcelPromotion.none;
      },
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  /// `GET /parcels/:id/actions` — what this caller may do from the current
  /// status, already filtered for their role.
  ///
  /// This is what action buttons are built from. The app deliberately holds no
  /// status list and no role table of its own; those rules live on the backend
  /// and change without the app shipping.
  Future<ResultValue<ParcelActions>> fetchParcelActions(String parcelId) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'parcels/$parcelId/actions',
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
      // A body shaped differently than expected would throw out of the parser
      // and land as a failure, which on the details screen reads as "no cancel
      // button" with nothing said about why. Parse what is there instead.
      parser: (data) => data is Map<String, dynamic>
          ? ParcelActions.fromMap(data)
          : ParcelActions.none,
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  /// `GET /parcels/:id` — one parcel.
  ///
  /// Now requires a token and is scoped to the sender, the assigned rider and
  /// admins. A parcel that isn't the caller's comes back as **404, not 403** —
  /// deliberately, so the error can't be used to probe which ids exist. Do not
  /// read a 404 here as "deleted".
  Future<ResultValue<Parcel>> fetchParcel(String parcelId) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'parcels/$parcelId',
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
      parser: (data) {
        final parcel = data is Map<String, dynamic> ? data['parcel'] ?? data : data;
        return Parcel.fromMap(parcel as Map<String, dynamic>);
      },
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  /// `POST /parcels/:id/cancel`.
  ///
  /// The window now closes when a rider accepts: `pending`, `processing` and
  /// `paid` are cancellable, and from `accepted` on the sender gets a 403. It
  /// used to run to `rider_arrived_for_pickup`. Never gate a button on this
  /// comment — `/parcels/:id/actions` is the live answer, and this line has
  /// already been wrong once. A parcel that was paid for is refunded in full to
  /// the sender's wallet as part of this call.
  ///
  /// [reason] is optional and must be at least 3 characters when given; the
  /// backend supplies a default when it is omitted.
  Future<ResultValue<String>> cancelParcel(
    String parcelId, {
    String? reason,
  }) async {
    final trimmed = reason?.trim();
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'parcels/$parcelId/cancel',
        header: {'Authorization': 'Bearer $accessToken'},
        data: {
          if (trimmed != null && trimmed.length >= 3) 'reason': trimmed,
        },
      ),
      parser: (data) => BaseModel.toRawString(data),
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  /// `PATCH /parcels/:id` — edit a parcel that is still `pending`.
  ///
  /// Only `pending` parcels are editable; past that the flow is cancel and
  /// re-request. Editing an address re-quotes automatically, so the returned
  /// request carries a fresh price.
  Future<ResultValue<ParcelRequest>> updateParcel(
    String parcelId,
    Map<String, dynamic> changes,
  ) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.patch(
        'parcels/$parcelId',
        header: {'Authorization': 'Bearer $accessToken'},
        data: changes,
      ),
      parser: (data) => ParcelRequest.fromMap(data),
      showErrorToast: true,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<MealDetails>> fetchMealDetails(String mealId) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'meal-variants/$mealId',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
      parser: (data) => MealDetails.fromMap(data),
    );
  }

  /// Meals with an active promotion near [lat]/[lng].
  ///
  /// [maxDistance] is a radius in kilometres. Coordinates are plain decimal
  /// degrees — the server handles GeoJSON ordering.
  Future<ResultValue<DiscountedMeals>> fetchDiscountedMeals({
    required num lat,
    required num lng,
    num maxDistance = 10,
    String? categories,
    int limit = 50,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'enhanced-meals/discounted',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'maxDistance': maxDistance,
          if (categories != null && categories.isNotEmpty)
            'categories': categories,
          'limit': limit,
        },
      ),
      parser: (data) => DiscountedMeals.fromMap(data),
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  /// Stores running a store-wide promotion near [lat]/[lng].
  ///
  /// Public endpoint. Note the radius param is `maxDistanceKm` here, unlike
  /// the discounted meals endpoint which uses `maxDistance`. Both are km.
  Future<ResultValue<FeaturedStores>> fetchFeaturedStores({
    required num lat,
    required num lng,
    num maxDistanceKm = 10,
    int limit = 20,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'stores/featured',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'maxDistanceKm': maxDistanceKm,
          'limit': limit,
        },
      ),
      parser: (data) => FeaturedStores.fromMap(data),
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<CourierListResponse>> fetchCourierList({
    int page = 1,
    int limit = 20,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'couriers',
        headers: {'Authorization': 'Bearer $accessToken'},
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      ),
      parser: (data) => CourierListResponse.fromMap(data),
    );
  }
}
