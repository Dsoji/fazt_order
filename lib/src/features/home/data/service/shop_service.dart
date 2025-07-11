import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../common/api/api_client.dart';
import '../../../../common/api/api_request_helper.dart';
import '../../../../common/api/dio_api_client.dart';
import '../model/response/shops_model/shops_model.dart';

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

  Future<ResultValue<ShopsModel>> fetchShopFoodCategory(String shopId) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'categories?store=$shopId',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
      parser: (data) => ShopsModel.fromMap(data),
    );
  }

  Future<ResultValue<String>> globalSearch(
      String searchQuery, String latitude, String longitude) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'meals/search?',
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        queryParameters: {
          'keyword': searchQuery,
          'latitude': latitude,
          'longitude': longitude,
          'limit': 50,
          'radius': 10000,
        },
      ),
      parser: (data) => data,
    );
  }

  // Future<ResultValue<UserModel>> signInUser({
  //   required String email,
  //   required String password,
  // }) async {
  //   return apiRequestHelper.handleApiRequest(
  //     () => apiClient.post(
  //       'auth/login',
  //       data: {
  //         'email': email,
  //         'password': password,
  //       },
  //     ),
  //     parser: (data) {
  //       final token = data['accessToken'];
  //       final userId = data['user']['id'];
  //       var box = Hive.box('data');
  //       final refreshToken = data['refreshToken'];
  //       box.put('accessToken', token);
  //       box.put('userId', userId);
  //       box.put('refreshToken', refreshToken);

  //       return UserModel.fromMap(data);
  //     },
  //     showErrorToast: true,
  //     showSuccessToast: true,
  //   );
  // }

  // Future<ResultValue<UserModel>> registerUser({
  //   required String email,
  //   required String password,
  //   required String firstName,
  //   required String lastName,
  //   required String phone,
  // }) async {
  //   return apiRequestHelper.handleApiRequest(
  //     () => apiClient.post(
  //       'auth/signup',
  //       data: {
  //         'firstName': firstName,
  //         'lastName': lastName,
  //         'email': email,
  //         'phone': phone,
  //         'role': "user",
  //         'password': password,
  //       },
  //     ),
  //     parser: (data) {
  //       print(data);
  //       final token = data['accessToken'];
  //       var box = Hive.box('data');
  //       box.put('accessToken', token);
  //       return UserModel.fromMap(data);
  //     },
  //     showErrorToast: true,
  //   );
  // }

  // Future<ResultValue<String>> emailVerification({
  //   required String email,
  //   required String? referral,
  //   required String endpoint,
  // }) async {
  //   return apiRequestHelper.handleApiRequest(
  //     () => apiClient.post(
  //       'auth/verify-otp',
  //       data: {
  //         "email": email,
  //         "referral": referral,
  //         "endpoint": endpoint,
  //       },
  //     ),
  //     parser: (data) {
  //       print(data);
  //       return BaseModel.toRawString(data);
  //     },
  //     showErrorToast: true,
  //     showSuccessToast: true,
  //   );
  // }

  // Future<ResultValue<String>> emailConfirmation({
  //   required String email,
  //   required String code,
  // }) async {
  //   return apiRequestHelper.handleApiRequest(
  //     () => apiClient.post(
  //       'auth/verify-otp',
  //       data: {
  //         "email": email,
  //         "otp": code,
  //       },
  //     ),
  //     parser: (data) {
  //       print(data);
  //       return BaseModel.toRawString(data);
  //     },
  //     showErrorToast: true,
  //   );
  // }

  // Future<ResultValue<String>> forgotPassword({
  //   required String email,
  //   required String code,
  //   required String password,
  // }) async {
  //   return apiRequestHelper.handleApiRequest(
  //     () => apiClient.post(
  //       'user/auth/resetPassword',
  //       data: {
  //         "email": email,
  //         "code": code, // reset code gotten by calling emailVerification
  //         "password": password, // the new password
  //         "device": deviceId,
  //       },
  //     ),
  //     parser: (data) {
  //       print(data);
  //       return BaseModel.toRawString(data);
  //     },
  //     showErrorToast: true,
  //     showSuccessToast: true,
  //   );
  // }

  // Future<ResultValue<String>> updateProfile({
  //   ProfilePayload? payload,
  // }) async {
  //   final String accessToken = await box.get('accessToken');

  //   return apiRequestHelper.handleApiRequest(
  //     () => apiClient.post(
  //       'user/profile/updateProfile',
  //       header: {
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //       data: payload,
  //     ),
  //     parser: (data) {
  //       print(data);
  //       return BaseModel.toRawString(data);
  //     },
  //     showErrorToast: true,
  //     showSuccessToast: true,
  //   );
  // }

  // Future<ResultValue<String>> updateAddress({
  //   AddressPayload? payload,
  // }) async {
  //   final String accessToken = await box.get('accessToken');

  //   return apiRequestHelper.handleApiRequest(
  //     () => apiClient.patch(
  //       'users/update',
  //       header: {
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //       data: payload,
  //     ),
  //     parser: (data) {
  //       print(data);
  //       return BaseModel.toRawString(data);
  //     },
  //     showErrorToast: true,
  //     showSuccessToast: true,
  //   );
  // }

  // Future<ResultValue<UserProfileModel>> fetchUserInfo() async {
  //   final String accessToken = await box.get('accessToken');
  //   return await apiRequestHelper.handleApiRequest<UserProfileModel>(
  //     () => apiClient.get(
  //       'user/profile',
  //       headers: {
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //     ),
  //     parser: (data) => UserProfileModel.fromMap(data),
  //     showErrorToast: true,
  //     // showSuccessToast: true,
  //   );
  // }

  // Future<ResultValue<String>> changeUsername({required String username}) async {
  //   final String accessToken = await box.get('accessToken');
  //   return await apiRequestHelper.handleApiRequest<String>(
  //     () => apiClient.post(
  //       'user/profile/changeUsername',
  //       header: {
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //       data: {
  //         "username": username,
  //       },
  //     ),
  //     parser: (data) => BaseModel.toRawString(data),
  //     showErrorToast: true,
  //     showSuccessToast: true,
  //   );
  // }

  // Future<ResultValue<String>> changeEmail({
  //   required String email,
  //   required String code,
  // }) async {
  //   final String accessToken = await box.get('accessToken');
  //   return await apiRequestHelper.handleApiRequest<String>(
  //     () => apiClient.post(
  //       'user/profile/changeEmail',
  //       header: {
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //       data: {
  //         "email": email,
  //         "code": code,
  //         "device": deviceId,
  //       },
  //     ),
  //     parser: (data) => BaseModel.toRawString(data),
  //     showErrorToast: true,
  //     showSuccessToast: true,
  //   );
  // }

  // Future<ResultValue<String>> changePswrd({
  //   required String password,
  //   required String oldPassword,
  // }) async {
  //   final String accessToken = await box.get('accessToken');
  //   return await apiRequestHelper.handleApiRequest<String>(
  //     () => apiClient.post(
  //       'user/auth/changePassword',
  //       header: {
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //       data: {
  //         "pastword": oldPassword, // the previous password
  //         "password": password,
  //       },
  //     ),
  //     parser: (data) => BaseModel.toRawString(data),
  //     showErrorToast: true,
  //     showSuccessToast: true,
  //   );
  // }

  // Future<ResultValue<String>> changePin({
  //   required String email,
  //   required String code,
  //   required String pin,
  // }) async {
  //   return await apiRequestHelper.handleApiRequest<String>(
  //     () => apiClient.post(
  //       'user/auth/resetPin',
  //       header: {
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //       data: {
  //         "email": email,
  //         "code": code, // reset code gotten by calling emailVerification
  //         "pin": pin, // the new pin
  //         "device": deviceId
  //       },
  //     ),
  //     parser: (data) => BaseModel.toRawString(data),
  //     showErrorToast: true,
  //     showSuccessToast: true,
  //   );
  // }

  // Future<ResultValue<UploadResponse>> updateImage(dynamic data) async {
  //   return await apiRequestHelper.handleApiRequest<UploadResponse>(
  //     () => apiClient.post(
  //       'mediaUpload',
  //       data: data,
  //       header: {
  //         'Authorization': 'Bearer $accessToken',
  //       },
  //     ),
  //     parser: (data) {
  //       logger.d(data);
  //       return UploadResponse.fromMap(data);
  //     },
  //     showErrorToast: true,
  //   );
  // }
}
