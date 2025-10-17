import 'package:fazt_order/src/common/app_colors.dart';
import 'package:fazt_order/src/common/ui_helpers.dart';
import 'package:fazt_order/src/features/bottom_sheets/cancel_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

import '../../common/components/vertical_stripe_pattern.dart';
import '../../common/widgets/reusable_buttons.dart';
import '../../common/widgets/text_styles.dart';
import '../home/data/model/response/my_orders_list/result.dart';

final logger = Logger();

class OngoingOrderView extends HookConsumerWidget {
  final OrderResult orderItems;

  const OngoingOrderView({
    super.key,
    required this.orderItems,
  });

  // Helper to select Lottie animation based on currentStep
  String _getLottieAsset(int step) {
    if (step == 1 || step == 2) {
      return 'asset/lottie/delivery-accepted.json';
    } else if (step == 3 || step == 4) {
      return 'asset/lottie/rice-cooker.json';
    } else if (step == 5 || step == 6) {
      return 'asset/lottie/yes-brruu.json';
    } else if (step == 7 || step == 8) {
      return 'asset/lottie/rice-cooker.json';
    }
    return 'asset/lottie/delivery-accepted.json';
  }

  void _showCancelOrderBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const CancelOrderBottomSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCancel = orderItems.status == 'pending';
    final cancelText = canCancel
        ? "Waiting for vendor to confirm your order. You can still cancel this order at the moment."
        : "You can not cancel this order at this moment.";
    final isCompleted = orderItems.status == 'completed';

    logger.d('Order Items: ${orderItems.status}');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Iconsax.arrow_left_2),
        ),
        title: Text(
          "Your Order",
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
                            _getLottieAsset(orderItems.status == 'paid'
                                ? 1
                                : orderItems.status == 'preparing'
                                    ? 2
                                    : orderItems.status == 'in_transit'
                                        ? 3
                                        : 4))),
                    verticalSpaceSmall,

                    verticalSpaceSmall,
                    Text(
                      textAlign: TextAlign.center,
                      orderItems.status == 'paid'
                          ? "Order has been paid for, waiting for vendor to confirm your order."
                          : orderItems.status == 'accepted'
                              ? "Order is accepted by vendor"
                              : orderItems.status == 'preparing'
                                  ? "Your order is being prepared by the vendor"
                                  : orderItems.status == 'ready'
                                      ? "Order ready and will be picked up by the rider"
                                      : orderItems.status == 'in_transit'
                                          ? "Order has been picked up and is on the way to you"
                                          : orderItems.status == 'arrived'
                                              ? "Rider has arrived"
                                              : "Order has been delivered",
                      style: const TextStyle(
                          fontSize: 16,
                          color: kcPrimaryNeutral200,
                          letterSpacing: 1),
                    ),
                    verticalSpaceSmall,
                    // const Text(
                    //   '00:00 ',
                    //   style: TextStyle(
                    //       fontSize: 16,
                    //       color: kcPrimaryNeutral200,
                    //       fontWeight: FontWeight.w600),
                    // ),
                    verticalSpaceSmall,
                    DashProgressBar(
                        currentStep: orderItems.status == 'paid'
                            ? 1
                            : orderItems.status == 'accepted'
                                ? 2
                                : orderItems.status == 'ready'
                                    ? 3
                                    : orderItems.status == 'in_transit'
                                        ? 4
                                        : orderItems.status == 'arrived'
                                            ? 5
                                            : orderItems.status == 'delivered'
                                                ? 6
                                                : 7,
                        totalSteps: 7,
                        activeColor: kcPrimary200,
                        inactiveColor: kcPrimary800),
                    verticalSpaceSmall,
                    if (orderItems.status == 'pending' ||
                        orderItems.status == 'recieved') ...[
                      verticalSpaceSmall,
                      Text(
                        cancelText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.grey, letterSpacing: 1),
                      ),
                      verticalSpaceMedium,
                      FullButton(
                        text: 'Cancel Order',
                        width: 150,
                        height: 48,
                        onPressed: () {
                          _showCancelOrderBottomSheet(context);
                        },
                        color: kcPrimary400,
                        textColor: kcWhite,
                      ),
                    ],
                    // if (isCompleted) verticalSpaceSmall,
                  ],
                ),
              ),
              verticalSpaceSmall,
              SvgPicture.asset('asset/svgs/dotted_line.svg'), // Dashed divider
              verticalSpace(4),

              // Delivery Details
              const Text(
                "Delivery Details",
                style: TextStyle(fontSize: 14, letterSpacing: 1),
              ),
              Row(
                children: [
                  const Icon(Iconsax.location, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      orderItems.deliveryLocation?.address ?? '',
                      style: const TextStyle(
                          color: kcPrimaryNeutral500, fontSize: 11),
                    ),
                  ),
                ],
              ),
              verticalSpaceSmall,
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
              verticalSpaceSmall,

              // OTP Section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.message, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        "OTP to share with your rider",
                        style: TextStyle(
                            color: kcPrimaryNeutral200,
                            fontSize: 12,
                            letterSpacing: 1),
                      ),
                    ],
                  ),
                  Text(
                    // orderItems.otp,
                    '0000',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: kcPrimaryNeutral200),
                  )
                ],
              ),

              verticalSpaceSmall,
              SvgPicture.asset('asset/svgs/dotted_line.svg'), // Dashed divider
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
                        color: kcPrimaryNeutral200),
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
                      Text(
                        item.mealVariant?.meal?.mealName ?? '',
                        style: const TextStyle(color: kcPrimaryNeutral500),
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
              SvgPicture.asset('asset/svgs/dotted_line.svg'), // Dashed divider
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
                          color: kcPrimaryNeutral100),
                    ),
                    verticalSpaceSmall,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Subtotal (${orderItems.items?.length} items)",
                            style: const TextStyle(
                                color: kcPrimaryNeutral300, fontSize: 14)),
                        Text(
                            "₦${orderItems.payment?.subtotal?.toStringAsFixed(0) ?? '0'}",
                            style: const TextStyle(
                                color: kcPrimaryNeutral100, fontSize: 12)),
                      ],
                    ),
                    verticalSpaceSmall,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Delivery Fee",
                            style: TextStyle(
                                color: kcPrimaryNeutral300, fontSize: 14)),
                        Text("₦${orderItems.payment?.deliveryFee}",
                            style: const TextStyle(
                                color: kcPrimaryNeutral100, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tax and other fees",
                            style: TextStyle(
                                color: kcPrimaryNeutral300, fontSize: 14)),
                        Text("₦${orderItems.payment?.serviceFee}",
                            style: const TextStyle(
                                color: kcPrimaryNeutral100, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total",
                            style: TextStyle(
                                color: kcPrimaryNeutral100,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        Text("₦${orderItems.payment?.total}",
                            style: const TextStyle(
                                color: kcPrimaryNeutral100,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
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
}
