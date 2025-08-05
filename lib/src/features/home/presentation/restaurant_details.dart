import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';

import '../../../../datamodels/menu_items.dart';
import '../../../common/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/widgets/text_styles.dart';
import '../data/controller/shop_controller.dart';
import '../data/model/response/shops_model/result.dart';
import '../data/model/response/store_meals/result.dart';

final logger = Logger();

class RestaurantDetailsView extends HookConsumerWidget {
  final ShopResult restaurant;

  const RestaurantDetailsView({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = useState("All");
    final selectedMenuItems = useState<List<MenuItem>>([]);
    final demoMenuItems = [
      MenuItem(
        name: "Jollof Rice",
        description: "Spicy rice cooked with tomatoes and peppers",
        price: 1500,
        imageUrl: "asset/images/rice.jpg",
        isAvailable: true,
      ),
      MenuItem(
        name: "Chicken Suya",
        description: "Grilled chicken with spicy peanut sauce",
        price: 2000,
        imageUrl: "asset/images/chicken.jpg",
        isAvailable: true,
      ),
      // Add more menu items as needed
    ];
    final shopId = restaurant.store?.id;
    logger.d('shopId: $shopId');

    useEffect(() {
      Future.microtask(() {
        ref
            .read(shopControllerProvider.notifier)
            .fetchShopFoodCategory(shopId!);
      });
      return null;
    }, [shopId]);

    final selectedItems =
        ref.watch(shopControllerProvider).shopFoodCategory.valueOrNull?.results;

    // Add this state for selected category ID
    final selectedCategoryId = useState<String?>(null);

    // Alternative: Fetch all meals when "All" is selected
    Future<void> fetchShopFood() async {
      if (selectedCategory.value == "All") {
        // Fetch all meals (you might need a different API endpoint for this)
        await ref
            .read(shopControllerProvider.notifier)
            .fetchShopFood(shopId!, ""); // or use a special parameter
      } else if (selectedCategoryId.value != null) {
        await ref
            .read(shopControllerProvider.notifier)
            .fetchShopFood(shopId!, selectedCategoryId.value!);
      }
    }

    final meals = ref.watch(shopControllerProvider).storeMeals;

    return Scaffold(
      backgroundColor: kcWhite,
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
      body: ListView(
        shrinkWrap: true,
        children: [
          // Header Image
          Image.network(
            restaurant.store?.storeDisplayImage ??
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjzZwJLYpHj9aghuqOmOuLUjpqMT2yrfmQhw&s',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          // Draggable Scrollable Sheet
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        restaurant.shopName ?? '',
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
                        // Implement favorite functionality
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
                        SvgPicture.asset('asset/svgs/delivery_icon.svg'),
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
                          "OPENING UNTIL 2PM",
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
                        SvgPicture.asset('asset/svgs/delivery_icon.svg'),
                        const SizedBox(width: 4),
                        const Text(
                          "Instant Delivery",
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
                const Gap(20),
                SvgPicture.asset("asset/svgs/dotted_line.svg"),
                const Gap(20),
                // Category Tabs
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (selectedItems?.length ?? 0) + 1,
                    itemBuilder: (context, index) {
                      final isSelected = index == 0
                          ? selectedCategory.value == "All"
                          : selectedItems != null &&
                              index - 1 < selectedItems.length &&
                              selectedCategory.value ==
                                  selectedItems[index - 1].categoryName;

                      final tabText = index == 0
                          ? "ALL"
                          : (selectedItems?[index - 1].categoryName ??
                                  "Unknown")
                              .toUpperCase();

                      return GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            selectedCategory.value = "All";
                            selectedCategoryId.value = null;
                          } else if (selectedItems != null &&
                              index - 1 < selectedItems.length) {
                            final category = selectedItems[index - 1];
                            selectedCategory.value =
                                category.categoryName ?? "Unknown";
                            selectedCategoryId.value =
                                category.id; // Get the category ID
                          }

                          // Call fetchShopFood when tab is selected
                          fetchShopFood();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? kcPrimary300 : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected
                                  ? kcPrimary300
                                  : kcPrimaryNeutral300,
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: kcPrimary300.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              tabText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color:
                                    isSelected ? kcWhite : kcPrimaryNeutral500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                meals.when(
                  data: (data) => Column(
                    children: data.results
                            ?.map((item) => _buildMenuItem(context, item))
                            .toList() ??
                        [],
                  ),
                  error: (error, stackTrace) => Text('Error: $error'),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),
                verticalSpaceMassive,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Result menuItem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: menuItem.mealImage != null && menuItem.mealImage!.isNotEmpty
                ? Image.network(
                    menuItem.mealImage!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.fastfood,
                          color: Colors.grey[600],
                          size: 30,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.fastfood,
                      color: Colors.grey[600],
                      size: 30,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menuItem.mealName ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  menuItem.mealDescription ?? '',
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
          menuItem.inStock == true
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _showAddToCartBottomSheet(context, menuItem);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kcPrimary300,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "+ Add",
                      style: ktBodyRegularSize16.copyWith(color: kcWhite),
                    ),
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kcPrimary800,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Out of Stock",
                    style: ktBodyRegularSize16.copyWith(color: kcPrimary300),
                  ),
                ),
        ],
      ),
    );
  }

  // Add this method to show the bottom sheet
  void _showAddToCartBottomSheet(BuildContext context, Result menuItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar and close button
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Handle bar
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    // Close button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: menuItem.mealImage != null &&
                                menuItem.mealImage!.isNotEmpty
                            ? Image.network(
                                menuItem.mealImage!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.fastfood,
                                      color: Colors.grey[600],
                                      size: 50,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.fastfood,
                                  color: Colors.grey[600],
                                  size: 50,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),

                      // Food name
                      Text(
                        menuItem.mealName ?? 'Food Item',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        menuItem.mealDescription ??
                            'Delicious food description',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Price
                      Text(
                        'From ₦${menuItem.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: kcPrimary300,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Customization sections
                      _buildCustomizationSection(
                        'Abacha Type',
                        ['Spicy', 'Bland', 'Normal'],
                        isRequired: true,
                        maxSelection: 1,
                      ),
                      const SizedBox(height: 16),

                      _buildCustomizationSection(
                        'Protein Options',
                        ['2 Pieces of Beef', 'Fish', 'Snail'],
                        isRequired: true,
                        maxSelection: 1,
                      ),
                      const SizedBox(height: 16),

                      _buildCustomizationSection(
                        'Extra Abacha',
                        ['Bland ₦1000', 'Spicy ₦1000', 'Normal ₦1000'],
                        isRequired: false,
                        maxSelection: 2,
                      ),
                      const SizedBox(height: 16),

                      _buildCustomizationSection(
                        'Extra Protein Option',
                        ['Fish ₦1000', 'Kroaker ₦1000', 'Goat Meat ₦1000'],
                        isRequired: false,
                        maxSelection: 2,
                      ),

                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build customization sections
  Widget _buildCustomizationSection(
    String title,
    List<String> options, {
    required bool isRequired,
    required int maxSelection,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select ${maxSelection == 1 ? '1' : 'up to $maxSelection'} from here',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ...options.map((option) => _buildOptionTile(option, maxSelection)),
      ],
    );
  }

  // Helper method to build option tiles
  Widget _buildOptionTile(String option, int maxSelection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            maxSelection == 1
                ? Icons.radio_button_unchecked
                : Icons.check_box_outline_blank,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              option,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
