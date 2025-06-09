import 'dart:ui';

import 'package:fazt_order/src/common/app_colors.dart';
import 'package:fazt_order/src/common/ui_helpers.dart';
import 'package:fazt_order/src/common/widgets/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  bool openOnly = false;
  double selectedRating = 5.0;
  String? selectedDeliveryTime;
  String deliveryFeeFrom = "0.0";
  String deliveryFeeTo = "0.0";

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Padding(
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
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  const Text(
                    "Filter",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, size: 24),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              verticalSpaceSmall,
              // Vendors Section
              const Text(
                "VENDORS",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kcPrimaryNeutral100,
                ),
              ),
              CheckboxListTile(
                title: const Text("Open only"),
                value: openOnly,
                onChanged: (value) {
                  setState(() {
                    openOnly = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: kcPrimary300,
              ),
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
              verticalSpaceSmall,
              // Rating Section
              const Text(
                "RATING",
                style: TextStyle(
                  fontSize: 14,
                  color: kcPrimaryNeutral100,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRatingButton(5.0),
                  _buildRatingButton(4.5),
                  _buildRatingButton(4.0),
                  _buildRatingButton(3.5),
                  _buildRatingButton(3.0),
                ],
              ),
              verticalSpace(18),
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
              verticalSpaceSmall,
              // Delivery Time Section
              Text("Delivery Time",
                  style:
                      ktBodyRegularSize16.copyWith(color: kcPrimaryNeutral100)),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Less than 30 mins"),
                value: selectedDeliveryTime == "30 mins",
                onChanged: (value) {
                  setState(() {
                    selectedDeliveryTime = value == true ? "30 mins" : null;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: kcPrimary300,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Less than 45 mins"),
                value: selectedDeliveryTime == "45 mins",
                onChanged: (value) {
                  setState(() {
                    selectedDeliveryTime = value == true ? "45 mins" : null;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: kcPrimary300,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Less than 1 hour"),
                value: selectedDeliveryTime == "1 hour",
                onChanged: (value) {
                  setState(() {
                    selectedDeliveryTime = value == true ? "1 hour" : null;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: kcPrimary300,
              ),
              verticalSpaceSmall,
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
              verticalSpaceSmall,
              // Delivery Fee Range Section
              const Text(
                "Delivery Fee Range",
                style: TextStyle(
                  fontSize: 14,
                  color: kcPrimaryNeutral100,
                ),
              ),
              verticalSpaceMedium,
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style: ktBodyRegularSize12.copyWith(
                            color: kcPrimaryNeutral200,
                          ),
                        ),
                        verticalSpaceTiny,
                        TextField(
                          decoration: InputDecoration(
                            hintText: "00",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: kcPrimaryNeutral950,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              deliveryFeeFrom = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'To',
                          style: ktBodyRegularSize12.copyWith(
                            color: kcPrimaryNeutral200,
                          ),
                        ),
                        verticalSpaceTiny,
                        TextField(
                          decoration: InputDecoration(
                            hintText: "00",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: kcPrimaryNeutral950,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              deliveryFeeTo = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcPrimary400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Apply",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              verticalSpaceMedium
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingButton(double rating) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRating = rating;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: selectedRating == rating ? kcPrimary300 : kcTransparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kcPrimary700)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: selectedRating == rating ? kcWhite : kcPrimary400,
            ),
            horizontalSpaceTiny,
            Text(
              rating.toString(),
              style: TextStyle(
                color: selectedRating == rating ? kcWhite : kcPrimary400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
