import 'package:fazt_order/src/features/order/ongoing_orders_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../common/app_colors.dart';
import '../../common/widgets/reusable_buttons.dart';
import '../home/data/controller/shop_controller.dart';

final logger = Logger();

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
                      order.status == 'paid' ||
                      order.status == 'preparing' ||
                      order.status == 'accepted' ||
                      order.status == 'ready' ||
                      order.status == 'in_transit' ||
                      order.status == 'arrived')
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
                  itemCount: ongoingOrders.length,
                  itemBuilder: (context, index) {
                    final order = ongoingOrders[index];
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
                                  child:
                                      firstItem?.mealVariant?.meal?.mealImage !=
                                              null
                                          ? Image.network(
                                              firstItem!.mealVariant!.meal!
                                                  .mealImage!,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        firstItem
                                                ?.mealVariant?.meal?.mealName ??
                                            "Courier Item",
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
        loading: () => ListView.builder(
              padding: const EdgeInsets.all(16),
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
        error: (error, stackTrace) {
          logger.d('❌ Error in MyOrdersList.fromMap: $error');
          logger.d('❌ Stack trace: $stackTrace');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Lottie.asset('asset/lottie/DBSkpgXyIT.json'),
                ),
                const SizedBox(height: 16),
                const Gap(16),
                Text(
                  "Error fetching orders ${error.toString()}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Gap(16),
                OutlinButton(
                  text: "Retry",
                  width: 150,
                  height: 48,
                  color: kcPrimary400,
                  bgColor: kcPrimaryNeutral900,
                  onPressed: () {
                    ref
                        .read(shopControllerProvider.notifier)
                        .fetchMyOrdersList();
                  },
                ),
              ],
            ),
          );
        });
  }
}
