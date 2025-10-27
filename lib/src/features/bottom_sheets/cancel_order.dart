import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:fazt_order/src/features/home/data/controller/shop_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import 'confirm_cancel_order.dart';

class CancelOrderDialog extends HookConsumerWidget {
  final String orderId;
  const CancelOrderDialog({
    super.key,
    required this.orderId,
  });

  void _showConfirmCancelOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const ConfirmCancelOrderDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: screenHeight(context) * 0.15,
              child: Lottie.asset('asset/lottie/cancel.json'),
            ),
            const SizedBox(height: 20),
            const Center(
                child: Text(
              'Are you sure you want to cancel this order?',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: kcPrimaryNeutral100,
                  letterSpacing: 1),
            )),
            const SizedBox(height: 30),
            Column(
              children: [
                OutlinButton(
                  width: screenWidth(context) * 0.7,
                  height: screenHeight(context) * 0.06,
                  color: kcPrimary400,
                  bgColor: kcWhite,
                  text: 'Cancel Order',
                  onPressed: () async {
                    final result = await ref
                        .read(shopControllerProvider.notifier)
                        .cancelOrder(orderId);
                    if (result) {
                      await ref
                          .read(shopControllerProvider.notifier)
                          .fetchMyOrdersList();
                      await ref
                          .read(shopControllerProvider.notifier)
                          .fetchCart();
                      Navigator.pop(context);
                      _showConfirmCancelOrderDialog(context);
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Failed to cancel order, please try again later.',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
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
            )
          ],
        ),
      ),
    );
  }
}
