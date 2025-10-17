import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../providers/navigation_provider.dart';
import '../../../providers/order_provider.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../common/widgets/text_styles.dart';
import '../bottom_sheets/edit_address_sheet.dart';
import '../home/data/controller/shop_controller.dart';
import '../home/data/model/response/cartlsit/cart.dart';
import '../payment/payment_screen.dart';
import '../profile/data/controller/profile_controller.dart';

class CheckoutScreen extends HookConsumerWidget {
  final Cart selectedItems;

  const CheckoutScreen({required this.selectedItems, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelectionVisible = useState(true);
    final orderState = ref.watch(orderProvider);
    final userDetails =
        ref.watch(profileControllerProvider).userDetails.valueOrNull;
    final messageController = useTextEditingController();
    final noteController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Checkout",
          style: ktBodyRegularSize20.copyWith(
              fontSize: 24, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Iconsax.arrow_left_2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery',
                style:
                    ktBodyRegularSize12.copyWith(color: kcPrimaryNeutral200)),
            verticalSpaceSmall,
            // Delivery Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Iconsax.location,
                          color: kcPrimaryNeutral200, size: 18),
                      const Gap(2),
                      Expanded(
                        child: Text(
                          userDetails?.user?.location?.address ?? "No Address",
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 2,
                          style: ktBodyRegularSize12.copyWith(
                              color: kcPrimaryNeutral500),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => EditAddressBottomSheet(
                        // currentAddress: orderState.deliveryAddress,
                        onUpdate: (newAddress) {
                          ref
                              .read(orderProvider.notifier)
                              .updateDeliveryAddress(newAddress);
                        },
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Iconsax.edit,
                          size: 15, color: kcPrimaryOrange400),
                      horizontalSpace(7),
                      Text('Edit',
                          style: ktBodyRegularSize14.copyWith(
                              color: kcPrimaryOrange400)),
                    ],
                  ),
                ),
              ],
            ),
            verticalSpaceSmall,

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     Container(
            //       height: screenHeight(context) * 0.067,
            //       width: screenHeight(context) * 0.2,
            //       decoration: BoxDecoration(
            //           color: kcPrimary980,
            //           borderRadius: BorderRadius.circular(20),
            //           border: Border.all(color: kcPrimary400)),
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 30.0, vertical: 8),
            //         child: Row(
            //           children: [
            //             const Icon(Iconsax.clock, color: kcPrimary200),
            //             horizontalSpaceTiny,
            //             Column(
            //               children: [
            //                 Text(
            //                   "Standard",
            //                   style: ktBodyRegularSize14.copyWith(
            //                       color: kcPrimary200),
            //                 ),
            //                 Text(
            //                   "30-40 Mins",
            //                   style: ktBodyRegularSize14.copyWith(
            //                       color: kcPrimary500),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //     Container(
            //       height: screenHeight(context) * 0.067,
            //       width: screenHeight(context) * 0.2,
            //       decoration: BoxDecoration(
            //           color: kcTransparent,
            //           borderRadius: BorderRadius.circular(20),
            //           border: Border.all(color: kcPrimaryNeutral800)),
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 30.0, vertical: 8),
            //         child: Row(
            //           children: [
            //             const Icon(Iconsax.calendar_edit,
            //                 color: kcPrimaryNeutral200),
            //             horizontalSpaceTiny,
            //             Column(
            //               children: [
            //                 Text(
            //                   "Schedule",
            //                   style: ktBodyRegularSize14.copyWith(
            //                       color: kcPrimaryNeutral200),
            //                 ),
            //                 Text(
            //                   "Select Time",
            //                   style: ktBodyRegularSize14.copyWith(
            //                       color: kcPrimaryNeutral500),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ],
            // ),

            verticalSpaceSmall,
            SvgPicture.asset('asset/svgs/dotted_line.svg'),
            verticalSpaceSmall,

            // Restaurant and Order Items
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.restaurant, color: Colors.white),
                ),
                horizontalSpace(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedItems.shop?.shopName ?? "Unknown Shop",
                        style: ktBodyRegularSize16,
                      ),
                      Text(
                        "${selectedItems.items?.length ?? 0} item",
                        style: ktBodyRegularSize14.copyWith(
                            color: kcPrimaryNeutral500),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        isSelectionVisible.value = !isSelectionVisible.value;
                      },
                      child: Row(
                        children: [
                          Text(
                            isSelectionVisible.value
                                ? "Hide Selection"
                                : "Show Selection",
                            style: ktBodyRegularSize12.copyWith(
                                color: kcPrimaryNeutral300),
                          ),
                          horizontalSpaceTiny,
                          Icon(
                            isSelectionVisible.value
                                ? Iconsax.arrow_up_2
                                : Iconsax.arrow_down_1,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            verticalSpace(16),

            // Order Items
            if (isSelectionVisible.value) ...[
              ...(selectedItems.items ?? []).asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: kcPrimaryNeutral800),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Pack ${index + 1}"),
                                        ],
                                      ),
                                      verticalSpaceSmall,
                                      Text(item.mealVariant?.meal?.mealName ??
                                          "Courier Item"),
                                      verticalSpaceTiny,
                                      Text(
                                          "₦${(item.mealVariant?.meal?.price ?? 0).toStringAsFixed(0)}"),
                                      verticalSpace(15),
                                      if (item.options != null &&
                                          item.options!.isNotEmpty) ...[
                                        Text(
                                          "Options:",
                                          style: ktBodyRegularSize12.copyWith(
                                            color: kcPrimaryNeutral300,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        verticalSpaceTiny,
                                        ...item.options!.map((option) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, bottom: 4.0),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 4,
                                                  height: 4,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: kcPrimaryNeutral400,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                horizontalSpaceTiny,
                                                Expanded(
                                                  child: Text(
                                                    option
                                                            .optionItemVariant
                                                            ?.optionItem
                                                            ?.item ??
                                                        "",
                                                    style: ktBodyRegularSize12
                                                        .copyWith(
                                                      color:
                                                          kcPrimaryNeutral400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                      // Row(
                                      //   children: [
                                      //     const Text("Your menu",
                                      //         style: TextStyle(
                                      //             color: kcPrimaryNeutral200)),
                                      //     horizontalSpaceSmall,
                                      //     GestureDetector(
                                      //       behavior:
                                      //           HitTestBehavior.translucent,
                                      //       child: const Row(
                                      //         children: [
                                      //           Icon(Iconsax.edit,
                                      //               size: 15,
                                      //               color: kcPrimary400),
                                      //           horizontalSpaceTiny,
                                      //           Text("Edit",
                                      //               style: TextStyle(
                                      //                   color: kcPrimary400)),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      verticalSpaceSmall,

                                      verticalSpaceSmall,
                                    ],
                                  ),
                                ),

                                // Container(
                                //   height: screenHeight(context) * 0.04,
                                //   width: screenWidth(context) * 0.25,
                                //   decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(20),
                                //     border: Border.all(color: kcPrimary400),
                                //   ),
                                //   child: Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceAround,
                                //     children: [
                                //       GestureDetector(
                                //         behavior: HitTestBehavior.translucent,
                                //         onTap: () {
                                //           // Handle quantity decrease
                                //           ref.read(shopControllerProvider.notifier).updateCartItemQuantity(item.id, item.quantity - 1);
                                //         },
                                //         child: const Icon(Iconsax.minus,
                                //             color: kcPrimary400),
                                //       ),
                                //       Text(
                                //         "${item.mealQuantity ?? 1}",
                                //         style: ktBodyRegularSize16.copyWith(
                                //             color: kcPrimary400),
                                //       ),
                                //       GestureDetector(
                                //         behavior: HitTestBehavior.translucent,
                                //         onTap: () {
                                //           // Handle quantity increase
                                //           // ref.read(shopControllerProvider.notifier).updateCartItemQuantity(item.id, item.quantity + 1);
                                //         },
                                //         child: const Icon(Iconsax.add,
                                //             color: kcPrimary400),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () async {
                                final result = await ref
                                    .read(shopControllerProvider.notifier)
                                    .removePackFromCart(
                                        selectedItems.id ?? '', index + 1);
                                if (result == true) {
                                  ref
                                      .read(shopControllerProvider.notifier)
                                      .fetchCart();
                                }
                              },
                              child: const SizedBox(
                                height: 25,
                                width: 25,
                                child: CircleAvatar(
                                  backgroundColor: kcPrimaryRed900,
                                  child: Icon(Iconsax.trash,
                                      color: kcPrimaryRed200, size: 15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpaceSmall,
                  ],
                );
              }),
            ],

            // Add Another Pack Button
            GestureDetector(
              onTap: () {
                ref.read(navigationProvider.notifier).state = 0;
                Navigator.pop(context);
              },
              child: Container(
                width: screenWidth(context) * 0.45,
                height: screenHeight(context) * 0.045,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: kcPrimary400)),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: kcPrimary400),
                    Text("Add Another Pack",
                        style: TextStyle(color: kcPrimary400)),
                  ],
                ),
              ),
            ),
            verticalSpaceMedium,
            SvgPicture.asset('asset/svgs/dotted_line.svg'),
            verticalSpaceMedium,

            // Leave a Message Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.message, size: 20),
                    horizontalSpaceSmall,
                    Text(
                      'Leave a message for the restaurant',
                      style: ktBodyRegularSize12.copyWith(
                          color: kcPrimaryNeutral200),
                    ),
                  ],
                ),
                verticalSpaceSmall,
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 3,
                ),
              ],
            ),

            verticalSpaceMedium,
            SvgPicture.asset('asset/svgs/dotted_line.svg'),
            verticalSpaceMedium,

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('asset/svgs/delivery_icon.svg',
                        width: 20, height: 20),
                    horizontalSpaceSmall,
                    Text(
                      'Leave a note for the rider',
                      style: ktBodyRegularSize12.copyWith(
                          color: kcPrimaryNeutral200),
                    ),
                  ],
                ),
                verticalSpaceSmall,
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: 'Type your note here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 3,
                ),
              ],
            ),

            verticalSpaceMedium,

            // Payment Details
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: kcWhite,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Details",
                    style: ktBodyRegularSize16.copyWith(
                        color: kcPrimaryNeutral100,
                        fontWeight: FontWeight.w500),
                  ),
                  verticalSpaceSmall,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal (${selectedItems.items?.length ?? 0} items)",
                        style: ktBodyRegularSize14.copyWith(
                            color: kcPrimaryNeutral300),
                      ),
                      Text(
                        "₦${selectedItems.subtotal?.toStringAsFixed(0) ?? "0"}",
                        style: ktBodyRegularSize14.copyWith(
                            color: kcPrimaryNeutral300,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  verticalSpaceTiny,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Delivery Fee",
                        style: ktBodyRegularSize14.copyWith(
                            color: kcPrimaryNeutral300),
                      ),
                      Text(
                        "₦${selectedItems.deliveryFee?.toStringAsFixed(0) ?? "0"}",
                        style: ktBodyRegularSize14.copyWith(
                            color: kcPrimaryNeutral100,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  verticalSpaceTiny,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tax and other fees",
                        style: ktBodyRegularSize14.copyWith(
                            color: kcPrimaryNeutral300),
                      ),
                      Text(
                        "₦${selectedItems.serviceFee?.toStringAsFixed(0) ?? "0"}",
                        style: ktBodyRegularSize14.copyWith(
                            color: kcPrimaryNeutral100,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  verticalSpaceSmall,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TOTAL",
                        style: ktBodyRegularSize16.copyWith(
                            color: kcPrimaryNeutral100,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "₦${(selectedItems.totalPrice ?? 0)}",
                        style: ktBodyRegularSize16.copyWith(
                            color: kcPrimaryNeutral100,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            verticalSpaceMedium,

            // Make Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        selectedItems: selectedItems,
                        vendorMessage: messageController.text,
                        riderMessage: noteController.text,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimary400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Make Payment",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
