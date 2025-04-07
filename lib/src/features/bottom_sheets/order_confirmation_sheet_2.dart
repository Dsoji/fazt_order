import 'package:fazt_order/src/common/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../datamodels/order_items.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';

class OrderConfirmationBottomSheet2 extends StatelessWidget {
  final String deliveryAddress;
  final List<OrderItem> orderItems;

  const OrderConfirmationBottomSheet2({
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
          Text(
            "Order Placed.",
            style: ktBodySemiBoldSize20.copyWith(color: kcPrimaryNeutral100),
          ),

          verticalSpaceMedium,

          Row(
            children: [
              const Icon(Iconsax.receipt2, color: kcPrimaryNeutral200, size: 20),
              horizontalSpaceSmall,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order ID",
                      style: ktBodyRegularSize16.copyWith(color: kcPrimaryNeutral100),
                    ),
                    Text(
                      "#1234567890asdf",
                      style: ktBodyRegularSize12.copyWith(color: kcPrimaryNeutral500),
                    ),
                  ],
                ),
              ),
            ],
          ),

          verticalSpaceMedium,

          Row(
            children: [
              Text("Share this digit with your rider", style: ktBodyRegularSize16.copyWith(color: kcPrimaryNeutral200),),
              Text("2345", style: ktBodyRegularSize16.copyWith(color: kcPrimaryNeutral200),),
            ],
          )
        ],
      ),
    );
  }
}