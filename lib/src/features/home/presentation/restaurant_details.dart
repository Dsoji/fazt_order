import 'package:cached_network_image/cached_network_image.dart';
import 'package:fazt_order/providers/navigation_provider.dart';
import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:logger/logger.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common/app_colors.dart';
import '../../../common/components/restaurant_card.dart';
import '../../../common/res/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/widgets/text_styles.dart';
import '../../profile/data/controller/profile_controller.dart';
import '../data/controller/shop_controller.dart';
import '../data/model/response/meal_details/item.dart' as meal_details;
import '../data/model/response/meal_variant_menu/result.dart';
import '../data/model/response/shops_model/day_schedule.dart';
import '../data/model/response/shops_model/result.dart';
import '../data/model/response/shops_model/shop_extension.dart';
import 'widgets/add_to_cart_bottom_sheet.dart';

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
    final searchQuery = useState<String>('');
    final searchController = useTextEditingController();
    final isSearching = useState(false);
    final selectedCategoryId = useState<String?>(null);
    final storeId = restaurant.store?.id;
    final shopId = restaurant.id;
    final scrollController = useScrollController();
    final mealsHasMore = ref.watch(
        shopControllerProvider.select((s) => s.mealVariantMenuHasMore));
    final isLoadingMoreMeals = ref.watch(
        shopControllerProvider.select((s) => s.isLoadingMoreMealVariantMenu));

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final position = scrollController.position;
        if (position.pixels >= position.maxScrollExtent - 300) {
          ref.read(shopControllerProvider.notifier).loadMoreMealVariantMenu(
                categoryId: selectedCategory.value == "All"
                    ? null
                    : selectedCategoryId.value,
                shopId: shopId,
              );
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController, shopId]);

    final isOpenNow = restaurant.isOpenNow;
    final openingHoursDisplayText = restaurant.openingHoursDisplayText;

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

    final selectedItems = ref.watch(shopControllerProvider
        .select((s) => s.shopFoodCategory.valueOrNull?.results));
    final cartItemAsync =
        ref.watch(shopControllerProvider.select((s) => s.fetchCart));
    final cartItem = cartItemAsync.valueOrNull?.carts ?? [];
    final totalItems = cartItemAsync.valueOrNull?.availableCarts ?? 0;

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

    final mealVariants =
        ref.watch(shopControllerProvider.select((s) => s.mealVariantMenu));

    final filteredResults = useMemoized(() {
      var filtered = mealVariants.valueOrNull?.results ??
          const <MealVariantMenuResult>[];
      if (searchQuery.value.isNotEmpty) {
        final q = searchQuery.value.toLowerCase();
        filtered = filtered.where((item) {
          final name = item.meal?.mealName?.toLowerCase() ?? '';
          final desc = item.meal?.mealDescription?.toLowerCase() ?? '';
          return name.contains(q) || desc.contains(q);
        }).toList();
      }
      if (selectedCategory.value != "All") {
        filtered = filtered
            .where((item) =>
                item.meal?.category?.categoryName == selectedCategory.value)
            .toList();
      }
      return filtered;
    }, [mealVariants, searchQuery.value, selectedCategory.value]);

    return Scaffold(
      backgroundColor: kcWhite,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isLoggedIn == false
          ? GestureDetector(
              onTap: () => context.go('/login'),
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
                        color: Colors.black.withValues(alpha: 0.2),
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
        leading: isSearching.value
            ? IconButton(
                onPressed: () {
                  searchController.clear();
                  searchQuery.value = '';
                  isSearching.value = false;
                },
                icon: const Icon(Icons.close),
              )
            : IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Iconsax.arrow_left_2),
              ),
        title: isSearching.value
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search meals...',
                  border: InputBorder.none,
                  hintStyle: ktBodySemiBoldSize20.copyWith(
                    fontSize: 24,
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                style: ktBodySemiBoldSize20.copyWith(fontSize: 24),
                onChanged: (value) {
                  searchQuery.value = value.toLowerCase();
                },
              )
            : Text(
                "Details",
                style: ktBodySemiBoldSize20.copyWith(fontSize: 24),
              ),
        centerTitle: true,
        actions: [
          if (!isSearching.value)
            IconButton(
              icon: const Icon(Iconsax.search_normal, color: kcBlack),
              onPressed: () {
                isSearching.value = true;
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.brand400,
        onRefresh: () async {
          if (isLoggedIn == true) {
            await ref.read(shopControllerProvider.notifier).fetchCart();
          }
          await Future.wait([
            ref
                .read(shopControllerProvider.notifier)
                .fetchShopFoodCategory(storeId!),
            fetchShopFood(),
          ]);
        },
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          // Header Image
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final imageUrl = restaurant.store?.storeDisplayImage;
                Widget fallback() => Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.storefront,
                        color: Colors.grey[600],
                        size: 48,
                      ),
                    );
                if (imageUrl == null || imageUrl.isEmpty) return fallback();
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => fallback(),
                  errorWidget: (context, url, error) => fallback(),
                );
              },
            ),
          ),
          // Info section
          SliverPadding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverToBoxAdapter(
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
                          "${restaurant.numberOfFavorites ?? 0}",
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
                          "From ₦${restaurant.deliveryFee ?? 0}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    RestaurantStatusPill(isOpen: isOpenNow),
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
                        Text(
                          openingHoursDisplayText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: kcPrimaryNeutral400,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
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
                                      color: kcPrimary300.withValues(alpha: 0.3),
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
                ],
              ),
            ),
          ),
          // Meals
          mealVariants.when(
            data: (_) {
              if (filteredResults.isEmpty && searchQuery.value.isNotEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No meals found matching your search',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList.builder(
                  itemCount: filteredResults.length,
                  itemBuilder: (context, i) => _MenuItemTile(
                    menuItem: filteredResults[i],
                    isOpenNow: isOpenNow,
                    isLoggedIn: isLoggedIn,
                  ),
                ),
              );
            },
            error: (error, stackTrace) {
              logger.d('Error loading meal variants: $error\n$stackTrace');
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'Unable to load meals right now.\nPlease try again later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList.builder(
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
          ),
          if (mealVariants.hasValue && filteredResults.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: isLoadingMoreMeals
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kcPrimary300,
                          ),
                        )
                      : !mealsHasMore
                          ? Text(
                              'No more meals',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: verticalSpaceMassive),
        ],
        ),
      ),
    );
  }

}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.menuItem,
    required this.isOpenNow,
    required this.isLoggedIn,
  });

  final MealVariantMenuResult menuItem;
  final bool isOpenNow;
  final bool? isLoggedIn;

  Widget _fallbackThumb() => Container(
        width: 80,
        height: 80,
        color: Colors.grey[300],
        child: Icon(
          Icons.fastfood,
          color: Colors.grey[600],
          size: 30,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final imageUrl = menuItem.meal?.mealImage;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasImage
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _fallbackThumb(),
                    errorWidget: (context, url, error) => _fallbackThumb(),
                  )
                : _fallbackThumb(),
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
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (!isOpenNow) {
                Fluttertoast.showToast(
                  msg: '⚠️ Shop is currently closed',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: AppColors.red200,
                  textColor: Colors.white,
                  fontSize: 14.0,
                );
                return;
              }
              if (isLoggedIn == true) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddToCartBottomSheet(menuItem: menuItem),
                );
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
          ),
        ],
      ),
    );
  }
}

