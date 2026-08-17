import 'package:cached_network_image/cached_network_image.dart';
import 'package:fazt_order/src/common/app_colors.dart';
import 'package:fazt_order/src/common/res/app_colors.dart';
import 'package:fazt_order/src/features/home/presentation/restaurant_details.dart';
import 'package:fazt_order/src/features/profile/data/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:logger/logger.dart';

import '../../features/home/data/controller/shop_controller.dart';
import '../../features/home/data/model/response/shops_model/promotion_display.dart';
import '../../features/home/data/model/response/shops_model/result.dart';
import '../../features/home/data/model/response/shops_model/shop_extension.dart';

final logger = Logger();

class RestaurantCard extends ConsumerWidget {
  final ShopResult restaurant;
  final int index;
  final bool? isLoggedIn;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.index,
    this.isLoggedIn = true,
  });

  // Helper function to get the current day's schedule

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Availability lives in one place — ShopStatusExtension.isOpenNow — so the
    // card, the details screen and checkout can never disagree about whether a
    // shop is taking orders.
    final isOpen = restaurant.isOpenNow;
    logger.d(
        '[RestaurantCard] shop=${restaurant.id} isOpenNow=$isOpen, isOpen=${restaurant.isOpen}');

    Future<void> toggleFavorite() async {
      await ref
          .read(profileControllerProvider.notifier)
          .addToFavorites(shopId: restaurant.id ?? '');
      await ref.read(profileControllerProvider.notifier).fetchFavouritesList();
      await ref.read(shopControllerProvider.notifier).revalidateShops();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailsView(
              restaurant: restaurant,
              isLoggedIn: isLoggedIn,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Builder(
                  builder: (context) {
                    final imageUrl = restaurant.store?.storeDisplayImage;
                    Widget fallback() => Container(
                          height: 160,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.storefront,
                            color: Colors.grey[500],
                            size: 48,
                          ),
                        );
                    if (imageUrl == null || imageUrl.isEmpty) {
                      return fallback();
                    }
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => fallback(),
                      errorWidget: (context, url, error) => fallback(),
                    );
                  },
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _PromoBadges(
                    promotion: restaurant.store?.promotionDisplay,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        restaurant.isLiked == true
                            ? Iconsax.heart5
                            : Iconsax.heart,
                        color: restaurant.isLiked == true
                            ? AppColors.green800
                            : kcPrimaryNeutral400,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              // Right padding is applied per-child so the status pill can sit
              // hard against the card edge while the text stays inset.
              padding: const EdgeInsets.fromLTRB(14, 12, 0, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Text(
                      restaurant.store?.storeName ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 0.1,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Row(
                      children: [
                        Icon(Iconsax.location,
                            size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurant.shopName ?? '',
                            style: TextStyle(
                                fontSize: 12.5, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(IconsaxPlusLinear.activity,
                          size: 14, color: kcPrimaryNeutral400),
                      const SizedBox(width: 4),
                      const Text(
                        "Instant Delivery",
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: kcPrimaryNeutral400),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: RestaurantStatusPill(
                          isOpen: isOpen,
                          label: restaurant.availabilityLabel,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantStatusPill extends StatelessWidget {
  const RestaurantStatusPill({super.key, required this.isOpen, this.label});

  final bool isOpen;

  /// Overrides the default OPEN/CLOSED wording — used to spell out
  /// "NOT ACCEPTING ORDERS" when the vendor has switched the toggle off.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.green800 : AppColors.red800;
    final label = this.label ?? (isOpen ? 'OPEN' : 'CLOSED');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBadges extends StatelessWidget {
  const _PromoBadges({required this.promotion});

  final PromotionDisplay? promotion;

  @override
  Widget build(BuildContext context) {
    if (promotion?.hasActivePromotion != true) return const SizedBox.shrink();

    final freeDelivery = promotion?.freeDelivery == true;
    final percent = promotion?.discountPercent ?? 0;
    final showDiscount = percent > 0;

    if (!freeDelivery && !showDiscount) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDiscount)
          _PromoChip(
            icon: Iconsax.discount_shape,
            label: '${percent.toStringAsFixed(0)}% OFF',
            color: kcPrimaryOrange500,
          ),
        if (showDiscount && freeDelivery) const SizedBox(height: 6),
        if (freeDelivery)
          const _PromoChip(
            icon: Iconsax.truck_fast,
            label: 'Free Delivery',
            color: AppColors.green800,
          ),
      ],
    );
  }
}

class _PromoChip extends StatelessWidget {
  const _PromoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
