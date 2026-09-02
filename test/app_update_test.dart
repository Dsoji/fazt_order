import 'package:fazt_order/src/common/api/api_client.dart';
import 'package:fazt_order/src/common/api/api_request_helper.dart';
import 'package:fazt_order/src/common/res/base.dart';
import 'package:fazt_order/src/features/app_update/data/controller/app_update_controller.dart';
import 'package:fazt_order/src/features/app_update/data/model/app_update.dart';
import 'package:fazt_order/src/features/app_update/data/service/app_version_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hands back a canned decision without going near Dio.
class _FakeService implements AppVersionService {
  _FakeService(this.answer);

  AppUpdate answer;
  int checks = 0;

  @override
  Future<ResultValue<AppUpdate>> check({String? currentVersion}) async {
    checks++;
    return ResultValue.success(answer);
  }

  int dismissals = 0;

  @override
  Future<ResultValue<AppUpdate>> dismiss({String? currentVersion}) async {
    dismissals++;
    return ResultValue.success(answer);
  }

  @override
  IApiClient get apiClient => throw UnimplementedError();

  @override
  ApiRequestHelper get apiRequestHelper => throw UnimplementedError();
}

/// A decision as the backend would send it, with the installed build stamped on
/// the way the service does.
AppUpdate decision({
  bool updateAvailable = true,
  bool updateRequired = false,
  bool canDismiss = true,
  String? latest = '1.4.0',
  String? installed = '1.3.0',
  String? title,
  String? message,
  String? requiredReason,
}) =>
    AppUpdate(
      updateAvailable: updateAvailable,
      updateRequired: updateRequired,
      canDismiss: canDismiss,
      latestVersion: latest,
      installedVersion: installed,
      title: title,
      message: message,
      requiredReason: requiredReason,
    );

void main() {
  group('shouldPrompt', () {
    test('prompts when the backend agrees and the build is behind', () {
      expect(decision().shouldPrompt, isTrue);
    });

    test('stays quiet when the installed build is already current', () {
      expect(decision(installed: '1.4.0').shouldPrompt, isFalse);
    });

    test('stays quiet when the installed build is ahead of the store', () {
      expect(decision(installed: '1.5.0').shouldPrompt, isFalse);
    });

    test('ignores the build number when comparing', () {
      expect(decision(installed: '1.4.0+31').shouldPrompt, isFalse);
    });

    test('never prompts when the backend says there is nothing', () {
      expect(decision(updateAvailable: false).shouldPrompt, isFalse);
    });

    test('trusts the backend when the versions cannot be compared', () {
      expect(decision(latest: null).shouldPrompt, isTrue);
      expect(decision(installed: null, latest: '1.4.0').shouldPrompt, isTrue);
      expect(decision(latest: 'newest').shouldPrompt, isTrue);
    });
  });

  group('isBlocking', () {
    test('blocks a required update on an out-of-date build', () {
      final update = decision(updateRequired: true, canDismiss: false);
      expect(update.isBlocking, isTrue);
    });

    test('blocks when dismissals have run out', () {
      expect(decision(canDismiss: false).isBlocking, isTrue);
    });

    test('never blocks a build that is already current', () {
      // The one failure with no way back: demanding a version the user is
      // already running would lock them out of the app entirely.
      final update = decision(
        updateRequired: true,
        canDismiss: false,
        installed: '1.4.0',
      );
      expect(update.isBlocking, isFalse);
      expect(update.shouldPrompt, isFalse);
    });

    test('a dismissible update on an old build is not blocking', () {
      expect(decision().isBlocking, isFalse);
    });

    test('required beats a stray canDismiss:true', () {
      final update = decision(updateRequired: true, canDismiss: true);
      expect(update.isBlocking, isTrue);
    });
  });

  test('AppUpdate.none prompts for nothing', () {
    expect(AppUpdate.none.shouldPrompt, isFalse);
    expect(AppUpdate.none.isBlocking, isFalse);
  });

  group('refresh', () {
    test('re-asks the backend on every pull', () async {
      final service = _FakeService(decision());
      final controller = AppUpdateController(service);

      await controller.refresh();
      await controller.refresh();

      expect(service.checks, 2);
    });

    test('does not re-prompt for a popup already closed this session',
        () async {
      final service = _FakeService(decision());
      final controller = AppUpdateController(service);

      await controller.check();
      expect(controller.state.shouldShow, isTrue);
      controller.markHandled();

      await controller.refresh();

      expect(controller.state.shouldShow, isFalse);
    });

    test('prompts again when a newer version is published', () async {
      final service = _FakeService(decision());
      final controller = AppUpdateController(service);

      await controller.check();
      controller.markHandled();

      service.answer = decision(latest: '1.5.0');
      await controller.refresh();

      expect(controller.state.shouldShow, isTrue);
    });

    test('brings back an update that has turned blocking', () async {
      final service = _FakeService(decision());
      final controller = AppUpdateController(service);

      await controller.check();
      controller.markHandled();

      service.answer = decision(canDismiss: false);
      await controller.refresh();

      expect(controller.state.shouldShow, isTrue);
      expect(controller.state.update.isBlocking, isTrue);
    });

    test('a plain check always re-prompts', () async {
      final service = _FakeService(decision());
      final controller = AppUpdateController(service);

      await controller.check();
      controller.markHandled();

      await controller.check();

      expect(controller.state.shouldShow, isTrue);
    });
  });

  group('dismiss', () {
    test('spends an allowance when there is a session to spend it from',
        () async {
      final service = _FakeService(decision());
      final controller =
          AppUpdateController(service, isSignedIn: () => true);
      await controller.check();

      expect(await controller.dismiss(), isTrue);
      expect(service.dismissals, 1);
      expect(controller.state.shouldShow, isFalse);
    });

    test('closes locally rather than calling the API when signed out',
        () async {
      // An anonymous caller has no allowance to spend and the request answers
      // 401 — which the Dio interceptor reads as an expired session and turns
      // into a toast and a redirect to onboarding, off a tap on "Not now".
      final service = _FakeService(decision());
      final controller =
          AppUpdateController(service, isSignedIn: () => false);
      await controller.check();

      expect(await controller.dismiss(), isTrue);
      expect(service.dismissals, 0);
      expect(controller.state.shouldShow, isFalse);
    });

    test('refuses to dismiss a blocking update, signed in or not', () async {
      final service = _FakeService(decision(updateRequired: true));
      final controller =
          AppUpdateController(service, isSignedIn: () => false);
      await controller.check();

      expect(await controller.dismiss(), isFalse);
      expect(service.dismissals, 0);
      expect(controller.state.shouldShow, isTrue);
    });
  });

  group('the three-dismissal allowance', () {
    test('an optional update is dismissible on every launch until it is not',
        () async {
      // The tally lives on the backend; the app renders whatever the latest
      // decision says. This walks the doc's table: three launches with a Later
      // button, then a fourth without one.
      final service = _FakeService(decision());
      final controller =
          AppUpdateController(service, isSignedIn: () => true);

      for (var used = 0; used < 3; used++) {
        service.answer = decision().copyWith(
          dismissalsUsed: used,
          dismissalsRemaining: 3 - used,
        );
        await controller.check();
        expect(controller.state.update.isBlocking, isFalse,
            reason: 'launch ${used + 1} of 3 should still offer Later');

        // The dismissal the user spends comes back as the recomputed decision.
        service.answer = decision().copyWith(
          dismissalsUsed: used + 1,
          dismissalsRemaining: 2 - used,
        );
        expect(await controller.dismiss(), isTrue);
      }

      service.answer = decision(
        updateRequired: true,
        canDismiss: false,
        requiredReason: 'dismissal_limit_reached',
      ).copyWith(dismissalsUsed: 3, dismissalsRemaining: 0);
      await controller.check();

      expect(controller.state.update.isBlocking, isTrue);
      expect(await controller.dismiss(), isFalse);
      expect(service.dismissals, 3);
    });

    test('an optional update stays dismissible when canDismiss is missing', () {
      // Defaulting the field to false would hand someone a wall on their first
      // launch, with all three dismissals still unspent.
      final update = AppUpdate.fromMap(const {
        'updateAvailable': true,
        'updateRequired': false,
        'latestVersion': '1.4.0',
        'dismissalLimit': 3,
        'dismissalsUsed': 0,
        'dismissalsRemaining': 3,
      }).copyWith(installedVersion: '1.3.0');

      expect(update.shouldPrompt, isTrue);
      expect(update.canDismiss, isTrue);
      expect(update.isBlocking, isFalse);
    });

    test('a required update still blocks when canDismiss is missing', () {
      final update = AppUpdate.fromMap(const {
        'updateAvailable': true,
        'updateRequired': true,
        'latestVersion': '1.4.0',
      }).copyWith(installedVersion: '1.3.0');

      expect(update.isBlocking, isTrue);
    });

    test('reads booleans the backend sends as strings or numbers', () {
      final update = AppUpdate.fromMap(const {
        'updateAvailable': 'true',
        'updateRequired': 0,
        'canDismiss': 1,
        'latestVersion': '1.4.0',
      }).copyWith(installedVersion: '1.3.0');

      expect(update.shouldPrompt, isTrue);
      expect(update.isBlocking, isFalse);
    });

    test('an explicit canDismiss:false is honoured', () {
      final update = AppUpdate.fromMap(const {
        'updateAvailable': true,
        'updateRequired': false,
        'canDismiss': false,
        'latestVersion': '1.4.0',
      }).copyWith(installedVersion: '1.3.0');

      expect(update.isBlocking, isTrue);
    });
  });

  group('copy', () {
    test('dashboard copy wins over every fallback', () {
      final update = decision(
        updateRequired: true,
        canDismiss: false,
        title: 'Time to update',
        message: 'We fixed the thing.',
        requiredReason: 'marked_compulsory',
      );

      expect(update.resolvedTitle, 'Time to update');
      expect(update.resolvedMessage, 'We fixed the thing.');
    });

    test('a blocking popup says why when the record carries no copy', () {
      String messageFor(String? reason) => decision(
            updateRequired: true,
            canDismiss: false,
            requiredReason: reason,
          ).resolvedMessage;

      expect(messageFor('below_minimum_supported'),
          'This version is no longer supported.');
      expect(
          messageFor('marked_compulsory'), 'A required update is available.');
      expect(
          messageFor('compulsory_date_passed'), 'This update is now required.');
      expect(
          messageFor('dismissal_limit_reached'), 'Please update to continue.');
      // An unrecognised reason is still blocking; only the wording falls back.
      expect(messageFor('something_new'), 'Please update to continue.');
      expect(messageFor(null), 'Please update to continue.');
    });

    test('an optional popup keeps the softer wording', () {
      expect(decision().resolvedTitle, 'Update available');
      expect(decision().resolvedMessage, 'A new version of Fazt is available.');
    });

    test('a blocking popup titles itself as required', () {
      expect(
        decision(updateRequired: true, canDismiss: false).resolvedTitle,
        'Update required',
      );
    });

    test('blank dashboard copy counts as absent', () {
      final update = decision(title: '  ', message: '  ');
      expect(update.resolvedTitle, 'Update available');
      expect(update.resolvedMessage, 'A new version of Fazt is available.');
    });
  });

  group('fromMap', () {
    test('reads the fields the version record carries', () {
      final update = AppUpdate.fromMap(const {
        'appType': 'user',
        'platform': 'android',
        'updateAvailable': true,
        'updateRequired': false,
        'canDismiss': true,
        'currentVersion': '1.0.0',
        'latestVersion': '1.1.0',
        'minimumSupportedVersion': '1.0.0',
        'updateType': 'optional',
        'dismissalLimit': 3,
        'dismissalsUsed': 1,
        'dismissalsRemaining': 2,
        'title': 'New version available',
        'message': 'Faster order acceptance and bug fixes.',
        'storeUrl': 'https://play.google.com/store/apps/details?id=com.fazt',
      });

      expect(update.updateAvailable, isTrue);
      expect(update.latestVersion, '1.1.0');
      expect(update.minimumSupportedVersion, '1.0.0');
      expect(update.updateType, 'optional');
      expect(update.dismissalLimit, 3);
      expect(update.dismissalsRemaining, 2);
      expect(update.requiredReason, isNull);
    });

    test('an up-to-date answer leaves the optional fields absent', () {
      // Nothing on this shape is filled in beyond the verdict itself.
      final update = AppUpdate.fromMap(const {
        'updateAvailable': false,
        'updateRequired': false,
        'canDismiss': true,
        'currentVersion': '1.0.0',
        'latestVersion': '1.0.0',
      });

      expect(update.shouldPrompt, isFalse);
      expect(update.title, isNull);
      expect(update.storeUrl, isNull);
      expect(update.requiredReason, isNull);
    });
  });

  group('resolvedStoreUrl', () {
    test('prefers the link the backend sent', () {
      const url = 'https://play.google.com/store/apps/details?id=other';
      expect(
        decision().copyWith(storeUrl: url).resolvedStoreUrl,
        url,
      );
    });

    test('falls back to this app own listing when the record has none', () {
      // Every freshly seeded version record comes back without one, and a
      // blocking popup needs the Update button to go somewhere.
      expect(
        decision().resolvedStoreUrl,
        anyOf(BasePaths.appStoreUrl, BasePaths.playStoreUrl),
      );
    });

    test('treats a blank link as absent', () {
      expect(
        decision().copyWith(storeUrl: '   ').resolvedStoreUrl,
        anyOf(BasePaths.appStoreUrl, BasePaths.playStoreUrl),
      );
    });
  });
}
