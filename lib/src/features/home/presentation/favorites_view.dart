import 'package:fazt_order/src/common/widgets/shimmer_restaurant_card.dart';
import 'package:fazt_order/src/features/home/data/controller/shop_controller.dart';
import 'package:fazt_order/src/features/profile/data/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/app_colors.dart';
import '../../../common/components/restaurant_card.dart';
import '../../../common/widgets/text_styles.dart';

class FavoritesView extends HookConsumerWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favouritesAsync = ref.watch(profileControllerProvider).favouritesList;

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final value = ref.read(profileControllerProvider).favouritesList;
        final hasData =
            value.hasValue && (value.value?.shops?.isNotEmpty ?? false);
        if (!value.isLoading && !hasData) {
          ref.read(profileControllerProvider.notifier).fetchFavouritesList();
        }
      });
      return null;
    }, const []);
    final shops = ref.watch(shopControllerProvider).shops;

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
      body: Expanded(
        child: shops.when(
          loading: () => shops.maybeWhen(
            data: (data) {
              final likedShops = data.results?.where((shop) => shop.isLiked == true).toList() ?? [];
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: likedShops.length,
                itemBuilder: (context, index) {
                  final shop = likedShops[index];
                  return RestaurantCard(
                    restaurant: shop,
                    index: index,
                  );
                },
              );
            },
            orElse: () => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 10,
              itemBuilder: (context, index) => const ShimmerRestaurantCard(),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading shops: ${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(shopControllerProvider.notifier).fetchShops();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (shops) => RefreshIndicator(
            onRefresh: () async {
              await ref.read(profileControllerProvider.notifier).fetchProfile();
              await ref.read(shopControllerProvider.notifier).fetchShops();
              await ref.read(shopControllerProvider.notifier).fetchCart();
              await ref
                  .read(shopControllerProvider.notifier)
                  .fetchMyOrdersList();
              await ref.read(profileControllerProvider.notifier).fetchWallet();
              await ref
                  .read(profileControllerProvider.notifier)
                  .fetchFavouritesList();
              await ref.read(shopControllerProvider.notifier).fetchShops();
            },
            child: shops.results?.where((shop) => shop.isLiked == true).isEmpty == true
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No favorites yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the heart icon on restaurants to add them to favorites',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: shops.results?.where((shop) => shop.isLiked == true).length ?? 0,
                    itemBuilder: (context, index) {
                      final likedShops = shops.results?.where((shop) => shop.isLiked == true).toList() ?? [];
                      final shop = likedShops[index];
                      return RestaurantCard(
                        restaurant: shop,
                        index: index,
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
