import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';

import '../../common/app_colors.dart';
import '../../common/widgets/text_styles.dart';

class ParcelConfirmDetails extends HookConsumerWidget {
  const ParcelConfirmDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDeliveryType = useState('Standard');
    final otpCode = useState('0987');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Review",
          style: ktBodySemiBoldSize20.copyWith(
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Time Section
            _buildDeliveryTimeSection(selectedDeliveryType),
            const Gap(24),

            // Pick Up Details Section
            _buildPickUpDetailsSection(),
            const Gap(24),

            // Delivery Details Section
            _buildDeliveryDetailsSection(),
            const Gap(24),

            // Parcel Type Section
            _buildParcelTypeSection(),
            const Gap(24),

            // OTP and Note Section
            _buildOTPAndNoteSection(otpCode.value),
            const Gap(24),

            // Payment Details Section
            _buildPaymentDetailsSection(),
            const Gap(32),

            // Make Payment Button
            _buildMakePaymentButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTimeSection(ValueNotifier<String> selectedDeliveryType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Delivery Time",
          style: ktBodySemiBoldSize20.copyWith(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _buildDeliveryOption(
                'Standard',
                '30-40 Mins',
                Iconsax.clock,
                selectedDeliveryType.value == 'Standard',
                () => selectedDeliveryType.value = 'Standard',
              ),
            ),
            const Gap(12),
            Expanded(
              child: _buildDeliveryOption(
                'Schedule',
                'Select Time',
                Iconsax.calendar_1,
                selectedDeliveryType.value == 'Schedule',
                () => selectedDeliveryType.value = 'Schedule',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryOption(
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? kcPrimaryGreen500.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? kcPrimaryGreen500 : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? kcPrimaryGreen500 : Colors.grey[600],
              size: 24,
            ),
            const Gap(8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? kcPrimaryGreen700 : Colors.grey[700],
              ),
            ),
            const Gap(4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? kcPrimaryGreen600 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickUpDetailsSection() {
    return _buildDetailsSection(
      title: "Pick Up Details",
      icon: Iconsax.tick_circle,
      iconColor: kcPrimaryGreen500,
      name: "Ridwan",
      phone: "08023456776",
      address: "12, Oritshe street, ikeja, Lagos State",
    );
  }

  Widget _buildDeliveryDetailsSection() {
    return _buildDetailsSection(
      title: "Delivery Details",
      icon: Iconsax.location,
      iconColor: kcPrimaryGreen500,
      name: "Ridwan",
      phone: "08023456776",
      address: "12, Oritshe street, ikeja, Lagos State",
    );
  }

  Widget _buildDetailsSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String name,
    required String phone,
    required String address,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const Gap(8),
              Text(
                title,
                style: ktBodySemiBoldSize20.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Icon(Iconsax.arrow_right_3, color: Colors.grey[600], size: 16),
            ],
          ),
          const Gap(12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const Gap(4),
          Text(
            phone,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Gap(4),
          Text(
            address,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelTypeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Iconsax.box, color: kcPrimaryGreen500, size: 20),
          const Gap(12),
          Text(
            "Parcel Type",
            style: ktBodySemiBoldSize20.copyWith(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            "Food",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPAndNoteSection(String otpCode) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(Iconsax.message_text, color: kcPrimaryGreen500, size: 20),
              const Gap(12),
              Expanded(
                child: Text(
                  "OTP receiver shares with the rider",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kcPrimaryGreen500,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  otpCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(Iconsax.clipboard_text, color: kcPrimaryGreen500, size: 20),
              const Gap(12),
              Expanded(
                child: Text(
                  "Kindly leave at the shop with the sales person",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Details",
            style: ktBodySemiBoldSize20.copyWith(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const Gap(16),
          _buildPaymentRow("Delivery Fee", "N 1000"),
          const Gap(8),
          _buildPaymentRow("Tax and other fees", "N 1000"),
          const Divider(color: Colors.grey),
          const Gap(8),
          _buildPaymentRow("Total", "N 3000", isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildMakePaymentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle payment
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment processing...')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kcPrimaryGreen500,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Make Payment",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
