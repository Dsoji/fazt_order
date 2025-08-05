import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../common/api/api_client.dart';
import '../../../../common/api/api_request_helper.dart';
import '../../../../common/api/dio_api_client.dart';
import '../model/response/search_global/search_global.dart';
import '../model/response/shops_model/shops_model.dart';
import '../model/response/store_categories/store_categories.dart';
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
}
