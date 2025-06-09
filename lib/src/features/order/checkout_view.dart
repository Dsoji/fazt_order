import 'package:fazt_order/src/features/home/presentation/payment_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import '../../../datamodels/menu_items.dart';
import '../../../datamodels/order_items.dart';
import '../../../providers/order_provider.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../common/widgets/text_styles.dart';
import '../bottom_sheets/edit_address_sheet.dart';

// Placeholder EditAddressBottomSheet (replace with your actual implementation)
// class EditAddressBottomSheet extends StatelessWidget {
//   final String currentAddress;
//   final Function(String) onUpdate;
//
//   const EditAddressBottomSheet({required this.currentAddress, required this.onUpdate, Key? key})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             decoration: const InputDecoration(labelText: "New Address"),
//             onSubmitted: (value) {
//               onUpdate(value);
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

class CheckoutScreen extends ConsumerStatefulWidget {
  final List<MenuItem> selectedItems;

  const CheckoutScreen({required this.selectedItems, super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isSelectionVisible = true;

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final cartItems =
        orderState.items.where((item) => item.tab == 'cart').toList();

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
                Row(
                  children: [
                    const Icon(Iconsax.location,
                        color: kcPrimaryNeutral200, size: 18),
                    horizontalSpace(8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Computer Village",
                          style: ktBodyRegularSize16.copyWith(
                              color: kcPrimaryNeutral200),
                        ),
                        verticalSpaceSmall,
                        Text(
                          orderState.deliveryAddress,
                          style: ktBodyRegularSize12.copyWith(
                              color: kcPrimaryNeutral500),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => EditAddressBottomSheet(
                        currentAddress: orderState.deliveryAddress,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: screenHeight(context) * 0.067,
                  width: screenHeight(context) * 0.2,
                  decoration: BoxDecoration(
                      color: kcPrimary980,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kcPrimary400)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Iconsax.clock, color: kcPrimary200),
                        horizontalSpaceTiny,
                        Column(
                          children: [
                            Text(
                              "Standard",
                              style: ktBodyRegularSize14.copyWith(
                                  color: kcPrimary200),
                            ),
                            Text(
                              "30-40 Mins",
                              style: ktBodyRegularSize14.copyWith(
                                  color: kcPrimary500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: screenHeight(context) * 0.067,
                  width: screenHeight(context) * 0.2,
                  decoration: BoxDecoration(
                      color: kcTransparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kcPrimaryNeutral800)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Iconsax.calendar_edit,
                            color: kcPrimaryNeutral200),
                        horizontalSpaceTiny,
                        Column(
                          children: [
                            Text(
                              "Schedule",
                              style: ktBodyRegularSize14.copyWith(
                                  color: kcPrimaryNeutral200),
                            ),
                            Text(
                              "Select Time",
                              style: ktBodyRegularSize14.copyWith(
                                  color: kcPrimaryNeutral500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

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
                        orderState.restaurantName,
                        style: ktBodyRegularSize16,
                      ),
                      Text(
                        "${cartItems.length} item",
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
                        setState(() {
                          _isSelectionVisible = !_isSelectionVisible;
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            _isSelectionVisible
                                ? "Hide Selection"
                                : "Show Selection",
                            style: ktBodyRegularSize12.copyWith(
                                color: kcPrimaryNeutral300),
                          ),
                          horizontalSpaceTiny,
                          Icon(
                            _isSelectionVisible
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
            if (_isSelectionVisible) ...[
              ...cartItems.asMap().entries.map((entry) {
                int index = entry.key;
                OrderItem item = entry.value;
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
                                      Text(item.name),
                                      verticalSpaceTiny,
                                      Text(
                                          "₦${(item.price * item.quantity).toStringAsFixed(0)}"),
                                      verticalSpace(15),
                                      Row(
                                        children: [
                                          const Text("Your menu",
                                              style: TextStyle(
                                                  color: kcPrimaryNeutral200)),
                                          horizontalSpaceSmall,
                                          GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            child: const Row(
                                              children: [
                                                Icon(Iconsax.edit,
                                                    size: 15,
                                                    color: kcPrimary400),
                                                horizontalSpaceTiny,
                                                Text("Edit",
                                                    style: TextStyle(
                                                        color: kcPrimary400)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      verticalSpaceSmall,
                                      const Text("Spicy",
                                          style: TextStyle(
                                              color: kcPrimaryNeutral500)),
                                      verticalSpaceSmall,
                                    ],
                                  ),
                                ),
                                Container(
                                  height: screenHeight(context) * 0.04,
                                  width: screenWidth(context) * 0.25,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: kcPrimary400),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          ref
                                              .read(orderProvider.notifier)
                                              .updateQuantity(
                                                  index, item.quantity - 1,
                                                  tab: 'cart');
                                        },
                                        child: const Icon(Iconsax.minus,
                                            color: kcPrimary400),
                                      ),
                                      Text(
                                        "${item.quantity}",
                                        style: ktBodyRegularSize16.copyWith(
                                            color: kcPrimary400),
                                      ),
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          ref
                                              .read(orderProvider.notifier)
                                              .updateQuantity(
                                                  index, item.quantity + 1,
                                                  tab: 'cart');
                                        },
                                        child: const Icon(Iconsax.add,
                                            color: kcPrimary400),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                ref
                                    .read(orderProvider.notifier)
                                    .deleteItem(index, tab: 'cart');
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
                ref.read(orderProvider.notifier).addNewPack();
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
            Row(
              children: [
                const Icon(Iconsax.message, size: 20),
                horizontalSpaceSmall,
                Text(
                  'Leave a message for the restaurant',
                  style:
                      ktBodyRegularSize12.copyWith(color: kcPrimaryNeutral200),
                ),
              ],
            ),

            verticalSpaceMedium,
            SvgPicture.asset('asset/svgs/dotted_line.svg'),
            verticalSpaceMedium,

            Row(
              children: [
                SvgPicture.asset('asset/svgs/delivery_icon.svg',
                    width: 20, height: 20),
                horizontalSpaceSmall,
                Text(
                  'Leave a note for the rider',
                  style:
                      ktBodyRegularSize12.copyWith(color: kcPrimaryNeutral200),
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
                        "Subtotal (${cartItems.length} items)",
                        style: ktBodyRegularSize14.copyWith(
                            color: kcPrimaryNeutral300),
                      ),
                      Text(
                        "₦${orderState.subtotal.toStringAsFixed(0)}",
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
                        "₦${orderState.deliveryFee.toStringAsFixed(0)}",
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
                        "₦${orderState.taxAndFees.toStringAsFixed(0)}",
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
                        "₦${orderState.total.toStringAsFixed(0)}",
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
                        subtotal: orderState.subtotal,
                        deliveryFee: orderState.deliveryFee,
                        taxAndFees: orderState.taxAndFees,
                        total: orderState.total,
                        orderItems: cartItems,
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
