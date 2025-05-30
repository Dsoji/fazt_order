import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/payload/sign_up_payload.dart';
import '../model/response/user_model/user_model.dart';

enum AuthenticationStatus {
  verifySignUp,
  verificationSuccessful,
  verifyForgotPassword,
  forgotPassword,
  loginSuccessful,
  login,
  idle,
}

class AuthenticationState {
  final AsyncValue<UserModel> login;
  final AuthenticationStatus status;
  final AsyncValue<UserModel> signUp;
  final AsyncValue<SignUpPayload> signUpPayload;
  final AsyncValue<String> emailVerification;
  final AsyncValue<String> emailConfirmation;
  final AsyncValue<String> forgotPassword;
  final AsyncValue<String> addressUpdate;
  // final AsyncValue<ProfilePayload> profilePayload;
  // final AsyncValue<UserProfileModel> userDetails;
  final AsyncValue<String> userName;
  final AsyncValue<String> emailChange;
  final AsyncValue<String> resetPin;
  // final AsyncValue<UploadResponse> imageUpload;

  const AuthenticationState({
    required this.login,
    required this.signUp,
    required this.status,
    required this.signUpPayload,
    required this.emailVerification,
    required this.emailConfirmation,
    required this.forgotPassword,
    required this.userName,
    required this.emailChange,
    required this.resetPin,
    required this.addressUpdate,
  });

  factory AuthenticationState.initial() {
    return AuthenticationState(
      login: AsyncValue.data(UserModel()),
      status: AuthenticationStatus.idle,
      signUp: AsyncValue.data(UserModel()),
      signUpPayload: AsyncValue.data(SignUpPayload()),
      emailVerification: const AsyncValue.data(''),
      emailConfirmation: const AsyncValue.data(''),
      forgotPassword: const AsyncValue.data(''),
      userName: const AsyncValue.data(''),
      emailChange: const AsyncValue.data(''),
      resetPin: const AsyncValue.data(''),
      addressUpdate: const AsyncValue.data(''),
    );
  }

  AuthenticationState copyWith({
    AsyncValue<UserModel>? login,
    AsyncValue<UserModel>? signUp,
    AsyncValue<SignUpPayload>? signUpPayload,
    AuthenticationStatus? status,
    AsyncValue<String>? emailVerification,
    AsyncValue<String>? emailConfirmation,
    AsyncValue<String>? forgotPassword,
    AsyncValue<String>? userName,
    AsyncValue<String>? emailChange,
    AsyncValue<String>? resetPin,
    AsyncValue<String>? addressUpdate,
  }) {
    return AuthenticationState(
      login: login ?? this.login,
      status: status ?? this.status,
      signUp: signUp ?? this.signUp,
      signUpPayload: signUpPayload ?? this.signUpPayload,
      emailVerification: emailVerification ?? this.emailVerification,
      emailConfirmation: emailConfirmation ?? this.emailConfirmation,
      forgotPassword: forgotPassword ?? this.forgotPassword,
      userName: userName ?? this.userName,
      emailChange: emailChange ?? this.emailChange,
      resetPin: resetPin ?? this.resetPin,
      addressUpdate: addressUpdate ?? this.addressUpdate,
    );
  }

  @override
  String toString() {
    return 'AuthenticationState(login: $login, )';
  }

  @override
  bool operator ==(covariant AuthenticationState other) {
    if (identical(this, other)) return true;

    return other.login == login &&
        other.signUp == signUp &&
        other.status == status;
  }

  @override
  int get hashCode {
    return login.hashCode ^ signUp.hashCode ^ status.hashCode;
  }
}
