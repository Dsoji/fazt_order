import 'package:fazt_order/src/common/app_colors.dart';
import 'package:fazt_order/src/common/ui_helpers.dart';
import 'package:fazt_order/src/features/bottom_sheets/cancel_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';

import '../../common/components/vertical_stripe_pattern.dart';
import '../../common/widgets/reusable_buttons.dart';
import '../../common/widgets/text_styles.dart';
import '../home/data/model/response/my_orders_list/result.dart';

final logger = Logger();

class OngoingParcelStatusHelper {
  static String getGifAsset(String? status) {
    switch (status) {
      case 'paid':
      case 'ready':
      case 'accepted':
        return 'asset/gif/onboard1.gif';
      case 'preparing':
      case 'in_transit':
        return 'asset/gif/onboard3.gif';
      case 'arrived':
      case 'delivered':
        return 'asset/gif/onboard2.gif';
      default:
        return 'asset/gif/onboard1.gif';
    }
  }

  static String getStatusDescription(String? status) {
    switch (status) {
      case 'pending':
        return "Waiting for payment to be processed.";
      case 'paid':
      case 'ready':
        return "Parcel has been paid for, waiting for a rider to accept your order.";
      case 'accepted':
        return "Parcel is accepted by rider and on their way to the pickup location.";
      case 'in_transit':
        return "Parcel has been picked up and is on the way to you.";
      case 'arrived':
        return "Rider has arrived.";
      case 'delivered':
        return "Order has been delivered.";
      default:
        return "Waiting for rider to accept your order.";
    }
  }

  static int getProgressStep(String? status) {
    switch (status) {
      case 'pending': return 0;
      case 'paid': return 1;
      case 'ready': return 1;
      case 'accepted': return 1; // FIX: Was missed in progress bar, jumping to 5
      case 'in_transit': return 2;
      case 'arrived': return 3;
      case 'delivered': return 4;
      default: return 0;
    }
  }
}

class OngoingParcelOrderView extends HookConsumerWidget {
  final OrderResult orderItems;

  const OngoingParcelOrderView({
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
    final canCancel =
        orderItems.status == 'pending' || orderItems.status == 'paid';
    final cancelText = canCancel
        ? "Waiting for vendor to confirm your order. You can still cancel this order at the moment."
        : "You can not cancel this order at this moment.";

    logger.d('Order Items: ${orderItems.status}');
    logger.d('Order otp: ${orderItems.riderOtp}');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Iconsax.arrow_left_2),
        ),
        title: Text(
          "Your Parcel Order",
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
                    Image.asset(
                        OngoingParcelStatusHelper.getGifAsset(orderItems.status),
                        height: 250,
                        width: 250,
                    ),
                    verticalSpaceSmall,

                    verticalSpaceSmall,
                    Text(
                      textAlign: TextAlign.center,
                      OngoingParcelStatusHelper.getStatusDescription(orderItems.status),
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
                        currentStep: OngoingParcelStatusHelper.getProgressStep(orderItems.status),
                        totalSteps: 5,
                        activeColor: kcPrimary200,
                        inactiveColor: kcPrimary800),
                    verticalSpaceSmall,
                    if (orderItems.status == 'pending' ||
                        orderItems.status == 'paid') ...[
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
                          _showCancelOrderDialog(context);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
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
                    '${orderItems.riderOtp}',
                    style: const TextStyle(
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
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text("Subtotal (${orderItems.items?.length} items)",
                    //         style: const TextStyle(
                    //             color: kcPrimaryNeutral300, fontSize: 14)),
                    //     Text(
                    //         "₦${orderItems.payment?.subtotal?.toStringAsFixed(0) ?? '0'}",
                    //         style: const TextStyle(
                    //             color: kcPrimaryNeutral100, fontSize: 12)),
                    //   ],
                    // ),
                    // verticalSpaceSmall,
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
