import 'package:cached_network_image/cached_network_image.dart';
import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:fazt_order/src/features/order/completed_order_view.dart';
import 'package:fazt_order/src/features/order/widgets/order_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../common/app_colors.dart';
import '../../common/widgets/app_refresh_indicator.dart';
import '../home/data/controller/shop_controller.dart';
import 'order_statuses.dart';

class CompletedOrders extends HookConsumerWidget {
  const CompletedOrders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myOrdersList = ref.watch(shopControllerProvider).myOrdersList;
    final hasMore =
        ref.watch(shopControllerProvider.select((s) => s.myOrdersListHasMore));
    final isLoadingMore = ref.watch(
        shopControllerProvider.select((s) => s.isLoadingMoreMyOrdersList));
    final scrollController = useScrollController();

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final position = scrollController.position;
        if (position.pixels >= position.maxScrollExtent - 300) {
          ref.read(shopControllerProvider.notifier).loadMoreMyOrdersList();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return AppRefreshIndicator(
      color: kcPrimary300,
      onRefresh: ref.read(shopControllerProvider.notifier).fetchMyOrdersList,
      child: myOrdersList.when(
        data: (ordersData) {
          final completedOrders = ordersData.results
                  ?.where(
                      (order) => kCompletedOrderStatuses.contains(order.status))
                  .toList() ??
              [];

          if (completedOrders.isEmpty) {
            return RefreshableFill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: Lottie.asset('asset/lottie/DBSkpgXyIT.json'),
                  ),
                  const Text(
                    "No completed orders yet",
                    style: TextStyle(fontSize: 14, color: kcPrimaryNeutral500),
                  ),
                ],
              ),
            );
          }

          final showFooter = isLoadingMore || !hasMore;
          return ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
            itemCount: completedOrders.length + (showFooter ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= completedOrders.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                        : Text(
                            'No more orders',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                  ),
                );
              }

              final order = completedOrders[index];
              final firstItem =
                  order.items?.isNotEmpty == true ? order.items!.first : null;
              final imageUrl = firstItem?.mealVariant?.meal?.mealImage;
              final dateText = order.createdAt?.toString().split(' ')[0] ?? "";

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Material(
                  color: kcWhite,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CompletedOrderView(orderItems: order),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kcWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kcPrimaryNeutral900),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _CompletedThumbnail(imageUrl: imageUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Order #${order.orderNumber ?? 'Unknown'}",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: kcPrimaryNeutral100,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OrderStatusBadge(status: order.status),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Iconsax.location,
                                        size: 15, color: kcPrimaryNeutral500),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        order.deliveryLocation?.address ??
                                            "Unknown Address",
                                        style: const TextStyle(
                                            color: kcPrimaryNeutral500,
                                            fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Iconsax.calendar_1,
                                            size: 14,
                                            color: kcPrimaryNeutral400),
                                        const SizedBox(width: 4),
                                        Text(
                                          dateText,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: kcPrimaryNeutral400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "₦${(order.payment?.total ?? 0).toStringAsFixed(0)}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: kcPrimary300),
                                    ),
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
            },
          );
        },
        loading: () => ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: double.infinity,
                              height: 14,
                              color: Colors.white),
                          const SizedBox(height: 8),
                          Container(
                              width: 140, height: 12, color: Colors.white),
                          const SizedBox(height: 12),
                          Container(width: 90, height: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        error: (error, stackTrace) => RefreshableFill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 180,
                width: 180,
                child: Lottie.asset('asset/lottie/DBSkpgXyIT.json'),
              ),
              const Gap(16),
              OutlinButton(
                text: "Retry",
                width: 150,
                height: 48,
                color: kcPrimary400,
                bgColor: kcPrimaryNeutral900,
                onPressed: () {
                  ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedThumbnail extends StatelessWidget {
  const _CompletedThumbnail({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
          width: 72,
          height: 72,
          color: kcPrimaryNeutral950,
          child:
              const Icon(Iconsax.bag_2, color: kcPrimaryNeutral500, size: 28),
        );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return fallback();
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: 72,
      height: 72,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: 72,
        height: 72,
        color: kcPrimaryNeutral950,
      ),
      errorWidget: (context, url, error) => fallback(),
    );
  }
}
