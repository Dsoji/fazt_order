import 'package:fazt_order/src/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../datamodels/order_items.dart';
import '../../../common/app_colors.dart';
import '../../../common/widgets/text_styles.dart';
import '../../bottom_sheets/order_confirmation_sheet.dart';

class PaymentScreen extends StatefulWidget {
  final double subtotal;
  final double deliveryFee;
  final double taxAndFees;
  final double total;
  final List<OrderItem> orderItems;

  const PaymentScreen({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.taxAndFees,
    required this.total,
    required this.orderItems,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;
  String? _selectedCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      Text("Subtotal (3 items)",
                          style: ktBodyRegularSize14.copyWith(
                              color: kcPrimaryNeutral300)),
                      Text(
                        "₦${widget.subtotal.toStringAsFixed(0)}",
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
                      Text("Delivery Fee",
                          style: ktBodyRegularSize14.copyWith(
                              color: kcPrimaryNeutral300)),
                      Text(
                        "₦${widget.deliveryFee.toStringAsFixed(0)}",
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
                      Text("Tax and other fees",
                          style: ktBodyRegularSize14.copyWith(
                              color: kcPrimaryNeutral300)),
                      Text(
                        "₦${widget.taxAndFees.toStringAsFixed(0)}",
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
                        "₦${widget.total.toStringAsFixed(0)}",
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

            // Payment Method Section
            Text(
              "Payment Method",
              style: ktBodyRegularSize16.copyWith(
                  color: kcPrimaryNeutral100, fontWeight: FontWeight.w400),
            ),

            verticalSpaceSmall,

            // Wallet Option
            ListTile(
              leading: const Icon(
                Iconsax.wallet_1,
                color: kcPrimaryNeutral200,
                size: 20,
              ),
              title: Text(
                "₦1,000,000",
                style: ktBodyRegularSize18.copyWith(
                    color: kcPrimaryNeutral100, fontWeight: FontWeight.w400),
              ),
              subtitle: Text(
                "Wallet",
                style: ktBodyRegularSize14.copyWith(
                    color: kcPrimaryNeutral300, fontWeight: FontWeight.w400),
              ),
              trailing: _selectedPaymentMethod == "Wallet"
                  ? const Icon(Iconsax.tick_circle5,
                      size: 20, color: kcPrimaryGreen400)
                  : const Icon(Iconsax.tick_circle,
                      size: 20, color: kcPrimaryNeutral200),
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = "Wallet";
                  _selectedCard = null;
                });
              },
            ),

            // Credit/Debit Cards Section
            ListTile(
              leading: const Icon(
                Iconsax.cards,
                color: kcPrimaryNeutral300,
                size: 20,
              ),
              title: Text(
                "Credit/Debit Cards",
                style: ktBodyRegularSize16.copyWith(
                    color: kcPrimaryNeutral100, fontWeight: FontWeight.w400),
              ),
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = "Cards";
                });
              },
            ),

            // Card Options (visible only if Cards is selected)
            if (_selectedPaymentMethod == "Cards") ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Choose the card to pay with",
                  style: ktBodyRegularSize12.copyWith(
                      color: kcPrimaryNeutral300, fontWeight: FontWeight.w400),
                ),
              ),
              ListTile(
                leading: SvgPicture.asset(
                  'asset/svgs/master_card.svg',
                  width: 15,
                  height: 15,
                ),
                title: const Text("**** **** **** 1234"),
                trailing: _selectedCard == "MasterCard"
                    ? const Icon(Iconsax.tick_circle5,
                        size: 20, color: kcPrimaryGreen400)
                    : const Icon(Iconsax.tick_circle,
                        size: 20, color: kcPrimaryNeutral200),
                onTap: () {
                  setState(() {
                    _selectedCard = "MasterCard";
                  });
                },
              ),
              ListTile(
                leading: SvgPicture.asset(
                  "asset/svgs/visa_card.svg",
                  width: 12,
                  height: 12,
                ),
                title: const Text("**** **** **** 1234"),
                trailing: _selectedCard == "Visa"
                    ? const Icon(Iconsax.tick_circle5,
                        size: 20, color: kcPrimaryGreen400)
                    : const Icon(Iconsax.tick_circle,
                        size: 20, color: kcPrimaryNeutral200),
                onTap: () {
                  setState(() {
                    _selectedCard = "Visa";
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton.icon(
                  onPressed: () {
                    // Logic to add another card
                  },
                  icon: const Icon(Icons.add, color: kcPrimary400),
                  label: const Text(
                    "Add Another Card",
                    style: TextStyle(color: kcPrimary400),
                  ),
                ),
              ),
            ],
            verticalSpaceMedium,

            // Place Order Button

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedPaymentMethod == "Wallet" ||
                        _selectedCard != null)
                    ? () {
                        // Show the bottom sheet when Place Order is clicked
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) => OrderConfirmationBottomSheet(
                            deliveryAddress:
                                "12, Oritshe street, Ikeja, Lagos State",
                            orderItems: widget.orderItems,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimary400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Place Order",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            verticalSpaceSmall,

            // Close Order Button
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
                  "Close Order",
                  style: TextStyle(color: kcPrimary400, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
