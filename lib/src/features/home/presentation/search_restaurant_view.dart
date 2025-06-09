import 'package:fazt_order/src/common/widgets/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../providers/restaurant_provider.dart';
import '../../../common/app_colors.dart';
import '../../../common/components/restaurant_search_card.dart';
import '../../../common/ui_helpers.dart';

// Providers for search query and filter state
final searchQueryProvider = StateProvider<String>((ref) => "");
final selectedFilterProvider = StateProvider<String>((ref) => "ALL");

class SearchRestaurantView extends ConsumerStatefulWidget {
  final String initialQuery;

  const SearchRestaurantView({super.key, required this.initialQuery});

  @override
  _SearchRestaurantViewState createState() => _SearchRestaurantViewState();
}

class _SearchRestaurantViewState extends ConsumerState<SearchRestaurantView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the search query with the initial query
    _searchController.text = widget.initialQuery;
    ref.read(searchQueryProvider.notifier).state = widget.initialQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(restaurantProvider);
    final query = ref.watch(searchQueryProvider);
    final selectedFilter = ref.watch(selectedFilterProvider);

    // Filter restaurants based on the query
    final filteredRestaurants = restaurants
        .asMap()
        .entries
        .where((entry) =>
            entry.value.name.toLowerCase().contains(query.toLowerCase()))
        .map((entry) => MapEntry(entry.key, entry.value))
        .toList();

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
              const Text(
                'Computer Village',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                hintText: "Search for restaurants",
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Iconsax.close_circle,
                            color: kcPrimaryRed200, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = "";
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
          // Filter Tabs
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                FilterTab("ALL"),
                horizontalSpace(8),
                FilterTab("Restaurant"),
                horizontalSpace(8),
                FilterTab("Menu"),
              ],
            ),
          ),
          // Result Count or No Results Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: filteredRestaurants.isEmpty
                ? Text(
                    "0 result for $query",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  )
                : Text(
                    "${filteredRestaurants.length} results for $query",
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
          ),
          // Restaurant List
          Expanded(
            child: filteredRestaurants.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        SvgPicture.asset("asset/svgs/no_result.svg"),
                        verticalSpaceSmall,
                        const Text(
                          "No result found",
                          style: TextStyle(
                              fontSize: 16, color: kcPrimaryNeutral200),
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
                  )
                : ListView.builder(
                    // padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemCount: filteredRestaurants.length,
                    itemBuilder: (context, index) {
                      final entry = filteredRestaurants[index];
                      final originalIndex =
                          entry.key; // Original index in restaurantProvider
                      final restaurant = entry.value;
                      return RestaurantSearchCard(
                        restaurant: restaurant,
                        index: originalIndex, // Pass the original index
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget FilterTab(String title) {
    final isSelected = ref.watch(selectedFilterProvider) == title;
    return GestureDetector(
      onTap: () {
        ref.read(selectedFilterProvider.notifier).state = title;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kcPrimary300 : kcWhite,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: kcPrimary700, width: 1),
        ),
        child: Text(
          title,
          style: ktBodyRegularSize12.copyWith(
            color: isSelected ? Colors.white : kcPrimary400,
          ),
        ),
      ),
    );
  }
}
