import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../common/widgets/text_styles.dart';

class WalletView extends StatefulWidget {
  const WalletView({Key? key}) : super(key: key);

  @override
  _WalletViewState createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  // Sample data for cards and transactions (replace with provider or API data)
  final List<Map<String, String>> _cards = [
    {'type': 'Mastercard', 'number': '**** **** **** 1234'},
    {'type': 'Visa', 'number': '**** **** **** 1234'},
  ];

  final List<Map<String, dynamic>> _transactions = [
    {'type': 'Top Up', 'amount': 20000, 'date': 'Today 1:36 pm'},
    {'type': 'Top Up', 'amount': 20000, 'date': 'Today 1:36 pm'},
    {'type': 'Order Payment', 'amount': -20000, 'date': 'Today 1:36 pm'},
    {'type': 'Top Up', 'amount': 20000, 'date': 'Today 1:36 pm'},
  ];

  final double _balance = 356000000;

  void _deleteCard(int index) async {
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
      setState(() {
        _cards.removeAt(index);
      });
    }
  }

  void _addAnotherCard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kcPrimaryNeutral950,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddCardBottomSheet(
        onSave: (type, number) {
          setState(() {
            _cards.add({'type': type, 'number': number});
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      "₦ ${_balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
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
            Container(
              width: double.infinity,
              height: screenHeight(context) * 0.065,
              decoration: BoxDecoration(
                color: kcTransparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: kcPrimary400, width: 1),
              ),
              child: Center(
                child: Text(
                  "Top Up",
                  style: ktBodySemiBoldSize20.copyWith(
                    fontSize: 20,
                    color: kcPrimary400,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            verticalSpaceSmall,
            Text(
              "Credit/Debit Cards",
              style: ktBodyRegularSize12.copyWith(
                color: kcPrimaryNeutral500,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            verticalSpaceSmall,
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        card['type'] == 'Mastercard' ? 'asset/svgs/master_card.svg' : 'asset/svgs/visa_card.svg',
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: Text(
                          card['number']!,
                          style: ktBodyRegularSize12.copyWith(
                            color: Colors.black,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _deleteCard(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: kcPrimaryRed900,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.trash,
                            color: kcPrimaryRed200,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            verticalSpaceSmall,
            GestureDetector(
              onTap: _addAnotherCard,
              child: Row(
                children: [
                  const Icon(
                    Iconsax.add,
                    color: kcPrimary400,
                    size: 20,
                  ),
                  horizontalSpaceSmall,
                  Text(
                    "Add Another Card",
                    style: ktBodyRegularSize12.copyWith(
                      color: kcPrimary400,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            verticalSpaceMedium,
            // Transaction History Section
            Container(
              padding: const EdgeInsets.only(top: 18.0, bottom: 8.0, left: 16, right: 12),
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
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                    color: isPositive ? Colors.green : Colors.red,
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

class AddCardBottomSheet extends StatefulWidget {
  final Function(String, String) onSave;

  const AddCardBottomSheet({Key? key, required this.onSave}) : super(key: key);

  @override
  _AddCardBottomSheetState createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  void _saveCard() {
    final cardNumber = _cardNumberController.text.trim();
    final expiry = _expiryController.text.trim();
    final cvv = _cvvController.text.trim();

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
    if (cardNumber.length != 16 || !RegExp(r'^\d{16}$').hasMatch(cardNumber)) {
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

    widget.onSave(cardType, formattedCardNumber);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _cardNumberController,
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
                    controller: _expiryController,
                    hintText: "MM/YY",
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                horizontalSpaceMedium,
                Expanded(
                  child: _buildTextField(
                    label: "CVV",
                    controller: _cvvController,
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
                onPressed: _saveCard,
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
            hintStyle: TextStyle(
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