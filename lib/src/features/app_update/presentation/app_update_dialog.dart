import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/app_colors.dart';
import '../../../common/res/app_colors.dart';
import '../../../common/widgets/reusable_buttons.dart';
import '../../../common/widgets/text_styles.dart';
import '../data/controller/app_update_controller.dart';
import '../data/model/app_update.dart';

/// Presents the backend's update decision, if there is one to present.
///
/// Safe to call unconditionally — it returns immediately when nothing needs
/// showing, and won't stack a second popup on one that is already up.
Future<void> showAppUpdateDialogIfNeeded(
  BuildContext context,
  WidgetRef ref,
) async {
  final controller = ref.read(appUpdateControllerProvider.notifier);
  if (!ref.read(appUpdateControllerProvider).shouldShow) return;
  if (_isShowing) return;

  _isShowing = true;
  try {
    await showDialog<void>(
      context: context,
      // A required update has to be inescapable: barrier taps and the Android
      // back gesture are both closed off by the PopScope inside.
      barrierDismissible: false,
      builder: (_) => const AppUpdateDialog(),
    );
  } finally {
    _isShowing = false;
  }

  // Nothing left to prompt about this session unless the update is blocking,
  // in which case the next caller puts it straight back up.
  controller.markHandled();
}

bool _isShowing = false;

/// The popup itself. Every string it shows comes off the response — `title`,
/// `message` and `storeUrl` are dashboard-editable, so hardcoding copy here
/// would quietly override whatever ops set. The fallbacks for when ops set
/// nothing live on [AppUpdate] rather than in this widget.
class AppUpdateDialog extends ConsumerWidget {
  const AppUpdateDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appUpdateControllerProvider);
    final update = state.update;
    final blocking = update.isBlocking;

    return PopScope(
      canPop: !blocking,
      child: Dialog(
        backgroundColor: kcWhite,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 56,
                width: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.neutral950,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.arrow_circle_up,
                  color: AppColors.brand400,
                  size: 28,
                ),
              ),
              const Gap(20),
              Text(
                update.resolvedTitle,
                textAlign: TextAlign.center,
                style: ktBodySemiBoldSize20.copyWith(color: kcBlack),
              ),
              const Gap(10),
              Text(
                update.resolvedMessage,
                textAlign: TextAlign.center,
                style: ktBodyRegularSize14.copyWith(
                  color: AppColors.neutral400,
                  height: 1.5,
                ),
              ),
              if (update.latestVersion != null) ...[
                const Gap(8),
                Text(
                  'Version ${update.latestVersion}',
                  textAlign: TextAlign.center,
                  style: ktBodyRegularSize12.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
              const Gap(24),
              FullButton(
                text: 'Update',
                width: double.infinity,
                height: 48,
                color: AppColors.brand400,
                textColor: kcWhite,
                onPressed: () => _openStore(update),
              ),
              if (!blocking) ...[
                const Gap(8),
                _DismissButton(
                  isLoading: state.isDismissing,
                  remaining: update.dismissalsRemaining,
                  onPressed: () async {
                    final closed = await ref
                        .read(appUpdateControllerProvider.notifier)
                        .dismiss();
                    // A refused dismissal leaves the popup up; the state it
                    // re-read may well have turned it blocking.
                    if (closed && context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore(AppUpdate update) async {
    // Falls back to this app's own listing when the record carries no
    // storeUrl — see AppUpdate.resolvedStoreUrl.
    final uri = Uri.tryParse(update.resolvedStoreUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _DismissButton extends StatelessWidget {
  const _DismissButton({
    required this.isLoading,
    required this.remaining,
    required this.onPressed,
  });

  final bool isLoading;
  final int? remaining;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              // The last dismissal is worth flagging — the next launch is a
              // wall, and the backend gives no other warning.
              remaining == 1 ? 'Not now (last reminder)' : 'Not now',
              style: ktBodyRegularSize14.copyWith(
                color: AppColors.neutral400,
              ),
            ),
    );
  }
}
