import 'package:fazt_order/src/features/order/ongoing_orders_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../../common/app_colors.dart';
import '../home/data/controller/shop_controller.dart';

class MyOrders extends HookConsumerWidget {
  const MyOrders({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myOrdersList = ref.watch(shopControllerProvider).myOrdersList;

    return myOrdersList.when(
      data: (ordersData) {
        // Filter ongoing orders (you might need to adjust the status filter based on your API)
        final ongoingOrders = ordersData.results
                ?.where((order) =>
                    order.status == 'pending' ||
                    order.status == 'ongoing' ||
                    order.status == 'preparing' ||
                    order.status == 'ready')
                .toList() ??
            [];

        if (ongoingOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset('asset/lottie/DBSkpgXyIT.json'),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to place order
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: kcPrimary400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Place Order Now",
                      style: TextStyle(fontSize: 14, color: kcWhite),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ongoingOrders.length + (ongoingOrders.length ~/ 2),
                itemBuilder: (context, index) {
                  final itemIndex = index - (index ~/ 3);
                  final order = ongoingOrders[itemIndex];
                  final firstItem = order.items?.isNotEmpty == true
                      ? order.items!.first
                      : null;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OngoingOrderView(
                            orderItems: order,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: firstItem?.meal?.mealImage != null
                                    ? Image.network(
                                        firstItem!.meal!.mealImage!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            "asset/images/Frame 269.png",
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        "asset/images/Frame 269.png",
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      firstItem?.meal?.mealName ??
                                          "Unknown Item",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Iconsax.location,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            order.deliveryLocation?.address ??
                                                "Unknown Address",
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${order.items?.length ?? 0} items",
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "₦${(order.payment?.total ?? 0).toStringAsFixed(0)}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SvgPicture.asset("asset/svgs/dotted_line.svg"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Gap(130),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text("Error loading orders: $error"),
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
