import 'package:fazt_order/src/features/home/data/model/response/store_meals/store_meals.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/utils/failures.dart';
import '../../../../common/utils/multiple_results.dart';
import '../model/response/cart_lsit/cart_lsit.dart';
import '../model/response/search_global/search_global.dart';
import '../model/response/shops_model/shops_model.dart';
import '../model/response/store_categories/store_categories.dart';
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

  Future<Result<FailureHandler, ShopsModel>> fetchShops() async {
    try {
      // Try to get data from Hive cache first
      final box = Hive.box('data');
      final cachedData = box.get('shops');

      if (cachedData != null) {
        return Success(ShopsModel.fromJson(cachedData));
      }

      // If no cache, fetch from API
      final data = await authService.fetchShops();

      if (data.isSuccess) {
        // Store successful response in Hive
        final shopsData = data.value ?? ShopsModel();
        await box.put('shops', shopsData.toJson());
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
      String shopId) async {
    try {
      final data = await authService.fetchShopFoodCategory(shopId);

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
    String categoryId,
  ) async {
    try {
      final data = await authService.fetchShopFood(storeId, categoryId);

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
}
