import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import '../../../datamodels/restaurant.dart';
import '../../../providers/restaurant_provider.dart';
import '../../features/home/restaurant_details.dart';
import '../../features/home/search_restaurant_view.dart';
import '../app_colors.dart';
import '../ui_helpers.dart';
import '../widgets/text_styles.dart';

class RestaurantSearchCard extends ConsumerStatefulWidget {
  final Restaurant restaurant;
  final int index;

  const RestaurantSearchCard({
    super.key,
    required this.restaurant,
    required this.index,
  });

  @override
  _RestaurantSearchCardState createState() => _RestaurantSearchCardState();
}

class _RestaurantSearchCardState extends ConsumerState<RestaurantSearchCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(selectedFilterProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Expandable Card
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          widget.restaurant.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Restaurant Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${widget.restaurant.name} - ",
                                      style: ktBodySemiBoldSize16.copyWith(
                                        color: kcPrimaryNeutral200,
                                        fontFamily: "Lato",
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                    Text(
                                      widget.restaurant.location,
                                      style: ktBodyRegularSize14.copyWith(
                                        color: kcPrimaryNeutral200,
                                        fontFamily: "Lato",
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ],
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    widget.restaurant.isFavorite ? Iconsax.heart5 : Iconsax.heart,
                                    color: kcPrimaryNeutral200,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    ref.read(restaurantProvider.notifier).toggleFavorite(widget.index);
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset('asset/svgs/delivery_icon.svg'),
                                    horizontalSpace(4),
                                    Text(
                                      "From ₦${widget.restaurant.price}",
                                      style: ktBodyRegularSize12.copyWith(color: kcPrimaryNeutral200),
                                    ),
                                    horizontalSpace(4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: kcPrimaryOrange500,
                                      ),
                                      child: Text(
                                        widget.restaurant.isAvailable
                                            ? widget.restaurant.deliveryTime
                                            : "Closed",
                                        style: ktBodyRegularSize12.copyWith(color: kcWhite),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0, right: 6),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Iconsax.star1,
                                        color: kcPrimaryOrange700,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${widget.restaurant.rating} (${widget.restaurant.reviewCount})",
                                        style: ktBodyRegularSize14.copyWith(color: kcPrimaryNeutral200),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            verticalSpaceSmall,
                          ],
                        ),
                      ),
                      // Favorite Icon
                    ],
                  ),
                ),
                SvgPicture.asset("asset/svgs/dotted_line.svg"),

              ],
            ),
          ),
          // Expandable Content
          AnimatedContainer(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isExpanded ? null : 0,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectedFilter == "Menu" || selectedFilter == "ALL") ...[
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantDetailsView( // Updated to RestaurantDetailsView
                              restaurant: widget.restaurant,
                              // index: widget.index, // Commented out as per your previous code
                            ),
                          ),
                        );
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${widget.restaurant.name} ",
                                  style: ktBodySemiBoldSize16.copyWith(color: kcPrimaryNeutral200),
                                ),
                                const Icon(Iconsax.heart),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${widget.restaurant.location} ",
                                  style: ktBodyRegularSize12.copyWith(color: kcPrimaryNeutral500),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Iconsax.star1,
                                        color: kcPrimaryOrange700,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${widget.restaurant.rating} (${widget.restaurant.reviewCount})",
                                        style: ktBodyRegularSize14.copyWith(color: kcPrimaryNeutral200),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            verticalSpace(4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset('asset/svgs/delivery_icon.svg'),
                                    horizontalSpace(4),
                                    Text(
                                      "From ₦${widget.restaurant.price}",
                                      style: ktBodyRegularSize12.copyWith(color: kcPrimaryNeutral200),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: kcPrimaryOrange500,
                                  ),
                                  child: Text(
                                    widget.restaurant.isAvailable
                                        ? widget.restaurant.deliveryTime
                                        : "Closed",
                                    style: ktBodyRegularSize12.copyWith(color: kcWhite),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: _isExpanded ? screenHeight(context) * 0.188 : 0,
                      child: _isExpanded
                          ? Column(
                        children: [
                          verticalSpaceTiny,
                          SizedBox(
                            height: screenHeight(context) * 0.173,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildMenuItem("Amala", "₦400"),
                                const SizedBox(width: 8),
                                _buildMenuItem("Eba", "₦400"),
                                const SizedBox(width: 8),
                                _buildMenuItem("Jollof Rice", "₦400"),
                              ],
                            ),
                          ),
                          verticalSpaceTiny,
                          SvgPicture.asset("asset/svgs/dotted_line.svg"),
                        ],
                      )
                          : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String name, String price) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: kcPrimaryNeutral800, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "asset/images/Frame 2694.png",
              width: 80,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: ktBodyRegularSize12.copyWith(color: kcPrimaryNeutral200),
          ),
          verticalSpace(1),
          Text(
            name,
            style: ktBodyRegularSize12.copyWith(color: kcPrimaryNeutral500),
          ),
          verticalSpace(2),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: kcPrimary400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
            ),
            child: const Text(
              "Add to cart",
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}