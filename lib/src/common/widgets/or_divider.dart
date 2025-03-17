import 'package:flutter/material.dart';

import '../res/app_colors.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left line
        Expanded(
          child: Divider(
            color: AppColors.neutral600, // Line color
            thickness: 1, // Line thickness
          ),
        ),
        SizedBox(width: 8), // Space between line and text
        // "Or" text
        Text(
          "Or",
          style: TextStyle(
            color: AppColors.neutral600, // Text color
            fontSize: 12, // Text size
          ),
        ),
        SizedBox(width: 8), // Space between text and line
        // Right line
        Expanded(
          child: Divider(
            color: AppColors.neutral600, // Line color
            thickness: 1, // Line thickness
          ),
        ),
      ],
    );
  }
}
