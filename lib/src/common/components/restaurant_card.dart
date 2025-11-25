import 'package:fazt_order/src/common/app_colors.dart';
import 'package:fazt_order/src/common/res/app_colors.dart';
import 'package:fazt_order/src/features/home/presentation/restaurant_details.dart';
import 'package:fazt_order/src/features/profile/data/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../features/home/data/controller/shop_controller.dart';
import '../../features/home/data/model/response/shops_model/day_schedule.dart';
import '../../features/home/data/model/response/shops_model/result.dart';

class RestaurantCard extends ConsumerWidget {
  final ShopResult restaurant;
  final int index;
  final bool? isLoggedIn;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.index,
    this.isLoggedIn = true,
  });

  // Helper function to get the current day's schedule
  DaySchedule? _getCurrentDaySchedule(ShopResult shop) {
    final schedule = shop.store?.salesOperation?.schedule;
    if (schedule == null) return null;

    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday

    switch (weekday) {
      case 1:
        return schedule.monday;
      case 2:
        return schedule.tuesday;
      case 3:
        return schedule.wednesday;
      case 4:
        return schedule.thursday;
      case 5:
        return schedule.friday;
      case 6:
        return schedule.saturday;
      case 7:
        return schedule.sunday;
      default:
        return null;
    }
  }

  // Helper function to check if restaurant is currently open based on schedule
  bool _isRestaurantOpen(ShopResult shop) {
    final currentDaySchedule = _getCurrentDaySchedule(shop);

    // Check if the day is marked as open
    if (currentDaySchedule?.open != true) {
      return false;
    }

    // Get time slots for today
    final timeSlots = currentDaySchedule?.time;

    // If no time slots exist, fall back to the open flag
    if (timeSlots == null || timeSlots.isEmpty) {
      return currentDaySchedule?.open ?? false;
    }

    final now = DateTime.now();
    bool hasValidTimeSlot = false;

    // Check if current time falls within any time slot
    for (final timeSlot in timeSlots) {
      if (timeSlot.startTime != null && timeSlot.endTime != null) {
        hasValidTimeSlot = true;
        try {
          // Parse the ISO 8601 time strings
          final startTime = DateTime.parse(timeSlot.startTime!);
          final endTime = DateTime.parse(timeSlot.endTime!);

          // Extract only the time portion (hours and minutes) for comparison
          final currentTime =
              DateTime(2000, 1, 1, now.hour, now.minute, now.second);
          final startTimeOnly = DateTime(
              2000, 1, 1, startTime.hour, startTime.minute, startTime.second);
          final endTimeOnly = DateTime(
              2000, 1, 1, endTime.hour, endTime.minute, endTime.second);

          // Check if current time is within the time range
          if (currentTime.isAfter(
                  startTimeOnly.subtract(const Duration(seconds: 1))) &&
              currentTime
                  .isBefore(endTimeOnly.add(const Duration(seconds: 1)))) {
            return true;
          }
        } catch (e) {
          // If parsing fails, skip this time slot
          continue;
        }
      }
    }

    // If time slots exist but none have valid startTime/endTime, fall back to open flag
    if (!hasValidTimeSlot) {
      return currentDaySchedule?.open ?? false;
    }

    // If we have valid time slots but current time doesn't fall within any, return false
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = _isRestaurantOpen(restaurant);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailsView(
              restaurant: restaurant,
              isLoggedIn: isLoggedIn,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        shadowColor: Colors.white.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    child: Image.network(
                      restaurant.store?.storeDisplayImage ?? '',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.white,
                        child: const Center(child: Icon(Icons.error)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          (restaurant.store?.storeName ?? '').toUpperCase(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
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
                        child: restaurant.isLiked == true
                            ? const Icon(Iconsax.heart5,
                                color: AppColors.green800, size: 24)
                            : const Icon(Iconsax.heart,
                                color: kcPrimaryNeutral200, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  Text(
                    "Landmark: ${restaurant.shopName ?? ''}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  //     Row(
                  //       children: [
                  //         const Icon(Iconsax.star1,
                  //             color: kcPrimaryOrange700, size: 16),
                  //         const SizedBox(width: 4),
                  //         Text(
                  //           "${restaurant.rating} (${restaurant.numberOfFavorites.toString()})",
                  //           style: const TextStyle(fontSize: 14),
                  //         ),
                  //       ],
                  //     ),
                  // ],
                  // ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Row(
                        children: [
                          Icon(IconsaxPlusLinear.activity,
                              size: 16, color: kcPrimaryNeutral200),
                          SizedBox(width: 4),
                          Text(
                            "Instant Delivery",
                            style: TextStyle(
                                fontSize: 14, color: kcPrimaryNeutral200),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (isOpen)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kcPrimaryOrange500,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "OPEN",
                            style: TextStyle(fontSize: 12, color: kcWhite),
                          ),
                        ),
                      if (!isOpen)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.red800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "CLOSED",
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
