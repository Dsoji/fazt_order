import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import 'confirm_cancel_order.dart';

class CancelOrderBottomSheet extends StatelessWidget {
  const CancelOrderBottomSheet({
    super.key,
  });

  void _showConfirmCancelOrderBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const ConfirmCancelOrderBottomSheet();
      },
    );
  }

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          verticalSpaceLarge,
          Lottie.asset('asset/lottie/cancel.json'),
          const Center(
              child: Text(
            'Are you sure you want to cancel this order?',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: kcPrimaryNeutral100,
                letterSpacing: 1),
          )),
          Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _showConfirmCancelOrderBottomSheet(context);
                },
                child: Container(
                  // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  height: screenHeight(context) * 0.07,
                  width: screenWidth(context) * 0.9,
                  decoration: BoxDecoration(
                      color: kcWhite,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: kcPrimary400, width: 2)),
                  child: const Center(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: kcPrimary400,
                          letterSpacing: 1),
                    ),
                  ),
                ),
              ),
              verticalSpaceMedium,
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
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
          )
        ],
      ),
    );
  }
}
