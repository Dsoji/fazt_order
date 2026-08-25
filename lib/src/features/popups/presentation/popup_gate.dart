import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/app_colors.dart';
import '../../../common/res/app_colors.dart';
import '../../../common/widgets/reusable_buttons.dart';
import '../../../common/widgets/text_styles.dart';
import '../../../common/device_metadata.dart';
import '../../../common/notification_service.dart';
import '../../home/data/controller/shop_controller.dart';
import '../../profile/data/controller/profile_controller.dart';
import '../data/app_popup.dart';
import '../data/popup_service.dart';

/// Polls for blocking popups on launch and on every resume, and shows each one
/// as a modal that has to be acknowledged.
class PopupGate extends HookConsumerWidget {
  const PopupGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> poll() => _presentPending(context, ref);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => poll());
      return null;
    }, const []);

    // A push while the app is open is the cue that a popup may be waiting.
    useEffect(() {
      final sub = NotificationService.foregroundMessages.listen((_) => poll());
      return sub.cancel;
    }, const []);

    useOnAppLifecycleStateChange((_, state) {
      if (state == AppLifecycleState.resumed) poll();
    });

    return child;
  }
}

bool _polling = false;

/// Polls for pending popups and shows them. Also used by pull-to-refresh.
Future<void> showPendingPopups(BuildContext context, WidgetRef ref) =>
    _presentPending(context, ref);

Future<void> _presentPending(BuildContext context, WidgetRef ref) async {
  // Popups need a token, and an overlapping poll would stack duplicates.
  if (_polling || !DeviceMetadata.hasSession || !context.mounted) return;
  _polling = true;
  try {
    final service = ref.read(popupServiceProvider);
    final result = await service.pending();
    final popups = result.value ?? const <AppPopup>[];
    if (popups.isNotEmpty) {
      // A popup means something changed server-side (order status, refund…),
      // so refresh what sits behind it.
      ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
      ref.read(profileControllerProvider.notifier).fetchWallet();
    }
    for (final popup in popups) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AppPopupDialog(popup: popup),
      );
      // Acknowledged: tell the backend so it leaves the next poll.
      await service.markRead(popup.id);
    }
  } finally {
    _polling = false;
  }
}

class AppPopupDialog extends StatelessWidget {
  const AppPopupDialog({super.key, required this.popup});

  final AppPopup popup;

  @override
  Widget build(BuildContext context) {
    final reason = popup.reason;
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: kcWhite,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                child: Icon(
                  popup.isOrderCancelled
                      ? Iconsax.close_circle
                      : Iconsax.notification,
                  color: AppColors.brand400,
                  size: 28,
                ),
              ),
              const Gap(20),
              Text(
                popup.title,
                textAlign: TextAlign.center,
                style: ktBodySemiBoldSize20.copyWith(color: kcBlack),
              ),
              const Gap(10),
              Text(
                // With a structured reason, show it on its own line rather than
                // the sentence the server folded it into.
                popup.isOrderCancelled && popup.orderId != null
                    ? 'Order ${popup.orderId} was cancelled.'
                    : popup.message,
                textAlign: TextAlign.center,
                style: ktBodyRegularSize14.copyWith(
                  color: AppColors.neutral400,
                  height: 1.5,
                ),
              ),
              if (reason != null) ...[
                const Gap(12),
                Text(
                  'Reason: $reason',
                  textAlign: TextAlign.center,
                  style: ktBodyRegularSize14.copyWith(
                    color: kcBlack,
                    height: 1.5,
                  ),
                ),
              ],
              const Gap(24),
              FullButton(
                text: 'Got it',
                width: double.infinity,
                height: 48,
                color: AppColors.brand400,
                textColor: kcWhite,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
