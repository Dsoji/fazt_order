import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../common/app_colors.dart';
import '../../common/widgets/reusable_buttons.dart';
import '../home/data/controller/shop_controller.dart';
import '../home/data/model/response/my_orders_list/result.dart';
import 'ongoing_parcel_order.dart';
import 'widgets/order_detail_widgets.dart' show formatPrice;
import 'widgets/order_status_badge.dart';
import '../../common/widgets/app_refresh_indicator.dart';

/// Every parcel this customer has sent, newest first.
///
/// Parcels share the `orders` feed with food orders, so this screen filters a
/// mixed, paginated list down to `orderType == 'parcel'`. That filter is why
/// the paging here is not the usual scroll-to-the-bottom rule: a page can come
/// back all food, leaving too few parcels on screen to scroll at all, so the
/// list also pulls the next page whenever it is holding less than a screenful.
class ParcelOrderHistory extends HookConsumerWidget {
  const ParcelOrderHistory({super.key});

  /// Below this many rows the list cannot be scrolled, so scroll position can
  /// no longer drive paging and the list has to pull pages on its own.
  static const _minRowsBeforeScrollPages = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(shopControllerProvider.notifier);
    final ordersAsync = ref.watch(shopControllerProvider).myOrdersList;
    final hasMore = ref
        .watch(shopControllerProvider.select((s) => s.myOrdersListHasMore));
    final isLoadingMore = ref.watch(
        shopControllerProvider.select((s) => s.isLoadingMoreMyOrdersList));
    final page =
        ref.watch(shopControllerProvider.select((s) => s.myOrdersListPage));
    final scrollController = useScrollController();
    final lastAutoPagedFrom = useRef<int?>(null);

    final parcels = useMemoized(
      () => _parcelsFrom(ordersAsync.valueOrNull?.results),
      [ordersAsync],
    );

    // The feed starts out as an empty list rather than "loading", so arriving
    // here without having opened My Orders first would otherwise show an empty
    // history that is really just unfetched.
    useEffect(() {
      if ((ordersAsync.valueOrNull?.results ?? const []).isEmpty) {
        Future.microtask(controller.fetchMyOrdersList);
      }
      return null;
    }, const []);

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final position = scrollController.position;
        if (position.pixels >= position.maxScrollExtent - 300) {
          controller.loadMoreMyOrdersList();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    // Keep pulling pages while the parcels found so far can't fill a screen.
    // Each page is only ever auto-requested once: a request that fails leaves
    // the page number where it was, and asking again from the same page would
    // spin on a dead connection instead of leaving the user a pull-to-refresh.
    useEffect(() {
      if (parcels.length < _minRowsBeforeScrollPages &&
          hasMore &&
          !isLoadingMore &&
          ordersAsync.hasValue &&
          lastAutoPagedFrom.value != page) {
        lastAutoPagedFrom.value = page;
        Future.microtask(controller.loadMoreMyOrdersList);
      }
      return null;
    }, [parcels.length, hasMore, isLoadingMore, page, ordersAsync]);

    return Scaffold(
      backgroundColor: kcPrimaryNeutral990,
      appBar: AppBar(
        backgroundColor: kcWhite,
        surfaceTintColor: kcWhite,
        elevation: 0,
        title: const Text(
          'Parcel History',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: kcPrimaryNeutral100,
          ),
        ),
      ),
      body: AppRefreshIndicator(
        color: kcPrimary300,
        onRefresh: controller.fetchMyOrdersList,
        child: _buildBody(
          context,
          ref,
          ordersAsync: ordersAsync,
          parcels: parcels,
          scrollController: scrollController,
          hasMore: hasMore,
          isLoadingMore: isLoadingMore,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref, {
    required AsyncValue<dynamic> ordersAsync,
    required List<OrderResult> parcels,
    required ScrollController scrollController,
    required bool hasMore,
    required bool isLoadingMore,
  }) {
    if (ordersAsync.isLoading && parcels.isEmpty) {
      return const _ParcelListSkeleton();
    }

    if (ordersAsync.hasError && parcels.isEmpty) {
      return _MessageState(
        title: "We couldn't load your parcels",
        message: 'Check your connection and try again.',
        actionLabel: 'Retry',
        onAction: ref.read(shopControllerProvider.notifier).fetchMyOrdersList,
      );
    }

    if (parcels.isEmpty) {
      // Still paging through a feed that has shown no parcels yet — saying
      // "none" here would be a lie that a moment later corrects itself.
      if (isLoadingMore || hasMore) return const _ParcelListSkeleton();

      return _MessageState(
        title: 'No parcels yet',
        message: 'Parcels you send will show up here, with their status and '
            'what you paid.',
        actionLabel: 'Send a parcel',
        onAction: () => Navigator.maybePop(context),
      );
    }

    final showFooter = isLoadingMore || !hasMore;
    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: parcels.length + (showFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= parcels.length) {
          return _ListFooter(isLoadingMore: isLoadingMore);
        }
        final parcel = parcels[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ParcelCard(
            parcel: parcel,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OngoingParcelOrderView(orderItems: parcel),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Parcels out of the mixed feed, newest first. The feed's own order is not
  /// relied on — pages are merged as they arrive, so a late page can carry
  /// older rows.
  static List<OrderResult> _parcelsFrom(List<OrderResult>? results) {
    final parcels = (results ?? const <OrderResult>[])
        .where((order) => order.orderType == 'parcel')
        .toList()
      ..sort((a, b) {
        final left = a.createdAt;
        final right = b.createdAt;
        if (left == null || right == null) return 0;
        return right.compareTo(left);
      });
    return parcels;
  }
}

/// One parcel, read top to bottom: what happened to it, where it went, what it
/// cost.
class _ParcelCard extends StatelessWidget {
  const _ParcelCard({required this.parcel, required this.onTap});

  final OrderResult parcel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kcWhite,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kcWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kcPrimaryNeutral900),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  OrderStatusBadge(status: parcel.status),
                  const Spacer(),
                  Text(
                    _formatWhen(parcel.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: kcPrimaryNeutral500,
                    ),
                  ),
                ],
              ),
              const Gap(12),
              _RouteLine(
                pickup: parcel.pickupLocation?.address,
                dropoff: parcel.deliveryLocation?.address,
              ),
              const Gap(12),
              const Divider(height: 1, color: kcPrimaryNeutral900),
              const Gap(10),
              Row(
                children: [
                  const Icon(Iconsax.receipt_item,
                      size: 14, color: kcPrimaryNeutral500),
                  const Gap(4),
                  Expanded(
                    child: Text(
                      parcel.orderNumber == null
                          ? 'No order number'
                          : '#${parcel.orderNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kcPrimaryNeutral500,
                      ),
                    ),
                  ),
                  const Gap(8),
                  Text(
                    '₦${formatPrice((parcel.payment?.total ?? 0).round())}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kcPrimary300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pickup above drop-off, joined by a rail — the shape of the journey, so the
/// two addresses can't be mistaken for each other.
class _RouteLine extends StatelessWidget {
  const _RouteLine({required this.pickup, required this.dropoff});

  final String? pickup;
  final String? dropoff;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Gap(4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kcPrimary300, width: 2),
              ),
            ),
            Container(width: 1.5, height: 22, color: kcPrimaryNeutral900),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kcPrimary300,
              ),
            ),
          ],
        ),
        const Gap(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RouteAddress(label: 'From', address: pickup),
              const Gap(10),
              _RouteAddress(label: 'To', address: dropoff),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteAddress extends StatelessWidget {
  const _RouteAddress({required this.label, required this.address});

  final String label;
  final String? address;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: kcPrimaryNeutral500,
          ),
        ),
        Text(
          address == null || address!.isEmpty ? 'Address unavailable' : address!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kcPrimaryNeutral100,
          ),
        ),
      ],
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.isLoadingMore});

  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: isLoadingMore
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kcPrimary300,
                ),
              )
            : const Text(
                "That's all your parcels",
                style: TextStyle(fontSize: 12, color: kcPrimaryNeutral500),
              ),
      ),
    );
  }
}

/// Empty and error share a shape: an illustration, a plain sentence, one way
/// forward. Scrollable so pull-to-refresh still works with nothing on screen.
class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 180,
                  width: 180,
                  child: Lottie.asset('asset/lottie/DBSkpgXyIT.json'),
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kcPrimaryNeutral100,
                  ),
                ),
                const Gap(6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: kcPrimaryNeutral500,
                  ),
                ),
                const Gap(20),
                OutlinButton(
                  text: actionLabel,
                  width: 180,
                  height: 48,
                  color: kcPrimary400,
                  bgColor: kcPrimaryNeutral900,
                  onPressed: onAction,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shaped like [_ParcelCard] so the list doesn't jump when the real rows land.
class _ParcelListSkeleton extends StatelessWidget {
  const _ParcelListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: kcPrimaryNeutral950,
          highlightColor: kcPrimaryNeutral990,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kcWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kcPrimaryNeutral900),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _bar(width: 78, height: 20, radius: 20),
                    const Spacer(),
                    _bar(width: 60, height: 12),
                  ],
                ),
                const Gap(16),
                _bar(width: double.infinity, height: 12),
                const Gap(10),
                _bar(width: 200, height: 12),
                const Gap(18),
                Row(
                  children: [
                    _bar(width: 90, height: 12),
                    const Spacer(),
                    _bar(width: 64, height: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _bar({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: kcWhite,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// A parcel's date the way someone scanning the list reads it: recent ones by
/// name and time, older ones by date. Hand-rolled because `intl` isn't a
/// dependency of this app.
String _formatWhen(DateTime? date) {
  if (date == null) return '';
  final local = date.toLocal();
  final now = DateTime.now();
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(now.year, now.month, now.day);
  final daysApart = today.difference(day).inDays;

  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final time = '$hour12:${local.minute.toString().padLeft(2, '0')} '
      '${local.hour < 12 ? 'AM' : 'PM'}';

  if (daysApart == 0) return 'Today, $time';
  if (daysApart == 1) return 'Yesterday, $time';
  if (local.year == now.year) {
    return '${local.day} ${_months[local.month - 1]}, $time';
  }
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}
