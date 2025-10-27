import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';

class ConfirmCancelOrderDialog extends StatelessWidget {
  const ConfirmCancelOrderDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: screenHeight(context) * 0.15,
                width: screenWidth(context) * 0.7,
                child: Lottie.asset(
                  'asset/lottie/cancel-order.json',
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Your Order have been Cancelled.',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: kcPrimaryNeutral100,
                    letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                height: screenHeight(context) * 0.06,
                width: screenWidth(context) * 0.7,
                decoration: BoxDecoration(
                  color: kcPrimary400,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text(
                    'Back',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: kcWhite,
                        letterSpacing: 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
