import 'package:fazt_order/src/common/res/app_colors.dart';
import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:fazt_order/src/features/home/data/controller/shop_controller.dart';
import 'package:fazt_order/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gap/gap.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../common/app_colors.dart';
import '../../common/widgets/text_styles.dart';
import 'data/model/parcel_quote.dart';
import 'data/model/parcel_request.dart';
import 'widgets/parcel_payment_method_sheet.dart';

class ParcelConfirmDetails extends HookConsumerWidget {
  const ParcelConfirmDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDeliveryType = useState('Standard');
    final parcelAsync = ref.watch(shopControllerProvider).bookCourier;

    // The pickup code never rides on the create response. `GET /parcels/:id`
    // is the only endpoint that returns it, and only to the parcel's own
    // sender — who is exactly who is standing on this screen — so the parcel
    // is refetched by id once it has one, and kept here rather than in shared
    // state so it can only ever be this parcel's.
    final parcelId = parcelAsync.valueOrNull?.parcel?.id;
    final loadedParcel = useState<Parcel?>(null);
    useEffect(() {
      if (parcelId == null || parcelId.isEmpty) return null;
      var cancelled = false;
      Future.microtask(() async {
        final loaded = await ref
            .read(shopControllerProvider.notifier)
            .loadParcel(parcelId);
        if (!cancelled) loadedParcel.value = loaded;
      });
      return () => cancelled = true;
    }, [parcelId]);

    final pickupCode = loadedParcel.value?.pickupOTP;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Review",
          style: ktBodySemiBoldSize20.copyWith(
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: parcelAsync.when(
        data: (req) {
          final p = req.parcel;
          final pickupAddress = _formatAddress(
            p?.pickUpAddress?.address,
            p?.pickUpAddress?.city,
            p?.pickUpAddress?.state,
          );
          final deliveryAddress = _formatAddress(
            p?.deliveryAddress?.address,
            p?.deliveryAddress?.city,
            p?.deliveryAddress?.state,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDeliveryTimeSection(selectedDeliveryType),
                const Gap(24),
                FixedTimeline.tileBuilder(
                  theme: TimelineThemeData(
                    nodePosition: 0,
                    indicatorTheme: const IndicatorThemeData(
                      position: 0,
                      size: 20.0,
                    ),
                    connectorTheme: const ConnectorThemeData(
                      thickness: 2.0,
                      color: AppColors.green400,
                    ),
                  ),
                  builder: TimelineTileBuilder.connected(
                    itemCount: 2,
                    connectorBuilder: (context, index, type) {
                      return const DashedLineConnector(
                        color: AppColors.green400,
                        gap: 2.0,
                        dash: 4.0,
                      );
                    },
                    indicatorBuilder: (context, index) {
                      return index == 0
                          ? const DotIndicator(
                              color: AppColors.green400,
                              child: Icon(Icons.check,
                                  color: Colors.white, size: 12),
                            )
                          : const OutlinedDotIndicator(
                              borderWidth: 2.0,
                              color: AppColors.orange800,
                            );
                    },
                    contentsBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: _buildDetailsSection(
                            title: "Pick Up Details",
                            icon: Iconsax.tick_circle,
                            iconColor: kcPrimaryGreen500,
                            name: p?.senderInfo?.name ?? '-',
                            phone: p?.senderInfo?.phone ?? '-',
                            address: pickupAddress,
                          ),
                        );
                      }
                      return _buildDetailsSection(
                        title: "Delivery Details",
                        icon: Iconsax.location,
                        iconColor: kcPrimaryGreen500,
                        name: p?.receiverInfo?.name ?? '-',
                        phone: p?.receiverInfo?.phone ?? '-',
                        address: deliveryAddress,
                      );
                    },
                  ),
                ),
                const Gap(24),
                _buildParcelTypeSection(p?.parcelType ?? '-'),
                const Gap(24),
                _buildOTPAndNoteSection(
                  // The create response is kept as a fallback in case it ever
                  // starts carrying the field; today the fetched parcel is the
                  // only source. A parcel from before pickup codes existed
                  // resolves to null on both, and the block is left off.
                  pickupOTP: pickupCode ?? p?.pickupOTP,
                  deliveryOTP: p?.riderOTP,
                ),
                const Gap(24),
                _buildPaymentDetailsSection(
                  quote: req.quote,
                  deliveryFee: p?.deliveryFee,
                  serviceFee: p?.serviceFee,
                ),
                const Gap(32),
                FullButton(
                    isLoading: ref
                        .watch(shopControllerProvider)
                        .makeParcelPayment
                        .isLoading,
                    text: 'Make Payment',
                    width: double.infinity,
                    height: 48,
                    onPressed: () async {
                      // Ask before charging: wallet settles inline, paystack
                      // hands back a URL to open. Nothing is sent until the
                      // user picks one.
                      final method = await showParcelPaymentMethodSheet(
                        context,
                        amount: _payableTotal(
                          quote: req.quote,
                          deliveryFee: p?.deliveryFee,
                          serviceFee: p?.serviceFee,
                        ),
                      );
                      if (method == null || !context.mounted) return;

                      final result = await ref
                          .read(shopControllerProvider.notifier)
                          .makeParcelPayment(
                            p?.id ?? '',
                            method,
                            selectedDeliveryType.value,
                          );
                      if (!result || !context.mounted) return;

                      final details = ref
                          .read(shopControllerProvider)
                          .makeParcelPayment
                          .valueOrNull;

                      // A wallet payment is already settled — there is no
                      // redirect to follow, and pushing an empty webview would
                      // strand the user on a blank page.
                      if (details?.payment?.completed == true ||
                          details?.redirectRequired != true) {
                        Navigator.pop(context);
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FaztWebViewScreen(
                            uri: details?.payment?.paymentUrl ?? '',
                            reference: details?.payment?.reference ?? '',
                            title: 'Parcel Payment',
                          ),
                        ),
                      );
                    },
                    color: AppColors.brand400,
                    textColor: kcWhite),
                Gap(25),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Failed to load parcel details',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryTimeSection(ValueNotifier<String> selectedDeliveryType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Delivery Time",
          style: ktBodySemiBoldSize20.copyWith(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: _buildDeliveryOption(
                'Standard',
                '30-40 Mins',
                Iconsax.clock,
                selectedDeliveryType.value == 'Standard',
                () => selectedDeliveryType.value = 'Standard',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryOption(
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.brand980,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.brand400,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.brand400,
              size: 24,
            ),
            const Gap(8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.brand400,
              ),
            ),
            const Gap(4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.brand400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String name,
    required String phone,
    required String address,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: ktBodySemiBoldSize20.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Icon(Iconsax.arrow_right_3, color: Colors.grey[600], size: 16),
            ],
          ),
          const Gap(12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const Gap(4),
          Text(
            phone,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Gap(4),
          Text(
            address,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelTypeSection(String parcelType) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.box, color: kcPrimaryGreen500, size: 20),
            const Gap(12),
            Text(
              "Parcel Type",
              style: ktBodySemiBoldSize20.copyWith(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Gap(4),
        Text(
          parcelType,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ),
      ],
    );
  }

  /// The codes this parcel will be handed over on, plus the standing note.
  ///
  /// Two codes, two people, two moments — so each is labelled with both. A code
  /// the backend did not issue is left out rather than rendered as `0000`,
  /// which is a real-looking number the sender would go on to read out: parcels
  /// created before pickup codes existed have no [pickupOTP], and nothing is
  /// asked for one at collection.
  Widget _buildOTPAndNoteSection({int? pickupOTP, int? deliveryOTP}) {
    return Column(
      children: [
        if (pickupOTP != null) ...[
          _buildOTPRow(
            icon: Iconsax.box,
            label: "Pickup code",
            hint: "Give this to the rider at collection",
            code: pickupOTP,
          ),
          const Gap(12),
          const Divider(color: Colors.grey, thickness: 0.5),
          const Gap(12),
        ],
        if (deliveryOTP != null) ...[
          _buildOTPRow(
            icon: Iconsax.message_text,
            label: "Delivery code",
            hint: "Share with your receiver — they give it to the rider",
            code: deliveryOTP,
          ),
          const Gap(12),
          const Divider(color: Colors.grey, thickness: 0.5),
          const Gap(12),
        ],
        Row(
          children: [
            Icon(Iconsax.clipboard_text, color: kcPrimaryGreen500, size: 20),
            const Gap(12),
            Expanded(
              child: Text(
                "Kindly leave at the shop with the sales person",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOTPRow({
    required IconData icon,
    required String label,
    required String hint,
    required int code,
  }) {
    return Row(
      children: [
        Icon(icon, color: kcPrimaryGreen500, size: 20),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const Gap(2),
              // Both codes are the sender's to pass on, to two different
              // people. Without this line they are two anonymous 4-digit
              // numbers on one screen.
              Text(
                hint,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Text(
          code.toString().padLeft(4, '0'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  /// The payment breakdown.
  ///
  /// [quote] is the price the parcel was actually created under and wins
  /// whenever it is present — it already accounts for any promotion, and it is
  /// the figure the backend re-verifies at payment time. The parcel's own
  /// `deliveryFee`/`serviceFee` are the pre-discount fallback for parcels
  /// created before quoting existed; summing those when a promotion applied
  /// would overstate the total.
  Widget _buildPaymentDetailsSection({
    ParcelQuote? quote,
    num? deliveryFee,
    num? serviceFee,
  }) {
    final num dFee = quote?.payableDeliveryFee ?? deliveryFee ?? 0;
    final num sFee = quote?.serviceFee ?? serviceFee ?? 0;
    final num discount = quote?.discount ?? 0;
    final num total = _payableTotal(
      quote: quote,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Details",
            style: ktBodySemiBoldSize20.copyWith(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const Gap(16),
          _buildPaymentRow("Delivery Fee", "N ${dFee.toStringAsFixed(0)}"),
          const Gap(8),
          _buildPaymentRow(
              "Tax and other fees", "N ${sFee.toStringAsFixed(0)}"),
          if (discount > 0) ...[
            const Gap(8),
            _buildPaymentRow("Discount", "-N ${discount.toStringAsFixed(0)}"),
          ],
          const Gap(8),
          _buildPaymentRow("Total", "N ${total.toStringAsFixed(0)}",
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

/// What the parcel actually costs to pay.
///
/// The quote's total wins whenever it is present — it already accounts for any
/// promotion and is the figure the backend re-verifies at payment time. Summing
/// the parcel's own pre-discount fees is the fallback for parcels created
/// before quoting existed.
num _payableTotal({
  ParcelQuote? quote,
  num? deliveryFee,
  num? serviceFee,
}) {
  return quote?.totalPrice ??
      ((quote?.payableDeliveryFee ?? deliveryFee ?? 0) +
          (quote?.serviceFee ?? serviceFee ?? 0));
}

String _formatAddress(String? address, String? city, String? state) {
  final parts =
      [address, city, state].where((e) => (e ?? '').isNotEmpty).toList();
  if (parts.isEmpty) return '-';
  return parts.join(', ');
}
