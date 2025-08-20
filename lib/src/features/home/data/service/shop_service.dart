import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../common/api/api_client.dart';
import '../../../../common/api/api_request_helper.dart';
import '../../../../common/api/dio_api_client.dart';
import '../../../../common/utils/utils.dart';
import '../model/response/cartlsit/cartlsit.dart';
import '../model/response/meal_variant_menu/meal_variant_menu.dart';
import '../model/response/my_orders_list/my_orders_list.dart';
import '../model/response/order_link/order_link.dart';
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

  Future<ResultValue<ShopsModel>> fetchShops() async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'shops',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
      parser: (data) => ShopsModel.fromMap(data),
    );
  }

  Future<ResultValue<StoreCategories>> fetchShopFoodCategory(
      String shopId) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'categories?store=$shopId',
        headers: {
          'Authorization': 'Bearer $accessToken',
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
    String categoryId,
  ) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'meals',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        queryParameters: {
          'store': storeId,
          if (categoryId.isNotEmpty) 'category': categoryId,
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
      parser: (data) => OrderLink.fromJson(data),
    );
  }

  Future<ResultValue<MyOrdersList>> fetchMyOrdersList() async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient
          .get('orders', headers: {'Authorization': 'Bearer $accessToken'}),
      parser: (data) => MyOrdersList.fromMap(data),
    );
  }

  Future<ResultValue<StoreMealVariant>> fetchStoreMealVariant(
      String shopId) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'meal-variants?shop=$shopId',
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
      parser: (data) => StoreMealVariant.fromMap(data),
    );
  }

  Future<ResultValue<MealVariantMenu>> fetchMealVariantMenu({
    String? categoryId,
    String? shopId,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'meal-variants/menu',
        headers: {'Authorization': 'Bearer $accessToken'},
        queryParameters: {
          'category': categoryId,
          'shop': shopId,
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

  Future<ResultValue<String>> clearCart(String cartId) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.patch(
        'carts/$cartId/clear',
        header: {'Authorization': 'Bearer $accessToken'},
      ),
      parser: (data) => BaseModel.toRawString(data),
    );
  }
}
