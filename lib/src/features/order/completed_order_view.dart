import 'package:fazt_order/src/common/app_colors.dart';
import 'package:fazt_order/src/common/ui_helpers.dart';
import 'package:fazt_order/src/features/home/data/model/response/my_orders_list/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../../common/widgets/text_styles.dart';

class CompletedOrderView extends StatelessWidget {
  const CompletedOrderView({super.key, required this.orderItems});
  final OrderResult orderItems;

  @override
  Widget build(BuildContext context) {
    final isDelivered = orderItems.status == 'delivered';
    final isCancelled = orderItems.status == 'cancelled';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Iconsax.arrow_left_2),
        ),
        title: Text(
          "Order Details",
          style: ktBodySemiBoldSize20.copyWith(
            fontSize: 24,
            letterSpacing: 1,
          ),
        ),
      ),
      backgroundColor: kcPrimaryNeutral950,
      body: SingleChildScrollView(
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
                    SizedBox(
                      height: 150,
                      width: 150,
                      child: Lottie.asset(
                        isDelivered
                            ? 'asset/lottie/yes-brruu.json'
                            : 'asset/lottie/cancel.json',
                      ),
                    ),
                    verticalSpaceSmall,
                    Text(
                      isDelivered
                          ? "Order has been delivered successfully!"
                          : "Order has been cancelled",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: kcPrimaryNeutral200,
                        letterSpacing: 1,
                      ),
                    ),
                    verticalSpaceSmall,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDelivered ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        orderItems.status?.toUpperCase() ?? 'UNKNOWN',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (orderItems.createdAt != null) ...[
                      verticalSpaceSmall,
                      Text(
                        'Order Date: ${_formatDate(orderItems.createdAt!)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: kcPrimaryNeutral400,
                        ),
                      ),
                    ],
                    if (orderItems.orderNumber != null) ...[
                      verticalSpaceTiny,
                      Text(
                        'Order #${orderItems.orderNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: kcPrimaryNeutral400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              verticalSpaceSmall,
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
              verticalSpaceSmall,

              // Delivery Details
              const Text(
                "Delivery Details",
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 1,
                  color: kcPrimaryNeutral200,
                ),
              ),
              verticalSpaceTiny,
              Row(
                children: [
                  const Icon(Iconsax.location, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      orderItems.deliveryLocation?.address ??
                          'No address provided',
                      style: const TextStyle(
                        color: kcPrimaryNeutral500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              verticalSpaceSmall,
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
              verticalSpaceSmall,

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
                      color: kcPrimaryNeutral200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...(orderItems.items ?? []).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(left: 25.0, bottom: 4, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.mealVariant?.meal?.mealName ?? 'Unknown Item',
                          style: const TextStyle(color: kcPrimaryNeutral500),
                        ),
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
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
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
                        color: kcPrimaryNeutral100,
                      ),
                    ),
                    verticalSpaceSmall,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Subtotal (${orderItems.items?.length ?? 0} items)",
                          style: const TextStyle(
                            color: kcPrimaryNeutral300,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "₦${orderItems.payment?.subtotal?.toStringAsFixed(0) ?? '0'}",
                          style: const TextStyle(
                            color: kcPrimaryNeutral100,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    verticalSpaceSmall,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Delivery Fee",
                          style: TextStyle(
                            color: kcPrimaryNeutral300,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "₦${orderItems.payment?.deliveryFee ?? '0'}",
                          style: const TextStyle(
                            color: kcPrimaryNeutral100,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tax and other fees",
                          style: TextStyle(
                            color: kcPrimaryNeutral300,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "₦${orderItems.payment?.serviceFee ?? '0'}",
                          style: const TextStyle(
                            color: kcPrimaryNeutral100,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            color: kcPrimaryNeutral100,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "₦${orderItems.payment?.total ?? '0'}",
                          style: const TextStyle(
                            color: kcPrimaryNeutral100,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
