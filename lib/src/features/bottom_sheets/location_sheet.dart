import 'dart:ui';

import 'package:fazt_order/src/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../common/widgets/text_styles.dart';

class LocationBottomSheet extends StatelessWidget {
  const LocationBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Change current location",
                    style: TextStyle(
                      color: kcPrimaryNeutral100,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(
                        Iconsax.close_circle,
                        size: 24,
                        color: kcPrimaryNeutral100,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close the bottom sheet
                      },
                    ),
                  ),
                ],
              ),
              // Title
              const SizedBox(height: 8),
              // Description
              const Text(
                "This let us show nearby restaurants, stores you can order from and address to deliver to.",
                style: TextStyle(
                  fontSize: 14,
                  color: kcPrimaryNeutral300,
                ),
              ),
              const SizedBox(height: 16),
              // Search Bar
              TextField(
                onChanged: (value) {},
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  hintText: 'COMI',
                  hintStyle:
                      ktBodyRegularSize14.copyWith(color: kcPrimaryNeutral500),
                  suffixIcon: const Icon(
                    Iconsax.search_normal_1,
                    color: kcPrimaryNeutral500,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(
                      color: kcPrimary400,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(
                      color: kcPrimary400,
                      width: 1.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(
                      color: kcPrimary400,
                      width: 1.0,
                    ),
                  ),
                  filled: true,
                  fillColor: kcPrimary980,
                ),
              ),
              const SizedBox(height: 16),
              // List of locations
              ListView(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable ListView scrolling
                children: const [
                  LocationTile(
                    icon: Icons.gps_fixed,
                    title: "Use your current location",
                  ),
                  LocationTile(
                    icon: Iconsax.location,
                    title: "Computer Village",
                    subtitle: "12, Oritshe street, Ikeja, Lagos State",
                    isSelected: true,
                  ),
                  LocationTile(
                    icon: Iconsax.location,
                    title: "Community Secondary School",
                    subtitle:
                        "14, Ogbeni sare jeje street, Abeokuta, Ogun State",
                  ),
                  LocationTile(
                    icon: Iconsax.location,
                    title: "Comfort Estate",
                    subtitle: "12, okofor road, Akwa, Anambra State",
                  ),
                ],
              ),
              const SizedBox(height: 16), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

class LocationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;

  const LocationTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.green : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.green : Colors.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
