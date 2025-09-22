import 'package:fazt_order/src/common/app_colors.dart';
import 'package:fazt_order/src/features/home/presentation/restaurant_details.dart';
import 'package:fazt_order/src/features/profile/data/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../providers/restaurant_provider.dart';
import '../../features/home/data/model/response/shops_model/result.dart';

class RestaurantCard extends ConsumerWidget {
  final ShopResult restaurant;
  final int index;

  const RestaurantCard(
      {super.key, required this.restaurant, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailsView(restaurant: restaurant),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        shadowColor: Colors.white.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: Image.network(
                      restaurant.store?.storeDisplayImage ?? '',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.white,
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
                      Expanded(
                        child: Text(
                          "${restaurant.store?.storeName ?? ''} (${restaurant.shopName ?? ''})",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          await ref
                              .read(profileControllerProvider.notifier)
                              .addToFavorites(shopId: restaurant.id ?? '');
                          await ref
                              .read(profileControllerProvider.notifier)
                              .fetchFavouritesList();
                        },
                        child: const Icon(Iconsax.heart,
                            color: kcPrimaryNeutral200, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${restaurant.location?.address ?? ''}, ${restaurant.location?.city ?? ''}, ${restaurant.location?.state ?? ''} state.",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Iconsax.star1,
                              color: kcPrimaryOrange700, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "${restaurant.rating} (${restaurant.numberOfFavorites})",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_offer,
                              size: 16, color: kcPrimaryNeutral200),
                          const SizedBox(width: 4),
                          Text(
                            "From ₦${restaurant.deliveryFee}",
                            style: const TextStyle(
                                fontSize: 14, color: kcPrimaryNeutral200),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // if (restaurant.isAvailable)
                      //   Container(
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 8, vertical: 4),
                      //     decoration: BoxDecoration(
                      //       color: kcPrimaryOrange500,
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     child: Text(
                      //       restaurant.deliveryTime,
                      //       style:
                      //           const TextStyle(fontSize: 12, color: kcWhite),
                      //     ),
                      //   ),
                      // if (!restaurant.isAvailable)
                      //   Container(
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 8, vertical: 4),
                      //     decoration: BoxDecoration(
                      //       color: Colors.red[50],
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     child: const Text(
                      //       "Unavailable",
                      //       style: TextStyle(fontSize: 12, color: Colors.red),
                      //     ),
                      //   ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
