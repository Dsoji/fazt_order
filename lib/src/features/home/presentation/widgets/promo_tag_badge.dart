import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/res/app_colors.dart';
import '../../data/model/response/shops_model/promotion_display.dart';

/// The badge text the backend already formatted for us, e.g.
/// `20% OFF`, `FREE DELIVERY`, `20% OFF + FREE DELIVERY`.
///
/// [tag] is used verbatim when the API sends one; otherwise the label is
/// composed from the raw [promotion] fields.
String? promotionTagText(PromotionDisplay? promotion, {String? tag}) {
  if (promotion?.hasActivePromotion != true) return null;
  if (tag != null && tag.trim().isNotEmpty) return tag.trim();

  final percent = promotion?.discountPercent ?? 0;
  final freeDelivery = promotion?.freeDelivery == true;
  final parts = <String>[
    if (percent > 0) '${percent.toStringAsFixed(0)}% OFF',
    if (freeDelivery) 'FREE DELIVERY',
  ];
  if (parts.isEmpty) return null;
  return parts.join(' + ');
}

/// Price after [promotion] is applied, or null when there is nothing to
/// discount. [PromotionDisplay.maxDiscountAmount] caps the reduction.
num? discountedPrice(num? price, PromotionDisplay? promotion) {
  if (price == null || price <= 0) return null;
  if (promotion?.hasActivePromotion != true) return null;

  final percent = promotion?.discountPercent ?? 0;
  if (percent <= 0) return null;

  num off = price * percent / 100;
  final cap = promotion?.maxDiscountAmount ?? 0;
  if (cap > 0 && off > cap) off = cap;

  final discounted = price - off;
  if (discounted <= 0 || discounted >= price) return null;
  return discounted;
}

/// Human sentence describing an offer, e.g.
/// `20% off your order · Free delivery`.
String? promotionDetailText(PromotionDisplay? promotion) {
  if (promotion?.hasActivePromotion != true) return null;

  final percent = promotion?.discountPercent ?? 0;
  final cap = promotion?.maxDiscountAmount ?? 0;
  final parts = <String>[
    if (percent > 0)
      cap > 0
          ? '${percent.toStringAsFixed(0)}% off your order (up to ₦${cap.toStringAsFixed(0)})'
          : '${percent.toStringAsFixed(0)}% off your order',
    if (promotion?.freeDelivery == true) 'Free delivery',
  ];
  if (parts.isEmpty) return null;
  return parts.join(' · ');
}

/// Pill shown on discount meal / featured restaurant cards.
class PromoTagBadge extends StatelessWidget {
  const PromoTagBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final upper = label.toUpperCase();
    final hasDiscount = upper.contains('OFF');
    final color = hasDiscount ? kcPrimaryOrange500 : AppColors.green800;
    final icon = hasDiscount ? Iconsax.discount_shape : Iconsax.truck_fast;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width strip spelling out a store-wide offer. Renders nothing when the
/// store has no active promotion, so callers can drop it in unconditionally.
class PromotionOfferBanner extends StatelessWidget {
  const PromotionOfferBanner({super.key, required this.promotion});

  final PromotionDisplay? promotion;

  @override
  Widget build(BuildContext context) {
    final detail = promotionDetailText(promotion);
    if (detail == null) return const SizedBox.shrink();

    final freeDeliveryOnly =
        (promotion?.discountPercent ?? 0) <= 0 && promotion?.freeDelivery == true;
    final color = freeDeliveryOnly ? AppColors.green800 : kcPrimaryOrange500;
    final icon =
        freeDeliveryOnly ? Iconsax.truck_fast : Iconsax.discount_shape;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offer running now',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: kcPrimaryNeutral500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared "Section title" + optional trailing action used by the home rails.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: kcPrimaryNeutral500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
