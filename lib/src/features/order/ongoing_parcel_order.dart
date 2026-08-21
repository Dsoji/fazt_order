import 'package:fazt_order/src/common/app_colors.dart';
import 'package:fazt_order/src/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';

import '../../common/components/vertical_stripe_pattern.dart';
import '../../common/widgets/app_refresh_indicator.dart';
import '../../common/widgets/text_styles.dart';
import '../courier/data/model/parcel_request.dart';
import '../home/data/controller/shop_controller.dart';
import '../home/data/model/response/my_orders_list/payment.dart';
import '../home/data/model/response/my_orders_list/result.dart';
import 'widgets/parcel_actions_section.dart';
import 'widgets/pending_payment_action.dart';

final logger = Logger();

/// Renders the parcel lifecycle:
///
/// `pending → processing → paid → accepted → rider_arrived_for_pickup →
/// in_transit → arrived → delivered`, plus `cancelled` and `refunded`.
///
/// There is no `preparing` or `ready` on this path — those are kitchen statuses
/// and belong to food orders only. A `received` status can still show up on
/// parcels created under the old shared flow; it means the same thing as
/// `paid`. `ready` is kept for the same reason.
class OngoingParcelStatusHelper {
  /// Number of dashes in the progress bar. Must match the top of the range
  /// returned by [getProgressStep].
  static const int totalSteps = 6;

  static String getGifAsset(String? status) {
    switch (status) {
      case 'pending':
      case 'processing':
      case 'paid':
      case 'received':
      case 'ready':
      case 'accepted':
        return 'asset/gif/onboard1.gif';
      case 'rider_arrived_for_pickup':
      case 'in_transit':
        return 'asset/gif/onboard3.gif';
      case 'arrived':
      case 'delivered':
        return 'asset/gif/onboard2.gif';
      default:
        return 'asset/gif/onboard1.gif';
    }
  }

  static String getStatusDescription(String? status) {
    switch (status) {
      case 'pending':
        return "Waiting for payment to be processed.";
      case 'processing':
        return "Your payment is being confirmed.";
      case 'paid':
      case 'received':
      case 'ready':
        return "Parcel has been paid for, waiting for a rider to accept your order.";
      case 'accepted':
        return "Parcel is accepted by rider and on their way to the pickup location.";
      case 'rider_arrived_for_pickup':
        return "Rider has arrived at the pickup location.";
      case 'in_transit':
        return "Parcel has been picked up and is on the way to the receiver.";
      case 'arrived':
        return "Rider has arrived at the delivery location.";
      case 'delivered':
        return "Parcel has been delivered.";
      case 'cancelled':
        return "This parcel delivery was cancelled.";
      case 'refunded':
        return "This parcel delivery was cancelled and refunded to your wallet.";
      default:
        return "Waiting for rider to accept your order.";
    }
  }

  /// Number of filled dashes, 0..[totalSteps].
  static int getProgressStep(String? status) {
    switch (status) {
      case 'pending':
      case 'processing':
      case 'cancelled':
      case 'refunded':
        return 0;
      case 'paid':
      case 'received':
      case 'ready':
        return 1;
      case 'accepted':
        return 2;
      case 'rider_arrived_for_pickup':
        return 3;
      case 'in_transit':
        return 4;
      case 'arrived':
        return 5;
      case 'delivered':
        return totalSteps;
      default:
        return 0;
    }
  }
}

class OngoingParcelOrderView extends HookConsumerWidget {
  final OrderResult orderItems;

  const OngoingParcelOrderView({
    super.key,
    required this.orderItems,
  });

  /// This order's payment as the feed last reported it, or null when the feed
  /// has nothing for it — the caller falls back to the snapshot then.
  Payment? _livePayment(WidgetRef ref) {
    final id = orderItems.id;
    if (id == null || id.isEmpty) return null;

    final results =
        ref.watch(shopControllerProvider).myOrdersList.valueOrNull?.results;
    for (final order in results ?? const <OrderResult>[]) {
      if (order.id == id) return order.payment;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    logger.d('Order Items: ${orderItems.status}');
    logger.d('Order otp: ${orderItems.riderOtp}');
    // Without this id there is no cancel button and no pay button — every
    // action on this screen is keyed to the parcel, not the order — so it is
    // the first thing to check when they are missing.
    logger.d('Parcel id: ${orderItems.parcelId}');

    // [orderItems] is a snapshot taken when the list was last fetched, so its
    // status goes stale the moment something on this screen changes the parcel
    // — paying, most of all. `/parcels/:id/actions` is refetched here and after
    // every action, so its status is the current one; the snapshot is only the
    // fallback for orders with no parcel id, and while the first fetch is still
    // in flight.
    final liveStatus = (orderItems.parcelId?.isNotEmpty ?? false)
        ? ref.watch(shopControllerProvider).parcelActions.valueOrNull?.status ??
            orderItems.status
        : orderItems.status;

    // The same staleness applies to the payment. Finishing a charge from this
    // screen settles it on the server, and the snapshot would go on offering to
    // pay for something already paid for.
    final livePayment = _livePayment(ref) ?? orderItems.payment;

    // The pickup code lives on the parcel and nowhere else — the orders feed
    // has no field for it — so the screen fetches the parcel to show it. Only
    // the sender is ever sent one, and this screen is the sender's.
    //
    // The parcel is held here rather than in the controller's state: one
    // shared slot cannot say which parcel it is answering for, and the id it
    // was matched on is not always in the payload, so the code went missing on
    // the screen that exists to show it. A local value is only ever this
    // screen's parcel, and is cleared when the screen switches to another.
    // Which id addresses the parcel is not settled: the feed names one on some
    // order rows and not others, and where it doesn't, the order's own id is
    // all there is. Both are tried in turn rather than picking one and losing
    // the code on every order that disagrees — the first parcel that comes
    // back wins, and a wrong id costs one 404.
    final parcelId = orderItems.parcelId ?? '';
    final orderId = orderItems.id ?? '';
    final parcel = useState<Parcel?>(null);

    // Held as a callback rather than inlined in the effect, because the pull to
    // refresh has to walk the same candidates again — the pickup code is the
    // one thing on this screen the orders feed cannot re-deliver.
    final loadParcel = useCallback(() async {
      // A set, because the two are the same id on orders that carry both.
      final candidates = <String>{parcelId, orderId}
        ..removeWhere((id) => id.isEmpty);

      for (final id in candidates) {
        final loaded =
            await ref.read(shopControllerProvider.notifier).loadParcel(id);
        logger.d('GET parcels/$id -> status ${loaded?.status}, '
            'pickupOTP ${loaded?.pickupOTP}');
        if (loaded != null) return loaded;
      }
      return null;
    }, [parcelId, orderId]);

    useEffect(() {
      var cancelled = false;
      Future.microtask(() async {
        final loaded = await loadParcel();
        // The screen may have been popped, or moved to another parcel,
        // while the request was in flight.
        if (cancelled || loaded == null) return;
        parcel.value = loaded;
      });
      return () => cancelled = true;
    }, [loadParcel]);

    // Everything this screen reads that can move on the server: the orders feed
    // behind the payment, the parcel actions behind [liveStatus], and the parcel
    // itself behind the pickup code.
    Future<void> refresh() async {
      final controller = ref.read(shopControllerProvider.notifier);
      final refetching = <Future<void>>[
        controller.fetchMyOrdersList(),
        if (parcelId.isNotEmpty) controller.fetchParcelActions(parcelId),
      ];

      final loaded = await loadParcel();
      if (loaded != null && context.mounted) parcel.value = loaded;
      await Future.wait(refetching);
    }

    final pickupCode = parcel.value?.pickupOTP;
    // Read from the order, not the parcel: the two records used to carry
    // different delivery codes and only the order's was ever checked.
    final deliveryCode = orderItems.riderOtp;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Iconsax.arrow_left_2),
        ),
        title: Text(
          "Your Parcel Order",
          style: ktBodySemiBoldSize20.copyWith(
            fontSize: 24,
            letterSpacing: 1,
          ),
        ),
      ),
      backgroundColor: kcPrimaryNeutral950,
      body: AppRefreshIndicator(
        color: kcPrimary300,
        onRefresh: refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Icon and Order Status
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        OngoingParcelStatusHelper.getGifAsset(liveStatus),
                        height: 250,
                        width: 250,
                      ),
                      verticalSpaceSmall,

                      verticalSpaceSmall,
                      Text(
                        textAlign: TextAlign.center,
                        OngoingParcelStatusHelper.getStatusDescription(
                            liveStatus),
                        style: const TextStyle(
                            fontSize: 16,
                            color: kcPrimaryNeutral200,
                            letterSpacing: 1),
                      ),
                      verticalSpaceSmall,
                      // const Text(
                      //   '00:00 ',
                      //   style: TextStyle(
                      //       fontSize: 16,
                      //       color: kcPrimaryNeutral200,
                      //       fontWeight: FontWeight.w600),
                      // ),
                      verticalSpaceSmall,
                      DashProgressBar(
                          currentStep:
                              OngoingParcelStatusHelper.getProgressStep(
                                  liveStatus),
                          totalSteps: OngoingParcelStatusHelper.totalSteps,
                          activeColor: kcPrimary200,
                          inactiveColor: kcPrimary800),
                      verticalSpaceSmall,
                      verticalSpaceMedium,
                      // Every button here — and whether cancelling is offered at
                      // all — comes from `/parcels/:id/actions`. The old
                      // `pending || paid` gate has been dropped precisely because
                      // that line moves: it once ran to
                      // `rider_arrived_for_pickup` and now closes at `accepted`.
                      // Only the backend knows where it currently sits.
                      // A parcel that was created but never paid for also pays
                      // from here — it is the only screen it can still be
                      // reached from once the review screen is behind the user.
                      // An unpaid Paystack charge keeps its checkout link, so
                      // the way back into it is reopening that link rather than
                      // raising a new charge below.
                      if (PendingPaymentAction.isResumable(livePayment))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: PendingPaymentAction(
                            orderId: orderItems.id,
                            payment: livePayment,
                            onResolved: () => ref
                                .read(shopControllerProvider.notifier)
                                .fetchMyOrdersList(),
                          ),
                        ),
                      ParcelActionsSection(
                        parcelId: orderItems.parcelId,
                        // The way to cancel when the feed gave no parcel id.
                        orderId: orderItems.id,
                        // What the feed last said. It only decides anything
                        // while `/parcels/:id/actions` has not answered, and it
                        // is what keeps cancel on offer for a parcel no rider
                        // has accepted when that call fails outright.
                        fallbackStatus: orderItems.status,
                        amountDue: livePayment?.total,
                        deliveryType: orderItems.deliveryType,
                        existingPayment: livePayment,
                        onChanged: () => ref
                            .read(shopControllerProvider.notifier)
                            .fetchMyOrdersList(),
                      ),
                      // if (isCompleted) verticalSpaceSmall,
                    ],
                  ),
                ),
                verticalSpaceSmall,
                SvgPicture.asset(
                    'asset/svgs/dotted_line.svg'), // Dashed divider
                verticalSpace(4),

                // Delivery Details
                const Text(
                  "Delivery Details",
                  style: TextStyle(fontSize: 14, letterSpacing: 1),
                ),
                Row(
                  children: [
                    const Icon(Iconsax.location, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        orderItems.deliveryLocation?.address ?? '',
                        style: const TextStyle(
                            color: kcPrimaryNeutral500, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                verticalSpaceSmall,
                SvgPicture.asset('asset/svgs/dotted_line.svg'),
                verticalSpaceSmall,

                // Codes section. Two different 4-digit numbers held by two
                // different people, so each is labelled with who quotes it and
                // what it does. A code the backend never issued is left off
                // entirely rather than shown empty — pre-release parcels have no
                // pickup code, and the rider is not asked for one.
                if (pickupCode != null)
                  _ParcelCodeRow(
                    icon: Iconsax.box,
                    label: 'Pickup code',
                    hint: 'Give this to the rider at collection',
                    code: pickupCode,
                  ),
                if (pickupCode != null && deliveryCode != null)
                  verticalSpaceSmall,
                if (deliveryCode != null)
                  _ParcelCodeRow(
                    icon: Iconsax.message,
                    label: 'Delivery code',
                    hint:
                        'Share with your receiver — they give it to the rider',
                    code: deliveryCode,
                  ),

                if (pickupCode != null || deliveryCode != null) ...[
                  verticalSpaceSmall,
                  SvgPicture.asset('asset/svgs/dotted_line.svg'),
                  verticalSpaceSmall,
                ],

                // Order Summary
                const Row(
                  children: [
                    Icon(Iconsax.task_square,
                        size: 20, color: kcPrimaryNeutral200),
                    SizedBox(width: 8),
                    Text(
                      "Order Summary",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: kcPrimaryNeutral200),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...(orderItems.items ?? []).map((item) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 25.0, bottom: 4, top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.mealVariant?.meal?.mealName ?? '',
                          style: const TextStyle(color: kcPrimaryNeutral500),
                        ),
                        Text(
                          "x${item.mealQuantity ?? 0}",
                          style: const TextStyle(color: kcPrimaryNeutral500),
                        ),
                      ],
                    ),
                  );
                }),

                verticalSpaceSmall,
                SvgPicture.asset(
                    'asset/svgs/dotted_line.svg'), // Dashed divider
                verticalSpaceSmall,

                // Payment Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Payment Details",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                            color: kcPrimaryNeutral100),
                      ),
                      verticalSpaceSmall,
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text("Subtotal (${orderItems.items?.length} items)",
                      //         style: const TextStyle(
                      //             color: kcPrimaryNeutral300, fontSize: 14)),
                      //     Text(
                      //         "₦${orderItems.payment?.subtotal?.toStringAsFixed(0) ?? '0'}",
                      //         style: const TextStyle(
                      //             color: kcPrimaryNeutral100, fontSize: 12)),
                      //   ],
                      // ),
                      // verticalSpaceSmall,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Delivery Fee",
                              style: TextStyle(
                                  color: kcPrimaryNeutral300, fontSize: 14)),
                          Text("₦${orderItems.payment?.deliveryFee}",
                              style: const TextStyle(
                                  color: kcPrimaryNeutral100, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tax and other fees",
                              style: TextStyle(
                                  color: kcPrimaryNeutral300, fontSize: 14)),
                          Text("₦${orderItems.payment?.serviceFee}",
                              style: const TextStyle(
                                  color: kcPrimaryNeutral100, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total",
                              style: TextStyle(
                                  color: kcPrimaryNeutral100,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          Text("₦${orderItems.payment?.total}",
                              style: const TextStyle(
                                  color: kcPrimaryNeutral100,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One 4-digit code, with the person who quotes it named in [label].
///
/// A parcel can show two of these at once and they are not interchangeable —
/// one starts the trip, the other ends it — so neither is ever labelled just
/// "OTP".
class _ParcelCodeRow extends StatelessWidget {
  final IconData icon;
  final String label;

  /// Who this code is for and when — the sender holds both of them and hands
  /// each to a different person, so the screen says which.
  final String hint;

  final int code;

  const _ParcelCodeRow({
    required this.icon,
    required this.label,
    required this.hint,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                          color: kcPrimaryNeutral200,
                          fontSize: 12,
                          letterSpacing: 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  hint,
                  style:
                      const TextStyle(color: kcPrimaryNeutral500, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          // Padded, because a code the backend generated as 421 is still the
          // four characters "0421" to the person reading it out.
          code.toString().padLeft(4, '0'),
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: kcPrimaryNeutral200),
        ),
      ],
    );
  }
}
