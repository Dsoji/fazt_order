import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fazt_order/src/common/res/app_colors.dart';
import 'package:fazt_order/src/features/order/checkout_view.dart';
import 'package:fazt_order/src/features/order/completed_orders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../../providers/navigation_provider.dart';
import '../../../providers/order_provider.dart';
import '../../common/app_colors.dart';
import '../../common/widgets/reusable_buttons.dart';
import '../home/data/controller/shop_controller.dart';
import 'my_orders.dart';

class OrderView extends HookConsumerWidget {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vsync = useSingleTickerProvider();
    final tabController =
        useMemoized(() => TabController(length: 3, vsync: vsync));
    final selectedIndex = useState(0);
    final cartItemAsync = ref.watch(shopControllerProvider).fetchCart;

    final orderState = ref.watch(orderProvider);

    // Listen to tab changes
    useEffect(() {
      void listener() {
        selectedIndex.value = tabController.index;
      }

      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    // Fetch orders when the widget is first built

    useEffect(() {
      Future.microtask(() {
        ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
      });
      return null;
    }, []);

    // Handle cart data based on async state
    Widget buildCartContent() {
      return cartItemAsync.when(
        data: (cartData) {
          // Extract cart items from the async data
          final cartItems = cartData.carts ?? [];
          final availableCarts = cartData.availableCarts ?? 0;
          logger.d('Cart Items: ${cartItems.length}');

          if (availableCarts == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Lottie.asset('asset/lottie/DBSkpgXyIT.json'),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to place order
                      ref.read(navigationProvider.notifier).state = 0;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: kcPrimary400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Place Order Now",
                        style: TextStyle(fontSize: 14, color: kcWhite),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(shopControllerProvider.notifier).fetchCart();
              await ref
                  .read(shopControllerProvider.notifier)
                  .fetchMyOrdersList();
            },
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                if ((item.items?.length ?? 0) < 1) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          child: Row(
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Builder(
                                  builder: (context) {
                                    final imageUrl =
                                        item.shop?.store?.storeDisplayImage;
                                    Widget fallback() => Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.storefront,
                                            color: Colors.grey[600],
                                            size: 30,
                                          ),
                                        );
                                    if (imageUrl == null || imageUrl.isEmpty) {
                                      return fallback();
                                    }
                                    return CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          fallback(),
                                      errorWidget: (context, url, error) =>
                                          fallback(),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 7),
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.shop?.shopName ?? "Courier Item",
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                            "asset/svgs/delivery_icon.svg"),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            item.shop?.location?.address ?? "",
                                            maxLines: 2,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: kcPrimaryNeutral300,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${item.items?.length ?? 0} items",
                                      style: const TextStyle(
                                          color: kcPrimaryNeutral300,
                                          fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₦${(item.totalPrice ?? 0).toStringAsFixed(0)}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: kcPrimaryNeutral300),
                                    ),
                                    if ((item.discount ?? 0) > 0) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.local_offer_outlined,
                                                size: 11,
                                                color: Colors.green.shade700),
                                            const SizedBox(width: 4),
                                            Text(
                                              "You saved ₦${item.discount!.toStringAsFixed(0)}",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              final result = await ref
                                  .read(shopControllerProvider.notifier)
                                  .clearCart(item.id ?? '');
                              if (result) {
                                ref
                                    .read(shopControllerProvider.notifier)
                                    .fetchCart();
                              }
                            },
                            child: const CircleAvatar(
                              backgroundColor: kcPrimaryRed900,
                              radius: 12,
                              child: Icon(IconsaxPlusLinear.trash,
                                  size: 15, color: kcPrimaryRed200),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutScreen(
                                    selectedItems: item,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: kcPrimary300,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text('Checkout',
                                  style: TextStyle(color: kcWhite)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SvgPicture.asset("asset/svgs/dotted_line.svg"),
                  ],
                );
              },
            ),
          );
        },
        loading: () => Center(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                width: 200,
                child: Lottie.asset('asset/lottie/DBSkpgXyIT.json'),
              ),
              const Gap(16),
              const Text(
                'Unable to fetch cart items at this momemnt please try again later. Or head to your profile to create a shop.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 46, 22, 20),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(16),
              OutlinButton(
                text: "Retry",
                width: 150,
                height: 48,
                color: kcPrimary400,
                bgColor: kcPrimaryNeutral900,
                onPressed: () {
                  ref.read(shopControllerProvider.notifier).fetchCart();
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedTabControl(
              tabPadding: const EdgeInsets.all(0),
              controller: tabController,
              tabTextColor: AppColors.neutral500,
              selectedTabTextColor: Colors.white,
              indicatorPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                color: AppColors.neutral500,
              ),
              barDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              indicatorDecoration: BoxDecoration(
                color: AppColors.brand300,
                borderRadius: BorderRadius.circular(30),
              ),
              tabs: const [
                SegmentTab(label: "My Cart"),
                SegmentTab(label: "Ongoing"),
                SegmentTab(label: "Completed"),
              ],
            ),
          ),
          // TabBar

          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                /// My Cart Tab
                buildCartContent(),

                /// Ongoing Tab
                const MyOrders(),

                /// Completed Tab
                const CompletedOrders(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
