import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Per-device and per-build metadata the backend expects alongside `auth/signup`
/// and `auth/login`.
///
/// Two backend features hang off these fields and both stay silently dormant
/// when they're missing — the new-customer promo device lock fails open (the
/// promo is granted again on every fresh account), and the login response
/// simply omits its `appUpdate` block. Nothing errors either way, so treat a
/// missing value as a bug rather than a shrug.
class DeviceMetadata {
  DeviceMetadata._();

  /// Which of the three apps this build is. The rider and vendor apps send
  /// `rider` / `vendor` from the same field.
  static const String appType = 'user';

  static const String _deviceIdKey = 'device_id';

  /// Values the backend treats as absent — common emulator and SDK
  /// placeholders that would otherwise collapse every device onto one shared
  /// promo lock. Kept in sync with the backend's own list.
  static const Set<String> _placeholderIds = {
    'unknown',
    'null',
    'undefined',
    '0',
    '00000000-0000-0000-0000-000000000000',
    '000000000000000',
  };

  static String? _cachedAppVersion;

  static String get platform => Platform.isIOS ? 'ios' : 'android';

  /// A stable per-device id — `Settings.Secure.ANDROID_ID` on Android,
  /// `identifierForVendor` on iOS.
  ///
  /// The value must survive a logout and be identical on the next signup from
  /// the same handset; that is the entire mechanism behind the one-promo-per-
  /// device rule. Both sources regenerate the same id after a reinstall, so the
  /// Hive copy is a cache rather than the source of truth.
  ///
  /// Returns `null` rather than throwing when the platform won't say — auth
  /// must never fail because a device id couldn't be read.
  static Future<String?> deviceId() async {
    final box = Hive.box('data');
    final cached = _sanitise(box.get(_deviceIdKey) as String?);
    if (cached != null) return cached;

    String? raw;
    try {
      if (Platform.isAndroid) {
        raw = await const AndroidId().getId();
      } else if (Platform.isIOS) {
        raw = (await DeviceInfoPlugin().iosInfo).identifierForVendor;
      }
    } catch (_) {
      return null;
    }

    final id = _sanitise(raw);
    if (id != null) await box.put(_deviceIdKey, id);
    return id;
  }

  /// The build name read at startup, without waiting on a platform channel.
  ///
  /// [warmUp] fills this during `main`, so by the time the update popup needs
  /// to compare versions the value is already there — which is what lets that
  /// comparison stay synchronous. `null` only if the platform never answered.
  static String? get cachedAppVersion => _cachedAppVersion;

  /// The dotted numeric build name, e.g. `1.0.2`. Drives the update popup.
  static Future<String?> appVersion() async {
    if (_cachedAppVersion != null) return _cachedAppVersion;
    try {
      final info = await PackageInfo.fromPlatform();
      final version = info.version.trim();
      if (version.isEmpty) return null;
      return _cachedAppVersion = version;
    } catch (_) {
      return null;
    }
  }

  /// Whether a signed-in session's token is sitting on this device.
  ///
  /// `POST /app-versions/dismiss` needs one — an anonymous caller has no
  /// dismissal allowance to spend, and the 401 it answers with is picked up by
  /// the Dio interceptor as an expired session and turned into a forced
  /// sign-out. Asking first is what keeps a signed-out user tapping "Not now"
  /// from being bounced to onboarding.
  ///
  /// `false` when the box isn't open — a caller running before Hive is
  /// initialised is not signed in as far as anything here is concerned.
  static bool get hasSession {
    try {
      final token = Hive.box('data').get('accessToken');
      return token is String && token.trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Wipes the session box the way a sign-out should, keeping the device id.
  ///
  /// [deviceId] would read the same value back off the platform anyway, so this
  /// is belt and braces — but the id has to be identical between a logout and
  /// the next signup for the promo lock to hold, and that is not something to
  /// leave riding on a platform channel that can fail.
  static Future<void> clearSession() async {
    final box = Hive.box('data');
    final id = box.get(_deviceIdKey);
    await box.clear();
    if (id is String) await box.put(_deviceIdKey, id);
  }

  /// Reads the device id and build name once at startup so the values are warm
  /// by the time an auth call needs them.
  static Future<void> warmUp() async {
    await Future.wait([deviceId(), appVersion()]);
  }

  /// `null` unless the id is something the backend will actually accept: 8–200
  /// characters and not one of the known placeholders.
  static String? _sanitise(String? value) {
    final id = value?.trim();
    if (id == null || id.length < 8 || id.length > 200) return null;
    if (_placeholderIds.contains(id.toLowerCase())) return null;
    return id;
  }
}
