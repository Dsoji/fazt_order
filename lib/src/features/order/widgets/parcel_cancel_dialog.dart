import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lottie/lottie.dart';

import '../../../common/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/utils/failures.dart';
import '../../../common/widgets/reusable_buttons.dart';
import '../../home/data/controller/shop_controller.dart';

/// Confirms cancelling a parcel, with an optional reason.
///
/// Parcels cancel through `POST /parcels/:id/cancel`, not the order status
/// endpoint the food flow uses — it is that call which refunds a paid parcel to
/// the sender's wallet.
///
/// …when there is a parcel id to cancel with. Orders from the old shared flow
/// carry none, and neither does a feed that never populated it, so those fall
/// back to `PUT /orders/:id/status` — the same call the food flow cancels
/// with. It does not refund, which is why it is the fallback and not the
/// route: [parcelId] is used whenever it exists.
///
/// The backend decides whether cancelling is allowed at all; from `in_transit`
/// onward the sender gets a `403` explaining that the rider already has the
/// parcel. Its message is shown as-is, because it says something specific that
/// generic copy would lose.
class ParcelCancelDialog extends HookConsumerWidget {
  const ParcelCancelDialog({
    super.key,
    this.parcelId,
    this.orderId,
    this.requiresConfirmation = true,
  }) : assert(parcelId != null || orderId != null,
            'one of parcelId or orderId is needed to cancel');

  final String? parcelId;

  /// The order wrapping this parcel. Only used when there is no [parcelId].
  final String? orderId;

  /// From the action's `requiresConfirmation`. When the backend says no
  /// confirmation is needed, the dialog is skipped by the caller entirely —
  /// this is kept so the flag reaches the copy shown here.
  final bool requiresConfirmation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reasonController = useTextEditingController();
    final id = parcelId;
    final byParcel = id != null && id.isNotEmpty;
    final state = ref.watch(shopControllerProvider);
    final isCancelling =
        byParcel ? state.cancelParcel.isLoading : state.cancelOrder.isLoading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(12),
            SizedBox(
              height: screenHeight(context) * 0.13,
              child: Lottie.asset('asset/lottie/cancel.json'),
            ),
            const Gap(12),
            const Text(
              'Cancel this delivery?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: kcPrimaryNeutral100,
                letterSpacing: 1,
              ),
            ),
            const Gap(8),
            Text(
              byParcel
                  ? 'If you have already paid, the full amount goes back to '
                      'your wallet.'
                  : 'If you have already paid, our team will sort your refund '
                      'out with you.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: kcPrimaryNeutral500),
            ),
            const Gap(16),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Reason (optional)',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: kcPrimaryNeutral500,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const Gap(20),
            OutlinButton(
              width: screenWidth(context) * 0.7,
              height: screenHeight(context) * 0.06,
              color: kcPrimary400,
              bgColor: kcWhite,
              text: isCancelling ? 'Cancelling…' : 'Cancel Delivery',
              onPressed: () async {
                if (isCancelling) return;
                final controller = ref.read(shopControllerProvider.notifier);
                final done = byParcel
                    ? await controller.cancelParcel(
                        id,
                        // A reason under 3 characters is dropped rather than
                        // sent — the backend rejects those, and it supplies
                        // its own default when none is given.
                        reason: reasonController.text,
                      )
                    // No parcel id to cancel with; the order's own status
                    // endpoint takes the parcel down with it. It carries no
                    // reason field, so what was typed is dropped here.
                    : await controller.cancelOrder(orderId!);
                if (!context.mounted) return;

                if (done) {
                  await controller.fetchMyOrdersList();
                  if (!context.mounted) return;
                  Navigator.pop(context, true);
                  return;
                }

                // The backend's own wording explains *why* far better than
                // anything generic — "the rider has already collected it.
                // Please contact support." beats "Forbidden".
                final failure = byParcel
                    ? ref.read(shopControllerProvider).cancelParcel.error
                    : ref.read(shopControllerProvider).cancelOrder.error;
                Fluttertoast.showToast(
                  msg: failure is FailureHandler
                      ? failure.message
                      : 'Could not cancel this delivery.',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.TOP,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
                Navigator.pop(context, false);
              },
            ),
            const Gap(12),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => Navigator.pop(context, false),
              child: Container(
                height: screenHeight(context) * 0.06,
                width: screenWidth(context) * 0.7,
                decoration: BoxDecoration(
                  color: kcPrimary400,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    'Keep Delivery',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: kcWhite,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}
