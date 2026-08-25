import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../providers/navigation_provider.dart';
import '../../../../common/app_colors.dart';
import '../../data/controller/shop_controller.dart';
import '../../data/model/response/discounted_meals/discounted_meal.dart';
import '../../data/model/response/meal_variant_menu/result.dart';
import '../../data/model/response/shops_model/promotion_display.dart';
import 'add_to_cart_bottom_sheet.dart';
import 'promo_tag_badge.dart';

const double _cardWidth = 170;
const double _imageHeight = 110;

/// A horizontal ListView hands its children a tight height, so the rail height
/// *is* the card height: too little overflows, too much leaves dead space under
/// the last row. Image and paddings are fixed; only the text block moves with
/// the user's font scale, so that is the part we scale.
double _railHeight(BuildContext context) {
  const chrome = 18.0 + 16.0; // 8/10 padding + the 3/8/5 gaps between rows
  const textBlock = 68.0; // name + shop + price + meta lines at 1.0 scale
  return _imageHeight +
      chrome +
      MediaQuery.textScalerOf(context).scale(textBlock);
}

/// Horizontal rail of meals that currently have an active promotion.
///
/// Renders nothing when there is nothing promoted nearby — an empty list is a
/// normal response, not an error.
class DiscountMealsSection extends ConsumerWidget {
  const DiscountMealsSection({super.key, this.isLoggedIn = true});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discountedMeals =
        ref.watch(shopControllerProvider.select((s) => s.discountedMeals));
    final meals = discountedMeals.valueOrNull?.meals ?? const <DiscountedMeal>[];

    if (meals.isEmpty) {
      // Loading with nothing cached: show placeholders. Otherwise (empty or
      // failed) the section stays hidden.
      if (discountedMeals.isLoading) return const _DiscountMealsShimmer();
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeSectionHeader(
            title: 'Discount',
            subtitle: 'Deals running near you right now',
          ),
          SizedBox(
            height: _railHeight(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: meals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _DiscountMealCard(
                variant: meals[index],
                isLoggedIn: isLoggedIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The line under the price. It always resolves to something: a blank row on
/// one card would put back the dead space the rail height used to leave, and
/// everything on this rail has an active promotion to fall back on describing.
({IconData icon, String text}) _mealMeta(
  DiscountedMeal variant,
  PromotionDisplay? promotion,
) {
  final parts = <String>[];
  if (promotion?.freeDelivery == true) {
    parts.add('Free delivery');
  } else {
    final fee = variant.shop?.deliveryFee;
    if (fee != null) parts.add('₦${fee.toStringAsFixed(0)} delivery');
  }
  final time = variant.shop?.deliveryTime;
  if (time != null) parts.add('${time.toStringAsFixed(0)} min');
  if (parts.isNotEmpty) {
    return (icon: Iconsax.truck_fast, text: parts.join(' · '));
  }

  final cap = promotion?.maxDiscountAmount ?? 0;
  if (cap > 0) {
    return (
      icon: Iconsax.discount_shape,
      text: 'Up to ₦${cap.toStringAsFixed(0)} off',
    );
  }
  final category = variant.meal?.category?.categoryName?.trim();
  if (category != null && category.isNotEmpty) {
    return (icon: Iconsax.reserve, text: category);
  }
  return (icon: Iconsax.discount_shape, text: 'Deal running now');
}

class _DiscountMealCard extends ConsumerWidget {
  const _DiscountMealCard({required this.variant, required this.isLoggedIn});

  final DiscountedMeal variant;
  final bool isLoggedIn;

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    // The vendor's "Accepting orders" switch wins over any running promotion.
    if (variant.shop?.isOpen == false) {
      Fluttertoast.showToast(
        msg: '⚠️ This restaurant is not accepting orders right now',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    if (variant.inStock == false) {
      Fluttertoast.showToast(
        msg: '⚠️ This meal is out of stock',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    if (!isLoggedIn) {
      Fluttertoast.showToast(
        msg: 'Please login to add to cart',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    // `_id` on the rail is the meal-variant id, which is exactly what the
    // add-to-cart sheet fetches its details with.
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddToCartBottomSheet(
        menuItem: MealVariantMenuResult(id: variant.id),
      ),
    );

    // Straight to the Order tab once the item is in the cart — the rail sits on
    // Home, so there is nothing more to do here.
    if (added == true) {
      ref.read(navigationProvider.notifier).state = 1;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meal = variant.meal;
    final promotion = meal?.promotionDisplay;
    final tag = promotionTagText(promotion, tag: promotion?.tag);
    final price = meal?.price;
    final promoPrice = discountedPrice(price, promotion);
    final meta = _mealMeta(variant, promotion);
    final outOfStock = variant.inStock == false;

    return GestureDetector(
      onTap: () => _onTap(context, ref),
      child: Container(
        width: _cardWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
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
                _MealImage(imageUrl: meal?.mealImage),
                if (tag != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: PromoTagBadge(label: tag),
                    ),
                  ),
                if (outOfStock)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.45),
                      alignment: Alignment.center,
                      child: const Text(
                        'OUT OF STOCK',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal?.mealName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Iconsax.shop,
                          size: 11, color: kcPrimaryNeutral500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          variant.shop?.shopName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: kcPrimaryNeutral500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        promoPrice == null
                            ? (price == null
                                ? ''
                                : '₦${price.toStringAsFixed(0)}')
                            : '₦${promoPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: promoPrice == null
                              ? kcPrimary300
                              : kcPrimaryOrange700,
                        ),
                      ),
                      if (promoPrice != null && price != null) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '₦${price.toStringAsFixed(0)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: kcPrimaryNeutral600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(meta.icon, size: 11, color: kcPrimaryNeutral500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          meta.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: kcPrimaryNeutral500,
                          ),
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

class _MealImage extends StatelessWidget {
  const _MealImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
          height: _imageHeight,
          width: _cardWidth,
          color: Colors.grey[200],
          child: Icon(Icons.fastfood, color: Colors.grey[500], size: 32),
        );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback();

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      height: _imageHeight,
      width: _cardWidth,
      fit: BoxFit.cover,
      placeholder: (context, url) => fallback(),
      errorWidget: (context, url, error) => fallback(),
    );
  }
}

class _DiscountMealsShimmer extends StatelessWidget {
  const _DiscountMealsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeSectionHeader(title: 'Discount'),
          SizedBox(
            height: _railHeight(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: _cardWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
