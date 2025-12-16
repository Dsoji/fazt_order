import 'package:fazt_order/src/common/app_colors.dart';
import 'package:fazt_order/src/common/res/app_colors.dart';
import 'package:fazt_order/src/features/home/presentation/restaurant_details.dart';
import 'package:fazt_order/src/features/profile/data/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:logger/logger.dart';

import '../../features/home/data/controller/shop_controller.dart';
import '../../features/home/data/model/response/shops_model/day_schedule.dart';
import '../../features/home/data/model/response/shops_model/result.dart';

final logger = Logger();

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Function to get the current day's schedule and times

    DaySchedule? getCurrentDaySchedule() {
      final schedule = restaurant.store?.salesOperation?.schedule;
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

    // Helper function to check if restaurant is currently open based on emergency + schedule
    bool isRestaurantOpen() {
      // Emergency override: explicit false always closes
      if (restaurant.isOpen == false) {
        return false;
      }

      final currentDaySchedule = getCurrentDaySchedule();
      final now = DateTime.now();
      logger.d(
          '[RestaurantCard] shop=${restaurant.id} weekday=${now.weekday} dayOpen=${currentDaySchedule?.open}');

      // If no schedule or day marked closed, treat as closed
      if (currentDaySchedule?.open != true) {
        return false;
      }

      final timeSlots = currentDaySchedule?.time;

      // Day is open and no time slots: open 24/7 for that day
      if (timeSlots == null || timeSlots.isEmpty) {
        return true;
      }

      Duration? clockFromIso(String iso) {
        try {
          // Treat the time portion as a plain clock (ignore timezone in the string)
          final timePart = iso.split('T').last.replaceAll('Z', '');
          final segments = timePart.split(':');
          if (segments.length < 2) return null;
          final h = int.parse(segments[0]);
          final m = int.parse(segments[1]);
          final s =
              segments.length > 2 ? int.parse(segments[2].split('.').first) : 0;
          return Duration(hours: h, minutes: m, seconds: s);
        } catch (e) {
          logger.e('Error parsing time: $e');
          return null;
        }
      }

      // Use local clock to compare against clock-only slot times
      final nowClock =
          Duration(hours: now.hour, minutes: now.minute, seconds: now.second);

      var hasValidSlot = false;

      for (final slot in timeSlots) {
        if (slot.startTime == null || slot.endTime == null) continue;
        final start = clockFromIso(slot.startTime!);
        final end = clockFromIso(slot.endTime!);
        if (start == null || end == null) continue;
        hasValidSlot = true;

        final crossesMidnight = end <= start;
        logger.d(
            '[RestaurantCard] slot start=$start end=$end crossesMidnight=$crossesMidnight now=$nowClock');

        final inSameDayRange =
            !crossesMidnight && nowClock >= start && nowClock <= end;
        final inOvernightRange =
            crossesMidnight && (nowClock >= start || nowClock <= end);

        if (inSameDayRange || inOvernightRange) {
          return true;
        }
      }

      // If we had slots but none matched, closed
      if (hasValidSlot) return false;

      // Slots list existed but all were invalid: treat as closed to be safe
      return false;
    }

    final isOpen = isRestaurantOpen();

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
