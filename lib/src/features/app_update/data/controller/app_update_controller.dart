import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/device_metadata.dart';

import '../model/app_update.dart';
import '../service/app_version_service.dart';

final appUpdateControllerProvider =
    StateNotifierProvider<AppUpdateController, AppUpdateState>((ref) {
  return AppUpdateController(ref.watch(appVersionServiceProvider));
});

class AppUpdateState {
  const AppUpdateState({
    this.update = AppUpdate.none,
    this.isChecking = false,
    this.isDismissing = false,
    this.handled = false,
  });

  final AppUpdate update;
  final bool isChecking;
  final bool isDismissing;

  /// The popup has already run its course this session — shown and dismissed,
  /// or checked and found nothing. Stops a rebuild or a tab change from
  /// re-presenting a prompt the user just closed.
  final bool handled;

  /// A blocking update is never "handled": it has to come back every time it
  /// is asked for, since there is no dismissal that clears it.
  bool get shouldShow => update.shouldPrompt && (update.isBlocking || !handled);

  AppUpdateState copyWith({
    AppUpdate? update,
    bool? isChecking,
    bool? isDismissing,
    bool? handled,
  }) =>
      AppUpdateState(
        update: update ?? this.update,
        isChecking: isChecking ?? this.isChecking,
        isDismissing: isDismissing ?? this.isDismissing,
        handled: handled ?? this.handled,
      );
}

class AppUpdateController extends StateNotifier<AppUpdateState> {
  AppUpdateController(this._service, {bool Function()? isSignedIn})
      : _isSignedIn = isSignedIn ?? _hasSession,
        super(const AppUpdateState());

  final AppVersionService _service;

  /// Injected so the dismissal path can be tested without a Hive box.
  final bool Function() _isSignedIn;

  static bool _hasSession() => DeviceMetadata.hasSession;

  /// Asks the backend whether this build should prompt.
  ///
  /// Failure is silent and lands on [AppUpdate.none] — startup must not be
  /// gated on this call succeeding.
  Future<void> check() => _check(keepHandled: false);

  /// Re-asks off the back of a pull-to-refresh, so a version published while
  /// the app was open is picked up without a relaunch.
  ///
  /// Unlike [check] this keeps [AppUpdateState.handled], so an optional popup
  /// the user already closed doesn't come back on every pull. Neither of the
  /// two cases that must reappear is affected: a blocking update ignores
  /// `handled` outright, and a newly published version clears it.
  Future<void> refresh() => _check(keepHandled: true);

  Future<void> _check({required bool keepHandled}) async {
    if (state.isChecking) return;
    final offered = state.update.latestVersion;
    state = state.copyWith(isChecking: true);
    final result = await _service.check();
    final update = result.value ?? AppUpdate.none;
    state = state.copyWith(
      update: update,
      isChecking: false,
      handled: keepHandled && state.handled && update.latestVersion == offered,
    );
  }

  /// Takes the decision the login response already carried, so a cold start
  /// straight after signing in doesn't pay for a second round trip.
  ///
  /// [data] is the raw `appUpdate` block; it is simply absent when the login
  /// request didn't send all three of `appVersion`, `platform` and `appType`.
  void adoptFromLogin(dynamic data) {
    if (data is! Map<String, dynamic>) return;
    state = state.copyWith(
      update: AppUpdate.fromMap(data).copyWith(
        // Stamped from the cache `main` warmed up, so the decision is checked
        // against the build actually installed here and not the version string
        // the server echoed back.
        installedVersion: DeviceMetadata.cachedAppVersion,
      ),
      handled: false,
    );
  }

  /// Records a dismissal and reports whether the popup may now close.
  ///
  /// `false` means the backend refused — there was nothing to dismiss, or the
  /// update turned compulsory between the check and the tap. Either way the
  /// caller keeps the popup up and re-renders from the state, which by then
  /// holds whatever the backend last told us.
  Future<bool> dismiss() async {
    if (state.update.isBlocking) return false;

    // Dismissals are spent server-side and there is nothing to spend without a
    // token: an anonymous caller's tally reads 0 on every check, so the limit
    // only starts biting once someone signs in. Calling anyway earns a 401,
    // which the Dio interceptor reads as an expired session — toast, cleared
    // box, and a redirect to onboarding, all off a tap on "Not now". Close the
    // popup locally instead; there is no allowance to record.
    if (!_isSignedIn()) {
      state = state.copyWith(handled: true);
      return true;
    }

    state = state.copyWith(isDismissing: true);
    final result = await _service.dismiss();
    final update = result.value;

    if (update == null) {
      // The refusal itself carries no decision, so re-check rather than guess:
      // "already required" is one of the two reasons for a 400, and it flips
      // the popup to blocking.
      state = state.copyWith(isDismissing: false);
      await check();
      return false;
    }

    state = state.copyWith(
      update: update,
      isDismissing: false,
      handled: !update.isBlocking,
    );
    return !update.isBlocking;
  }

  /// Marks the prompt as done for this session without spending a dismissal —
  /// for the case where there was nothing to show in the first place.
  void markHandled() => state = state.copyWith(handled: true);
}
