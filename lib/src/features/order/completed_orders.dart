import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:fazt_order/src/features/order/completed_order_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../home/data/controller/shop_controller.dart';

class CompletedOrders extends HookConsumerWidget {
  const CompletedOrders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myOrdersList = ref.watch(shopControllerProvider).myOrdersList;
    final hasMore = ref.watch(
        shopControllerProvider.select((s) => s.myOrdersListHasMore));
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

    return myOrdersList.when(
      data: (ordersData) {
        // Filter completed orders (delivered, cancelled, or rejected)
        final completedOrders = ordersData.results
                ?.where((order) =>
                    order.status == 'delivered' ||
                    order.status == 'cancelled' ||
                    order.status == 'rejected')
                .toList() ??
            [];

        if (completedOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset('asset/lottie/DBSkpgXyIT.json'),
                ),
                const Text(
                  "No completed orders yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: completedOrders.length,
                itemBuilder: (context, index) {
                  final order = completedOrders[index];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CompletedOrderView(orderItems: order),
                              ),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            order.deliveryLocation?.address ??
                                                "Unknown Address",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          order.createdAt
                                                  ?.toString()
                                                  .split(' ')[0] ??
                                              "Unknown Date",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    verticalSpaceTiny,
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Order #${order.orderNumber ?? 'Unknown'}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          order.status ?? 'Unknown Status',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: order.status == 'delivered'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
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
                      verticalSpaceSmall,
                      SvgPicture.asset('asset/svgs/dotted_line.svg'),
                      verticalSpaceSmall,
                    ],
                  );
                },
              ),
              if (isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kcPrimary300,
                    ),
                  ),
                )
              else if (!hasMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'No more orders',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              const Gap(150),
            ],
          ),
        );
      },
      loading: () => ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 100,
                            height: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset('asset/lottie/DBSkpgXyIT.json'),
            ),
            const SizedBox(height: 16),
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
    );
  }
}
