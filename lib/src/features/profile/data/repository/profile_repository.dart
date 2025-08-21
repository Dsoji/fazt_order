import 'package:fazt_order/src/features/profile/data/model/response/image_upload_response.dart';
import 'package:fazt_order/src/features/profile/data/model/response/store_details/store_details.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/utils/multiple_results.dart';
import '../../../../common/utils/utils.dart';
import '../../../auth/data/model/payload/profile_payload.dart';
import '../../../auth/data/model/response/user_model/user_model.dart';
import '../model/payload/add_shop_payload.dart';
import '../model/payload/sales_operation_payload.dart';
import '../model/response/user_wallet/user_wallet.dart';
import '../service/profile_service.dart';

final profileRepositoryProvider = Provider((ref) {
  final authenticationService = ref.watch(profileServiceProvider);
  return ProfileRepository(
    authenticationService,
  );
});

class ProfileRepository {
  ProfileRepository(
    this.authService,
  );

  final ProfileeService authService;

  Future<Result<FailureHandler, String>> createShop({
    required String businnessName,
    required String registrationNumber,
    required String proofOfRegistration,
  }) async {
    try {
      final data = await authService.createShop(
        businnessName: businnessName,
        registrationNumber: registrationNumber,
        proofOfRegistration: proofOfRegistration,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update profile',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update profile'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> updatestoreDetails({
    required String storeName,
    required String storeDescription,
    required String storeDisplayImage,
    required String vendorType,
    required String officialEmail,
    required String officialPhone,
    required String storeAddress,
    required String storeId,
  }) async {
    try {
      final data = await authService.storeDetails(
        storeName: storeName,
        storeDescription: storeDescription,
        storeDisplayImage: storeDisplayImage,
        vendorType: vendorType,
        officialEmail: officialEmail,
        officialPhone: officialPhone,
        storeAddress: storeAddress,
        storeId: storeId,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update profile',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update profile'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> bankDetails({
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String storeId,
  }) async {
    try {
      final data = await authService.bankDetails(
        bankName: bankName,
        accountNumber: accountNumber,
        accountName: accountName,
        storeId: storeId,
      );
      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update profile',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update profile'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> updateProfile({
    ProfilePayload? payload,
  }) async {
    try {
      final data = await authService.updateProfile(payload: payload);

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update profile',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update profile'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, UserModel>> fetchProfile() async {
    try {
      final data = await authService.fetchProfile();

      if (data.isSuccess && data.value != null) {
        final profile = data.value!;

        // Save profile to Hive as a Map
        var box = Hive.box('data');

        await box.put('userProfile', profile.toMap());
        return Success(data.value ?? UserModel());
      } else {
        var box = Hive.box('data');
        final cachedMap = box.get('userProfile');

        if (cachedMap != null && cachedMap is Map<String, dynamic>) {
          final cachedProfile = UserModel.fromMap(cachedMap);
          return Success(cachedProfile);
        }

        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update profile',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update profile'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      var box = Hive.box('data');
      final cachedMap = box.get('userProfile');

      if (cachedMap != null && cachedMap is Map<String, dynamic>) {
        final cachedProfile = UserModel.fromMap(cachedMap);
        return Success(cachedProfile);
      }

      return Error(failure);
    }
  }

  Future<Result<FailureHandler, ImageUploadResponse>> uploadImage(
      dynamic payload) async {
    try {
      final data = await authService.updateImage(payload);

      if (data.isSuccess) {
        return Success(data.value ?? ImageUploadResponse());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update image',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update image'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> shopSchedule({
    required String storeId,
    required SchedulePayload payload,
  }) async {
    try {
      final data = await authService.shopSchedule(
        storeId: storeId,
        payload: payload,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update schedule',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update schedule'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  // Future<Result<FailureHandler, ManagerList>> listManager() async {
  //   try {
  //     final data = await authService.listManage();

  //     if (data.isSuccess) {
  //       return Success(data.value ?? ManagerList());
  //     } else {
  //       return Error(
  //         data.error ??
  //             FailureHandler(
  //               message: 'Failed to fetch manager list',
  //               stackTrace: StackTrace.current,
  //               exception: Exception('Failed to fetch manager list'),
  //             ),
  //       );
  //     }
  //   } on FailureHandler catch (failure) {
  //     return Error(failure);
  //   }
  // }

  Future<Result<FailureHandler, String>> addManager({
    required String storeId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final data = await authService.addManager(
        storeId: storeId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to add Manager',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to add Manager'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> addShop({
    required AddShopPayload payload,
  }) async {
    try {
      final data = await authService.addShop(payload: payload);

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to add shop',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to add shop'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, StoreDetails>> addMealCategory({
    required String category,
  }) async {
    try {
      final data = await authService.addMealCategory(category: category);

      if (data.isSuccess && data.value != null) {
        final profile = data.value!;

        // Save profile to Hive as a Map
        var box = Hive.box('data');

        await box.put('storeInfo', profile.toMap());
        return Success(data.value ?? StoreDetails());
      } else {
        var box = Hive.box('data');
        final cachedMap = box.get('userProfile');

        if (cachedMap != null && cachedMap is Map<String, dynamic>) {
          final cachedProfile = StoreDetails.fromMap(cachedMap);
          return Success(cachedProfile);
        }

        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update profile',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update profile'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      var box = Hive.box('data');
      final cachedMap = box.get('userProfile');

      if (cachedMap != null && cachedMap is Map<String, dynamic>) {
        final cachedProfile = StoreDetails.fromMap(cachedMap);
        return Success(cachedProfile);
      }

      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> addMeal({
    required String category,
    required String mealName,
    required String mealDescription,
    required String priceDescription,
    required int price,
    required bool inStock,
    required String imageUrl,
    required String shopId,
  }) async {
    try {
      final data = await authService.addMeal(
        category: category,
        mealName: mealName,
        mealDescription: mealDescription,
        priceDescription: priceDescription,
        price: price,
        inStock: inStock,
        imageUrl: imageUrl,
        shopId: shopId,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to add meal',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to add meal'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, StoreDetails>> storeDetails() async {
    try {
      final data = await authService.storeInfo();

      if (data.isSuccess && data.value != null) {
        final profile = data.value!;

        // Save profile to Hive as a Map
        var box = Hive.box('data');

        await box.put('storeInfo', profile.toMap());
        return Success(data.value ?? StoreDetails());
      } else {
        var box = Hive.box('data');
        final cachedMap = box.get('userProfile');

        if (cachedMap != null && cachedMap is Map<String, dynamic>) {
          final cachedProfile = StoreDetails.fromMap(cachedMap);
          return Success(cachedProfile);
        }

        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update profile',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update profile'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      var box = Hive.box('data');
      final cachedMap = box.get('userProfile');

      if (cachedMap != null && cachedMap is Map<String, dynamic>) {
        final cachedProfile = StoreDetails.fromMap(cachedMap);
        return Success(cachedProfile);
      }

      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> newProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final data = await authService.newProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to add meal',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to add meal'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, UserWallet>> fetchWallet() async {
    try {
      final data = await authService.fetchWallet();

      if (data.isSuccess) {
        return Success(data.value ?? UserWallet());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch wallet',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch wallet'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }
}
