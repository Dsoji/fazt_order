import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';

import '../../../webview_flutter.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../common/widgets/text_styles.dart';
import '../home/data/controller/shop_controller.dart';
import '../home/data/model/response/cartlsit/cart.dart';
import '../profile/data/controller/profile_controller.dart';

final logger = Logger();

class PaymentScreen extends HookConsumerWidget {
  const PaymentScreen({
    required this.selectedItems,
    this.vendorMessage,
    this.riderMessage,
    super.key,
  });

  final Cart selectedItems;
  final String? vendorMessage;
  final String? riderMessage;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch wallet and transaction history when widget is first built
    useEffect(() {
      Future.microtask(() {
        ref.read(profileControllerProvider.notifier).fetchWallet();
      });
      return null;
    }, []);

    final selectedPaymentMethod = useState<String>("wallet");
    final userDetails =
        ref.watch(profileControllerProvider).userDetails.valueOrNull;
    final location = userDetails?.user?.location;
    final walletState = ref.watch(profileControllerProvider).wallet;
    final balance =
        walletState.valueOrNull?.data?.wallet?.availableBalance?.toDouble() ??
            0.0;
    // final balance
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payment",
          style: ktBodyRegularSize20.copyWith(
              fontSize: 24, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Iconsax.arrow_left_2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: kcWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment Details",
                  style: ktBodyRegularSize16.copyWith(
                      color: kcPrimaryNeutral100, fontWeight: FontWeight.w500),
                ),
                verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Subtotal (${selectedItems.items?.length ?? 0} items)",
                      style: ktBodyRegularSize14.copyWith(
                          color: kcPrimaryNeutral300),
                    ),
                    Text(
                      "₦${selectedItems.subtotal?.toStringAsFixed(0) ?? "0"}",
                      style: ktBodyRegularSize14.copyWith(
                          color: kcPrimaryNeutral300,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                verticalSpaceTiny,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Delivery Fee",
                      style: ktBodyRegularSize14.copyWith(
                          color: kcPrimaryNeutral300),
                    ),
                    Text(
                      "₦${selectedItems.deliveryFee?.toStringAsFixed(0) ?? "0"}",
                      style: ktBodyRegularSize14.copyWith(
                          color: kcPrimaryNeutral100,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                verticalSpaceTiny,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tax and other fees",
                      style: ktBodyRegularSize14.copyWith(
                          color: kcPrimaryNeutral300),
                    ),
                    Text(
                      "₦${selectedItems.serviceFee?.toStringAsFixed(0) ?? "0"}",
                      style: ktBodyRegularSize14.copyWith(
                          color: kcPrimaryNeutral100,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TOTAL",
                      style: ktBodyRegularSize16.copyWith(
                          color: kcPrimaryNeutral100,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "₦${(selectedItems.totalPrice ?? 0)}",
                      style: ktBodyRegularSize16.copyWith(
                          color: kcPrimaryNeutral100,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          verticalSpaceSmall,
          const Divider(
            color: kcPrimaryNeutral300,
            thickness: 0.5,
          ),
          verticalSpaceSmall,
          const Text(
            "Payment Method",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          verticalSpaceSmall,
          ListTile(
            leading: const Icon(
              Iconsax.wallet_1,
              color: kcPrimaryNeutral200,
              size: 20,
            ),
            title: Text(
              "Wallet",
              style: ktBodyRegularSize18.copyWith(
                  color: kcPrimaryNeutral100, fontWeight: FontWeight.w400),
            ),
            trailing: selectedPaymentMethod.value == "wallet"
                ? const Icon(Iconsax.tick_circle5,
                    size: 20, color: kcPrimaryGreen400)
                : const Icon(Iconsax.tick_circle,
                    size: 20, color: kcPrimaryNeutral200),
            onTap: () {
              selectedPaymentMethod.value = "wallet";
            },
          ),
          ListTile(
            leading: const Icon(
              Iconsax.cards,
              color: kcPrimaryNeutral300,
              size: 20,
            ),
            title: Text(
              "Paystack",
              style: ktBodyRegularSize16.copyWith(
                  color: kcPrimaryNeutral100, fontWeight: FontWeight.w400),
            ),
            trailing: selectedPaymentMethod.value == "paystack"
                ? const Icon(Iconsax.tick_circle5,
                    size: 20, color: kcPrimaryGreen400)
                : const Icon(Iconsax.tick_circle,
                    size: 20, color: kcPrimaryNeutral200),
            onTap: () {
              selectedPaymentMethod.value = "paystack";
            },
          ),
          verticalSpaceLarge,
          FullButton(
            text: 'Place Order',
            width: double.infinity,
            height: 48,
            isLoading: ref.watch(shopControllerProvider).makeOrders.isLoading,
            onPressed: () async {
              if (selectedPaymentMethod.value == "wallet") {
                final totalPrice = selectedItems.totalPrice ?? 0.0;
                if (totalPrice > balance) {
                  Fluttertoast.showToast(
                    msg:
                        'Insufficient balance. Available: ₦${balance.toStringAsFixed(2)}, Required: ₦${totalPrice.toStringAsFixed(2)}',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return; // Prevent order placement
                } else {
                  final result =
                      await ref.read(shopControllerProvider.notifier).makeOrder(
                            selectedItems.id ?? '',
                            userDetails?.user?.location?.address ??
                                'Just an address',
                            userDetails?.user?.location?.city ?? 'ogba',
                            userDetails?.user?.location?.state ?? 'Lagos',
                            userDetails?.user?.location?.coordinates?[0]
                                    .toString() ??
                                '333.0',
                            userDetails?.user?.location?.coordinates?[1]
                                    .toString() ??
                                '6.540',
                            vendorMessage ?? "",
                            riderMessage ?? "",
                            selectedPaymentMethod.value,
                          );
                  if (result == true) {
                    final orderLink = ref
                        .read(shopControllerProvider)
                        .makeOrders
                        .valueOrNull
                        ?.payment
                        ?.paymentUrl;
                    final reference = ref
                        .read(shopControllerProvider)
                        .makeOrders
                        .valueOrNull
                        ?.payment
                        ?.reference;
                    logger.d('order link: $orderLink');
                    if (orderLink != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FaztWebViewScreen(
                            uri: orderLink,
                            reference: reference,
                          ),
                        ),
                      );
                    } else {
                      ref
                          .read(shopControllerProvider.notifier)
                          .fetchMyOrdersList();
                      ref.read(shopControllerProvider.notifier).fetchCart();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  }
                }
              } else if (selectedPaymentMethod.value == "paystack") {
                final result = await ref
                    .read(shopControllerProvider.notifier)
                    .makeOrder(
                      selectedItems.id ?? '',
                      userDetails?.user?.location?.address ?? 'Just an address',
                      userDetails?.user?.location?.city ?? 'ogba',
                      userDetails?.user?.location?.state ?? 'Lagos',
                      userDetails?.user?.location?.coordinates?[0].toString() ??
                          '333.0',
                      userDetails?.user?.location?.coordinates?[1].toString() ??
                          '6.540',
                      vendorMessage ?? "",
                      riderMessage ?? "",
                      selectedPaymentMethod.value,
                    );
                logger.d('result: $result');
                if (result == true) {
                  final orderLink = ref
                      .read(shopControllerProvider)
                      .makeOrders
                      .valueOrNull
                      ?.payment
                      ?.paymentUrl;
                  logger.d('order link: $orderLink');
                  final reference = ref
                      .read(shopControllerProvider)
                      .makeOrders
                      .valueOrNull
                      ?.payment
                      ?.reference;
                  logger.d('order link: $orderLink');
                  if (orderLink != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FaztWebViewScreen(
                          uri: orderLink,
                          reference: reference,
                        ),
                      ),
                    );
                  } else {
                    ref
                        .read(shopControllerProvider.notifier)
                        .fetchMyOrdersList();
                    ref.read(shopControllerProvider.notifier).fetchCart();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                }
              }
            },
            color: kcPrimary400,
            textColor: kcWhite,
          )
        ],
      ),
    );
  }
}
