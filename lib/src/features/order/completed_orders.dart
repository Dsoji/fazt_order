import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../common/ui_helpers.dart';
import '../home/data/controller/shop_controller.dart';

class CompletedOrders extends HookConsumerWidget {
  const CompletedOrders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myOrdersList = ref.watch(shopControllerProvider).myOrdersList;

    return myOrdersList.when(
      data: (ordersData) {
        // Filter completed orders
        final completedOrders = ordersData.results
                ?.where((order) => order.status == 'delivered')
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedOrders.length,
          itemBuilder: (context, index) {
            final order = completedOrders[index];
            return Column(
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  order.createdAt?.toString().split(' ')[0] ??
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
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
            ElevatedButton(
              onPressed: () {
                ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
