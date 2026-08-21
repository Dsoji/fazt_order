import 'dart:convert';

import '../../../../common/device_metadata.dart';
import '../../../../common/res/base.dart';
import '../../../../common/utils/app_version.dart';

/// The backend's update-popup decision.
///
/// Every rule — which version is current, how many dismissals a user gets,
/// whether the update is optional or compulsory and when it turns compulsory —
/// lives on the backend. The app renders this and nothing more; there is no
/// version comparison to do here.
///
/// Arrives from two places with an identical shape: `POST /app-versions/check`,
/// and the `appUpdate` block the login response carries when the request sent
/// `appVersion` + `platform` + `appType` together.
///
/// The backend's answer is then checked against the build actually installed on
/// this handset — see [shouldPrompt]. Both have to agree before anything is
/// shown.
class AppUpdate {
  /// A newer build exists. Everything else on this object is meaningless when
  /// this is `false`.
  final bool updateAvailable;

  /// The popup blocks: no dismiss control, no back gesture, Update is the only
  /// way out.
  final bool updateRequired;

  /// The user still has dismissals left. Never trust this on its own —
  /// [isBlocking] is the check to render against.
  final bool canDismiss;

  final String? currentVersion;
  final String? latestVersion;

  /// The oldest build still allowed. Absent until an admin sets one, and only
  /// ever a reason the backend reached its own verdict — nothing here decides
  /// anything from it.
  final String? minimumSupportedVersion;

  /// `optional` or `compulsory`, the backend's own label for the record. Say
  /// what it says in telemetry; [isBlocking] is what the UI branches on.
  final String? updateType;

  final int? dismissalLimit;
  final int? dismissalsUsed;
  final int? dismissalsRemaining;

  /// Dashboard-editable copy. Render these rather than hardcoded strings.
  final String? title;
  final String? message;

  final String? storeUrl;

  /// Why the update is compulsory — only set when [updateRequired] is true.
  /// One of `dismissal_limit_reached`, `marked_compulsory`,
  /// `compulsory_date_passed`, `below_minimum_supported`.
  final String? requiredReason;

  /// The build installed on this device, attached locally after the response
  /// lands. Not part of the API payload.
  final String? installedVersion;

  const AppUpdate({
    this.updateAvailable = false,
    this.updateRequired = false,
    this.canDismiss = false,
    this.currentVersion,
    this.latestVersion,
    this.minimumSupportedVersion,
    this.updateType,
    this.dismissalLimit,
    this.dismissalsUsed,
    this.dismissalsRemaining,
    this.title,
    this.message,
    this.storeUrl,
    this.requiredReason,
    this.installedVersion,
  });

  /// The safe answer for every failure path — a network error, a malformed
  /// body, a backend that degraded its own check. A broken update check must
  /// never hold up app startup, so "no update" is what everything falls back
  /// to.
  static const AppUpdate none = AppUpdate();

  /// Whether to show a popup at all.
  ///
  /// The backend has to say so **and** the version installed on this device has
  /// to actually be behind [latestVersion]. The second half is the on-device
  /// check: `currentVersion` is whatever the app managed to send, and if that
  /// never arrived — or the version record is stale — the backend can offer an
  /// update to someone already running it. Comparing locally means the build in
  /// the user's hand has the final say on whether it is out of date.
  bool get shouldPrompt => updateAvailable && _isBehindLatest;

  /// Whether the popup must trap the user.
  ///
  /// A required update is blocking even if [canDismiss] somehow came back
  /// `true`; the stricter of the two wins so a backend inconsistency can't leak
  /// a dismiss button onto a forced update. It is gated on [shouldPrompt]
  /// rather than [updateAvailable] deliberately — locking someone out of the
  /// app to demand a version they already have is the one failure here with no
  /// way back.
  bool get isBlocking => shouldPrompt && (updateRequired || !canDismiss);

  /// The build running right now, read off the platform rather than echoed back
  /// by the server.
  ///
  /// Falls back to the `currentVersion` the response carries, which is what
  /// this app sent in the first place.
  String? get resolvedInstalledVersion =>
      installedVersion ?? DeviceMetadata.cachedAppVersion ?? currentVersion;

  /// Where the Update button sends the user.
  ///
  /// [storeUrl] is dashboard-editable and unset on a freshly seeded version
  /// record, so this falls back to this app's own listing for the running
  /// platform. On a blocking popup Update is the only way out, and a button
  /// that does nothing would leave the user with no way back into the app.
  String get resolvedStoreUrl {
    final url = storeUrl?.trim();
    if (url != null && url.isNotEmpty) return url;
    return DeviceMetadata.platform == 'ios'
        ? BasePaths.appStoreUrl
        : BasePaths.playStoreUrl;
  }

  /// The heading to show.
  ///
  /// Dashboard copy wins; the fallback says which of the two popups this is,
  /// because "Update available" over a popup with no way out reads as a
  /// mistake.
  String get resolvedTitle {
    final custom = title?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    return isBlocking ? 'Update required' : 'Update available';
  }

  /// The body copy to show.
  ///
  /// `title` and `message` are absent until an admin fills them in, and a
  /// blocking popup carrying neither leaves someone locked out of the app with
  /// no idea why. [requiredReason] is used here as copy and nothing else — what
  /// makes the popup block stays with `canDismiss`, so an unrecognised reason
  /// still blocks and simply falls back to the generic wording.
  String get resolvedMessage {
    final custom = message?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    if (!isBlocking) return 'A new version of Fazt is available.';
    return switch (requiredReason) {
      'below_minimum_supported' => 'This version is no longer supported.',
      'marked_compulsory' => 'A required update is available.',
      'compulsory_date_passed' => 'This update is now required.',
      _ => 'Please update to continue.',
    };
  }

  /// Whether [latestVersion] is genuinely ahead of what is installed.
  ///
  /// Defaults to `true` when the comparison can't be made — an unreadable or
  /// missing version must not be able to silently switch off a compulsory
  /// update. Failing towards the backend's answer is the safe direction.
  bool get _isBehindLatest =>
      isNewerVersion(
        latest: latestVersion,
        installed: resolvedInstalledVersion,
      ) ??
      true;

  factory AppUpdate.fromMap(Map<String, dynamic> data) {
    final required = _bool(data['updateRequired'], false);
    return AppUpdate(
      updateAvailable: _bool(data['updateAvailable'], false),
      updateRequired: required,
      // `canDismiss` is `!updateRequired` on the backend's side, so that is
      // what a missing or unreadable one falls back to. Defaulting to `false`
      // manufactures the one popup with no way out of it — no Later button,
      // no back gesture — from an optional update the user still has all
      // three of their dismissals for. The safe direction on this field is
      // the opposite of the other two: an update that isn't required is
      // dismissible until the backend says otherwise.
      canDismiss: _bool(data['canDismiss'], !required),
      currentVersion: data['currentVersion'] as String?,
      latestVersion: data['latestVersion'] as String?,
      minimumSupportedVersion: data['minimumSupportedVersion'] as String?,
      updateType: data['updateType'] as String?,
      dismissalLimit: (data['dismissalLimit'] as num?)?.toInt(),
      dismissalsUsed: (data['dismissalsUsed'] as num?)?.toInt(),
      dismissalsRemaining: (data['dismissalsRemaining'] as num?)?.toInt(),
      title: data['title'] as String?,
      message: data['message'] as String?,
      storeUrl: data['storeUrl'] as String?,
      requiredReason: data['requiredReason'] as String?,
    );
  }

  /// Reads the shapes a boolean actually arrives in — `true`, `"true"`, `1` —
  /// and falls back rather than throwing on anything else. Which way each
  /// field falls back is the caller's call; see [fromMap].
  static bool _bool(dynamic value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalised = value.trim().toLowerCase();
      if (normalised == 'true') return true;
      if (normalised == 'false') return false;
    }
    return fallback;
  }

  Map<String, dynamic> toMap() => {
        'updateAvailable': updateAvailable,
        'updateRequired': updateRequired,
        'canDismiss': canDismiss,
        'currentVersion': currentVersion,
        'latestVersion': latestVersion,
        'minimumSupportedVersion': minimumSupportedVersion,
        'updateType': updateType,
        'dismissalLimit': dismissalLimit,
        'dismissalsUsed': dismissalsUsed,
        'dismissalsRemaining': dismissalsRemaining,
        'title': title,
        'message': message,
        'storeUrl': storeUrl,
        'requiredReason': requiredReason,
      };

  factory AppUpdate.fromJson(String data) =>
      AppUpdate.fromMap(json.decode(data) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  AppUpdate copyWith({
    bool? updateAvailable,
    bool? updateRequired,
    bool? canDismiss,
    String? currentVersion,
    String? latestVersion,
    String? minimumSupportedVersion,
    String? updateType,
    int? dismissalLimit,
    int? dismissalsUsed,
    int? dismissalsRemaining,
    String? title,
    String? message,
    String? storeUrl,
    String? requiredReason,
    String? installedVersion,
  }) =>
      AppUpdate(
        updateAvailable: updateAvailable ?? this.updateAvailable,
        updateRequired: updateRequired ?? this.updateRequired,
        canDismiss: canDismiss ?? this.canDismiss,
        currentVersion: currentVersion ?? this.currentVersion,
        latestVersion: latestVersion ?? this.latestVersion,
        minimumSupportedVersion:
            minimumSupportedVersion ?? this.minimumSupportedVersion,
        updateType: updateType ?? this.updateType,
        dismissalLimit: dismissalLimit ?? this.dismissalLimit,
        dismissalsUsed: dismissalsUsed ?? this.dismissalsUsed,
        dismissalsRemaining: dismissalsRemaining ?? this.dismissalsRemaining,
        title: title ?? this.title,
        message: message ?? this.message,
        storeUrl: storeUrl ?? this.storeUrl,
        requiredReason: requiredReason ?? this.requiredReason,
        installedVersion: installedVersion ?? this.installedVersion,
      );

  @override
  String toString() =>
      'AppUpdate(updateAvailable: $updateAvailable, updateRequired: '
      '$updateRequired, canDismiss: $canDismiss, latestVersion: $latestVersion)';
}
