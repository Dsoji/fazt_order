import 'package:fazt_order/src/common/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../profile/data/controller/profile_controller.dart';
import '../data/controller/shop_controller.dart';
import '../data/model/response/search_global/meal.dart';
import '../data/model/response/search_global/search_global.dart';
import '../data/model/response/search_global/shop.dart';

// Providers for search query and filter state
final searchQueryProvider = StateProvider<String>((ref) => "");
final selectedFilterProvider = StateProvider<String>((ref) => "ALL");

class SearchRestaurantView extends HookConsumerWidget {
  final String initialQuery;

  const SearchRestaurantView({super.key, required this.initialQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final query = ref.watch(searchQueryProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);
    final tabController = useTabController(initialLength: 3);

    // Initialize the search query with the initial query
    useEffect(() {
      searchController.text = initialQuery;
      Future.microtask(() {
        ref.read(searchQueryProvider.notifier).state = initialQuery;
      });
      return null;
    }, []);

    // Watch the global search results
    final searchResults = ref.watch(shopControllerProvider).searchQuery;

    // Trigger global search when query changes
    useEffect(() {
      if (query.isNotEmpty) {
        // You might want to get actual latitude and longitude from user location
        const latitude = "6.5244"; // Default to Lagos coordinates
        const longitude = "3.3792";
        Future.microtask(() {
          ref.read(shopControllerProvider.notifier).globalSearch(
                query,
                latitude,
                longitude,
              );
        });
      }
      return null;
    }, [query]);

    // Listen to tab changes
    useEffect(() {
      void listener() {
        final tabIndex = tabController.index;
        final filterOptions = ["ALL", "Restaurant", "Menu"];
        Future.microtask(() {
          ref.read(selectedFilterProvider.notifier).state =
              filterOptions[tabIndex];
        });
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    final userDetails =
        ref.watch(profileControllerProvider).userDetails.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            // Navigate back to HomeView or show location bottom sheet
            Navigator.pop(context);
          },
          child: Row(
            children: [
              const Icon(Iconsax.location, color: kcPrimary400),
              horizontalSpaceTiny,
              Text(
                (userDetails?.user?.location?.address ?? 'Location Unknown')
                            .length >
                        12
                    ? '${(userDetails?.user?.location?.address ?? 'Location Unknown').substring(0, 12)}...'
                    : (userDetails?.user?.location?.address ??
                        'Location Unknown'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
            onTap: () {},
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                hintText: "Search for restaurants and meals",
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Iconsax.close_circle,
                            color: kcPrimaryRed200, size: 20),
                        onPressed: () {
                          searchController.clear();
                          ref
                              .read(shopControllerProvider.notifier)
                              .globalSearch(
                                query,
                                userDetails?.user?.location?.coordinates?[1] ??
                                    '0',
                                userDetails?.user?.location?.coordinates?[0] ??
                                    '0',
                              );
                        },
                      ),
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(
                        Iconsax.search_normal,
                        color: kcPrimary500,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: kcPrimary400, width: 1),
                ),
                filled: true,
                fillColor: kcPrimary980,
              ),
              onChanged: (value) {
                // Update the search query in real-time
                ref.read(searchQueryProvider.notifier).state = value;
                // Navigate back if the search bar is empty
                if (value.isEmpty) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: kcPrimaryNeutral900,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: tabController,
              indicator: BoxDecoration(
                color: kcPrimary300,
                borderRadius: BorderRadius.circular(25),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: kcPrimaryNeutral200,
              labelStyle: ktBodyRegularSize12.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: ktBodyRegularSize12,
              tabs: const [
                Tab(text: "ALL"),
                Tab(text: "Restaurant"),
                Tab(text: "Menu"),
              ],
            ),
          ),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                // ALL Tab
                _buildAllTab(searchResults, query, context),
                // Restaurant Tab
                _buildRestaurantTab(searchResults, query, context),
                // Menu Tab
                _buildMenuTab(searchResults, query, context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTab(AsyncValue<SearchGlobal> searchResults, String query,
      BuildContext context) {
    return searchResults.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => _buildErrorWidget(error, query),
      data: (searchGlobal) {
        final shops = searchGlobal.shops ?? [];
        final meals = searchGlobal.meals ?? [];

        // Create a combined list with type information
        final List<MapEntry<String, dynamic>> allResults = [];

        // Add shops with type identifier
        for (int i = 0; i < shops.length; i++) {
          allResults.add(MapEntry('shop', shops[i]));
        }

        // Add meals with type identifier
        for (int i = 0; i < meals.length; i++) {
          allResults.add(MapEntry('meal', meals[i]));
        }

        if (allResults.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            _buildResultCount(allResults.length, query),
            Expanded(
              child: ListView.builder(
                itemCount: allResults.length,
                itemBuilder: (context, index) {
                  final result = allResults[index];
                  final item = result.value;
                  final type = result.key;

                  if (type == 'shop' && item is Shop) {
                    return _buildShopResult(item, index);
                  } else if (type == 'meal' && item is Meal) {
                    return _buildMealResult(item, index);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRestaurantTab(AsyncValue<SearchGlobal> searchResults,
      String query, BuildContext context) {
    return searchResults.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => _buildErrorWidget(error, query),
      data: (searchGlobal) {
        final shops = searchGlobal.shops ?? [];

        if (shops.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            _buildResultCount(shops.length, query),
            Expanded(
              child: ListView.builder(
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  return _buildShopResult(shops[index], index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuTab(AsyncValue<SearchGlobal> searchResults, String query,
      BuildContext context) {
    return searchResults.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => _buildErrorWidget(error, query),
      data: (searchGlobal) {
        final meals = searchGlobal.meals ?? [];

        if (meals.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            _buildResultCount(meals.length, query),
            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  return _buildMealResult(meals[index], index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultCount(int count, String query) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Text(
        "$count results for $query",
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildErrorWidget(Object error, String query) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Error searching, please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset("asset/svgs/no_result.svg"),
          verticalSpaceSmall,
          const Text(
            "No result found",
            style: TextStyle(fontSize: 16, color: kcPrimaryNeutral200),
          ),
          verticalSpaceTiny,
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            behavior: HitTestBehavior.translucent,
            child: RichText(
              text: const TextSpan(
                text: 'Explore other Options',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: kcPrimary400,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopResult(Shop shop, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              shop.store?.storeDisplayImage ?? 'asset/images/placeholder.png',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.store, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop.store?.storeName ?? 'Unknown Store',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shop.location?.address ?? 'No address available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealResult(Meal meal, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              meal.store?.storeDisplayImage ?? 'asset/images/placeholder.png',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meal from ${meal.shop?.store?.storeName ?? 'Unknown Store'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meal.shop?.location?.address ?? 'No address available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
