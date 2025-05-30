import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/payload/address_payload.dart';
import '../model/payload/profile_payload.dart';
import '../model/payload/sign_up_payload.dart';
import '../model/response/user_model/user_model.dart';
import '../repository/authentication_repository.dart';
import '../state/authentication_state.dart';

final authenticationControllerProvider =
    StateNotifierProvider<AuthenticationController, AuthenticationState>((ref) {
  final authenticationRepository = ref.watch(authenticationRepositoryProvider);
  return AuthenticationController(
    authenticationRepository: authenticationRepository,
    ref: ref,
  );
});

class AuthenticationController extends StateNotifier<AuthenticationState> {
  AuthenticationController({
    required AuthenticationRepository authenticationRepository,
    required this.ref,
  })  : _authenticationRepository = authenticationRepository,
        super(
          AuthenticationState.initial(),
        ) {
    // geAuthCredential();
  }

  final AuthenticationRepository _authenticationRepository;
  final Ref ref;

  void resetAuthStatus() {
    if (state.status != AuthenticationStatus.idle) {
      state = state.copyWith(status: AuthenticationStatus.idle);
    }
  }

  Future<bool> signIn(
    String email,
    String password, {
    bool isLoggingIn = true,
  }) async {
    state = state.copyWith(login: const AsyncValue.loading());

    final result = await _authenticationRepository.authSignIn(
      email: email,
      pswrd: password,
    );
    return result.when(
      (error) {
        state = state.copyWith(
          login: AsyncValue.error(result.getError() ?? '', StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          login: AsyncValue.data(result.getSuccess() ?? UserModel()),
          status: AuthenticationStatus.loginSuccessful,
        );
        return true;
      },
    );
  }

  void updateSignUpDetails(SignUpPayload newDetails) {
    state = state.copyWith(signUpPayload: AsyncValue.data(newDetails));
  }

  // void updateProfileDetails(ProfilePayload newDetails) {
  //   state = state.copyWith(profilePayload: AsyncValue.data(newDetails));
  // }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    state = state.copyWith(signUp: const AsyncValue.loading());

    final result = await _authenticationRepository.authSignUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          signUp: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          signUp: AsyncValue.data(success),
          status: AuthenticationStatus.verifySignUp,
        );
        return true;
      },
    );
  }

  Future<bool> emailVerify(
    String email,
    String? referral,
    String endpoint,
  ) async {
    state = state.copyWith(emailVerification: const AsyncValue.loading());

    final result = await _authenticationRepository.emailVerify(
      email: email,
      referral: referral,
      endpoint: endpoint,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          emailVerification: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          emailVerification: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> emailConfirm(
    String email,
    String code,
  ) async {
    state = state.copyWith(emailConfirmation: const AsyncValue.loading());

    final result = await _authenticationRepository.emailConfirm(
      email: email,
      code: code,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          emailConfirmation: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          emailConfirmation: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> forgotPassword(
    String email,
    String code,
    String password,
  ) async {
    state = state.copyWith(forgotPassword: const AsyncValue.loading());

    final result = await _authenticationRepository.forgotPassword(
      email: email,
      code: code,
      password: password,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          forgotPassword: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          forgotPassword: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> updateProfile(
    ProfilePayload payload,
  ) async {
    state = state.copyWith(forgotPassword: const AsyncValue.loading());

    final result = await _authenticationRepository.updateProfile(
      payload: payload,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          forgotPassword: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          forgotPassword: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> updateAddress(
    AddressPayload payload,
  ) async {
    state = state.copyWith(addressUpdate: const AsyncValue.loading());

    final result = await _authenticationRepository.updateAddress(
      payload: payload,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          addressUpdate: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          addressUpdate: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  // Future<bool> fetchProfile() async {
  //   state = state.copyWith(userDetails: const AsyncValue.loading());

  //   final result = await _authenticationRepository.fetchProfileDetails();

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         userDetails: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         userDetails: AsyncValue.data(success),
  //       );
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> updateUsername(
  //   String payload,
  // ) async {
  //   state = state.copyWith(userName: const AsyncValue.loading());

  //   final result = await _authenticationRepository.updateUsername(
  //     name: payload,
  //   );

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         userName: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         userName: AsyncValue.data(success),
  //       );
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> updateEmail(
  //   String payload,
  //   String code,
  // ) async {
  //   state = state.copyWith(emailChange: const AsyncValue.loading());

  //   final result = await _authenticationRepository.updateEmail(
  //     email: payload,
  //     code: code,
  //   );

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         emailChange: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         emailChange: AsyncValue.data(success),
  //       );
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> changePassword(
  //   String password,
  //   String oldPassword,
  // ) async {
  //   state = state.copyWith(forgotPassword: const AsyncValue.loading());

  //   final result = await _authenticationRepository.updatePswrd(
  //     password: password,
  //     oldPassword: oldPassword,
  //   );

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         forgotPassword: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         forgotPassword: AsyncValue.data(success),
  //       );
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> changePin(
  //   String email,
  //   String code,
  //   String pin,
  // ) async {
  //   state = state.copyWith(resetPin: const AsyncValue.loading());

  //   final result = await _authenticationRepository.updatePin(
  //     email: email,
  //     pin: pin,
  //     code: code,
  //   );

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         resetPin: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         resetPin: AsyncValue.data(success),
  //       );
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> uploadMultipleFiles(List<File> files) async {
  //   state = state.copyWith(imageUpload: const AsyncValue.loading());

  //   final formData = FormData();

  //   for (var file in files) {
  //     final fileName = file.path.split('/').last;

  //     formData.files.add(
  //       MapEntry(
  //         "file", // 👈 This must match what the backend expects
  //         await MultipartFile.fromFile(
  //           file.path,
  //           filename: fileName,
  //           contentType: MediaType('image', fileName.split('.').last),
  //         ),
  //       ),
  //     );
  //   }

  //   final result = await _authenticationRepository.uploadImage(formData);

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         imageUpload: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         imageUpload: AsyncValue.data(success ?? UploadResponse()),
  //       );
  //       return true;
  //     },
  //   );
  // }
}
