import 'package:fazt_order/src/common/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../datamodels/restaurant.dart';
import '../../../providers/restaurant_provider.dart';

class RestaurantCard extends ConsumerWidget {
  final Restaurant restaurant;
  final int index;

  const RestaurantCard({Key? key, required this.restaurant, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  child: Image.asset(
                    restaurant.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        ref.read(restaurantProvider.notifier).toggleFavorite(index);
                      },
                      // child: Icon(Iconsax.heart, color: restaurant.isFavorite ? Colors.red : kcPrimaryNeutral200, size: 24),
                      child: restaurant.isFavorite
                          ? const Icon(Iconsax.heart5, color: kcPrimaryRed300, size: 24)
                          : const Icon(Iconsax.heart, color: kcPrimaryNeutral200, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      restaurant.location,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    Row(
                      children: [
                        const Icon(Iconsax.star1, color: kcPrimaryOrange700, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${restaurant.rating} (${restaurant.reviewCount})",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_offer, size: 16, color: kcPrimaryNeutral200),
                        const SizedBox(width: 4),
                        Text(
                          "From ₦${restaurant.price}",
                          style: const TextStyle(fontSize: 14, color: kcPrimaryNeutral200),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (restaurant.isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kcPrimaryOrange500,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          restaurant.deliveryTime,
                          style: const TextStyle(fontSize: 12, color: kcWhite),
                        ),
                      ),
                    if (!restaurant.isAvailable)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Unavailable",
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}