import 'package:fazt_order/src/features/home/data/model/response/shops_model/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../providers/restaurant_provider.dart';
import '../../../common/app_colors.dart';
import '../../../common/components/restaurant_card.dart';
import '../../../common/widgets/text_styles.dart';

class FavoritesView extends ConsumerWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the list of restaurants and filter for favorites
    final restaurants = ref.watch(restaurantProvider);
    final favoriteRestaurants =
        restaurants.where((restaurant) => restaurant.isFavorite).toList();

    return Scaffold(
      backgroundColor: kcPrimaryNeutral950,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Favorites",
          style: ktBodySemiBoldSize20.copyWith(
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: kcPrimaryNeutral950,
        elevation: 0,
      ),
      body: favoriteRestaurants.isEmpty
          ? Center(
              child: Text(
                "No favorite restaurants yet.",
                style: ktBodyRegularSize12.copyWith(
                  color: kcPrimaryNeutral500,
                  fontSize: 16,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favoriteRestaurants.length,
              itemBuilder: (context, index) {
                final restaurant = favoriteRestaurants[index];
                // Find the original index in the full restaurant list for toggling favorite
                final originalIndex = restaurants.indexOf(restaurant);
                return RestaurantCard(
                  restaurant: ShopResult(),
                  index: originalIndex,
                );
              },
            ),
    );
  }
}
