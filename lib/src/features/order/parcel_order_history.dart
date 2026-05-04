import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:fazt_order/src/features/order/ongoing_parcel_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../home/data/controller/shop_controller.dart';

class ParcelOrderHistory extends HookConsumerWidget {
  const ParcelOrderHistory({super.key});

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
        // Filter completed orders
        final completedOrders = ordersData.results
                ?.where((order) => order.orderType == 'parcel')
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
                  "No parcel out yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: const Text("Parcel Order History"),
          ),
          body: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: completedOrders.length +
                ((isLoadingMore || !hasMore) ? 1 : 0),
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
                            'No more parcels',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                  ),
                );
              }
              final order = completedOrders[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              OngoingParcelOrderView(orderItems: order)));
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpaceSmall,
                    SvgPicture.asset('asset/svgs/dotted_line.svg'),
                    verticalSpaceSmall,
                  ],
                ),
              );
            },
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
