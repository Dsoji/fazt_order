import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/app_colors.dart';
import '../../../common/res/app_colors.dart';
import '../data/model/parcel_quote.dart';

/// Naira, grouped in thousands. Prices come back as plain numbers.
String formatNaira(num? amount) {
  final value = (amount ?? 0).round();
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}₦$buffer';
}

/// The Courier section's promotion badge.
///
/// Renders nothing when there is no active promotion, so it can be dropped in
/// unconditionally. The tag arrives pre-formatted — `20% OFF`, `₦1,000 OFF`,
/// `FREE DELIVERY` — and is shown exactly as sent.
///
/// **Display only.** This badge cannot move money; what gets charged comes from
/// the quote and is re-verified server-side at payment.
class ParcelPromotionBanner extends StatelessWidget {
  const ParcelPromotionBanner({super.key, required this.promotion});

  final ParcelPromotion? promotion;

  @override
  Widget build(BuildContext context) {
    if (promotion?.hasBadge != true) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kcPrimaryOrange500.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kcPrimaryOrange500.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.discount_shape,
              size: 16, color: kcPrimaryOrange500),
          const Gap(8),
          Expanded(
            child: Text(
              promotion!.tag!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kcPrimaryOrange500,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const Text(
            'on parcel delivery',
            style: TextStyle(fontSize: 12, color: kcPrimaryNeutral500),
          ),
        ],
      ),
    );
  }
}

/// What this delivery will cost, broken down.
///
/// Shown before the user commits so the payable total is never a surprise on
/// the confirm screen. Every figure comes off the quote rather than being
/// recomputed here — the backend re-verifies the same numbers at payment time,
/// and a total the app worked out itself would only ever disagree.
class ParcelQuoteCard extends StatelessWidget {
  const ParcelQuoteCard({
    super.key,
    required this.quote,
    this.isLoading = false,
  });

  final ParcelQuote? quote;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _decoration,
        child: const Row(
          children: [
            SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            Gap(12),
            Text(
              'Working out your delivery cost…',
              style: TextStyle(fontSize: 13, color: kcPrimaryNeutral500),
            ),
          ],
        ),
      );
    }

    final q = quote;
    if (q == null || q.totalPrice == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.receipt_item,
                  size: 16, color: AppColors.brand400),
              const Gap(8),
              const Text(
                'Delivery cost',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              if (q.distance != null)
                Text(
                  '${q.distance!.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kcPrimaryNeutral500,
                  ),
                ),
            ],
          ),
          const Gap(12),
          _QuoteRow(
            label: 'Delivery fee',
            value: formatNaira(q.payableDeliveryFee ?? q.deliveryFee),
            // The pre-discount fee is worth showing struck through only when
            // the promotion actually moved it.
            strikethrough: (q.payableDeliveryFee != null &&
                    q.deliveryFee != null &&
                    q.payableDeliveryFee! < q.deliveryFee!)
                ? formatNaira(q.deliveryFee)
                : null,
          ),
          if (q.serviceFee != null)
            _QuoteRow(
              label: 'Service fee',
              value: formatNaira(q.serviceFee),
            ),
          if (q.hasDiscount)
            _QuoteRow(
              label: 'Discount',
              value: '-${formatNaira(q.discount)}',
              valueColor: AppColors.green800,
            ),
          const Gap(10),
          const Divider(height: 1, color: AppColors.neutral900),
          const Gap(10),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              if (q.hasDiscount && q.originalTotalPrice != null) ...[
                Text(
                  formatNaira(q.originalTotalPrice),
                  style: const TextStyle(
                    fontSize: 12,
                    color: kcPrimaryNeutral500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const Gap(6),
              ],
              Text(
                formatNaira(q.totalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brand400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static final BoxDecoration _decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.neutral900),
  );
}

class _QuoteRow extends StatelessWidget {
  const _QuoteRow({
    required this.label,
    required this.value,
    this.strikethrough,
    this.valueColor,
  });

  final String label;
  final String value;
  final String? strikethrough;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: kcPrimaryNeutral500),
          ),
          const Spacer(),
          if (strikethrough != null) ...[
            Text(
              strikethrough!,
              style: const TextStyle(
                fontSize: 12,
                color: kcPrimaryNeutral500,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const Gap(6),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
