import 'package:fazt_order/providers/navigation_provider.dart';
import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/app_colors.dart';
import '../../../common/res/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/widgets/text_styles.dart';
import '../../auth/login/presentation/login_screen.dart';
import '../../profile/data/controller/profile_controller.dart';
import '../data/controller/shop_controller.dart';
import '../data/model/response/meal_details/item.dart' as meal_details;
import '../data/model/response/meal_variant_menu/result.dart';
import '../data/model/response/shops_model/result.dart';

final logger = Logger();

class RestaurantDetailsView extends HookConsumerWidget {
  final ShopResult restaurant;
  final bool? isLoggedIn;

  const RestaurantDetailsView({
    super.key,
    required this.restaurant,
    this.isLoggedIn = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = useState("All");
    final storeId = restaurant.store?.id;
    final shopId = restaurant.id;
    logger.d('shopId: $shopId');
    logger.d('storeId: $storeId');

    useEffect(() {
      Future.microtask(() {
        if (isLoggedIn == true) {
          ref.read(shopControllerProvider.notifier).fetchCart();
        }
        ref
            .read(shopControllerProvider.notifier)
            .fetchShopFoodCategory(storeId!);
        ref.read(shopControllerProvider.notifier).fetchMealVariantMenu(
              shopId: shopId,
            );
      });
      return null;
    }, [shopId]);

    final selectedItems =
        ref.watch(shopControllerProvider).shopFoodCategory.valueOrNull?.results;
    final cartItemAsync = ref.watch(shopControllerProvider).fetchCart;
    logger.d('cartItemAsync: $cartItemAsync');
    final cartItem = cartItemAsync.valueOrNull?.carts ?? [];
    logger.d('cartItem: $cartItem');
    final totalItems = cartItemAsync.valueOrNull?.totalCarts ?? 0;
    logger.d('totalItems: $totalItems');

    // Add this state for selected category ID
    final selectedCategoryId = useState<String?>(null);

    // Alternative: Fetch all meals when "All" is selected
    Future<void> fetchShopFood() async {
      if (selectedCategory.value == "All") {
        await ref.read(shopControllerProvider.notifier).fetchMealVariantMenu(
              shopId: shopId,
            );
      } else if (selectedCategoryId.value != null) {
        await ref.read(shopControllerProvider.notifier).fetchMealVariantMenu(
              categoryId: selectedCategoryId.value,
              shopId: shopId,
            );
      }
    }

    final mealVariants = ref.watch(shopControllerProvider).mealVariantMenu;

    logger.d('cartItem: $cartItem');

    return Scaffold(
      backgroundColor: kcWhite,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isLoggedIn == false
          ? GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: Container(
                width: 82,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.brand400,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(color: Colors.black),
                    ),
                    Icon(
                      IconsaxPlusLinear.login_1,
                      color: Colors.black,
                    ),
                  ],
                ),
              ))
          : cartItem.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.brand900,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        // Navigate to Order tab (index 1) in the bottom navigation
                        ref.read(navigationProvider.notifier).state = 1;
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.shopping_cart,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$totalItems items in cart, tap to view',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : null,
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
                    GestureDetector(
                      onTap: () async {
                        await ref
                            .read(profileControllerProvider.notifier)
                            .addToFavorites(shopId: restaurant.id ?? '');
                        await ref
                            .read(profileControllerProvider.notifier)
                            .fetchFavouritesList();
                        await ref
                            .read(shopControllerProvider.notifier)
                            .revalidateShops();
                      },
                      child: Icon(
                          restaurant.isLiked == true
                              ? Iconsax.heart5
                              : Iconsax.heart,
                          color: restaurant.isLiked == true
                              ? AppColors.green800
                              : kcPrimaryNeutral200,
                          size: 24),
                    ),
                  ],
                ),
                verticalSpace(1),
                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Iconsax.location,
                            color: kcPrimaryNeutral500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              restaurant.location?.address ?? '',
                              style: ktBodyRegularSize12.copyWith(
                                  color: kcPrimaryNeutral500),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                mealVariants.when(
                  data: (data) => Column(
                    children: data.results
                            ?.map((item) => _buildMenuItem(context, item))
                            .toList() ??
                        [],
                  ),
                  error: (error, stackTrace) {
                    logger
                        .d('Error loading meal variants: $error\n$stackTrace');
                    return Text('Error: $error');
                  },
                  loading: () => ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: double.infinity,
                                    height: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 100,
                                    height: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                verticalSpaceMassive,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    MealVariantMenuResult menuItem,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: (menuItem.meal?.mealImage != null &&
                    menuItem.meal!.mealImage!.isNotEmpty)
                ? Image.network(
                    menuItem.meal!.mealImage!,
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
                  menuItem.meal?.mealName ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  menuItem.meal?.mealDescription ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "From ₦${menuItem.meal?.price ?? 0}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // menuItem.inStock == true
          //     ?
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (isLoggedIn == true) {
                _showAddToCartBottomSheet(context, menuItem as dynamic);
              } else {
                Fluttertoast.showToast(
                  msg: 'Please login to add to cart',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.orangeAccent,
                  textColor: Colors.white,
                  fontSize: 14.0,
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          // : Container(
          //     padding:
          //         const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          //     decoration: BoxDecoration(
          //       color: kcPrimary800,
          //       borderRadius: BorderRadius.circular(30),
          //     ),
          //     child: Text(
          //       "Out of Stock",
          //       style: ktBodyRegularSize16.copyWith(color: kcPrimary300),
          //     ),
          // ),
        ],
      ),
    );
  }

  // Add this method to show the bottom sheet
  void _showAddToCartBottomSheet(
      BuildContext context, MealVariantMenuResult menuItem) {
    final options = menuItem.meal?.optionGroup;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToCartBottomSheet(menuItem: menuItem),
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
              style: const TextStyle(fontSize: 16, color: Colors.black),
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

// Create a separate HookConsumerWidget for the bottom sheet content
class AddToCartBottomSheet extends HookConsumerWidget {
  final MealVariantMenuResult menuItem;

  const AddToCartBottomSheet({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.microtask(() {
        ref
            .read(shopControllerProvider.notifier)
            .fetchMealDetails(menuItem.id ?? '');
      });
      return null;
    }, [menuItem.id]);

    final mealDetailsAsync = ref.watch(shopControllerProvider).mealDetails;
    final quantity = useState(1);
    final selectedItemsWithQuantity =
        useState<Map<String, Map<String, int>>>({});
    final mealVariants =
        ref.watch(shopControllerProvider).storeMealVariant.valueOrNull?.results;

    // Move useMemoized outside of AsyncValue.when
    final totalPrice = useMemoized(() {
      final mealDetails = mealDetailsAsync.valueOrNull;
      if (mealDetails == null) return 0;

      int basePrice = mealDetails.mealVariant?.meal?.price ?? 0;
      num optionsPrice = 0;
      final options = mealDetails.mealVariant?.meal?.optionGroup;

      // Calculate price from selected options with quantities
      if (options != null) {
        for (final optionGroup in options) {
          final selectedItemsForGroup =
              selectedItemsWithQuantity.value[optionGroup.id ?? ''] ?? {};
          final items = optionGroup.items ?? [];

          for (final entry in selectedItemsForGroup.entries) {
            final itemId = entry.key;
            final quantity = entry.value;

            // Find the corresponding item to get its price
            final item =
                items.where((item) => item.variant?.id == itemId).firstOrNull;
            if (item != null) {
              optionsPrice += ((item.price ?? 0) * quantity).toInt();
            }
          }
        }
      }

      return (basePrice + optionsPrice) * quantity.value;
    }, [
      selectedItemsWithQuantity.value,
      quantity.value,
      mealDetailsAsync,
    ]);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar and close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
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
            // Content area with AsyncValue.when
            Flexible(
              child: mealDetailsAsync.when(
                data: (mealDetails) {
                  final options = mealDetails.mealVariant?.meal?.optionGroup;

                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Food image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: mealDetails.mealVariant?.meal?.mealImage !=
                                      null &&
                                  mealDetails
                                      .mealVariant!.meal!.mealImage!.isNotEmpty
                              ? Image.network(
                                  mealDetails.mealVariant!.meal!.mealImage!,
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
                          mealDetails.mealVariant?.meal?.mealName ??
                              'Food Item',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Text(
                          mealDetails.mealVariant?.meal?.mealDescription ??
                              'Delicious food description',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.neutral500,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Price
                        Text(
                          'From ₦${mealDetails.mealVariant?.meal?.price ?? 0}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.neutral200,
                          ),
                        ),
                        const Gap(16),
                        const Divider(
                          color: AppColors.neutral200,
                          thickness: 0.5,
                        ),
                        const Gap(16),

                        // Dynamic customization sections based on optionGroup
                        if (options != null && options.isNotEmpty)
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: options.length,
                            separatorBuilder: (context, index) => const Divider(
                              color: AppColors.neutral200,
                              thickness: 0.5,
                              height: 32,
                            ),
                            itemBuilder: (context, index) {
                              final optionGroup = options[index];
                              final items = optionGroup.items ?? [];

                              final optionNames = items.map((item) {
                                final price = item.price ?? 0;
                                return price > 0
                                    ? '${item.item} ₦$price'
                                    : item.item ?? '';
                              }).toList();

                              return buildCustomizationSection(
                                optionGroup.groupName ?? 'Customization',
                                optionNames,
                                items,
                                isRequired: optionGroup.least != null &&
                                    optionGroup.least! > 0,
                                maxSelection: optionGroup.most ?? 1,
                                groupId: optionGroup.id ?? '',
                                selectedItemIdsWithQuantity:
                                    selectedItemsWithQuantity
                                            .value[optionGroup.id ?? ''] ??
                                        {},
                                onSelectionChanged:
                                    (selectedItemIdsWithQuantity) {
                                  final newSelectedItems =
                                      Map<String, Map<String, int>>.from(
                                          selectedItemsWithQuantity.value);
                                  newSelectedItems[optionGroup.id ?? ''] =
                                      selectedItemIdsWithQuantity;
                                  selectedItemsWithQuantity.value =
                                      newSelectedItems;
                                },
                              );
                            },
                          )
                        else
                          const Column(
                            children: [],
                          ),

                        // Add to Cart Section
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, bottom: 16),
                          child: Row(
                            children: [
                              // Quantity Selector
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                      color: AppColors.brand400, width: 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (quantity.value > 1) {
                                          quantity.value--;
                                        }
                                      },
                                      child: const Icon(
                                        Icons.remove,
                                        color: AppColors.brand300,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '${quantity.value}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.brand300,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () {
                                        quantity.value++;
                                      },
                                      child: const Icon(
                                        Icons.add,
                                        color: AppColors.brand300,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Add to Cart Button
                              Expanded(
                                child: FullButton(
                                  text: 'Add to Cart ₦$totalPrice',
                                  width: double.infinity,
                                  height: 48,
                                  isLoading: ref
                                      .watch(shopControllerProvider)
                                      .addToCart
                                      .isLoading,
                                  onPressed: () async {
                                    // Check if required options are selected
                                    final options = mealDetails
                                        .mealVariant?.meal?.optionGroup;
                                    bool hasRequiredSelections = true;
                                    String? missingRequiredGroup;

                                    if (options != null) {
                                      for (final optionGroup in options) {
                                        final isRequired =
                                            optionGroup.least != null &&
                                                optionGroup.least! > 0;
                                        if (isRequired) {
                                          final selectedItemsForGroup =
                                              selectedItemsWithQuantity.value[
                                                      optionGroup.id ?? ''] ??
                                                  {};

                                          if (selectedItemsForGroup.isEmpty) {
                                            hasRequiredSelections = false;
                                            missingRequiredGroup =
                                                optionGroup.groupName;
                                            break;
                                          }
                                        }
                                      }
                                    }

                                    if (!hasRequiredSelections) {
                                      Fluttertoast.showToast(
                                        msg:
                                            '🚨 Please select all required options',
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.TOP,
                                        backgroundColor: Colors.yellow[600],
                                        textColor: Colors.black,
                                        fontSize: 14.0,
                                      );

                                      return;
                                    }

                                    // Prepare the options data for the API
                                    List<Map<String, dynamic>> optionsData = [];

                                    for (final optionGroup in options ?? []) {
                                      final selectedItemsForGroup =
                                          selectedItemsWithQuantity.value[
                                                  optionGroup.id ?? ''] ??
                                              {};

                                      for (final entry
                                          in selectedItemsForGroup.entries) {
                                        optionsData.add({
                                          "optionItemVariant": entry.key,
                                          "quantity": entry.value,
                                        });
                                      }
                                    }

                                    // Call your updated addToCart method
                                    final result = await ref
                                        .read(shopControllerProvider.notifier)
                                        .addToCart(
                                          menuItem.id ?? '',
                                          quantity.value,
                                          optionsData,
                                        );

                                    if (result == true) {
                                      await ref
                                          .read(shopControllerProvider.notifier)
                                          .fetchCart();
                                      Navigator.pop(context);
                                    }
                                  },
                                  color: AppColors.brand400,
                                  textColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 150,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                error: (error, stackTrace) {
                  logger.e('Error loading meal details: $error\n$stackTrace');
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load meal details',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red[400],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(shopControllerProvider.notifier)
                                  .fetchMealDetails(menuItem.id ?? '');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brand400,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build customization sections
  Widget buildCustomizationSection(
    String title,
    List<String> options,
    List<meal_details.Item> items, // Use the meal_details Item type
    {
    required bool isRequired,
    required int maxSelection,
    required String groupId,
    required Map<String, int> selectedItemIdsWithQuantity,
    required Function(Map<String, int>) onSelectionChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            if (isRequired) ...[
              const Spacer(),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    IconsaxPlusLinear.tick_circle,
                    color: AppColors.brand300,
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Required',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.brand300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final item = items[index];
          final itemId = item.id ?? '';
          final itemVariantId = item.variant?.id ?? '';
          final isSelected =
              selectedItemIdsWithQuantity.containsKey(itemVariantId);
          final quantity = selectedItemIdsWithQuantity[itemVariantId] ?? 0;

          // Add debug print
          print('Item: $itemId, isSelected: $isSelected, quantity: $quantity');

          return buildOptionTileWithQuantity(
            option,
            maxSelection,
            isSelected: isSelected,
            quantity: quantity,
            onTap: () {
              Map<String, int> newSelection =
                  Map.from(selectedItemIdsWithQuantity);

              if (maxSelection == 1) {
                // Single selection - replace current selection
                if (isSelected) {
                  newSelection.clear();
                } else {
                  newSelection.clear();
                  newSelection[itemVariantId] = 1;
                }
              } else {
                // Multiple selection with quantity
                if (isSelected) {
                  newSelection.remove(itemVariantId);
                } else {
                  if (newSelection.length < maxSelection) {
                    newSelection[itemVariantId] = 1;
                  }
                }
              }

              print('New selection: $newSelection');
              onSelectionChanged(newSelection);
            },
            onQuantityChanged: (newQuantity) {
              Map<String, int> newSelection =
                  Map.from(selectedItemIdsWithQuantity);
              if (newQuantity > 0) {
                newSelection[itemVariantId] = newQuantity;
              } else {
                newSelection.remove(itemVariantId);
              }
              print('Quantity changed: $newSelection');
              onSelectionChanged(newSelection);
            },
          );
        }),
      ],
    );
  }

  // Helper method to build option tiles
  Widget buildOptionTile(
    String option,
    int maxSelection, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.brand300 : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppColors.brand300.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              maxSelection == 1
                  ? (isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked)
                  : (isSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank),
              color: isSelected ? AppColors.brand300 : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? AppColors.brand300 : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Updated option tile with quantity controls
  Widget buildOptionTileWithQuantity(
    String option,
    int maxSelection, {
    required bool isSelected,
    required int quantity,
    required VoidCallback onTap,
    required Function(int) onQuantityChanged,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.brand300 : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppColors.brand300.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              maxSelection == 1
                  ? (isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked)
                  : (isSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank),
              color: isSelected ? AppColors.brand300 : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? AppColors.brand300 : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            // Quantity controls (only show when selected)
            if (isSelected && quantity > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.brand300.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.brand300, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (quantity > 1) {
                          onQuantityChanged(quantity - 1);
                        } else {
                          onQuantityChanged(0); // Remove item
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.remove,
                          size: 16,
                          color: AppColors.brand300,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$quantity',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brand300,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        onQuantityChanged(quantity + 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.brand300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
