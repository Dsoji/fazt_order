import 'package:fazt_order/src/common/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

import '../../../datamodels/order_items.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';

class OrderConfirmationBottomSheet extends StatelessWidget {
  final String deliveryAddress;
  final List<OrderItem> orderItems;

  const OrderConfirmationBottomSheet({
    Key? key,
    required this.deliveryAddress,
    required this.orderItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ask Oluwadamilola to provide the Json for the lottie animation
          const Center(
            child: Icon(
              Iconsax.notification,
              color: Colors.orange,
              size: 40,
            ),
          ),

          verticalSpaceMedium,

          // Placing Your Order Title
          Text(
            "Placing Your Order",
            style: ktBodySemiBoldSize20.copyWith(color: kcPrimaryNeutral100),
          ),

          verticalSpace(15),
          SvgPicture.asset('asset/svgs/dotted_line.svg'),
          verticalSpace(15),

          // Delivery Address
          Row(
            children: [
              const Icon(Iconsax.location,
                  color: kcPrimaryNeutral200, size: 20),
              horizontalSpaceSmall,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Computer Village",
                      style: ktBodyRegularSize16.copyWith(
                          color: kcPrimaryNeutral100),
                    ),
                    Text(
                      deliveryAddress,
                      style: ktBodyRegularSize12.copyWith(
                          color: kcPrimaryNeutral500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          verticalSpaceMedium,
          SvgPicture.asset('asset/svgs/dotted_line.svg'),
          verticalSpaceMedium,

          // Delivery Time
          Row(
            children: [
              const Icon(Iconsax.clock, color: kcPrimaryNeutral200, size: 20),
              horizontalSpaceSmall,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Standard",
                      style: ktBodyRegularSize16.copyWith(
                          color: kcPrimaryNeutral100),
                    ),
                    Text(
                      "30-40 Mins",
                      style: ktBodyRegularSize12.copyWith(
                          color: kcPrimaryNeutral500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpaceMedium,
          SvgPicture.asset('asset/svgs/dotted_line.svg'),
          verticalSpaceMedium,

          // Order Summary
          Row(
            children: [
              const Icon(Iconsax.task_square,
                  color: kcPrimaryNeutral200, size: 20),
              horizontalSpaceSmall,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Summary",
                      style: ktBodyRegularSize16.copyWith(
                          color: kcPrimaryNeutral100),
                    ),
                  ],
                ),
              ),
            ],
          ),

          verticalSpaceSmall,

          // Order Items
          ...orderItems.asMap().entries.map((entry) {
            int index = entry.key;
            OrderItem item = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(color: kcPrimaryNeutral500),
                  ),
                  Text(
                    "x${item.quantity}",
                    style: const TextStyle(color: kcPrimaryNeutral500),
                  ),
                ],
              ),
            );
          }).toList(),

          const Spacer(),

          // Cancel Order Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: kcPrimary400, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Cancel Order",
                style: TextStyle(color: kcPrimary400, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
