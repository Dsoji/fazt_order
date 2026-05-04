import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/utils/multiple_results.dart';
import '../../../../common/utils/utils.dart';
import '../model/payload/address_payload.dart';
import '../model/payload/profile_payload.dart';
import '../model/response/user_model/user_model.dart';
import '../service/authentication_service.dart';

final authenticationRepositoryProvider = Provider((ref) {
  final authenticationService = ref.watch(authenticationServiceProvider);
  return AuthenticationRepository(
    authenticationService,
  );
});

class AuthenticationRepository {
  AuthenticationRepository(
    this.authService,
  );

  final AuthenticationService authService;

  Future<Result<FailureHandler, UserModel>> authSignIn({
    required String email,
    String? pswrd,
    String? code,
  }) async {
    try {
      final data = await authService.signInUser(
        email: email,
        password: pswrd,
        code: code,
      );

      if (data.isSuccess) {
        return Success(data.value ?? UserModel());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to log in',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to log in'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, UserModel>> authSignUp({
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    String? password,
    String? signupOtpToken,
    String? referralCode,
  }) async {
    try {
      final data = await authService.registerUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        signupOtpToken: signupOtpToken,
        referralCode: referralCode,
      );

      if (data.isSuccess) {
        return Success(data.value ?? UserModel());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to register user',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to register user'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> sendEmailOtp({
    required String email,
    required String purpose,
  }) async {
    try {
      final data =
          await authService.sendEmailOtp(email: email, purpose: purpose);

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to send OTP',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to send OTP'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> verifyEmailOtp({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    try {
      final data = await authService.verifyEmailOtp(
        email: email,
        otp: otp,
        purpose: purpose,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Invalid or expired OTP',
                stackTrace: StackTrace.current,
                exception: Exception('Invalid or expired OTP'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> emailVerify({
    required String email,
    required String? referral,
    required String endpoint,
  }) async {
    try {
      final data = await authService.emailVerification(
        email: email,
        referral: referral,
        endpoint: endpoint,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to verify email',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to verify email'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> emailConfirm({
    required String email,
    required String code,
  }) async {
    try {
      final data = await authService.emailConfirmation(
        email: email,
        code: code,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to confirm email',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to confirm email'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> forgotPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      final data = await authService.forgotPassword(
        email: email,
        code: code,
        password: password,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to rest password',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to rest password'),
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

  Future<Result<FailureHandler, String>> updateAddress({
    AddressPayload? payload,
  }) async {
    try {
      final data = await authService.updateAddress(payload: payload);

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to update address',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to update address'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, String>> resendEmailVerification({
    required String email,
  }) async {
    try {
      final data = await authService.resendEmailVerification(
        email: email,
      );

      if (data.isSuccess) {
        return Success(data.value ?? '');
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to resend verification email',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to resend verification email'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }
}
