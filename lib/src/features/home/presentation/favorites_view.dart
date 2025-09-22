import 'package:fazt_order/src/common/widgets/shimmer_restaurant_card.dart';
import 'package:fazt_order/src/features/home/data/model/response/shops_model/result.dart';
import 'package:fazt_order/src/features/home/data/model/response/shops_model/location.dart'
    as shops_location;
import 'package:fazt_order/src/features/home/data/model/response/shops_model/store.dart'
    as shops_store;
import 'package:fazt_order/src/features/profile/data/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
      body: favouritesAsync.when(
        data: (resp) {
          final shops = resp.shops ?? [];
          if (shops.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final fav = shops[index];
              final shopResult = ShopResult(
                id: fav.id,
                shopName: fav.shopName,
                manager: fav.manager,
                phone: fav.phone,
                numberOfFavorites: fav.numberOfFavorites,
                rating: (fav.rating is int)
                    ? fav.rating as int
                    : (fav.rating?.toInt()),
                deliveryFee: (fav.deliveryFee is int)
                    ? fav.deliveryFee as int
                    : (fav.deliveryFee?.toInt()),
                createdAt: fav.createdAt,
                updatedAt: fav.updatedAt,
                location: shops_location.Location(
                  type: fav.location?.type,
                  coordinates: fav.location?.coordinates,
                  address: fav.location?.address,
                  state: fav.location?.state,
                  city: fav.location?.city,
                ),
                store: shops_store.Store(
                  storeDisplayImage: fav.store?.storeDisplayImage,
                  storeName: fav.store?.storeName,
                  id: fav.store?.id,
                ),
              );
              return RestaurantCard(
                restaurant: shopResult,
                index: index,
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: 10,
          itemBuilder: (context, index) => const ShimmerRestaurantCard(),
        ),
        error: (e, _) => Center(
          child: Text(
            'Failed to load favorites',
            style: ktBodySemiBoldSize20,
          ),
        ),
      ),
    );
  }
}
