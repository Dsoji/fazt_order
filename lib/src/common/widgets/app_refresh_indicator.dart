import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/app_update/data/controller/app_update_controller.dart';
import '../../features/app_update/presentation/app_update_dialog.dart';
import '../../features/popups/presentation/popup_gate.dart';

/// A [RefreshIndicator] that also re-runs the app-version check and polls for
/// pending popups.
///
/// Every pull-to-refresh in the app goes through this rather than
/// [RefreshIndicator] directly, so a version published after the user opened
/// the app is picked up without waiting for the next cold start — the update
/// gate only runs once per launch, and a session left open for days would
/// otherwise never hear about a compulsory update.
///
/// The check rides alongside [onRefresh] instead of after it: the two are
/// independent, and chaining them would add the check's latency to every pull.
/// It cannot fail the refresh — `/app-versions/check` degrades to "no update"
/// rather than throwing.
class AppRefreshIndicator extends ConsumerWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
  });

  final RefreshCallback onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: color,
      backgroundColor: backgroundColor,
      onRefresh: () async {
        final checking =
            ref.read(appUpdateControllerProvider.notifier).refresh();
        try {
          await onRefresh();
        } finally {
          // Awaited in a finally so a failed refresh still can't swallow a
          // blocking update — that popup is the one thing a pull must surface.
          await checking;
          if (context.mounted) await showAppUpdateDialogIfNeeded(context, ref);
          // Any pull is also a cue that a popup may be waiting.
          if (context.mounted) await showPendingPopups(context, ref);
        }
      },
      child: child,
    );
  }
}

/// Makes a state that doesn't scroll — an empty list, an error, a skeleton
/// shorter than the viewport — still accept a pull.
///
/// [RefreshIndicator] only reacts to scroll notifications, so a bare [Center]
/// under one swallows the gesture and the screen looks like it lost its
/// refresh exactly when the user most needs it: when there is nothing there.
class RefreshableFill extends StatelessWidget {
  const RefreshableFill({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}
