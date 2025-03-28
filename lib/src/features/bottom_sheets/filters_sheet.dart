import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              // Title
              const Text(
                "Filter",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Vendors Section
              const Text(
                "VENDORS",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
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
                activeColor: Colors.green,
              ),
              const Divider(),
              // Rating Section
              const Text(
                "RATING",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
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
              const Divider(),
              // Delivery Time Section
              const Text(
                "DELIVERY TIME",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              CheckboxListTile(
                title: const Text("Less than 30 mins"),
                value: selectedDeliveryTime == "30 mins",
                onChanged: (value) {
                  setState(() {
                    selectedDeliveryTime = value == true ? "30 mins" : null;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: Colors.green,
              ),
              CheckboxListTile(
                title: const Text("Less than 45 mins"),
                value: selectedDeliveryTime == "45 mins",
                onChanged: (value) {
                  setState(() {
                    selectedDeliveryTime = value == true ? "45 mins" : null;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: Colors.green,
              ),
              CheckboxListTile(
                title: const Text("Less than 1 hour"),
                value: selectedDeliveryTime == "1 hour",
                onChanged: (value) {
                  setState(() {
                    selectedDeliveryTime = value == true ? "1 hour" : null;
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: Colors.green,
              ),
              const Divider(),
              // Delivery Fee Range Section
              const Text(
                "DELIVERY FEE RANGE",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "From",
                        hintText: "0.0",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.pink[50],
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          deliveryFeeFrom = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "To",
                        hintText: "0.0",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.pink[50],
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          deliveryFeeTo = value;
                        });
                      },
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
                    backgroundColor: Colors.green,
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
              const SizedBox(height: 16),
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
          color: selectedRating == rating ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rating.toString(),
              style: TextStyle(
                color: selectedRating == rating ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.star,
              size: 16,
              color: selectedRating == rating ? Colors.white : Colors.yellow,
            ),
          ],
        ),
      ),
    );
  }
}