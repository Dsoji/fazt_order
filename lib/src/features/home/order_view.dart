import 'package:fazt_order/src/common/app_colors.dart';
import 'package:fazt_order/src/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../datamodels/menu_items.dart';
import '../../../datamodels/order_items.dart';
import 'checkout_view.dart';

class OrderView extends ConsumerStatefulWidget {
  const OrderView({Key? key}) : super(key: key);

  @override
  _OrderViewState createState() => _OrderViewState();
}

class _OrderViewState extends ConsumerState<OrderView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<OrderItem> _cartItems = [
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
  ];

  // Add a list of ongoing orders
  List<OrderItem> _ongoingItems = [
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
    OrderItem(name: "Abacha", quantity: 3, price: 5000),
  ];

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

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      // AppBar(
      //   title: const Text("Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      //   actions: [
      //     TextButton(
      //       onPressed: _cartItems.isNotEmpty ? _clearCart : null,
      //       child: Text(
      //         "Clear cart items",
      //         style: TextStyle(color: _cartItems.isNotEmpty ? kcPrimary400 : Colors.grey, decoration: TextDecoration.underline,),
      //
      //       ),
      //     ),
      //   ],
      // ),
      AppBar(
        title: const Text("Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          GestureDetector(
            onTap: _cartItems.isNotEmpty ? _clearCart : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Match TextButton padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Clear cart items",
                    style: TextStyle(
                      color: _cartItems.isNotEmpty ? kcPrimary400 : Colors.grey,
                    ),
                  ),
                  // horizontalLine(width: 90, color: _cartItems.isNotEmpty ? kcPrimary400 : Colors.grey, thicknessValue: 1),
                  verticalSpace(1),
                  Container(
                    height: 1,
                    width: 90,
                    color: _cartItems.isNotEmpty ? kcPrimary400 : Colors.grey,
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
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            tabs: [
              Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: _tabController.index == 0
                        ? Border.all(color: kcTransparent)
                        : Border.all(color: kcPrimary700),
                    color: _tabController.index == 0 ? kcPrimary300 : kcTransparent,
                  ),
                  child: Text(
                    "My Cart",
                    style: TextStyle(color: _tabController.index == 0 ? kcWhite : kcPrimary400, fontSize: 12),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: _tabController.index == 1
                        ? Border.all(color: kcTransparent)
                        : Border.all(color: kcPrimary700),
                    color: _tabController.index == 1 ? kcPrimary300 : kcTransparent,
                  ),
                  child: Text(
                    "Ongoing",
                    style: TextStyle(color: _tabController.index == 1 ? kcWhite : kcPrimary400, fontSize: 12),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: _tabController.index == 2
                        ? Border.all(color: kcTransparent)
                        : Border.all(color: kcPrimary700),
                    color: _tabController.index == 2 ? kcPrimary300 : kcTransparent,
                  ),
                  child: Text(
                    "Completed",
                    style: TextStyle(color: _tabController.index == 2 ? kcWhite : kcPrimary400, fontSize: 12),
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
                // My Cart Tab
                _cartItems.isEmpty
                    ? const Center(child: Text("Your cart is empty", style: TextStyle(fontSize: 14, color: kcPrimary400),))
                    : ListView.builder(
                  itemCount: _cartItems.length,
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Row(
                              children: [
                                // Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    "asset/images/Frame 269.png",
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                horizontalSpace(7),
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                      verticalSpaceTiny,
                                      Row(
                                        children: [
                                          SvgPicture.asset("asset/svgs/delivery_icon.svg"),
                                          horizontalSpaceTiny,
                                          const Text(
                                            "12, Oritshe street, Ikeja, Lagos State",
                                            maxLines: 2,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: kcPrimaryNeutral300, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      verticalSpaceTiny,
                                      Text(
                                        "${item.quantity} items",
                                        style: const TextStyle(color: kcPrimaryNeutral300, fontSize: 12),
                                      ),
                                      verticalSpaceTiny,
                                      Text(
                                        "₦${item.price.toStringAsFixed(0)}",
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: kcPrimaryNeutral300),
                                      ),
                                    ],
                                  ),
                                ),
                                // Actions
                                verticalSpaceTiny,
                              ],
                            ),
                          ),
                          Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                            onTap: () => _removeItem(index),
                            child: const CircleAvatar(
                                backgroundColor: kcPrimaryRed900,
                                radius: 12,
                                child: Icon(Iconsax.trash, size: 15, color: kcPrimaryRed200),
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
                                  selectedItems: [
                                    MenuItem(
                                      name: item.name,
                                      description: "Delicious Abacha",
                                      price: item.price,
                                      imageUrl: "https://via.placeholder.com/80",
                                      isAvailable: true,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: kcPrimary300,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text('Checkout', style: TextStyle(color: kcWhite))
                          ),
                        ),
                        )
                      ]
                        ),
                        SvgPicture.asset("asset/svgs/dotted_line.svg"),
                      ],
                    );
                  },
                ),


                // Ongoing Tab (Placeholder)
                _ongoingItems.isEmpty
                    ? const Center(child: Text("No ongoing orders"))
                    : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _ongoingItems.length + (_ongoingItems.length ~/ 2), // Add delivery sections
                  itemBuilder: (context, index) {
                    // Check if the current index is for a delivery section
                    if (index % 3 == 2) {
                      // Show "Delivery to Computer Villa..." section after every 2 items
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          children: [
                            Image.asset('asset/images/Frame 2693.png',
                            width: 80,
                            height: 80,),
                            verticalSpaceMedium,
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Delivery to Computer Villa...",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                verticalSpaceTiny,
                                Row(
                                  children: [
                                    Icon(Iconsax.location, size: 16, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(
                                      "12, Oritshe street, Ikeja, Lagos State",
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    // Calculate the actual item index (subtract the delivery sections)
                    final itemIndex = index - (index ~/ 3);
                    final item = _ongoingItems[itemIndex];
                    return Padding(
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
                              horizontalSpaceMedium,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    verticalSpaceTiny,
                                    Row(
                                      children: [
                                        Icon(Iconsax.location, size: 16, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          "12, Oritshe street, Ikeja, Lagos State",
                                          style: TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "${item.quantity} items",
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "₦${item.price.toStringAsFixed(0)}",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          verticalSpaceSmall,
                          SvgPicture.asset("asset/svgs/dotted_line.svg"),
                        ],
                      ),
                    );
                  },
                ),


                // Completed Tab (Placeholder)
                const Center(child: Text("No completed orders")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}