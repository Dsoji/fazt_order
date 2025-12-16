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
import '../../../common/widgets/shimmer_restaurant_card.dart';
import '../../../common/widgets/text_styles.dart';
import '../../bottom_sheets/filters_sheet.dart';
import '../../bottom_sheets/location_sheet.dart';
import '../../profile/data/controller/profile_controller.dart';
import '../data/controller/shop_controller.dart';
import '../data/model/response/shops_model/day_schedule.dart';
import 'search_restaurant_view.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  // Helper function to get the current day's schedule
  DaySchedule? _getCurrentDaySchedule(ShopResult shop) {
    final schedule = shop.store?.salesOperation?.schedule;
    if (schedule == null) return null;

    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday

    switch (weekday) {
      case 1:
        return schedule.monday;
      case 2:
        return schedule.tuesday;
      case 3:
        return schedule.wednesday;
      case 4:
        return schedule.thursday;
      case 5:
        return schedule.friday;
      case 6:
        return schedule.saturday;
      case 7:
        return schedule.sunday;
      default:
        return null;
    }
  }

  // Helper function to check if restaurant is currently open based on schedule
  bool _isRestaurantOpen(ShopResult shop) {
    // Emergency override: explicit false always closes
    if (shop.isOpen == false) {
      return false;
    }

    // Check if schedule exists at all
    final schedule = shop.store?.salesOperation?.schedule;

    // If no schedule object exists at all, fall back to shop.isOpen flag
    if (schedule == null) {
      // If shop.isOpen is explicitly true, return true
      // If shop.isOpen is null, default to true (open by default)
      return shop.isOpen ?? true;
    }

    // Otherwise, check the schedule
    final currentDaySchedule = _getCurrentDaySchedule(shop);

    // If no schedule exists for current day, fall back to shop.isOpen flag
    if (currentDaySchedule == null) {
      // If shop.isOpen is explicitly true, return true
      // If shop.isOpen is null, default to true (open by default)
      return shop.isOpen ?? true;
    }

    // If schedule exists but day is marked closed
    if (currentDaySchedule.open != true) {
      return false;
    }

    final timeSlots = currentDaySchedule.time;

    // Day open with no time slots: open all day
    // When schedule says open:true and time array is empty, shop is open all day
    // This takes precedence - if schedule says open, respect it
    if (timeSlots == null || timeSlots.isEmpty) {
      return true;
    }

    // Helper function to extract time from ISO string as Duration
    Duration? clockFromIso(String iso) {
      try {
        // Parse as UTC DateTime first, then convert to local time
        // This handles cases where times are stored in UTC but represent local business hours
        final dateTime = DateTime.parse(iso).toLocal();
        return Duration(
            hours: dateTime.hour,
            minutes: dateTime.minute,
            seconds: dateTime.second);
      } catch (e) {
        // Fallback: try parsing as plain time (ignore timezone)
        try {
          final timePart = iso.split('T').last.replaceAll('Z', '');
          final segments = timePart.split(':');
          if (segments.length < 2) return null;
          final h = int.parse(segments[0]);
          final m = int.parse(segments[1]);
          final s =
              segments.length > 2 ? int.parse(segments[2].split('.').first) : 0;
          return Duration(hours: h, minutes: m, seconds: s);
        } catch (e2) {
          return null;
        }
      }
    }

    final now = DateTime.now();
    // Use local clock to compare against clock-only slot times
    final nowClock =
        Duration(hours: now.hour, minutes: now.minute, seconds: now.second);

    var hasValidSlot = false;

    for (final timeSlot in timeSlots) {
      if (timeSlot.startTime == null || timeSlot.endTime == null) continue;

      final start = clockFromIso(timeSlot.startTime!);
      final end = clockFromIso(timeSlot.endTime!);
      if (start == null || end == null) continue;

      hasValidSlot = true;
      final crossesMidnight = end <= start;

      // For same-day ranges: current time must be >= start AND < end (exclusive end)
      // For overnight ranges: current time must be >= start OR < end
      final inSameDayRange =
          !crossesMidnight && nowClock >= start && nowClock < end;
      final inOvernightRange =
          crossesMidnight && (nowClock >= start || nowClock < end);

      if (inSameDayRange || inOvernightRange) {
        return true;
      }
    }

    // We had slots but none matched; treat as closed
    if (hasValidSlot) return false;

    // Slots list existed but all invalid
    return false;
  }

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

    final shops = ref.watch(shopControllerProvider).shops;
    final isFilterApplied = useState(false);
    final selectedFilter = useState<String?>(null);
    Future<void> handleRefresh() async {
      await ref.read(profileControllerProvider.notifier).fetchProfile();
      await ref.read(shopControllerProvider.notifier).revalidateShops();
      await ref.read(shopControllerProvider.notifier).fetchCart();
      await ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
      await ref.read(profileControllerProvider.notifier).fetchWallet();
      await ref.read(profileControllerProvider.notifier).fetchFavouritesList();
    }

    // Helper function to filter shops based on selected filter
    List<ShopResult> filterShops(List<ShopResult>? allShops) {
      if (allShops == null) return [];

      if (selectedFilter.value == null) {
        return allShops;
      }

      switch (selectedFilter.value) {
        case 'Open now':
          return allShops.where((shop) => _isRestaurantOpen(shop)).toList();
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
            child: RefreshIndicator(
              onRefresh: handleRefresh,
              child: shops.when(
                loading: () => shops.maybeWhen(
                  data: (data) {
                    final filteredShops = filterShops(data.results);
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: filteredShops.length,
                      itemBuilder: (context, index) {
                        final shop = filteredShops[index];
                        return RestaurantCard(
                          restaurant: shop,
                          index: index,
                        );
                      },
                    );
                  },
                  orElse: () => ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 10,
                    itemBuilder: (context, index) =>
                        const ShimmerRestaurantCard(),
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
                        const SizedBox(height: 120),
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
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredShops.length,
                    itemBuilder: (context, index) {
                      final shop = filteredShops[index];
                      return RestaurantCard(
                        restaurant: shop,
                        index: index,
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
