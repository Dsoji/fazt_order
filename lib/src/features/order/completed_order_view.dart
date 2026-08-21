import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../common/res/app_colors.dart';
import '../../common/widgets/app_refresh_indicator.dart';
import '../home/data/controller/shop_controller.dart';
import '../home/data/model/response/my_orders_list/result.dart';
import '../home/data/model/response/my_orders_list/status_history.dart';
import 'widgets/order_detail_widgets.dart';

/// The detail page for an order that has finished — delivered, cancelled or
/// declined.
///
/// Built from the same cards as [OngoingOrderView] so an order reads the same
/// way before and after it lands: gradient header, outcome, the rider who
/// brought it, items with the payment breakdown, delivery details. The
/// differences are all things that only make sense once an order is over — the
/// timeline is rebuilt from what actually happened rather than projected
/// forward, the OTP is gone, and the rider can no longer be called.
class CompletedOrderView extends ConsumerWidget {
  const CompletedOrderView({super.key, required this.orderItems});

  final OrderResult orderItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the order back out of the list state, the same way [OngoingOrderView]
    // does, so a pull-to-refresh here shows what the refetch brought back —
    // a refund settling, a rider record filling in — instead of redrawing the
    // snapshot this page was pushed with.
    final ordersList = ref.watch(shopControllerProvider).myOrdersList;
    final order = ordersList.valueOrNull?.results?.firstWhere(
          (result) => result.id == orderItems.id,
          orElse: () => orderItems,
        ) ??
        orderItems;

    final status = order.status?.toLowerCase();
    final isDelivered = status == 'delivered';
    final rider = order.rider;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: const OrderDetailBackButton(),
        title: const Text(
          'Order details',
          style: TextStyle(
            color: AppColors.neutral100,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: AppRefreshIndicator(
        color: AppColors.brand300,
        onRefresh: ref.read(shopControllerProvider.notifier).fetchMyOrdersList,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderSummaryCard(
                order: order,
                gradient: isDelivered
                    ? null
                    : const [AppColors.neutral300, AppColors.neutral200],
              ),
              const Gap(16),
              if (isDelivered)
                _DeliveredCard(order: order)
              else ...[
                TerminalBanner(status: status ?? 'cancelled'),
                const Gap(16),
                _HistoryCard(order: order),
              ],
              // A cancelled order never had a rider, so only a delivered one has
              // anything worth showing here.
              if (isDelivered && rider?.hasDetails == true) ...[
                const Gap(16),
                RiderCard(rider: rider, canCall: false),
              ],
              const Gap(16),
              OrderItemsCard(order: order),
              const Gap(16),
              OrderDeliveryCard(order: order, showOtp: false),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Outcome
// ---------------------------------------------------------------------------

/// The celebration card for a delivered order, with the journey it took.
class _DeliveredCard extends StatelessWidget {
  final OrderResult order;

  const _DeliveredCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final deliveredAt = _timestampFor(order, 'delivered') ?? order.updatedAt;

    return SectionCard(
      title: 'Outcome',
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 130,
                  width: 130,
                  child: Lottie.asset('asset/lottie/yes-brruu.json'),
                ),
                const Gap(6),
                const Text(
                  'Order delivered successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral100,
                  ),
                ),
                if (deliveredAt != null) ...[
                  const Gap(4),
                  Text(
                    'Delivered on ${formatDate(deliveredAt)} '
                    'at ${formatTime(deliveredAt)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral400,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Gap(18),
          _CompletedTimeline(order: order),
        ],
      ),
    );
  }
}

/// What happened to an order that never made it, laid out as a rail.
class _HistoryCard extends StatelessWidget {
  final OrderResult order;

  const _HistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'What happened',
      child: _CompletedTimeline(order: order),
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline
// ---------------------------------------------------------------------------

/// The stages this order actually went through.
///
/// The ongoing page projects the full six-step journey and marks how far the
/// order has got. Here the journey is over, so the rail is built from the
/// status history the backend recorded — every step shown is one that really
/// happened, and the final one is where the order stopped.
class _CompletedTimeline extends StatelessWidget {
  final OrderResult order;

  const _CompletedTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final steps = _stepsFor(order);

    if (steps.isEmpty) {
      return const Text(
        'No history was recorded for this order.',
        style: TextStyle(fontSize: 13, color: AppColors.neutral500),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          TimelineStep(
            title: steps[i].title,
            subtitle: steps[i].subtitle,
            // Everything here already happened, so every step is done except
            // the last, which is highlighted as where the order came to rest.
            isDone: i < steps.length - 1,
            isCurrent: i == steps.length - 1,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _StepData {
  final String title;
  final String subtitle;

  const _StepData(this.title, this.subtitle);
}

/// Builds the rail from the recorded status history.
///
/// Falls back to a two-step placed/finished rail when the backend sent no
/// history, so the card is never empty for an order we do have dates for.
List<_StepData> _stepsFor(OrderResult order) {
  final history = order.statusHistory ?? const <StatusHistory>[];
  final placedAt = order.orderPlacedAt ?? order.createdAt;

  final entries = history
      .where((entry) => entry.status != null && entry.status!.isNotEmpty)
      .toList()
    ..sort((a, b) {
      final aTime = a.timestamp;
      final bTime = b.timestamp;
      if (aTime == null || bTime == null) return 0;
      return aTime.compareTo(bTime);
    });

  if (entries.isEmpty) {
    final finishedAt = order.updatedAt;
    return [
      _StepData(
        'Order placed',
        placedAt != null ? formatDateTime(placedAt) : 'Placed',
      ),
      _StepData(
        _titleForStatus(order.status?.toLowerCase()),
        finishedAt != null ? formatDateTime(finishedAt) : 'Completed',
      ),
    ];
  }

  return [
    for (final entry in entries)
      _StepData(
        _titleForStatus(entry.status?.toLowerCase()),
        entry.timestamp != null
            ? formatDateTime(entry.timestamp!)
            : (entry.notes?.trim().isNotEmpty == true
                ? entry.notes!.trim()
                : 'Recorded'),
      ),
  ];
}

String _titleForStatus(String? status) {
  switch (status) {
    case 'pending':
      return 'Order placed';
    case 'processing':
      return 'Confirming your payment';
    case 'paid':
    case 'received':
      return 'Payment confirmed';
    case 'accepted':
      return 'Vendor confirmed the order';
    case 'preparing':
      return 'Preparing your order';
    case 'ready':
      return 'Ready for pickup';
    case 'rider_arrived_for_pickup':
      return 'Rider arrived at pickup';
    case 'in_transit':
      return 'On the way to you';
    case 'arrived':
      return 'Rider arrived';
    case 'delivered':
      return 'Order delivered';
    case 'cancelled':
      return 'Order cancelled';
    case 'rejected':
      return 'Order declined by the vendor';
    case 'refunded':
      return 'Refunded to your wallet';
    default:
      return status?.replaceAll('_', ' ') ?? 'Order updated';
  }
}

/// The moment the order first reached [status], if the backend recorded it.
DateTime? _timestampFor(OrderResult order, String status) {
  for (final entry in order.statusHistory ?? const <StatusHistory>[]) {
    if (entry.status?.toLowerCase() == status && entry.timestamp != null) {
      return entry.timestamp;
    }
  }
  return null;
}
