import 'package:cached_network_image/cached_network_image.dart';
import 'package:fazt_order/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
import '../data/model/response/meal_variant_menu/result.dart';
import '../data/model/response/shops_model/result.dart';
import '../data/model/response/shops_model/shop_extension.dart';
import 'providers/active_pack_provider.dart';
import 'widgets/add_to_cart_bottom_sheet.dart';
import 'widgets/pack_builder_sheet.dart';
import 'widgets/promo_tag_badge.dart';
import '../../../common/widgets/app_refresh_indicator.dart';

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
    final mealsHasMore = ref
        .watch(shopControllerProvider.select((s) => s.mealVariantMenuHasMore));
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
    // Vendor-side kill switch, kept separate from schedule-driven closing so we
    // can tell the customer *why* they cannot order right now.
    final isAcceptingOrders = restaurant.isAcceptingOrders;
    final openingHoursDisplayText = restaurant.openingHoursDisplayText;
    final storePromotion = restaurant.store?.promotionDisplay;
    final storePromotionTag = promotionTagText(storePromotion);
    final hasFreeDelivery = storePromotion?.hasActivePromotion == true &&
        storePromotion?.freeDelivery == true;

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
    // Packs are the customer's own grouping of this shop's cart items, so all
    // of this is read straight off the cart already in hand — no extra call.
    final shopCart = cartForShop(cartItemAsync.valueOrNull, shopId);
    final shopPackNumbers = packNumbersOf(shopCart);
    final shopItemCount = shopCart?.items?.length ?? 0;
    final activePack = ref.watch(activePackProvider)[shopId];

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
      var filtered =
          mealVariants.valueOrNull?.results ?? const <MealVariantMenuResult>[];
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
      backgroundColor: kcPrimaryNeutral950,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isLoggedIn == false
          ? GestureDetector(
              onTap: () => context.go('/login'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.brand400,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: kcPrimary300.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                        color: kcBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      IconsaxPlusLinear.login_1,
                      color: kcBlack,
                      size: 18,
                    ),
                  ],
                ),
              ))
          : shopPackNumbers.isNotEmpty
              ? _PackCartBar(
                  // With a pack targeted the bar reports where the last meal
                  // landed; with none it falls back to the cart summary, and
                  // the next add opens a fresh pack.
                  activePack: activePack,
                  activePackExists: shopPackNumbers.contains(activePack),
                  packCount: shopPackNumbers.length,
                  itemCount: shopItemCount,
                  onTapToView: shopId == null
                      ? null
                      : () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => PackBuilderSheet(
                              shopId: shopId,
                              onCheckout: () {
                                ref.read(navigationProvider.notifier).state = 1;
                                Navigator.pop(context);
                              },
                            ),
                          ),
                )
              : null,
      body: AppRefreshIndicator(
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
            // Search bar, or the restaurant header that collapses as you scroll.
            if (isSearching.value)
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: kcWhite,
                surfaceTintColor: kcTransparent,
                leading: IconButton(
                  onPressed: () {
                    searchController.clear();
                    searchQuery.value = '';
                    isSearching.value = false;
                  },
                  icon: const Icon(Icons.close, color: kcPrimaryNeutral200),
                ),
                title: TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search meals...',
                    border: InputBorder.none,
                    hintStyle: ktBodySemiBoldSize20.copyWith(
                      fontSize: 18,
                      color: kcPrimaryNeutral600,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: ktBodySemiBoldSize20.copyWith(fontSize: 18),
                  onChanged: (value) {
                    searchQuery.value = value.toLowerCase();
                  },
                ),
              )
            else
              SliverAppBar(
                pinned: true,
                expandedHeight: 240,
                backgroundColor: kcPrimary300,
                surfaceTintColor: kcTransparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                leading: _GlassIconButton(
                  icon: Iconsax.arrow_left_2,
                  onTap: () => Navigator.pop(context),
                ),
                actions: [
                  _GlassIconButton(
                    icon: Iconsax.search_normal,
                    onTap: () => isSearching.value = true,
                  ),
                  _GlassIconButton(
                    icon: restaurant.isLiked == true
                        ? Iconsax.heart5
                        : Iconsax.heart,
                    iconColor:
                        restaurant.isLiked == true ? AppColors.red800 : kcWhite,
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
                  ),
                  const SizedBox(width: 6),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  titlePadding: const EdgeInsetsDirectional.only(
                      start: 56, bottom: 16, end: 16),
                  title: Text(
                    restaurant.store?.storeName ?? restaurant.shopName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kcWhite,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Builder(
                        builder: (context) {
                          final imageUrl = restaurant.store?.storeDisplayImage;
                          Widget fallback() => Container(
                                color: kcPrimaryNeutral900,
                                child: const Icon(
                                  Icons.storefront,
                                  color: kcPrimaryNeutral700,
                                  size: 48,
                                ),
                              );
                          if (imageUrl == null || imageUrl.isEmpty) {
                            return fallback();
                          }
                          return CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => fallback(),
                            errorWidget: (context, url, error) => fallback(),
                          );
                        },
                      ),
                      // Scrim keeps the white controls and title legible on any
                      // store image.
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black54,
                              Colors.transparent,
                              Colors.black87,
                            ],
                            stops: [0, 0.42, 1],
                          ),
                        ),
                      ),
                      if (storePromotionTag != null)
                        Positioned(
                          top: kToolbarHeight + 24,
                          left: 16,
                          right: 16,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: PromoTagBadge(label: storePromotionTag),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            // Info card — overlaps the header image by a few pixels so the two
            // read as one surface.
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: kcWhite,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(22)),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Gap(12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.shopName ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: kcBlack,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const Spacer(),
                          RestaurantStatusPill(
                            isOpen: isOpenNow,
                            label: restaurant.availabilityLabel,
                          ),
                        ],
                      ),
                      if (!isAcceptingOrders) ...[
                        const Gap(10),
                        const _NotAcceptingOrdersBanner(),
                      ],
                      const Gap(6),
                      Row(
                        children: [
                          const Icon(Iconsax.location,
                              size: 14, color: kcPrimaryNeutral500),
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
                      const Gap(14),
                      // Delivery / favourites at a glance
                      Container(
                        decoration: BoxDecoration(
                          color: kcPrimaryNeutral950,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            _StatCell(
                              icon: Iconsax.truck_fast,
                              iconColor: hasFreeDelivery
                                  ? AppColors.green800
                                  : kcPrimary300,
                              value: hasFreeDelivery
                                  ? 'Free'
                                  : '₦${restaurant.deliveryFee ?? 0}',
                              valueColor:
                                  hasFreeDelivery ? AppColors.green800 : null,
                              strikethrough: hasFreeDelivery
                                  ? '₦${restaurant.deliveryFee ?? 0}'
                                  : null,
                              label: 'Delivery',
                            ),
                            const _StatDivider(),
                            _StatCell(
                              icon: Iconsax.heart5,
                              iconColor: AppColors.red800,
                              value: '${restaurant.numberOfFavorites ?? 0}',
                              label: 'Favourites',
                            ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      Row(
                        children: [
                          const Icon(Iconsax.clock,
                              size: 14, color: kcPrimaryNeutral500),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              openingHoursDisplayText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: kcPrimaryNeutral400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.brand980,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(IconsaxPlusLinear.activity,
                                    size: 12, color: kcPrimary300),
                                SizedBox(width: 4),
                                Text(
                                  'Instant Delivery',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: kcPrimary300,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (storePromotionTag != null) ...[
                        const Gap(14),
                        PromotionOfferBanner(promotion: storePromotion),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Category tabs + menu heading
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: Container(
                  color: kcWhite,
                  padding: const EdgeInsets.fromLTRB(16, 4, 0, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                margin: const EdgeInsets.only(
                                    right: 10, top: 6, bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? kcPrimary300 : kcWhite,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: isSelected
                                        ? kcPrimary300
                                        : kcPrimaryNeutral900,
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: kcPrimary300.withValues(
                                                alpha: 0.28),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
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
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? kcWhite
                                          : kcPrimaryNeutral400,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 16, 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'Menu',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: kcBlack,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (mealVariants.hasValue)
                              Text(
                                filteredResults.length == 1
                                    ? '1 item'
                                    : '${filteredResults.length} items',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: kcPrimaryNeutral500,
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
            // Meals
            mealVariants.when(
              data: (_) {
                if (filteredResults.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _MenuEmptyState(
                      isSearch: searchQuery.value.isNotEmpty,
                      category: selectedCategory.value,
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                  sliver: SliverList.builder(
                    itemCount: filteredResults.length,
                    itemBuilder: (context, i) => _MenuItemTile(
                      menuItem: filteredResults[i],
                      shopId: shopId,
                      isOpenNow: isOpenNow,
                      closedMessage: isAcceptingOrders
                          ? '⚠️ Shop is currently closed'
                          : '⚠️ This restaurant is not accepting orders right now',
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
                        style:
                            TextStyle(fontSize: 15, color: kcPrimaryNeutral500),
                      ),
                    ),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                sliver: SliverList.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kcWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Shimmer.fromColors(
                      baseColor: kcPrimaryNeutral900,
                      highlightColor: kcPrimaryNeutral950,
                      child: Row(
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: kcWhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    width: double.infinity,
                                    height: 14,
                                    color: kcWhite),
                                const SizedBox(height: 8),
                                Container(
                                    width: 160, height: 12, color: kcWhite),
                                const SizedBox(height: 12),
                                Container(
                                    width: 70, height: 14, color: kcWhite),
                              ],
                            ),
                          ),
                        ],
                      ),
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

/// Shown when the vendor has switched "Accepting orders" off, so the customer
/// knows the restaurant is unavailable rather than just quiet.
class _NotAcceptingOrdersBanner extends StatelessWidget {
  const _NotAcceptingOrdersBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.red900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Iconsax.info_circle, size: 16, color: AppColors.red400),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Not accepting orders',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.red300,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'This restaurant has paused new orders. You can browse the '
                  'menu and order once they are back.',
                  style: ktBodyRegularSize12.copyWith(color: AppColors.red200),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.menuItem,
    required this.shopId,
    required this.isOpenNow,
    required this.closedMessage,
    required this.isLoggedIn,
  });

  final MealVariantMenuResult menuItem;
  final String? shopId;
  final bool isOpenNow;
  final String closedMessage;
  final bool? isLoggedIn;

  Widget _fallbackThumb() => Container(
        width: 84,
        height: 84,
        color: kcPrimaryNeutral950,
        child: const Icon(
          Icons.fastfood,
          color: kcPrimaryNeutral700,
          size: 28,
        ),
      );

  void _onAdd(BuildContext context) {
    if (!isOpenNow) {
      Fluttertoast.showToast(
        msg: closedMessage,
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
        builder: (_) => AddToCartBottomSheet(
          menuItem: menuItem,
          shopId: shopId,
        ),
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
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = menuItem.meal?.mealImage;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final promotion = menuItem.meal?.promotionDisplay;
    final promotionTag = promotionTagText(promotion, tag: promotion?.tag);
    final price = menuItem.meal?.price;
    final discounted = discountedPrice(price, promotion);
    final description = menuItem.meal?.mealDescription ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kcWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kcBlack.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onAdd(context),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: hasImage
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => _fallbackThumb(),
                              errorWidget: (context, url, error) =>
                                  _fallbackThumb(),
                            )
                          : _fallbackThumb(),
                    ),
                    if (promotionTag != null)
                      Positioned(
                        left: 4,
                        bottom: 4,
                        right: 4,
                        child: PromoTagBadge(label: promotionTag),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuItem.meal?.mealName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kcBlack,
                          height: 1.2,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: kcPrimaryNeutral500,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      if (discounted != null)
                        Row(
                          children: [
                            Text(
                              "₦${discounted.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: kcPrimaryOrange700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "₦${price ?? 0}",
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: kcPrimaryNeutral600,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          "From ₦${price ?? 0}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: kcPrimary300,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Add button — the whole card is tappable too.
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onAdd(context),
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: isOpenNow ? kcPrimary300 : kcPrimaryNeutral800,
                        shape: BoxShape.circle,
                        boxShadow: isOpenNow
                            ? [
                                BoxShadow(
                                  color: kcPrimary300.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: const Icon(Icons.add, color: kcWhite, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular translucent control that sits over the header image.
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = kcWhite,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 36,
          width: 36,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: kcBlack.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(color: kcWhite.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      ),
    );
  }
}

/// One figure in the rating / delivery / favourites strip.
class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueColor,
    this.strikethrough,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color? valueColor;

  /// Original figure, shown struck through beside [value] (e.g. a delivery fee
  /// waived by a promotion).
  final String? strikethrough;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? kcBlack,
                  ),
                ),
              ),
              if (strikethrough != null) ...[
                const SizedBox(width: 4),
                Text(
                  strikethrough!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kcPrimaryNeutral600,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: kcPrimaryNeutral500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 26,
      color: kcPrimaryNeutral900,
    );
  }
}

/// Shown when a category, or a search, turns up nothing.
class _MenuEmptyState extends StatelessWidget {
  const _MenuEmptyState({required this.isSearch, required this.category});

  final bool isSearch;
  final String category;

  @override
  Widget build(BuildContext context) {
    final title = isSearch ? 'No meals match your search' : 'Nothing here yet';
    final subtitle = isSearch
        ? 'Try a different name or clear the search.'
        : category == 'All'
            ? 'This restaurant has not added any meals yet.'
            : 'No meals under "$category" right now.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
      child: Column(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: const BoxDecoration(
              color: kcPrimaryNeutral900,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fastfood_outlined,
              size: 26,
              color: kcPrimaryNeutral600,
            ),
          ),
          const Gap(14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kcPrimaryNeutral300,
            ),
          ),
          const Gap(4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: kcPrimaryNeutral500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

/// The floating bar on the menu screen, once this restaurant has a cart.
///
/// It names the pack the last meal went into — and therefore the pack the next
/// one will join — because a customer building several packs has no other way
/// to tell where an item is about to land. "Tap to view" opens the pack list,
/// which is where a pack is switched or a new one started.
class _PackCartBar extends StatelessWidget {
  const _PackCartBar({
    required this.activePack,
    required this.activePackExists,
    required this.packCount,
    required this.itemCount,
    required this.onTapToView,
  });

  final int? activePack;
  final bool activePackExists;
  final int packCount;
  final int itemCount;
  final VoidCallback? onTapToView;

  @override
  Widget build(BuildContext context) {
    final label = activePack != null
        // "Added" once the pack holds something; until then the customer has
        // only aimed at it, and saying otherwise would claim an item they
        // haven't picked yet.
        ? '${activePackExists ? 'Added to' : 'Adding to'} Pack $activePack'
        : packCount == 1
            ? '1 pack · $itemCount ${itemCount == 1 ? 'item' : 'items'}'
            : '$packCount packs · $itemCount items';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kcPrimary300,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: kcPrimary300.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTapToView,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: kcWhite.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Iconsax.shopping_cart,
                    size: 17,
                    color: kcWhite,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kcWhite,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 20,
                  width: 1,
                  color: kcWhite.withValues(alpha: 0.28),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Tap to view',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kcWhite,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Iconsax.arrow_right_3,
                  size: 15,
                  color: kcWhite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
