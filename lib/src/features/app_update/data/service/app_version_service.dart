import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/api/api_client.dart';
import '../../../../common/api/api_request_helper.dart';
import '../../../../common/api/dio_api_client.dart';
import '../../../../common/device_metadata.dart';
import '../model/app_update.dart';

final appVersionServiceProvider = Provider<AppVersionService>((ref) {
  return AppVersionService(
    apiClient: ref.watch(dioApiClientProvider),
    apiRequestHelper: ref.watch(apiRequestHelperProvider),
  );
});

/// `POST /app-versions/check` and `POST /app-versions/dismiss`.
class AppVersionService {
  AppVersionService({
    required this.apiClient,
    required this.apiRequestHelper,
  });

  final IApiClient apiClient;
  final ApiRequestHelper apiRequestHelper;

  /// The update decision for this build.
  ///
  /// Works signed-out — a token, when present, is what lets the backend attach
  /// this user's remaining dismissal allowance instead of a fresh one.
  ///
  /// Errors are never toasted: this runs on cold start, and a failed check
  /// means "no update", not something to interrupt the user about.
  Future<ResultValue<AppUpdate>> check({String? currentVersion}) async {
    final version = currentVersion ?? await DeviceMetadata.appVersion();
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'app-versions/check',
        data: {
          'appType': DeviceMetadata.appType,
          'platform': DeviceMetadata.platform,
          'currentVersion': version,
        },
      ),
      parser: (data) => _parse(data, version),
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  /// Spends one of the user's dismissals and returns the updated decision.
  ///
  /// The tally is deliberately server-side: a counter kept on the device would
  /// reset on a reinstall or a data wipe, which is exactly the move someone
  /// makes to dodge the prompt. Requires a token — an anonymous caller has no
  /// allowance to spend.
  ///
  /// A `400` comes back when there is nothing to dismiss, or when the update
  /// has already turned compulsory. Both mean "leave the popup open".
  Future<ResultValue<AppUpdate>> dismiss({String? currentVersion}) async {
    final version = currentVersion ?? await DeviceMetadata.appVersion();
    final device = await DeviceMetadata.deviceId();
    return apiRequestHelper.handleApiRequest(
      () => apiClient.post(
        'app-versions/dismiss',
        data: {
          'appType': DeviceMetadata.appType,
          'platform': DeviceMetadata.platform,
          'currentVersion': version,
          if (device != null) 'deviceId': device,
        },
      ),
      parser: (data) => _parse(data, version),
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  /// Anything that isn't a decision-shaped object is treated as "no update" —
  /// the same degradation the backend applies when its own check throws.
  ///
  /// [installed] is stamped on so the decision can be checked against the build
  /// actually running here, rather than against the `currentVersion` the server
  /// echoes back.
  static AppUpdate _parse(dynamic data, String? installed) =>
      data is Map<String, dynamic>
          ? AppUpdate.fromMap(data).copyWith(installedVersion: installed)
          : AppUpdate.none;
}
