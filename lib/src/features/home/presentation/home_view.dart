import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../providers/restaurant_provider.dart';
import '../../../common/app_colors.dart';
import '../../../common/components/restaurant_card.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/widgets/shimmer_restaurant_card.dart';
import '../../bottom_sheets/filters_sheet.dart';
import '../../bottom_sheets/location_sheet.dart';
import '../../profile/data/controller/profile_controller.dart';
import '../data/controller/shop_controller.dart';
import 'search_restaurant_view.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void showLocationBottomSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return const LocationBottomSheet();
        },
      );
    }

    void showFilterBottomSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return const FilterBottomSheet();
        },
      );
    }

    // Access the list of restaurants
    final restaurants = ref.watch(restaurantProvider);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(profileControllerProvider.notifier).fetchProfile();
        ref.read(shopControllerProvider.notifier).revalidateShops();
        ref.read(shopControllerProvider.notifier).fetchCart();
        ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
        ref.read(profileControllerProvider.notifier).fetchWallet();
        ref.read(profileControllerProvider.notifier).fetchTransactionHistory();
        ref.read(profileControllerProvider.notifier).fetchFavouritesList();
        // ref.read(profileControllerProvider.notifier).fetchStoreDetails();
        // ref.read(profileControllerProvider.notifier).listManager();
        // ref.read(mealControllerProvider.notifier).fetchMealCategory();
      });
      return null;
    }, []);

    String truncateWithEllipsis(int cutoff, String text) {
      return (text.length <= cutoff) ? text : '${text.substring(0, cutoff)}...';
    }

    final userDetails = ref.watch(profileControllerProvider).userDetails;

    final shops = ref.watch(shopControllerProvider).shops;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            showLocationBottomSheet(context);
          },
          child: Row(
            children: [
              const Icon(Iconsax.location, color: kcPrimary400),
              horizontalSpaceTiny,
              userDetails.maybeWhen(
                loading: () => userDetails.hasValue
                    ? Text(
                        truncateWithEllipsis(
                            25,
                            userDetails.value?.user?.location?.address ??
                                'Your Location'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors
                              .grey, // Slightly dimmed to indicate loading
                        ),
                      )
                    : const Text(
                        'Loading location...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                error: (error, stackTrace) => userDetails.hasValue
                    ? Text(
                        truncateWithEllipsis(
                            25,
                            userDetails.value?.user?.location?.address ??
                                'Your Location'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors
                              .red, // Red tint to indicate error but show cached data
                        ),
                      )
                    : const Text(
                        'Your Location',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                orElse: () => Text(
                  truncateWithEllipsis(
                      25,
                      userDetails.valueOrNull?.user?.location?.address ??
                          'Your Location'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              horizontalSpaceTiny,
              SvgPicture.asset(
                'asset/svgs/arrow-down.svg',
                color: kcPrimaryNeutral200,
              ),
            ],
          ),
        ),
        // actions: [
        //   GestureDetector(
        //     behavior: HitTestBehavior.translucent,
        //     onTap: () {
        //       showFilterBottomSheet(context);
        //     },
        //     child: Row(
        //       children: [
        //         const Icon(
        //           Iconsax.document_filter,
        //           color: kcPrimary300,
        //           size: 16,
        //         ),
        //         horizontalSpaceTiny,
        //         Text(
        //           "Filter",
        //           style: ktBodyRegularSize14.copyWith(color: kcPrimary300),
        //         ),
        //         horizontalSpaceSmall,
        //       ],
        //     ),
        //   )
        // ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) {
                if (value.isNotEmpty) {
                  // Reset the search query provider
                  ref.read(searchQueryProvider.notifier).state = value;
                  // Navigate to SearchRestaurantScreen with the query
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchRestaurantView(initialQuery: value),
                    ),
                  );
                }
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                hintText: 'Search',
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: const Icon(
                  Iconsax.search_normal_1,
                  color: kcPrimaryNeutral500,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: kcPrimaryNeutral900,
              ),
            ),
          ),
          verticalSpace(15),
          // Restaurant List (Single ListView)
          Expanded(
            child: shops.when(
              loading: () => shops.maybeWhen(
                data: (data) => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: data.results?.length ?? 0,
                  itemBuilder: (context, index) {
                    final shop = data.results![index];
                    return RestaurantCard(
                      restaurant: shop,
                      index: index,
                    );
                  },
                ),
                orElse: () => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: 10,
                  itemBuilder: (context, index) =>
                      const ShimmerRestaurantCard(),
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
                        ref
                            .read(shopControllerProvider.notifier)
                            .revalidateShops();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (shops) => RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(profileControllerProvider.notifier)
                      .fetchProfile();
                  await ref
                      .read(shopControllerProvider.notifier)
                      .revalidateShops();

                  await ref.read(shopControllerProvider.notifier).fetchCart();
                  await ref
                      .read(shopControllerProvider.notifier)
                      .fetchMyOrdersList();
                  await ref
                      .read(profileControllerProvider.notifier)
                      .fetchWallet();
                  await ref
                      .read(profileControllerProvider.notifier)
                      .fetchFavouritesList();
                  await ref
                      .read(shopControllerProvider.notifier)
                      .revalidateShops();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: shops.results?.length ?? 0,
                  itemBuilder: (context, index) {
                    final shop = shops.results![index];
                    return RestaurantCard(
                      restaurant: shop,
                      index: index,
                    );
                  },
                ),
              ),
            ),
          ),
          const Gap(92),
        ],
      ),
    );
  }
}
