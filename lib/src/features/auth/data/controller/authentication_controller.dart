import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../providers/navigation_provider.dart';
import '../../../../common/user_location_provider.dart';
import '../../../app_update/data/controller/app_update_controller.dart';
import '../../../home/data/controller/shop_controller.dart';
import '../../../profile/data/controller/profile_controller.dart';
import '../model/payload/address_payload.dart';
import '../model/payload/profile_payload.dart';
import '../model/payload/sign_up_payload.dart';
import '../model/response/user_model/new_customer_promotion.dart';
import '../model/response/user_model/user_model.dart';
import '../repository/authentication_repository.dart';
import '../state/authentication_state.dart';
import 'package:fazt_order/src/common/device_metadata.dart';

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
    String email, {
    String? password,
    String? code,
    bool isLoggingIn = true,
  }) async {
    assert(
      (password != null) ^ (code != null),
      'Provide exactly one of password or code',
    );
    state = state.copyWith(login: const AsyncValue.loading());

    final result = await _authenticationRepository.authSignIn(
      email: email,
      pswrd: password,
      code: code,
    );
    return result.when(
      (error) {
        state = state.copyWith(
          login: AsyncValue.error(result.getError() ?? '', StackTrace.current),
        );
        return false;
      },
      (success) {
        final user = result.getSuccess() ?? UserModel();
        state = state.copyWith(
          login: AsyncValue.data(user),
          status: AuthenticationStatus.loginSuccessful,
        );
        // The login response already carries the update decision when the
        // request sent appVersion + platform + appType, so taking it here saves
        // the cold-start check a round trip. Absent block, nothing happens.
        final update = user.appUpdate;
        if (update != null) {
          ref
              .read(appUpdateControllerProvider.notifier)
              .adoptFromLogin(update.toMap());
        }
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
    required String firstName,
    required String lastName,
    required String phone,
    String? password,
    String? signupOtpToken,
    String? referralCode,
  }) async {
    state = state.copyWith(signUp: const AsyncValue.loading());

    final result = await _authenticationRepository.authSignUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      signupOtpToken: signupOtpToken,
      referralCode: referralCode,
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

  /// Asks whether this handset can still claim the new-customer promo, so the
  /// signup screen can show the offer as unavailable up front.
  ///
  /// Advisory only — the backend decides at signup regardless of what this
  /// said, and a refusal never blocks registration.
  Future<NewCustomerPromotion> checkPromoEligibility() async {
    state = state.copyWith(promoEligibility: const AsyncValue.loading());
    final result =
        await _authenticationRepository.checkNewCustomerPromoEligibility();
    final promo = result.getSuccess() ?? NewCustomerPromotion.unknown;
    state = state.copyWith(promoEligibility: AsyncValue.data(promo));
    return promo;
  }

  Future<bool> sendEmailOtp({
    required String email,
    required String purpose,
  }) async {
    state = state.copyWith(sendOtp: const AsyncValue.loading());

    final result = await _authenticationRepository.sendEmailOtp(
      email: email,
      purpose: purpose,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          sendOtp: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(sendOtp: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<String?> verifyEmailOtp({
    required String email,
    required String otp,
    required String purpose,
  }) async {
    state = state.copyWith(verifyOtp: const AsyncValue.loading());

    final result = await _authenticationRepository.verifyEmailOtp(
      email: email,
      otp: otp,
      purpose: purpose,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          verifyOtp: AsyncValue.error(error, StackTrace.current),
        );
        return null;
      },
      (token) {
        state = state.copyWith(verifyOtp: AsyncValue.data(token));
        return token;
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

  Future<void> signOut() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {
      // simulator / no-token environments
    }
    await DeviceMetadata.clearSession();
    // The box clear drops the cached coordinates; this drops the copy the
    // controller is still holding, so the next user does not inherit them.
    ref.invalidate(userLocationProvider);
    ref.invalidate(profileControllerProvider);
    ref.invalidate(shopControllerProvider);
    ref.invalidate(navigationProvider);
    state = AuthenticationState.initial();
  }

  Future<bool> resendEmailVerification(String email) async {
    state = state.copyWith(emailVerification: const AsyncValue.loading());

    final result = await _authenticationRepository.resendEmailVerification(
      email: email,
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
}
