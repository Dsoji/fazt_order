import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../webview_flutter.dart';
import '../../../common/app_colors.dart';
import '../../../common/res/app_colors.dart';
import '../../../common/widgets/reusable_buttons.dart';
import '../../courier/data/model/parcel_actions.dart';
import '../../courier/widgets/parcel_payment_method_sheet.dart';
import '../../home/data/controller/shop_controller.dart';
import '../../home/data/model/response/my_orders_list/payment.dart';
import 'order_detail_widgets.dart' show formatPrice;
import 'parcel_cancel_dialog.dart';
import 'pending_payment_action.dart';

/// The action area on a parcel screen, built from `GET /parcels/:id/actions`.
///
/// Everything here comes off the response: the status line, which buttons
/// exist, their labels, and whether each needs a confirmation step. The app
/// holds no status list and no role table of its own — those rules live on the
/// backend and change without the app shipping, so a local copy would go stale
/// silently rather than loudly.
///
/// Two things are decided here rather than there. The first is cancelling a
/// parcel no rider has accepted: the sender may always do that, so
/// [ParcelActions.cancellableBeforeRider] keeps the button up even when the
/// actions call answers without a cancel entry or fails outright. Past that
/// point the backend's answer is the only one — whether a rider already on
/// their way may be stood down is its call.
///
/// The second is paying. Payment is not a lifecycle transition, so it
/// never shows up in `actions`; a parcel left unpaid comes back as `pending`
/// with cancel as its only entry. That parcel still has to be payable from
/// here, so [ParcelActions.awaitingPayment] drives a pay button alongside the
/// backend's own.
///
/// Which is why the pay button here stands down when the parcel still has a
/// resumable Paystack charge ([existingPayment]). That case belongs to
/// [PendingPaymentAction] on the screen above: it reopens the charge that
/// already exists, where this section would start a second one and risk
/// billing the customer twice. With nothing outstanding, this button is the
/// only way to pay and stays.
///
/// Renders nothing without a parcel id. Orders from the old shared flow have
/// none, and there is nothing to drive from.
class ParcelActionsSection extends HookConsumerWidget {
  const ParcelActionsSection({
    super.key,
    required this.parcelId,
    this.orderId,
    this.fallbackStatus,
    this.amountDue,
    this.deliveryType,
    this.existingPayment,
    this.onChanged,
  });

  final String? parcelId;

  /// The order this parcel belongs to. Cancelling falls back to the order's
  /// own status endpoint when there is no [parcelId] to use the parcel one
  /// with, so a parcel the feed never gave an id for is still cancellable.
  final String? orderId;

  /// The status the screen already knows, from the orders feed.
  ///
  /// Used only while the actions call has not answered — or could not. A
  /// parcel no rider has accepted is cancellable regardless, and this is what
  /// that decision is made from when the backend's own answer is missing.
  final String? fallbackStatus;

  /// What the parcel costs, shown in the payment sheet and weighed against the
  /// wallet balance there. The backend re-verifies the figure when the charge
  /// lands, so this is display only.
  final num? amountDue;

  /// The type the parcel was created under, echoed back to `POST /orders/parcel`
  /// so paying later does not silently reprice it as a standard delivery.
  final String? deliveryType;

  /// The order's own payment record, when the screen has one. An unsettled
  /// charge here means the screen is already offering a way to finish it, and
  /// this section's own pay button steps aside.
  final Payment? existingPayment;

  /// Fired after an action changes the parcel, so the surrounding screen can
  /// refresh what it is showing.
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = parcelId;
    final hasParcelId = id != null && id.isNotEmpty;

    useEffect(() {
      if (!hasParcelId) return null;
      Future.microtask(
        () => ref.read(shopControllerProvider.notifier).fetchParcelActions(id),
      );
      return null;
    }, [id]);

    // Nothing to act on at all — no parcel to ask about and no order to cancel
    // through.
    if (!hasParcelId && (orderId == null || orderId!.isEmpty)) {
      return const SizedBox.shrink();
    }

    final actionsAsync = ref.watch(shopControllerProvider).parcelActions;
    // Only meaningful when there was a parcel id to have fetched them with —
    // otherwise this slot holds some other parcel's answer, or none.
    final actions = hasParcelId ? actionsAsync.valueOrNull : null;
    final failed = hasParcelId && actions == null && actionsAsync.hasError;

    // Still waiting on the first fetch: nothing to show yet, and nothing has
    // gone wrong. Without a parcel id there is nothing to wait for, and the
    // snapshot status drives the section on its own.
    if (hasParcelId && actions == null && !failed) {
      return const SizedBox.shrink();
    }

    final status = actions?.status ?? fallbackStatus;
    final description = actions?.statusDescription ??
        (failed ? "We couldn't load this parcel's latest status." : null);
    // The backend's answer when there is one, and on top of it the standing
    // rule that a parcel no rider has accepted may always be cancelled. A
    // failed actions call therefore no longer takes the cancel button down
    // with it — which is the whole point, since an unaccepted parcel is
    // exactly the one a sender is most likely to want out of.
    final canCancel = (actions?.canCancel ?? false) ||
        ParcelActions.cancellableBeforeRider(status);
    final cancelAction = actions?.cancelAction;
    final awaitingPayment = actions?.awaitingPayment ?? (status == 'pending');
    final canResumePayment = PendingPaymentAction.isResumable(existingPayment);
    final isPaying =
        ref.watch(shopControllerProvider).makeParcelPayment.isLoading;

    if (description == null &&
        !canCancel &&
        (!awaitingPayment || canResumePayment)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral900),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.info_circle,
                    size: 16, color: AppColors.brand400),
                const Gap(8),
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: kcPrimaryNeutral200,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            if (canCancel || (awaitingPayment && !canResumePayment))
              const Gap(16),
          ],
          // A charge that can still be resumed is paid for by the screen's own
          // [PendingPaymentAction], sitting just above this box — so this
          // section stays quiet rather than offering a second, competing
          // button that would start a fresh charge.
          // Paying posts the parcel, so it needs the parcel's own id.
          if (awaitingPayment && !canResumePayment && hasParcelId) ...[
            FullButton(
              width: double.infinity,
              height: 46,
              color: AppColors.brand400,
              textColor: kcWhite,
              isLoading: isPaying,
              text: amountDue == null || amountDue! <= 0
                  ? 'Make Payment'
                  : 'Pay ₦${formatPrice(amountDue!.round())}',
              onPressed: () => _pay(context, ref, id),
            ),
            if (canCancel) const Gap(12),
          ],
          if (canCancel)
            OutlinButton(
              width: double.infinity,
              height: 46,
              color: kcPrimary400,
              bgColor: Colors.white,
              // The backend's own label wins — it phrases the action for this
              // caller and this status.
              text: cancelAction?.label ?? 'Cancel Delivery',
              onPressed: () async {
                final cancelled = await showDialog<bool>(
                  context: context,
                  builder: (_) => ParcelCancelDialog(
                    parcelId: hasParcelId ? id : null,
                    orderId: orderId,
                    requiresConfirmation:
                        cancelAction?.requiresConfirmation ?? true,
                  ),
                );
                if (cancelled == true) {
                  onChanged?.call();
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          if (failed && hasParcelId)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => ref
                    .read(shopControllerProvider.notifier)
                    .fetchParcelActions(id),
                child: const Text(
                  'Try again',
                  style: TextStyle(fontSize: 13, color: kcPrimary400),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Charges a parcel that was created but never paid for.
  ///
  /// The same `POST /orders/parcel` the review screen uses: wallet settles
  /// inline and there is nothing to open, while paystack hands back a URL for
  /// the webview. Either way the actions are refetched afterwards, since a
  /// successful charge moves the parcel off `pending` and changes what this
  /// section may offer.
  Future<void> _pay(BuildContext context, WidgetRef ref, String id) async {
    final controller = ref.read(shopControllerProvider.notifier);
    if (ref.read(shopControllerProvider).makeParcelPayment.isLoading) return;

    final method = await showParcelPaymentMethodSheet(
      context,
      amount: amountDue ?? 0,
    );
    if (method == null || !context.mounted) return;

    final paid = await controller.makeParcelPayment(
      id,
      method,
      deliveryType ?? 'Standard',
    );
    if (!paid || !context.mounted) return;

    final details = ref.read(shopControllerProvider).makeParcelPayment.valueOrNull;

    // A wallet payment is already settled — there is no redirect to follow,
    // and pushing an empty webview would strand the user on a blank page.
    if (details?.payment?.completed != true &&
        details?.redirectRequired == true) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FaztWebViewScreen(
            uri: details?.payment?.paymentUrl ?? '',
            reference: details?.payment?.reference ?? '',
            title: 'Parcel Payment',
          ),
        ),
      );
    }

    await controller.fetchParcelActions(id);
    onChanged?.call();
  }
}
