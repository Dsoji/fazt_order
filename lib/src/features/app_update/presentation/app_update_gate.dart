import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/controller/app_update_controller.dart';
import 'app_update_dialog.dart';

/// Runs the update check once per session and puts the popup up over [child].
///
/// Wrapped around the first screen a cold start can land on — the dashboard
/// when signed in, onboarding when not — because a compulsory update has to
/// stop a signed-out user too, and `/app-versions/check` works without a token.
///
/// The check never gates the frame: [child] builds immediately and the popup
/// arrives after the response, if there is one to show. A failed check is
/// indistinguishable from "no update", by design.
class AppUpdateGate extends HookConsumerWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      // Deferred to the first post-frame callback: showDialog needs a Navigator
      // that this widget's own build hasn't finished installing yet.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // The frame can land after this widget is gone — a fast redirect off
        // onboarding, for one — and reading a provider off a disposed element
        // throws.
        if (!context.mounted) return;
        final controller = ref.read(appUpdateControllerProvider.notifier);
        // The login response may already have handed us a decision, in which
        // case there is nothing to ask for.
        if (!ref.read(appUpdateControllerProvider).update.updateAvailable) {
          await controller.check();
        }
        if (context.mounted) await showAppUpdateDialogIfNeeded(context, ref);
      });
      return null;
    }, const []);

    return child;
  }
}
