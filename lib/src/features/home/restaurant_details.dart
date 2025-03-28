import 'package:fazt_order/src/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../datamodels/menu_items.dart';
import '../../../datamodels/restaurant.dart';
import '../../../providers/restaurant_provider.dart';
import '../../common/app_colors.dart';
import '../../common/widgets/text_styles.dart';

class RestaurantDetailsView extends ConsumerStatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailsView({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  ConsumerState<RestaurantDetailsView> createState() => _RestaurantDetailsViewState();
}

class _RestaurantDetailsViewState extends ConsumerState<RestaurantDetailsView> {
  String _selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    // Filter menu items based on the selected category (for simplicity, we'll show all items for now)
    final menuItems = widget.restaurant.menuItems;

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
            child: Image.asset(
              widget.restaurant.imageUrl,
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
                  controller: scrollController, // Attach the scroll controller for dragging
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                                "${widget.restaurant.name} - ${widget.restaurant.location}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                widget.restaurant.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                final restaurants = ref.read(restaurantProvider);
                                final index = restaurants.indexWhere(
                                      (r) =>
                                  r.name == widget.restaurant.name &&
                                      r.location == widget.restaurant.location,
                                );
                                if (index != -1) {
                                  ref.read(restaurantProvider.notifier).toggleFavorite(index);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.yellow,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.restaurant.rating} (${widget.restaurant.reviewCount})",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Price and Delivery Time
                        Row(
                          children: [
                            Text(
                              "From ₦${widget.restaurant.price}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.restaurant.deliveryTime,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                Text(
                                  "OPENING UNTIL ${widget.restaurant.openingHours}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.local_shipping,
                                  color: Colors.grey[600],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.restaurant.deliveryType.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        // Category Tabs
                        SizedBox(
                          height: screenHeight(context) * 0.032,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            final menuItem = menuItems[index];
                            return _buildMenuItem(menuItem);
                          },
                        ),
                        verticalSpace(12),
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
              color: isSelected ? kcPrimary300 : kcWhite,
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? null : Border.all(color: kcPrimary700, width: 1),
            ),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
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
              ? ElevatedButton(
            onPressed: () {
              // Implement add to cart functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              "Add",
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          )
              : Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Implement notify me functionality
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Notify Me",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Out of Stock",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}