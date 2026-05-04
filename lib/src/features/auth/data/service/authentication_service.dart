import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../common/api/api_client.dart';
import '../../../../common/api/api_request_helper.dart';
import '../../../../common/api/dio_api_client.dart';
import '../../../../common/utils/utils.dart';
import '../model/payload/address_payload.dart';
import '../model/payload/profile_payload.dart';
import '../model/response/user_model/user_model.dart';

final logger = Logger();
final authenticationServiceProvider = Provider<AuthenticationService>((ref) {
  final dioApiClient = ref.watch(dioApiClientProvider);
  final apiRequestHelper = ref.watch(apiRequestHelperProvider);
  return AuthenticationService(
    apiClient: dioApiClient,
    apiRequestHelper: apiRequestHelper,
  );
});

class AuthenticationService {
  final IApiClient apiClient;
  final ApiRequestHelper apiRequestHelper;

  AuthenticationService({
    required this.apiClient,
    required this.apiRequestHelper,
  });

  // Add getter methods to access Hive data safely
  Box get _box => Hive.box('data');
  String? get deviceId => _box.get('device_id');
  String? get storedToken => _box.get('fcm_token');
  String? get accessToken => _box.get('accessToken');
  String? get fcmToken => _box.get('fcm_token');

  Future<ResultValue<UserModel>> signInUser({
    required String email,
    String? password,
    String? code,
  }) async {
    assert(
      (password != null) ^ (code != null),
      'Provide exactly one of password or code',
    );
    logger.d('fcmToken: $fcmToken');
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'auth/login',
        data: {
          'email': email,
          if (password != null && password.isNotEmpty) 'password': password,
          if (code != null && code.isNotEmpty) 'code': code,
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      ),
      parser: (data) {
        final token = data['accessToken'];
        var box = Hive.box('data');
        final refreshToken = data['refreshToken'];
        box.put('accessToken', token);
        box.put('refreshToken', refreshToken);

        return UserModel.fromMap(data);
      },
      showErrorToast: true,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<UserModel>> registerUser({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    String? password,
    String? signupOtpToken,
    String? referralCode,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'auth/signup',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'role': "user",
          if (password != null && password.isNotEmpty) 'password': password,
          if (signupOtpToken != null && signupOtpToken.isNotEmpty)
            'signupOtpToken': signupOtpToken,
          if (referralCode != null && referralCode.isNotEmpty)
            'referredByCode': referralCode,
        },
      ),
      parser: (data) {
        final token = data['accessToken'];

        var box = Hive.box('data');
        final refreshToken = data['refreshToken'];
        box.put('accessToken', token);
        box.put('refreshToken', refreshToken);

        return UserModel.fromMap(data);
      },
      showErrorToast: true,
    );
  }

  Future<ResultValue<String>> sendEmailOtp({
    required String email,
    required String purpose,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'auth/send-email-otp',
        data: {
          'email': email,
          'purpose': purpose,
        },
      ),
      parser: (data) => BaseModel.toRawString(data),
      showErrorToast: true,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<String>> verifyEmailOtp({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'auth/verify-email-otp',
        data: {
          'email': email,
          'otp': otp,
          'purpose': purpose,
        },
      ),
      parser: (data) => (data?['otpProofToken'] ?? '').toString(),
      showErrorToast: true,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<String>> emailVerification({
    required String email,
    required String? referral,
    required String endpoint,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'auth/verify-otp',
        data: {
          "email": email,
          "referral": referral,
          "endpoint": endpoint,
        },
      ),
      parser: (data) {
        print(data);
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<String>> emailConfirmation({
    required String email,
    required String code,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'auth/verify-otp',
        data: {
          "email": email,
          "otp": code,
        },
      ),
      parser: (data) {
        print(data);
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
    );
  }

  Future<ResultValue<String>> forgotPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'user/auth/resetPassword',
        data: {
          "email": email,
          "code": code, // reset code gotten by calling emailVerification
          "password": password, // the new password
          "device": deviceId,
        },
      ),
      parser: (data) {
        print(data);
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: false,
    );
  }

  Future<ResultValue<String>> updateProfile({
    ProfilePayload? payload,
  }) async {
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
      showSuccessToast: false,
    );
  }

  Future<ResultValue<String>> updateAddress({
    AddressPayload? payload,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.patch(
        'users/update',
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
      showSuccessToast: false,
    );
  }

  Future<ResultValue<String>> resendEmailVerification({
    required String email,
  }) async {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'auth/resend-otp',
        data: {"email": email},
      ),
      parser: (data) {
        print(data);
        return BaseModel.toRawString(data);
      },
      showErrorToast: true,
      showSuccessToast: false,
    );
  }
}
