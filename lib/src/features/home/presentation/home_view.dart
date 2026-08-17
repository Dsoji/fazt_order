import 'package:fazt_order/src/features/home/data/model/response/shops_model/result.dart';
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
import '../../../common/user_location_provider.dart';
import '../../../common/widgets/shimmer_restaurant_card.dart';
import '../../../common/widgets/text_styles.dart';
import '../../auth/data/model/response/user_model/promotion_state.dart';
import '../../bottom_sheets/filters_sheet.dart';
import '../../bottom_sheets/location_sheet.dart';
import '../../profile/data/controller/profile_controller.dart';
import '../data/controller/shop_controller.dart';
import '../data/model/response/shops_model/shop_extension.dart';
import 'search_restaurant_view.dart';
import 'widgets/discount_meals_section.dart';
import 'widgets/featured_restaurants_section.dart';
import '../../../common/widgets/app_refresh_indicator.dart';

final _promoDialogShownProvider = StateProvider<bool>((_) => false);

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? kcPrimary300 : kcPrimaryNeutral900,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: ktBodyRegularSize14.copyWith(
            color: isSelected ? kcWhite : kcPrimaryNeutral100,
          ),
        ),
      ),
    );
  }

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

    // valueOrNull, not value: on an AsyncError carrying no previous data
    // `value` rethrows the failure, which during build takes the whole home
    // screen down over a profile fetch that the rest of the page copes with.
    final promotionState = userDetails.valueOrNull?.user?.promotionState;

    useEffect(() {
      final freeDelivery = promotionState?.freeDeliveryRemaining ?? 0;
      final discount = promotionState?.discountRemaining ?? 0;
      if (freeDelivery <= 0 && discount <= 0) return null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (ref.read(_promoDialogShownProvider)) return;
        ref.read(_promoDialogShownProvider.notifier).state = true;
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (_) =>
              _PromotionAnnouncementDialog(promotionState: promotionState!),
        );
      });
      return null;
    }, [
      promotionState?.freeDeliveryRemaining,
      promotionState?.discountRemaining,
    ]);

    // The user's delivery address, restored from cache on launch. Null only
    // before they have ever set one, in which case the feed goes out unlocated
    // and is refetched by the effect below as soon as an address exists.
    final coordinates = ref.watch(effectiveCoordinatesProvider);
    final lat = coordinates?.lat;
    final lng = coordinates?.lng;

    // What the feed request fired on mount was built with. Only a change from
    // this is worth a refetch — on a warm launch the cached coordinates were
    // already on that first request.
    final feedCoordinates = useRef<Coordinates?>(coordinates);

    useEffect(() {
      if (lat == null || lng == null) return null;
      Future.microtask(() {
        if (feedCoordinates.value != coordinates) {
          feedCoordinates.value = coordinates;
          ref.read(shopControllerProvider.notifier).revalidateShops();
        }
        ref
            .read(shopControllerProvider.notifier)
            .fetchDiscountedMeals(lat: lat, lng: lng);
        ref
            .read(shopControllerProvider.notifier)
            .fetchFeaturedStores(lat: lat, lng: lng);
      });
      return null;
    }, [lat, lng]);

    final shops = ref.watch(shopControllerProvider).shops;
    final shopsHasMore =
        ref.watch(shopControllerProvider.select((s) => s.shopsHasMore));
    final isLoadingMoreShops =
        ref.watch(shopControllerProvider.select((s) => s.isLoadingMoreShops));
    final isFilterApplied = useState(false);
    final selectedFilter = useState<String?>(null);
    final scrollController = useScrollController();

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final position = scrollController.position;
        if (position.pixels >= position.maxScrollExtent - 300) {
          ref.read(shopControllerProvider.notifier).loadMoreShops();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    Future<void> handleRefresh() async {
      await ref.read(profileControllerProvider.notifier).fetchProfile();
      await ref.read(shopControllerProvider.notifier).revalidateShops();
      await ref.read(shopControllerProvider.notifier).fetchCart();
      await ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
      await ref.read(profileControllerProvider.notifier).fetchWallet();
      await ref.read(profileControllerProvider.notifier).fetchFavouritesList();
      if (lat != null && lng != null) {
        await ref
            .read(shopControllerProvider.notifier)
            .fetchDiscountedMeals(lat: lat, lng: lng, background: true);
        await ref
            .read(shopControllerProvider.notifier)
            .fetchFeaturedStores(lat: lat, lng: lng, background: true);
      }
    }

    // Promo rails sit above the restaurant list and only make sense on the
    // unfiltered feed.
    Widget promoSections() {
      if (selectedFilter.value != null) return const SizedBox.shrink();
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DiscountMealsSection(),
          FeaturedRestaurantsSection(),
        ],
      );
    }

    // Helper function to filter shops based on selected filter
    List<ShopResult> filterShops(List<ShopResult>? allShops) {
      if (allShops == null) return [];

      if (selectedFilter.value == null) {
        return allShops;
      }

      switch (selectedFilter.value) {
        case 'Open now':
          return allShops.where((shop) => shop.isOpenNow).toList();
        case 'Favourites':
          return allShops.where((shop) => shop.isLiked == true).toList();
        default:
          return allShops;
      }
    }

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
        actions: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              isFilterApplied.value = !isFilterApplied.value;
            },
            child: Row(
              children: [
                const Icon(
                  Iconsax.document_filter,
                  color: kcPrimary300,
                  size: 16,
                ),
                horizontalSpaceTiny,
                Text(
                  "Filter",
                  style: ktBodyRegularSize14.copyWith(color: kcPrimary300),
                ),
                horizontalSpaceSmall,
              ],
            ),
          )
        ],
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
          if (isFilterApplied.value) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (selectedFilter.value != null) ...[
                      horizontalSpaceSmall,
                      _buildFilterChip(
                        label: 'Reset',
                        isSelected: false,
                        onTap: () {
                          selectedFilter.value = null; // Clear all selections
                        },
                      ),
                    ],
                    horizontalSpaceSmall,
                    _buildFilterChip(
                      label: 'Open now',
                      isSelected: selectedFilter.value == 'Open now',
                      onTap: () {
                        if (selectedFilter.value == 'Open now') {
                          selectedFilter.value = null; // Reset
                        } else {
                          selectedFilter.value = 'Open now';
                        }
                        // Handle Open now filter logic here
                      },
                    ),
                    horizontalSpaceSmall,
                    _buildFilterChip(
                      label: 'Favourites',
                      isSelected: selectedFilter.value == 'Favourites',
                      onTap: () {
                        if (selectedFilter.value == 'Favourites') {
                          selectedFilter.value = null; // Reset
                        } else {
                          selectedFilter.value = 'Favourites';
                        }
                        // Handle Favourites filter logic here
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
          verticalSpace(15),

          // Restaurant List (Single ListView)
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: handleRefresh,
              child: shops.when(
                loading: () => shops.maybeWhen(
                  data: (data) {
                    final filteredShops = filterShops(data.results);
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: filteredShops.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) return promoSections();
                        final shop = filteredShops[index - 1];
                        return RestaurantCard(
                          restaurant: shop,
                          index: index - 1,
                        );
                      },
                    );
                  },
                  orElse: () => ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 11,
                    itemBuilder: (context, index) => index == 0
                        ? promoSections()
                        : const ShimmerRestaurantCard(),
                  ),
                ),
                error: (error, stackTrace) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    const SizedBox(height: 120),
                    Column(
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
                    const SizedBox(height: 120),
                  ],
                ),
                data: (shops) {
                  final filteredShops = filterShops(shops.results);
                  if (filteredShops.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      children: [
                        promoSections(),
                        const SizedBox(height: 80),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.search_normal_1,
                              color: kcPrimaryNeutral500,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              selectedFilter.value == 'Open now'
                                  ? 'No restaurants are open now'
                                  : selectedFilter.value == 'Favourites'
                                      ? 'No favourite restaurants found'
                                      : 'No restaurants found',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: kcPrimaryNeutral500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 120),
                      ],
                    );
                  }
                  final showFooter = !isFilterApplied.value &&
                      (isLoadingMoreShops || !shopsHasMore);
                  return ListView.builder(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredShops.length + 1 + (showFooter ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == 0) return promoSections();
                      final shopIndex = index - 1;
                      if (shopIndex >= filteredShops.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: isLoadingMoreShops
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: kcPrimary300,
                                    ),
                                  )
                                : Text(
                                    'No more shops',
                                    style: ktBodyRegularSize14.copyWith(
                                      color: kcPrimaryNeutral500,
                                    ),
                                  ),
                          ),
                        );
                      }
                      final shop = filteredShops[shopIndex];
                      return RestaurantCard(
                        restaurant: shop,
                        index: shopIndex,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const Gap(92),
        ],
      ),
    );
  }
}

class _PromotionAnnouncementDialog extends StatelessWidget {
  const _PromotionAnnouncementDialog({required this.promotionState});

  final PromotionState promotionState;

  @override
  Widget build(BuildContext context) {
    final freeDelivery = promotionState.freeDeliveryRemaining ?? 0;
    final discount = promotionState.discountRemaining ?? 0;
    final percent = promotionState.percentDiscount ?? 0;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close,
                    size: 20, color: kcPrimaryNeutral500),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'asset/gif/onboard3.gif',
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
            const Gap(16),
            Text(
              'You\'ve got perks!',
              style: ktBodySemiBoldSize20.copyWith(
                fontSize: 18,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(6),
            const Text(
              'Use them on your next orders before they run out.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: kcPrimaryNeutral500,
                height: 1.4,
              ),
            ),
            const Gap(16),
            if (freeDelivery > 0)
              _PerkRow(
                icon: Iconsax.truck_fast,
                accent: kcPrimary400,
                title: 'Free Delivery',
                subtitle: '$freeDelivery left',
              ),
            if (freeDelivery > 0 && discount > 0) const Gap(8),
            if (discount > 0)
              _PerkRow(
                icon: Iconsax.discount_shape,
                accent: kcPrimaryOrange300,
                title: percent > 0
                    ? '${percent.toStringAsFixed(0)}% Off'
                    : 'Discount',
                subtitle: '$discount left',
              ),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: kcPrimary400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerkRow extends StatelessWidget {
  const _PerkRow({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
