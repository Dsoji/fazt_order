import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/utils/failures.dart';
import '../../../../common/utils/multiple_results.dart';
import '../model/response/shops_model/shops_model.dart';
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

  Future<Result<FailureHandler, ShopsModel>> fetchShopFoodCategory(
      String shopId) async {
    try {
      final data = await authService.fetchShopFoodCategory(shopId);

      if (data.isSuccess) {
        return Success(data.value ?? ShopsModel());
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

  Future<Result<FailureHandler, String>> globalSearch(
      String searchQuery, String latitude, String longitude) async {
    try {
      final data =
          await authService.globalSearch(searchQuery, latitude, longitude);

      if (data.isSuccess) {
        return Success(data.value ?? '');
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

  // Future<Result<FailureHandler, UserModel>> authSignIn({
  //   required String email,
  //   required String pswrd,
  // }) async {
  //   try {
  //     final data = await authService.signInUser(
  //       email: email,
  //       password: pswrd,
  //     );

  //     if (data.isSuccess) {
  //       return Success(data.value ?? UserModel());
  //     } else {
  //       return Error(
  //         data.error ??
  //             FailureHandler(
  //               message: 'Failed to fetch products',
  //               stackTrace: StackTrace.current,
  //               exception: Exception('Failed to fetch products'),
  //             ),
  //       );
  //     }
  //   } on FailureHandler catch (failure) {
  //     return Error(failure);
  //   }
  // }

  // Future<Result<FailureHandler, UserProfileModel>> fetchProfileDetails({
  //   ProfilePayload? payload,
  // }) async {
  //   try {
  //     final data = await authService.fetchUserInfo();

  //     if (data.isSuccess) {
  //       return Success(data.value ?? UserProfileModel());
  //     } else {
  //       return Error(
  //         data.error ??
  //             FailureHandler(
  //               message: 'Failed to update profile',
  //               stackTrace: StackTrace.current,
  //               exception: Exception('Failed to update profile'),
  //             ),
  //       );
  //     }
  //   } on FailureHandler catch (failure) {
  //     return Error(failure);
  //   }
  // }

  // Future<Result<FailureHandler, String>> updateUsername({
  //   required String name,
  // }) async {
  //   try {
  //     final data = await authService.changeUsername(
  //       username: name,
  //     );

  //     if (data.isSuccess) {
  //       return Success(data.value ?? '');
  //     } else {
  //       return Error(
  //         data.error ??
  //             FailureHandler(
  //               message: 'Failed to change username',
  //               stackTrace: StackTrace.current,
  //               exception: Exception('Failed to change username'),
  //             ),
  //       );
  //     }
  //   } on FailureHandler catch (failure) {
  //     return Error(failure);
  //   }
  // }

  // Future<Result<FailureHandler, String>> updateEmail({
  //   required String email,
  //   required String code,
  // }) async {
  //   try {
  //     final data = await authService.changeEmail(
  //       email: email,
  //       code: code,
  //     );

  //     if (data.isSuccess) {
  //       return Success(data.value ?? '');
  //     } else {
  //       return Error(
  //         data.error ??
  //             FailureHandler(
  //               message: 'Failed to change email',
  //               stackTrace: StackTrace.current,
  //               exception: Exception('Failed to change email'),
  //             ),
  //       );
  //     }
  //   } on FailureHandler catch (failure) {
  //     return Error(failure);
  //   }
  // }

  // Future<Result<FailureHandler, String>> updatePswrd({
  //   required String password,
  //   required String oldPassword,
  // }) async {
  //   try {
  //     final data = await authService.changePswrd(
  //       password: password,
  //       oldPassword: oldPassword,
  //     );

  //     if (data.isSuccess) {
  //       return Success(data.value ?? '');
  //     } else {
  //       return Error(
  //         data.error ??
  //             FailureHandler(
  //               message: 'Failed to change password',
  //               stackTrace: StackTrace.current,
  //               exception: Exception('Failed to change password'),
  //             ),
  //       );
  //     }
  //   } on FailureHandler catch (failure) {
  //     return Error(failure);
  //   }
  // }

  // Future<Result<FailureHandler, String>> updatePin({
  //   required String email,
  //   required String pin,
  //   required String code,
  // }) async {
  //   try {
  //     final data = await authService.changePin(
  //       email: email,
  //       pin: pin,
  //       code: code,
  //     );

  //     if (data.isSuccess) {
  //       return Success(data.value ?? '');
  //     } else {
  //       return Error(
  //         data.error ??
  //             FailureHandler(
  //               message: 'Failed to change password',
  //               stackTrace: StackTrace.current,
  //               exception: Exception('Failed to change password'),
  //             ),
  //       );
  //     }
  //   } on FailureHandler catch (failure) {
  //     return Error(failure);
  //   }
  // }

  // Future<Result<FailureHandler, UploadResponse>> uploadImage(
  //     dynamic payload) async {
  //   print(payload);
  //   try {
  //     final data = await authService.updateImage(payload);

  //     if (data.isSuccess) {
  //       return Success(data.value ?? UploadResponse());
  //     } else {
  //       return Error(
  //         data.error ??
  //             FailureHandler(
  //               message: 'Failed to update image',
  //               stackTrace: StackTrace.current,
  //               exception: Exception('Failed to update image'),
  //             ),
  //       );
  //     }
  //   } on FailureHandler catch (failure) {
  //     return Error(failure);
  //   }
  // }
}
