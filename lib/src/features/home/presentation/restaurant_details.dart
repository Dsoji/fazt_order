import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../datamodels/menu_items.dart';
import '../../../common/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/widgets/text_styles.dart';
import '../../order/checkout_view.dart';
import '../data/model/response/shops_model/result.dart';

class RestaurantDetailsView extends ConsumerStatefulWidget {
  final ShopResult restaurant;

  const RestaurantDetailsView({
    super.key,
    required this.restaurant,
  });

  @override
  ConsumerState<RestaurantDetailsView> createState() =>
      _RestaurantDetailsViewState();
}

class _RestaurantDetailsViewState extends ConsumerState<RestaurantDetailsView> {
  String _selectedCategory = "All";
  final List<MenuItem> _selectedItems = []; // Track selected items

  @override
  Widget build(BuildContext context) {
    // Filter menu items based on the selected category (for simplicity, we'll show all items for now)
    final restaurant = widget.restaurant;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Iconsax.arrow_left_2),
        ),
        title: Text(
          "Details",
          style: ktBodySemiBoldSize20.copyWith(fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal, color: kcBlack),
            onPressed: () {
              // Implement search functionality if needed
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Header Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.network(
              restaurant.store?.storeDisplayImage ??
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjzZwJLYpHj9aghuqOmOuLUjpqMT2yrfmQhw&s',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          // Draggable Scrollable Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.75,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: kcWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // Restaurant Name and Location
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.store?.storeName ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Iconsax.heart5,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                // final restaurants =
                                //     ref.read(restaurantProvider);
                                // final index = restaurants.indexWhere(
                                //   (r) =>
                                //       r.name == widget.restaurant.name &&
                                //       r.location == widget.restaurant.location,
                                // );
                                // if (index != -1) {
                                //   ref
                                //       .read(restaurantProvider.notifier)
                                //       .toggleFavorite(index);
                                // }
                              },
                            ),
                          ],
                        ),
                        verticalSpace(1),
                        // Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Iconsax.location,
                                  color: kcPrimaryNeutral500,
                                ),
                                Text(
                                  restaurant.location?.address ?? '',
                                  style: ktBodyRegularSize12.copyWith(
                                      color: kcPrimaryNeutral500),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: kcPrimaryOrange700,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${restaurant.rating} (${restaurant.numberOfFavorites})",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kcPrimaryNeutral500,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        horizontalSpace(8),
                        // Price and Delivery Time
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                    'asset/svgs/delivery_icon.svg'),
                                horizontalSpaceTiny,
                                Text(
                                  "From ₦${restaurant.deliveryFee}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: kcPrimaryOrange500,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '5 minutes',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: kcWhite,
                                ),
                              ),
                            ),
                          ],
                        ),
                        verticalSpaceSmall,
                        SvgPicture.asset('asset/svgs/dotted_line.svg'),
                        verticalSpaceSmall,
                        const SizedBox(height: 8),
                        // Opening Hours and Delivery Type
                        Row(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Colors.grey[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  "OPENING UNTIL 2PM", //TODO: get opening time
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: kcPrimaryNeutral400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                SvgPicture.asset(
                                    'asset/svgs/delivery_icon.svg'),
                                const SizedBox(width: 4),
                                const Text(
                                  "Instant Delivery", //TODO: get delivery type
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: kcPrimaryNeutral400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 15.0, right: 75),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '9:00 PM ',
                                style: ktBodyRegularSize14.copyWith(
                                    color: kcPrimaryNeutral100),
                              ),
                              Text(
                                'Instant Delivery',
                                style: ktBodyRegularSize14.copyWith(
                                    color: kcPrimaryNeutral100),
                              )
                            ],
                          ),
                        ),
                        verticalSpace(20),

                        SvgPicture.asset("asset/svgs/dotted_line.svg"),
                        verticalSpaceMedium,
                        // Category Tabs
                        SizedBox(
                          height: screenHeight(context) * 0.032,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildCategoryTab("All"),
                              _buildCategoryTab("Main Course"),
                              _buildCategoryTab("Sides"),
                              _buildCategoryTab("Protein"),
                              _buildCategoryTab("Drinks"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Menu Items List
                        // ListView.builder(
                        //   shrinkWrap: true,
                        //   physics: const NeverScrollableScrollPhysics(),
                        //   itemCount: menuItems.length,
                        //   itemBuilder: (context, index) {
                        //     final menuItem = menuItems[index];
                        //     return _buildMenuItem(menuItem);
                        //   },
                        // ),

                        verticalSpaceMassive,
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selectedItems.isNotEmpty
                                ? () {
                                    // Navigate to CheckoutScreen with selected items
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CheckoutScreen(
                                          selectedItems: _selectedItems,
                                        ),
                                      ),
                                    );
                                  }
                                : null, // Disable button if no items are selected
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kcPrimary400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              "Proceed to Checkout",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String title) {
    final isSelected = _selectedCategory == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = title;
        });
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? kcPrimary700 : kcWhite,
              borderRadius: BorderRadius.circular(20),
              border:
                  isSelected ? null : Border.all(color: kcPrimary700, width: 1),
            ),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: isSelected ? kcPrimary300 : kcPrimary400,
                fontSize: 12,
              ),
            ),
          ),
          horizontalSpaceSmall,
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuItem menuItem) {
    final isSelected = _selectedItems.contains(menuItem);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Menu Item Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              menuItem.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Menu Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menuItem.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  menuItem.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "From ₦${menuItem.price}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Add Button or Out of Stock Label
          menuItem.isAvailable
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedItems.remove(menuItem);
                      } else {
                        _selectedItems.add(menuItem);
                      }
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? kcPrimary300 : kcPrimary300,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isSelected ? "Added" : "+  Add",
                          style: ktBodyRegularSize16.copyWith(color: kcWhite),
                        ),
                      ],
                    ),
                  ),
                )
              : Row(
                  children: [
                    const SizedBox(width: 8),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kcPrimary800,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Out of Stock",
                              style: ktBodyRegularSize16.copyWith(
                                  color: kcPrimary300),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
