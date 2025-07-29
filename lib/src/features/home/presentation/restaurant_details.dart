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
    final shopId = restaurant.store?.id;
    logger.d('shopId: $shopId');

    useEffect(() {
      ref.read(shopControllerProvider.notifier).fetchShopFoodCategory(shopId!);
      return null;
    }, [shopId]);
    final selectedItems =
        ref.watch(shopControllerProvider).shopFoodCategory.valueOrNull?.results;

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
                DefaultTabController(
                  length: (selectedItems?.length ?? 0) + 1, // +1 for "All" tab
                  child: TabBar(
                    isScrollable: true,
                    onTap: (index) {
                      if (index == 0) {
                        selectedCategory.value = "All";
                      } else if (selectedItems != null &&
                          index - 1 < selectedItems.length) {
                        selectedCategory.value =
                            selectedItems[index - 1].categoryName ?? "Unknown";
                      }
                    },
                    tabs: [
                      const Tab(text: "ALL"),
                      ...(selectedItems?.map((category) => Tab(
                              text: (category.categoryName ?? "Unknown")
                                  .toUpperCase())) ??
                          []),
                    ],
                    labelColor: kcPrimary300,
                    unselectedLabelColor: kcPrimary400,
                    indicator: BoxDecoration(
                      color: kcPrimary700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ),
                const SizedBox(height: 16),
                verticalSpaceMassive,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      MenuItem menuItem, ValueNotifier<List<MenuItem>> selectedItems) {
    final isSelected = selectedItems.value.contains(menuItem);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
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
          menuItem.isAvailable
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (isSelected) {
                      selectedItems.value = selectedItems.value
                          .where((item) => item != menuItem)
                          .toList();
                    } else {
                      selectedItems.value = [...selectedItems.value, menuItem];
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kcPrimary300,
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
