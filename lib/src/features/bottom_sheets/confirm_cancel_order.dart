import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';

class ConfirmCancelOrderBottomSheet extends StatelessWidget {
  const ConfirmCancelOrderBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          verticalSpaceLarge,
          Center(
            child: SizedBox(
                height: screenHeight(context) * 0.3,
                width: screenWidth(context) * 0.9,
                child: Lottie.asset(
                  'asset/lottie/cancel-order.json',
                  alignment: Alignment.center,
                )),
          ),
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
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Container(
              height: screenHeight(context) * 0.07,
              width: screenWidth(context) * 0.9,
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
        ],
      ),
    );
  }
}
