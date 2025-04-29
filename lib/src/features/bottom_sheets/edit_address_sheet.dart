import 'package:fazt_order/src/common/app_colors.dart';
import 'package:fazt_order/src/common/ui_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditAddressBottomSheet extends StatefulWidget {
  final String currentAddress;
  final Function(String) onUpdate;

  const EditAddressBottomSheet({
    Key? key,
    required this.currentAddress,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditAddressBottomSheetState createState() => _EditAddressBottomSheetState();
}

class _EditAddressBottomSheetState extends State<EditAddressBottomSheet> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = "08122347890";
    _addressController.text = widget.currentAddress;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16).copyWith(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        // height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: kcWhite,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20)
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Information",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kcPrimaryNeutral100),
            ),
            verticalSpaceMedium,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Phone Number ", style: TextStyle(color: kcPrimaryNeutral200, fontSize: 12),),
                verticalSpaceSmall,
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: "e.g 08122345670",
                    filled: true,
                    fillColor: kcPrimaryNeutral900,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: kcPrimaryNeutral800),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: kcPrimaryNeutral800),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: kcPrimaryNeutral800),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            verticalSpaceMedium,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Delivery Address ", style: TextStyle(color: kcPrimaryNeutral200, fontSize: 12),),
                verticalSpaceSmall,
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: "Enter address",
                    filled: true,
                    fillColor: kcPrimary950,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: kcPrimary400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: kcPrimary400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: kcPrimary400),
                    ),
                  ),
                ),
              ],
            ),

            verticalSpaceMedium,

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onUpdate(_addressController.text);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimary400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Update",
                  style: TextStyle(color: kcWhite, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}