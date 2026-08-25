import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../common/app_colors.dart';
import '../../data/controller/shop_controller.dart';
import '../../data/model/response/featured_stores/featured_store.dart';
import '../../data/model/response/shops_model/result.dart';
import '../restaurant_details.dart';
import 'promo_tag_badge.dart';

const double _cardWidth = 150;
const double _imageHeight = 100;

/// A horizontal ListView hands its children a tight height, so the rail height
/// *is* the card height: too little overflows, too much leaves dead space under
/// the last row. Image and paddings are fixed; only the text block moves with
/// the user's font scale, so that is the part we scale.
double _railHeight(BuildContext context) {
  const chrome = 18.0 + 11.0; // 8/10 padding + the 6/5 gaps between rows
  const textBlock = 49.0; // name + rating + offer lines at 1.0 scale
  return _imageHeight +
      chrome +
      MediaQuery.textScalerOf(context).scale(textBlock);
}

/// Horizontal rail of restaurants running a store-wide promotion.
///
/// Renders nothing when nothing nearby is promoted — an empty list is a normal
/// response, not an error.
class FeaturedRestaurantsSection extends ConsumerWidget {
  const FeaturedRestaurantsSection({super.key, this.isLoggedIn = true});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured =
        ref.watch(shopControllerProvider.select((s) => s.featuredStores));
    final stores = featured.valueOrNull?.stores ?? const <FeaturedStore>[];

    if (stores.isEmpty) {
      if (featured.isLoading) return const _FeaturedRestaurantsShimmer();
      return const SizedBox.shrink();
    }

    /// The featured payload carries the store, not the shop. Match it against
    /// the loaded shops so the card can open the normal restaurant page.
    ShopResult? shopFor(FeaturedStore store) {
      final shops =
          ref.read(shopControllerProvider).shops.valueOrNull?.results ??
              const <ShopResult>[];
      for (final shop in shops) {
        if (store.id != null && shop.store?.id == store.id) return shop;
      }
      final name = store.storeName?.trim().toLowerCase();
      if (name == null || name.isEmpty) return null;
      for (final shop in shops) {
        if (shop.store?.storeName?.trim().toLowerCase() == name) return shop;
      }
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeSectionHeader(
            title: 'Featured',
            subtitle: 'Store-wide offers on every order',
          ),
          SizedBox(
            height: _railHeight(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: stores.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final store = stores[index];
                return _FeaturedStoreCard(
                  store: store,
                  // Display only — the match is resolved again on tap, since
                  // the shops list may still be loading while this rail draws.
                  deliveryFee: shopFor(store)?.deliveryFee,
                  onTap: () {
                    final shop = shopFor(store);
                    if (shop == null) {
                      Fluttertoast.showToast(
                        msg:
                            '${store.storeName ?? 'This restaurant'} is not available at your location right now',
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.orangeAccent,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => RestaurantDetailsView(
                          restaurant: shop,
                          isLoggedIn: isLoggedIn,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The line under the rating. It always resolves to something: a blank row on
/// one card would put back the dead space the rail height used to leave, and
/// every store on this rail has a store-wide offer to fall back on describing.
({IconData icon, String text}) _storeMeta(FeaturedStore store, num? deliveryFee) {
  final promotion = store.promotionDisplay;
  if (promotion?.freeDelivery == true) {
    return (icon: Iconsax.truck_fast, text: 'Free delivery');
  }
  final cap = promotion?.maxDiscountAmount ?? 0;
  if (cap > 0) {
    return (
      icon: Iconsax.discount_shape,
      text: 'Up to ₦${cap.toStringAsFixed(0)} off',
    );
  }
  final percent = promotion?.discountPercent ?? 0;
  if (percent > 0) {
    return (
      icon: Iconsax.discount_shape,
      text: '${percent.toStringAsFixed(0)}% off all orders',
    );
  }
  if (deliveryFee != null) {
    return (
      icon: Iconsax.truck_fast,
      text: '₦${deliveryFee.toStringAsFixed(0)} delivery',
    );
  }
  return (icon: Iconsax.shop, text: 'Offer running now');
}

class _FeaturedStoreCard extends StatelessWidget {
  const _FeaturedStoreCard({
    required this.store,
    required this.onTap,
    this.deliveryFee,
  });

  final FeaturedStore store;
  final VoidCallback onTap;
  final num? deliveryFee;

  @override
  Widget build(BuildContext context) {
    final tag =
        promotionTagText(store.promotionDisplay, tag: store.promotionTag);
    final rating = store.rating;
    final meta = _storeMeta(store, deliveryFee);

    return GestureDetector(
      onTap: onTap,
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
                _StoreImage(imageUrl: store.storeDisplayImage),
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
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.storeName ?? store.businessName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Iconsax.star1,
                          size: 12, color: kcPrimaryOrange700),
                      const SizedBox(width: 4),
                      Text(
                        rating == null ? '--' : rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: kcPrimaryNeutral400,
                        ),
                      ),
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

class _StoreImage extends StatelessWidget {
  const _StoreImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
          height: _imageHeight,
          width: _cardWidth,
          color: Colors.grey[200],
          child: Icon(Icons.storefront, color: Colors.grey[500], size: 32),
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

class _FeaturedRestaurantsShimmer extends StatelessWidget {
  const _FeaturedRestaurantsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeSectionHeader(title: 'Featured'),
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
