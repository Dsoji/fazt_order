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
    final ongoingItems =
        orderState.items.where((item) => item.tab == 'ongoing').toList();
    final completedItems =
        orderState.items.where((item) => item.tab == 'completed').toList();

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

    void clearItems() {
      final notifier = ref.read(orderProvider.notifier);
      if (selectedIndex.value == 0) {
        notifier.clearCartItems();
      } else if (selectedIndex.value == 1) {
        notifier.clearOngoingItems();
      } else if (selectedIndex.value == 2) {
        notifier.clearCompletedItems();
      }
    }

    final myOrdersList = ref.watch(shopControllerProvider).myOrdersList;

    // Handle cart data based on async state
    Widget buildCartContent() {
      return cartItemAsync.when(
        data: (cartData) {
          // Extract cart items from the async data
          final cartItems = cartData.carts ?? [];

          if (cartItems.isEmpty) {
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
                                child: Image.network(
                                  item.shop?.store?.storeDisplayImage ??
                                      "asset/images/placeholder.png",
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
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
                                        Text(
                                          orderState.deliveryAddress,
                                          maxLines: 2,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: kcPrimaryNeutral300,
                                              fontSize: 12),
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
                                      "₦${((item.totalPrice ?? 0) * (item.packCount ?? 0)).toStringAsFixed(0)}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: kcPrimaryNeutral300),
                                    ),
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
                'Unable to fetch option groups at this momemnt please try again later. Or head to your profile to create a shop.',
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
          // TabBar
          TabBar(
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            controller: tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorPadding: EdgeInsets.zero,
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            dividerColor: kcTransparent,
            indicatorColor: kcTransparent,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: [
              Tab(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: selectedIndex.value == 0
                        ? Border.all(color: kcTransparent)
                        : Border.all(color: kcPrimary700),
                    color:
                        selectedIndex.value == 0 ? kcPrimary300 : kcTransparent,
                  ),
                  child: Text(
                    "My Cart",
                    style: TextStyle(
                        color:
                            selectedIndex.value == 0 ? kcWhite : kcPrimary400,
                        fontSize: 12),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: selectedIndex.value == 1
                        ? Border.all(color: kcTransparent)
                        : Border.all(color: kcPrimary700),
                    color:
                        selectedIndex.value == 1 ? kcPrimary300 : kcTransparent,
                  ),
                  child: Text(
                    "Ongoing",
                    style: TextStyle(
                        color:
                            selectedIndex.value == 1 ? kcWhite : kcPrimary400,
                        fontSize: 12),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: selectedIndex.value == 2
                        ? Border.all(color: kcTransparent)
                        : Border.all(color: kcPrimary700),
                    color:
                        selectedIndex.value == 2 ? kcPrimary300 : kcTransparent,
                  ),
                  child: Text(
                    "Completed",
                    style: TextStyle(
                        color:
                            selectedIndex.value == 2 ? kcWhite : kcPrimary400,
                        fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          // TabBarView
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
