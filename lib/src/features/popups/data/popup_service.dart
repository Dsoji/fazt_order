import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../common/api/api_client.dart';
import '../../../common/api/api_request_helper.dart';
import '../../../common/api/dio_api_client.dart';
import 'app_popup.dart';

final popupServiceProvider = Provider<PopupService>((ref) {
  return PopupService(
    apiClient: ref.watch(dioApiClientProvider),
    apiRequestHelper: ref.watch(apiRequestHelperProvider),
  );
});

/// `GET /notifications/pending-popups` and `PATCH /notifications/:id/read`.
///
/// Errors are never toasted — this runs on launch and resume, and a failed
/// poll just means nothing to show.
class PopupService {
  PopupService({required this.apiClient, required this.apiRequestHelper});

  final IApiClient apiClient;
  final ApiRequestHelper apiRequestHelper;

  Future<ResultValue<List<AppPopup>>> pending({int limit = 5}) {
    return apiRequestHelper.handleApiRequest(
      () => apiClient.get(
        'notifications/pending-popups',
        queryParameters: {'limit': limit},
      ),
      parser: (data) {
        final list = data is Map ? data['popups'] : null;
        if (list is! List) return const <AppPopup>[];
        return [
          for (final p in list)
            if (p is Map<String, dynamic>) AppPopup.fromMap(p),
        ];
      },
      showErrorToast: false,
      showSuccessToast: false,
    );
  }

  /// Acknowledges a popup; the backend drops it from the next poll.
  Future<ResultValue<void>> markRead(String id) {
    return apiRequestHelper.handleApiRequest<void>(
      () => apiClient.patch('notifications/$id/read'),
      parser: (_) {},
      showErrorToast: false,
      showSuccessToast: false,
    );
  }
}
