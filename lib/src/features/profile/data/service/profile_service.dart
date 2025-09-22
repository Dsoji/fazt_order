import 'package:fazt_order/src/features/profile/data/model/response/image_upload_response.dart';
import 'package:fazt_order/src/features/profile/data/model/response/transaction_history.dart';
import 'package:fazt_order/src/features/profile/data/model/response/store_details/store_details.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../common/api/api.dart';
import '../../../../common/api/api_request_helper.dart';
import '../../../../common/utils/utils.dart';
import '../../../auth/data/model/payload/profile_payload.dart';
import '../../../auth/data/model/response/user_model/user_model.dart';
// import '../../../manage_users/data/model/response/manager_list/manager_list.dart';
import '../model/payload/add_shop_payload.dart';
import '../model/payload/sales_operation_payload.dart';
import '../model/response/user_wallet/user_wallet.dart';

final logger = Logger();
//
final profileServiceProvider = Provider<ProfileeService>((ref) {
  final dioApiClient = ref.watch(dioApiClientProvider);
  final apiRequestHelper = ref.watch(apiRequestHelperProvider);
  return ProfileeService(
    apiClient: dioApiClient,
    apiRequestHelper: apiRequestHelper,
  );
});

var box = Hive.box('data');
String? deviceId = box.get('device_id');
String storedToken = box.get('fcm_token');
String? accessToken = box.get('accessToken');
String? userId = box.get('userId');
String? storeId = box.get('storeId');

class ProfileeService {
  final IApiClient apiClient;
  final ApiRequestHelper apiRequestHelper;

  ProfileeService({
    required this.apiClient,
    required this.apiRequestHelper,
  });

  Future<ResultValue<String>> updateProfile({
    ProfilePayload? payload,
  }) async {
    final String accessToken = await box.get('accessToken');

    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'user/profile/updateProfile',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: payload,
      ),
      parser: (data) {
        print(data);
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: true,
    );
  }

  Future<ResultValue<String>> createShop({
    required String businnessName,
    required String registrationNumber,
    required String proofOfRegistration,
  }) async {
    final String accessToken = await box.get('accessToken');

    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'stores',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: {
          "businessName": businnessName,
          "registrationNumber": registrationNumber,
          "proofOfRegistration": proofOfRegistration
        },
      ),
      parser: (data) {
        print(data);
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: true,
    );
  }

  Future<ResultValue<String>> storeDetails({
    required String storeName,
    required String storeDescription,
    required String storeDisplayImage,
    required String vendorType,
    required String officialEmail,
    required String officialPhone,
    required String storeAddress,
    required String storeId,
  }) async {
    final String accessToken = await box.get('accessToken');

    return apiRequestHelper.handleApiRequest(
      () => apiClient.patch(
        'stores/details/$storeId',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: {
          "storeName": storeName,
          "storeDescription": storeDescription,
          "storeDisplayImage": storeDisplayImage,
          "officialEmail": officialEmail,
          "officialPhone": officialPhone,
          "storeAddress": storeAddress
        },
      ),
      parser: (data) {
        print(data);
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: true,
    );
  }

  Future<ResultValue<String>> bankDetails({
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String storeId,
  }) async {
    final String accessToken = await box.get('accessToken');

    return apiRequestHelper.handleApiRequest(
      () => apiClient.patch(
        'stores/bank-details/$storeId',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: {
          "bankName": bankName,
          "accountNumber": accountNumber,
          "accountName": accountName
        },
      ),
      parser: (data) {
        print(data);
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: true,
    );
  }

  Future<ResultValue<UserModel>> fetchProfile() async {
    return apiRequestHelper.handleApiRequest<UserModel>(
      () => apiClient.get(
        'users/me',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
      parser: (data) {
        print(data);
        return UserModel.fromMap(data);
      },
      showErrorToast: true,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<ImageUploadResponse>> updateImage(dynamic data) async {
    return await apiRequestHelper.handleApiRequest<ImageUploadResponse>(
      () => apiClient.post(
        'upload/image',
        data: data,
        header: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'multipart/form-data',
        },
      ),
      parser: (data) {
        return ImageUploadResponse.fromMap(data);
      },
      showErrorToast: true,
    );
  }

  Future<ResultValue<String>> shopSchedule({
    required String storeId,
    required SchedulePayload payload,
  }) async {
    final String accessToken = await box.get('accessToken');

    return apiRequestHelper.handleApiRequest(
      () => apiClient.patch(
        'stores/sales-operation/$storeId',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: payload,
      ),
      parser: (data) {
        print(data);
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: true,
    );
  }

  Future<ResultValue<String>> addManager({
    required String storeId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final String accessToken = await box.get('accessToken');

    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'stores/$storeId/managers',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: {
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "phone": phoneNumber,
          "password": password,
        },
      ),
      parser: (data) {
        print(data);
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: true,
    );
  }

  // Future<ResultValue<ManagerList>> listManage() async {
  //   final String accessToken = await box.get('accessToken');

  //   return apiRequestHelper.handleApiRequest<ManagerList>(
  //     () => apiClient.get(
  //       'users/',
  //       headers: {
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //       queryParameters: {
  //         "store": storeId,
  //         "role": "manager",
  //       },
  //     ),
  //     parser: (data) {
  //       return ManagerList.fromMap(data);
  //     },
  //     showErrorToast: true,
  //     showSuccessToast: true,
  //   );
  // }

  Future<ResultValue<String>> addShop({
    required AddShopPayload payload,
  }) async {
    final String accessToken = await box.get('accessToken');

    return apiRequestHelper.handleApiRequest(
      () => apiClient.post('shops',
          header: {
            'Authorization': 'Bearer $accessToken',
          },
          data: payload),
      parser: (data) {
        print(data);
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: true,
    );
  }

  Future<ResultValue<StoreDetails>> addMealCategory({
    required String category,
  }) async {
    return apiRequestHelper.handleApiRequest<StoreDetails>(
      () => apiClient.patch(
        'meals/category',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: {
          "category": category,
        },
      ),
      parser: (data) {
        logger.d(data);
        return StoreDetails.fromMap(data);
      },
      showErrorToast: true,
      showSuccessToast: true,
    );
  }

  Future<ResultValue<String>> addMeal({
    required String category,
    required String mealName,
    required String mealDescription,
    required String priceDescription,
    required int price,
    required bool inStock,
    required String imageUrl,
    required String shopId,
  }) async {
    final String accessToken = await box.get('accessToken');

    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'meals',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: {
          "shop": shopId,
          "category": category,
          "mealName": mealName,
          "mealDescription": mealDescription,
          "priceDescription": priceDescription,
          "mealImage": imageUrl,
          "price": price,
          "inStock": inStock,
          // "optionGroup": [
          //     "67f6d339824c82d196994e2c"
          // ]
        },
      ),
      parser: (data) {
        print(data);
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: true,
    );
  }

  Future<ResultValue<StoreDetails>> storeInfo() async {
    final String accessToken = await box.get('accessToken');

    return apiRequestHelper.handleApiRequest<StoreDetails>(
      () => apiClient.get(
        'stores/$storeId',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
      parser: (data) {
        logger.d(data);
        return StoreDetails.fromMap(data);
      },
      showErrorToast: true,
      showSuccessToast: true,
    );
  }

  Future<ResultValue<String>> newProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final String accessToken = await box.get('accessToken');

    return apiRequestHelper.handleApiRequest(
      () => apiClient.patch(
        'users/update',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: {
          "firstName": firstName,
          "lastName": lastName,
          // "email":"Temilolwa",
          "phone": phone
        },
      ),
      parser: (data) {
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: true,
    );
  }

  Future<ResultValue<UserWallet>> fetchWallet() async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'users/wallet',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
      parser: (data) {
        return UserWallet.fromMap(data);
      },
      showErrorToast: true,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<String>> verifyPayment({
    required String paymentId,
  }) async {
    final String accessToken = await box.get('accessToken');

    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'payments/verify',
        header: {
          'Authorization': 'Bearer $accessToken',
        },
        data: {
          "reference": paymentId,
        },
      ),
      parser: (data) {
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: true,
    );
  }

  Future<ResultValue<TransactionHistoryResponse>>
      fetchTransactionHistory() async {
    final String accessToken = await box.get('accessToken');

    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'payments/transactions',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
      parser: (data) {
        return TransactionHistoryResponse.fromMap(data);
      },
      showErrorToast: true,
      showSuccessToast: false,
    );
  }
}
