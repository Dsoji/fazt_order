import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/widgets/text_styles.dart';
import '../data/controller/profile_controller.dart';

class WalletView extends HookConsumerWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch wallet state from provider
    final walletState = ref.watch(profileControllerProvider).wallet.valueOrNull;

    // Local state for cards and transactions
    final cards = useState<List<Map<String, String>>>([]);
    final transactions = useState<List<Map<String, dynamic>>>([]);
    final wallet = ref.watch(profileControllerProvider).wallet.valueOrNull;

    // Fetch wallet data when widget is first built
    useEffect(() {
      Future.microtask(() {
        ref.read(profileControllerProvider.notifier).fetchWallet();
      });
      return null;
    }, []);

    void deleteCard(int index) async {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Card'),
          content: const Text('Are you sure you want to delete this card?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        cards.value = [...cards.value]..removeAt(index);
      }
    }

    void addAnotherCard() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: kcPrimaryNeutral950,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => AddCardBottomSheet(
          onSave: (type, number) {
            cards.value = [
              ...cards.value,
              {'type': type, 'number': number}
            ];
          },
        ),
      );
    }

    // Get balance from wallet state or use default
    final balance = wallet?.wallet?.availableBalance?.toDouble() ?? 0.00;

    return Scaffold(
      backgroundColor: kcPrimaryNeutral950,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Wallet",
          style: ktBodySemiBoldSize20.copyWith(
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: kcPrimaryNeutral950,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Balance Section
            Container(
              width: double.infinity,
              height: screenHeight(context) * 0.17,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                image: DecorationImage(
                  image: AssetImage("asset/images/wallet_background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 38.0, left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Available Balance",
                      style: ktBodyRegularSize12.copyWith(
                        color: kcPrimaryNeutral500,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    verticalSpaceTiny,
                    Text(
                      "₦ ${balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                      style: ktBodySemiBoldSize20.copyWith(
                        fontSize: 40,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            verticalSpaceMedium,
            // Top Up Section

            OutlinButton(
                text: 'Top Up',
                width: double.infinity,
                height: screenHeight(context) * 0.065,
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: kcPrimaryNeutral990,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: kcBlack.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: kcPrimary400.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: kcPrimary400,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance,
                                      color: kcWhite,
                                      size: 20,
                                    ),
                                  ),
                                  horizontalSpaceSmall,
                                  Expanded(
                                    child: Text(
                                      'Bank Transfer Details',
                                      style: ktTitleSemiBoldSize16.copyWith(
                                        color: kcPrimaryNeutral100,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: kcPrimaryNeutral200
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: kcPrimaryNeutral400,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  // Instructions
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: kcPrimaryBlue400.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            kcPrimaryBlue400.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          color: kcPrimaryBlue400,
                                          size: 16,
                                        ),
                                        horizontalSpaceSmall,
                                        Expanded(
                                          child: Text(
                                            'Transfer to the account below to top up your wallet',
                                            style:
                                                ktLabelRegularSize12.copyWith(
                                              color: kcPrimaryBlue400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  verticalSpaceMedium,

                                  // Bank Details Cards
                                  _buildDetailCard(
                                    context: context,
                                    icon: Icons.account_balance,
                                    label: 'Bank Name',
                                    value: walletState
                                            ?.wallet?.bankTransfer?.bankName ??
                                        'N/A',
                                    iconColor: kcPrimary400,
                                  ),

                                  verticalSpaceSmall,

                                  _buildDetailCard(
                                    context: context,
                                    icon: Icons.credit_card,
                                    label: 'Account Number',
                                    value: walletState?.wallet?.bankTransfer
                                            ?.accountNumber ??
                                        'N/A',
                                    iconColor: kcPrimaryBlue400,
                                    copyable: true,
                                  ),

                                  verticalSpaceSmall,

                                  _buildDetailCard(
                                    context: context,
                                    icon: Icons.person,
                                    label: 'Account Name',
                                    value: walletState?.wallet?.bankTransfer
                                            ?.accountName ??
                                        'N/A',
                                    iconColor: kcPrimaryOrange500,
                                  ),
                                ],
                              ),
                            ),

                            // Footer Actions
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: const BoxDecoration(
                                color: kcPrimaryNeutral950,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinButton(
                                      text: 'Copy Details',
                                      width: double.infinity,
                                      height: 48,
                                      onPressed: () {
                                        // Copy all details to clipboard
                                        final details = '''
Bank: ${walletState?.wallet?.bankTransfer?.bankName ?? 'N/A'}
Account: ${walletState?.wallet?.bankTransfer?.accountNumber ?? 'N/A'}
Name: ${walletState?.wallet?.bankTransfer?.accountName ?? 'N/A'}''';
                                        // Add copy to clipboard functionality here
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Bank details copied to clipboard'),
                                            backgroundColor: kcPrimary400,
                                          ),
                                        );
                                      },
                                      color: kcPrimary400,
                                      bgColor: kcPrimaryNeutral990,
                                    ),
                                  ),
                                  horizontalSpaceSmall,
                                  Expanded(
                                    child: FullButton(
                                      text: 'Got it',
                                      width: double.infinity,
                                      height: 48,
                                      onPressed: () => Navigator.pop(context),
                                      color: kcPrimary400,
                                      textColor: kcWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                color: kcPrimary400,
                bgColor: kcPrimaryNeutral900),
            verticalSpaceSmall,

            // Transaction History Section
            Container(
              padding: const EdgeInsets.only(
                  top: 18.0, bottom: 8.0, left: 16, right: 12),
              decoration: BoxDecoration(
                color: kcPrimary980,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Transaction History",
                    style: ktBodyRegularSize18.copyWith(
                      color: kcPrimaryNeutral100,
                    ),
                  ),
                  verticalSpaceSmall,
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.value.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions.value[index];
                      final isPositive = transaction['amount']! > 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.money_recive,
                                  color: kcPrimary300,
                                  size: 20,
                                ),
                                horizontalSpaceSmall,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction['type']!,
                                        style: ktBodyRegularSize12.copyWith(
                                          color: kcPrimary300,
                                          fontSize: 14,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      verticalSpaceTiny,
                                      Text(
                                        transaction['date']!,
                                        style: ktBodyRegularSize12.copyWith(
                                          color: kcPrimary500,
                                          fontSize: 12,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${isPositive ? '+' : '-'} ₦${transaction['amount']!.abs().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                                  style: ktBodyRegularSize12.copyWith(
                                    color:
                                        isPositive ? Colors.green : Colors.red,
                                    fontSize: 14,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            verticalSpaceSmall,
                            SvgPicture.asset(
                              'asset/svgs/dotted_line.svg',
                              color: kcPrimary600,
                            ),
                            verticalSpaceSmall,
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCardBottomSheet extends HookConsumerWidget {
  final Function(String, String) onSave;

  const AddCardBottomSheet({super.key, required this.onSave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardNumberController = useTextEditingController();
    final expiryController = useTextEditingController();
    final cvvController = useTextEditingController();

    void saveCard() {
      final cardNumber = cardNumberController.text.trim();
      final expiry = expiryController.text.trim();
      final cvv = cvvController.text.trim();

      if (cardNumber.isEmpty || expiry.isEmpty || cvv.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Basic validation for card number (16 digits), expiry (MM/YY), and CVV (3-4 digits)
      if (cardNumber.length != 16 ||
          !RegExp(r'^\d{16}$').hasMatch(cardNumber)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid card number. Must be 16 digits.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!RegExp(r'^(0[1-9]|1[0-2])/([0-9]{2})$').hasMatch(expiry)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid expiry date. Format must be MM/YY.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (cvv.length < 3 || cvv.length > 4 || !RegExp(r'^\d+$').hasMatch(cvv)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid CVV. Must be 3 or 4 digits.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Determine card type based on card number (simplified logic)
      String cardType = 'Visa';
      if (cardNumber.startsWith('4')) {
        cardType = 'Visa';
      } else if (cardNumber.startsWith('5')) {
        cardType = 'Mastercard';
      }

      // Format card number for display (e.g., **** **** **** 1234)
      final formattedCardNumber =
          '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';

      onSave(cardType, formattedCardNumber);
      Navigator.pop(context);
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Add Another Card",
                  style: ktBodySemiBoldSize20.copyWith(
                    fontSize: 20,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            verticalSpaceMedium,
            // Card Number Field
            _buildTextField(
              label: "Card Number",
              controller: cardNumberController,
              hintText: "1234 **** 5678",
              keyboardType: TextInputType.number,
            ),
            verticalSpaceMedium,
            // Expiry and CVV Fields
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: "Valid thru",
                    controller: expiryController,
                    hintText: "MM/YY",
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                horizontalSpaceMedium,
                Expanded(
                  child: _buildTextField(
                    label: "CVV",
                    controller: cvvController,
                    hintText: "CVV",
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            verticalSpaceLarge,
            // Add Card Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Add Card",
                  style: ktBodySemiBoldSize20.copyWith(
                    fontSize: 16,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            verticalSpaceMedium,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ktBodyRegularSize12.copyWith(
            color: kcPrimaryNeutral500,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
        verticalSpaceTiny,
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Colors.black,
            letterSpacing: 1,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: kcPrimaryNeutral800,
              fontSize: 14,
            ),
            filled: true,
            fillColor: kcPrimaryNeutral900,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: kcPrimaryNeutral800),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: kcPrimaryNeutral800),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: kcPrimary400),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildDetailCard({
  required IconData icon,
  required String label,
  required String value,
  required Color iconColor,
  bool copyable = false,
  required BuildContext context,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kcPrimaryNeutral950,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: kcPrimaryNeutral800,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),
        horizontalSpaceSmall,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: ktLabelSemiBoldSize11.copyWith(
                  color: kcPrimaryNeutral500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: ktBodySemiBoldSize14.copyWith(
                  color: kcPrimaryNeutral100,
                ),
              ),
            ],
          ),
        ),
        if (copyable)
          IconButton(
            onPressed: () {
              // Add copy to clipboard functionality here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied to clipboard'),
                  backgroundColor: kcPrimary400,
                ),
              );
            },
            icon: const Icon(
              Icons.copy,
              color: kcPrimaryNeutral500,
              size: 16,
            ),
          ),
      ],
    ),
  );
}
