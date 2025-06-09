import 'package:flutter/material.dart';

class DashProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;

  const DashProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Total spacing count = totalSteps - 1
        double totalSpacing = constraints.maxWidth * 0.05;
        double spacing = totalSpacing / (totalSteps - 1);
        double dashWidth = (constraints.maxWidth - totalSpacing) / totalSteps;
        double dashHeight = dashWidth * 0.07;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isOdd) {
              // spacing
              return SizedBox(width: spacing);
            } else {
              int dashIndex = index ~/ 2;
              bool isActive = dashIndex < currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: dashWidth,
                height: dashHeight,
                decoration: BoxDecoration(
                  color:
                      isActive ? activeColor : inactiveColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(dashHeight / 2),
                ),
              );
            }
          }),
        );
      },
    );
  }
}
