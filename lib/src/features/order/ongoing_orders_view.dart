import 'package:fazt_order/src/features/bottom_sheets/cancel_order.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:lottie/lottie.dart';

import '../../common/res/app_colors.dart';
import '../../common/widgets/reusable_buttons.dart';
import '../home/data/controller/shop_controller.dart';
import '../home/data/model/response/my_orders_list/result.dart';
import 'widgets/order_detail_widgets.dart';
import '../../common/widgets/app_refresh_indicator.dart';

/// Statuses where the order has left the ongoing flow for good.
const _terminalStatuses = {'delivered', 'cancelled', 'rejected', 'refunded'};

/// Statuses where a rider should be attached to the order.
const _riderStatuses = {'ready', 'in_transit', 'arrived'};

/// The customer-facing order details page.
///
/// Mirrors the vendor Order Details layout — summary card, progress timeline,
/// items with the payment breakdown, delivery details — so the same order reads
/// the same way on both sides of the app. The cards themselves live in
/// `widgets/order_detail_widgets.dart` and are shared with [CompletedOrderView].
class OngoingOrderView extends ConsumerWidget {
  final OrderResult orderItems;

  const OngoingOrderView({
    super.key,
    required this.orderItems,
  });

  void _showCancelOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CancelOrderDialog(orderId: orderItems.id ?? '');
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track the order in the list state so a refresh (vendor accepted, rider
    // assigned, ...) is reflected here without leaving the page.
    final ordersList = ref.watch(shopControllerProvider).myOrdersList;
    final order = ordersList.valueOrNull?.results?.firstWhere(
          (result) => result.id == orderItems.id,
          orElse: () => orderItems,
        ) ??
        orderItems;

    final status = order.status?.toLowerCase();
    final isTerminal = status != null && _terminalStatuses.contains(status);
    final canCancel = status == 'pending' || status == 'paid';

    Future<void> refreshOrders() =>
        ref.read(shopControllerProvider.notifier).fetchMyOrdersList();

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
        onRefresh: refreshOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderSummaryCard(order: order),
              const Gap(16),
              if (status == 'cancelled' || status == 'rejected')
                TerminalBanner(status: status!)
              else
                _TimelineCard(order: order),
              if (_shouldShowRider(order, status)) ...[
                const Gap(16),
                RiderCard(rider: order.rider),
              ],
              const Gap(16),
              OrderItemsCard(order: order),
              const Gap(16),
              OrderDeliveryCard(order: order),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isTerminal
          ? null
          : _ActionBar(
              status: status,
              canCancel: canCancel,
              onCancel: () => _showCancelOrderDialog(context),
            ),
    );
  }

  /// The rider section appears once one is attached, and from the pickup stage
  /// onwards it also explains that a rider is still being assigned.
  bool _shouldShowRider(OrderResult order, String? status) {
    if (order.rider?.hasDetails == true) return true;
    return status != null && _riderStatuses.contains(status);
  }
}

// ---------------------------------------------------------------------------
// Progress
// ---------------------------------------------------------------------------

class _TimelineCard extends StatelessWidget {
  final OrderResult order;

  const _TimelineCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.status?.toLowerCase();
    final steps = _stepsFor(order);
    final currentStep = _stepForStatus(status);

    return SectionCard(
      title: 'Progress',
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 130,
                  width: 130,
                  child: Lottie.asset(_lottieForStatus(status)),
                ),
                const Gap(6),
                Text(
                  _statusDescription(status),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.neutral400,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const Gap(18),
          for (var i = 0; i < steps.length; i++)
            TimelineStep(
              title: steps[i].title,
              subtitle: steps[i].subtitle,
              isDone: i < currentStep,
              isCurrent: i == currentStep,
              isLast: i == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _StepData {
  final String title;
  final String subtitle;

  const _StepData(this.title, this.subtitle);
}

/// The animation that plays above the timeline for the current status.
String _lottieForStatus(String? status) {
  switch (status) {
    case 'paid':
    case 'accepted':
      return 'asset/lottie/delivery-accepted.json';
    case 'preparing':
    case 'ready':
    case 'delivered':
      return 'asset/lottie/rice-cooker.json';
    case 'in_transit':
    case 'arrived':
      return 'asset/lottie/yes-brruu.json';
    default:
      return 'asset/lottie/delivery-accepted.json';
  }
}

String _statusDescription(String? status) {
  switch (status) {
    case 'pending':
      return 'Waiting for payment to be processed.';
    case 'paid':
      return 'Order has been paid for, waiting for the vendor to confirm it.';
    case 'accepted':
      return 'Your order was accepted by the vendor.';
    case 'preparing':
      return 'Your order is being prepared by the vendor.';
    case 'ready':
      return 'Order ready and waiting to be picked up by a rider.';
    case 'in_transit':
      return 'Your order has been picked up and is on the way to you.';
    case 'arrived':
      return 'Your rider has arrived.';
    case 'delivered':
      return 'Your order has been delivered.';
    default:
      return 'Waiting for the vendor to confirm your order.';
  }
}

List<_StepData> _stepsFor(OrderResult order) {
  final status = order.status?.toLowerCase();
  final placedAt = order.orderPlacedAt ?? order.createdAt;
  final isPickedUp =
      status == 'in_transit' || status == 'arrived' || status == 'delivered';

  return [
    _StepData(
      'Order placed',
      placedAt != null ? formatDateTime(placedAt) : 'Placed',
    ),
    _StepData(
      'Vendor confirmed the order',
      (status == 'pending' || status == 'paid')
          ? 'Waiting for the vendor'
          : 'Order accepted',
    ),
    _StepData(
      'Preparing your order',
      status == 'preparing'
          ? 'In progress'
          : (status == 'ready' || isPickedUp)
              ? 'Completed'
              : 'Yet to start',
    ),
    _StepData(
      'Ready for pickup',
      status == 'ready'
          ? 'Waiting for a rider'
          : isPickedUp
              ? 'Picked up by the rider'
              : 'Not ready yet',
    ),
    _StepData(
      'On the way to you',
      switch (status) {
        'in_transit' => 'The rider is on the way',
        'arrived' => 'The rider has arrived',
        'delivered' => 'Completed',
        _ => 'Yet to be picked up',
      },
    ),
    _StepData(
      'Order delivered',
      status == 'delivered' ? 'Order delivered' : 'Yet to be delivered',
    ),
  ];
}

int _stepForStatus(String? status) {
  switch (status) {
    case 'pending':
    case 'paid':
      return 0;
    case 'accepted':
      return 1;
    case 'preparing':
      return 2;
    case 'ready':
      return 3;
    case 'in_transit':
    case 'arrived':
      return 4;
    case 'delivered':
      return 5;
    default:
      return 0;
  }
}

// ---------------------------------------------------------------------------
// Action bar
// ---------------------------------------------------------------------------

class _ActionBar extends StatelessWidget {
  final String? status;
  final bool canCancel;
  final VoidCallback onCancel;

  const _ActionBar({
    required this.status,
    required this.canCancel,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content;

    if (canCancel) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Waiting for the vendor to confirm your order. You can still cancel it for now.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.neutral500),
          ),
          const Gap(10),
          OutlinButton(
            text: 'Cancel order',
            width: double.infinity,
            height: 50,
            fontSize: 15,
            onPressed: onCancel,
            color: AppColors.red500,
            bgColor: Colors.transparent,
          ),
        ],
      );
    } else {
      final banner = switch (status) {
        'accepted' => const WaitingBanner(
            icon: IconsaxPlusLinear.tick_circle,
            title: 'Order confirmed',
            message: 'The vendor accepted your order and will start soon.',
          ),
        'preparing' => const WaitingBanner(
            icon: IconsaxPlusLinear.reserve,
            title: 'Being prepared',
            message: 'The vendor is preparing your order right now.',
          ),
        'ready' => const WaitingBanner(
            icon: IconsaxPlusLinear.box_tick,
            title: 'Waiting for a rider',
            message: 'Your order is ready and waiting to be picked up.',
          ),
        'in_transit' => const WaitingBanner(
            icon: IconsaxPlusLinear.truck,
            title: 'On the way',
            message: 'The rider is bringing your order to you.',
          ),
        'arrived' => const WaitingBanner(
            icon: IconsaxPlusLinear.location_tick,
            title: 'Rider has arrived',
            message: 'Share your OTP with the rider to collect your order.',
          ),
        _ => null,
      };

      if (banner == null) return const SizedBox.shrink();
      content = banner;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.neutral900)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: content,
        ),
      ),
    );
  }
}
