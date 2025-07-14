import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import '../../../datamodels/menu_items.dart';
import '../../../providers/order_provider.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import 'checkout_view.dart';
import 'ongoing_orders_view.dart';

class OrderView extends ConsumerStatefulWidget {
  const OrderView({super.key});

  @override
  _OrderViewState createState() => _OrderViewState();
}

class _OrderViewState extends ConsumerState<OrderView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _clearItems() {
    final notifier = ref.read(orderProvider.notifier);
    if (_tabController.index == 0) {
      notifier.clearCartItems();
    } else if (_tabController.index == 1) {
      notifier.clearOngoingItems();
    } else if (_tabController.index == 2) {
      notifier.clearCompletedItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final cartItems =
        orderState.items.where((item) => item.tab == 'cart').toList();
    final ongoingItems =
        orderState.items.where((item) => item.tab == 'ongoing').toList();
    final completedItems =
        orderState.items.where((item) => item.tab == 'completed').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          GestureDetector(
            onTap: (cartItems.isNotEmpty && _tabController.index == 0) ||
                    (ongoingItems.isNotEmpty && _tabController.index == 1) ||
                    (completedItems.isNotEmpty && _tabController.index == 2)
                ? _clearItems
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _tabController.index == 0
                        ? "Clear cart items"
                        : _tabController.index == 1
                            ? "Clear ongoing items"
                            : "Clear completed items",
                    style: TextStyle(
                      color:
                          (cartItems.isNotEmpty && _tabController.index == 0) ||
                                  (ongoingItems.isNotEmpty &&
                                      _tabController.index == 1) ||
                                  (completedItems.isNotEmpty &&
                                      _tabController.index == 2)
                              ? kcPrimary400
                              : kcPrimaryNeutral700,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Container(
                    height: 1,
                    width: 100,
                    color:
                        (cartItems.isNotEmpty && _tabController.index == 0) ||
                                (ongoingItems.isNotEmpty &&
                                    _tabController.index == 1) ||
                                (completedItems.isNotEmpty &&
                                    _tabController.index == 2)
                            ? kcPrimary400
                            : kcPrimaryNeutral700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // TabBar
          TabBar(
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            controller: _tabController,
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
                    border: _tabController.index == 0
                        ? Border.all(color: kcTransparent)
                        : Border.all(color: kcPrimary700),
                    color: _tabController.index == 0
                        ? kcPrimary300
                        : kcTransparent,
                  ),
                  child: Text(
                    "My Cart",
                    style: TextStyle(
                        color:
                            _tabController.index == 0 ? kcWhite : kcPrimary400,
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
                    border: _tabController.index == 1
                        ? Border.all(color: kcTransparent)
                        : Border.all(color: kcPrimary700),
                    color: _tabController.index == 1
                        ? kcPrimary300
                        : kcTransparent,
                  ),
                  child: Text(
                    "Ongoing",
                    style: TextStyle(
                        color:
                            _tabController.index == 1 ? kcWhite : kcPrimary400,
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
                    border: _tabController.index == 2
                        ? Border.all(color: kcTransparent)
                        : Border.all(color: kcPrimary700),
                    color: _tabController.index == 2
                        ? kcPrimary300
                        : kcTransparent,
                  ),
                  child: Text(
                    "Completed",
                    style: TextStyle(
                        color:
                            _tabController.index == 2 ? kcWhite : kcPrimary400,
                        fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                /// My Cart Tab
                cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 200,
                              width: 200,
                              child:
                                  Lottie.asset('asset/lottie/DBSkpgXyIT.json'),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                // context,
                                // MaterialPageRoute(
                                // builder: (context) => const OrderView(),
                                // ),
                                // );
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
                                  style:
                                      TextStyle(fontSize: 14, color: kcWhite),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.asset(
                                            "asset/images/Frame 269.png",
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    item.name,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color:
                                                            kcPrimaryNeutral300,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "${item.quantity} items",
                                                style: const TextStyle(
                                                    color: kcPrimaryNeutral300,
                                                    fontSize: 12),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "₦${(item.price * item.quantity).toStringAsFixed(0)}",
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
                                      onTap: () => ref
                                          .read(orderProvider.notifier)
                                          .deleteItem(index, tab: 'cart'),
                                      child: const CircleAvatar(
                                        backgroundColor: kcPrimaryRed900,
                                        radius: 12,
                                        child: Icon(Iconsax.trash,
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
                                        final selectedItems = [
                                          MenuItem(
                                            name: item.name,
                                            description:
                                                "Delicious ${item.name}",
                                            price: item.price,
                                            imageUrl:
                                                "https://via.placeholder.com/80",
                                            isAvailable: true,
                                          ),
                                        ];
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CheckoutScreen(
                                              selectedItems: selectedItems,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: kcPrimary300,
                                          borderRadius:
                                              BorderRadius.circular(30),
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

                /// Ongoing Tab
                ongoingItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 200,
                              width: 200,
                              child:
                                  Lottie.asset('asset/lottie/DBSkpgXyIT.json'),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const OrderView(),
                                //   ),
                                // );
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
                                  style:
                                      TextStyle(fontSize: 14, color: kcWhite),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            ongoingItems.length + (ongoingItems.length ~/ 2),
                        itemBuilder: (context, index) {
                          if (index % 3 == 2) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'asset/images/Frame 2693.png',
                                    width: 80,
                                    height: 80,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Delivery to Computer Villa...",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Iconsax.location,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            orderState.deliveryAddress,
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }

                          final itemIndex = index - (index ~/ 3);
                          final item = ongoingItems[itemIndex];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OngoingOrderView(
                                    orderItems: [item],
                                    orderTime: "2:00 pm",
                                    estimatedTime: "20-25 Minute",
                                    deliveryAddress: orderState.deliveryAddress,
                                    otp: "0987",
                                    subtotal: (item.price * item.quantity),
                                    deliveryFee: 1000,
                                    taxAndFees: 1000,
                                    total: (item.price * item.quantity +
                                            1000 +
                                            1000)
                                        .toDouble(),
                                    currentStep: 2,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          "asset/images/Frame 269.png",
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Iconsax.location,
                                                    size: 16,
                                                    color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  orderState.deliveryAddress,
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "${item.quantity} items",
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "₦${(item.price * item.quantity).toStringAsFixed(0)}",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SvgPicture.asset(
                                      "asset/svgs/dotted_line.svg"),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                /// Completed Tab
                completedItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 200,
                              width: 200,
                              child:
                                  Lottie.asset('asset/lottie/DBSkpgXyIT.json'),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => const OrderView(),
                                //   ),
                                // );
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
                                  style:
                                      TextStyle(fontSize: 14, color: kcWhite),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: completedItems.length,
                        itemBuilder: (context, index) {
                          final item = completedItems[index];
                          return Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                item.deliveryAddress ??
                                                    "Unknown Address",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Text(
                                                item.dateTime ?? "Unknown Date",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          verticalSpaceTiny,
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Order ID #${item.orderId ?? 'Unknown'}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          OngoingOrderView(
                                                        orderItems: [item],
                                                        orderTime: "2:00 pm",
                                                        estimatedTime:
                                                            "20-25 Minute",
                                                        deliveryAddress:
                                                            orderState
                                                                .deliveryAddress,
                                                        otp: "0987",
                                                        subtotal: (item.price *
                                                            item.quantity),
                                                        deliveryFee: 1000,
                                                        taxAndFees: 1000,
                                                        total: (item.price *
                                                                    item.quantity +
                                                                1000 +
                                                                1000)
                                                            .toDouble(),
                                                        currentStep: 8,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  "VIEW",
                                                  style: TextStyle(
                                                    color: kcPrimary400,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              verticalSpaceSmall,
                              SvgPicture.asset('asset/svgs/dotted_line.svg'),
                              verticalSpaceSmall,
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
