import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/utils/multiple_results.dart';
import '../../../../common/utils/utils.dart';
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
    required String pswrd,
  }) async {
    try {
      final data = await authService.signInUser(
        email: email,
        password: pswrd,
      );

      if (data.isSuccess) {
        return Success(data.value ?? UserModel());
      } else {
        return Error(
          data.error ??
              FailureHandler(
                message: 'Failed to fetch products',
                stackTrace: StackTrace.current,
                exception: Exception('Failed to fetch products'),
              ),
        );
      }
    } on FailureHandler catch (failure) {
      return Error(failure);
    }
  }

  Future<Result<FailureHandler, UserModel>> authSignUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final data = await authService.registerUser(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          phone: phone);

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
