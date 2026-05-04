import 'package:cached_network_image/cached_network_image.dart';
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
import '../../features/home/data/model/response/shops_model/promotion_display.dart';
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
    logger.d(
        'restaurant.store?.salesOperation?.schedule: ${restaurant.store?.salesOperation?.schedule}');

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
      // Check if schedule exists at all - schedule takes precedence
      final schedule = restaurant.store?.salesOperation?.schedule;
      final now = DateTime.now();

      // If schedule exists, use it (schedule overrides restaurant.isOpen flag)
      if (schedule != null) {
        final currentDaySchedule = getCurrentDaySchedule();
        logger.d(
            '[RestaurantCard] shop=${restaurant.id} weekday=${now.weekday} dayOpen=${currentDaySchedule?.open}');

        // If no schedule exists for current day, check emergency override
        if (currentDaySchedule == null) {
          logger.d(
              '[RestaurantCard] shop=${restaurant.id} no day schedule, checking emergency override');
          // Emergency override: explicit false always closes
          if (restaurant.isOpen == false) {
            return false;
          }
          // If restaurant.isOpen is explicitly true, return true
          // If restaurant.isOpen is null, default to true (open by default)
          return restaurant.isOpen ?? true;
        }

        // If schedule exists but day is marked closed
        if (currentDaySchedule.open != true) {
          logger.d(
              '[RestaurantCard] shop=${restaurant.id} day marked closed, open=${currentDaySchedule.open}');
          return false;
        }

        final timeSlots = currentDaySchedule.time;
        logger.d('timeSlots: $timeSlots');
        logger.d(
            '[RestaurantCard] shop=${restaurant.id} dayOpen=true, timeSlots=${timeSlots?.length ?? 0}, isEmpty=${timeSlots?.isEmpty ?? true}, isNull=${timeSlots == null}');

        // Day open with no time slots: open all day
        // When schedule says open:true and time array is empty, shop is open all day
        // This MUST be checked BEFORE processing any time slots
        // Check for null or empty list - if either is true, return open all day
        final hasTimeSlots = timeSlots != null && timeSlots.isNotEmpty;
        if (!hasTimeSlots) {
          logger.d(
              '[RestaurantCard] shop=${restaurant.id} open all day (no time slots), returning true immediately');
          return true;
        }

        // Only process time slots if the array is NOT empty
        logger.d(
            '[RestaurantCard] shop=${restaurant.id} has ${timeSlots.length} time slot(s), processing...');

        Duration? clockFromIso(String iso) {
          try {
            // Extract time portion from ISO string (times are stored in UTC format but represent local business hours)
            // Example: "2025-11-21T09:00:00.000Z" -> extract "09:00:00" -> 9 AM local time
            final timePart =
                iso.split('T').last.replaceAll('Z', '').split('.').first;
            final segments = timePart.split(':');
            if (segments.length < 2) return null;
            final h = int.parse(segments[0]);
            final m = int.parse(segments[1]);
            final s = segments.length > 2 ? int.parse(segments[2]) : 0;
            return Duration(hours: h, minutes: m, seconds: s);
          } catch (e) {
            logger.e('[RestaurantCard] Error parsing time "$iso": $e');
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
          if (start == null || end == null) {
            logger.e(
                '[RestaurantCard] Failed to parse times: startTime=${slot.startTime}, endTime=${slot.endTime}');
            continue;
          }
          hasValidSlot = true;

          final crossesMidnight = end <= start;
          logger.d(
              '[RestaurantCard] shop=${restaurant.id} slot: startTime=${slot.startTime} -> $start, endTime=${slot.endTime} -> $end, nowClock=$nowClock, crossesMidnight=$crossesMidnight');

          // For same-day ranges: current time must be >= start AND < end (exclusive end)
          // For overnight ranges: current time must be >= start OR < end
          final inSameDayRange =
              !crossesMidnight && nowClock >= start && nowClock < end;
          final inOvernightRange =
              crossesMidnight && (nowClock >= start || nowClock < end);

          logger.d(
              '[RestaurantCard] shop=${restaurant.id} inSameDayRange=$inSameDayRange, inOvernightRange=$inOvernightRange');

          if (inSameDayRange || inOvernightRange) {
            logger.d(
                '[RestaurantCard] shop=${restaurant.id} is OPEN (within time slot)');
            return true;
          }
        }

        // If we had slots but none matched, closed
        if (hasValidSlot) {
          logger.d(
              '[RestaurantCard] shop=${restaurant.id} is CLOSED (outside time slots)');
          return false;
        }

        // Slots list existed but all were invalid: treat as closed to be safe
        logger.d(
            '[RestaurantCard] shop=${restaurant.id} is CLOSED (no valid time slots)');
        return false;
      }

      // No schedule exists - fall back to restaurant.isOpen flag
      logger.d(
          '[RestaurantCard] shop=${restaurant.id} no schedule, isOpen=${restaurant.isOpen}');
      // Emergency override: explicit false always closes
      if (restaurant.isOpen == false) {
        return false;
      }
      // If restaurant.isOpen is explicitly true, return true
      // If restaurant.isOpen is null, default to true (open by default)
      return restaurant.isOpen ?? true;
    }

    final isOpen = isRestaurantOpen();
    logger.d(
        '[RestaurantCard] shop=${restaurant.id} FINAL isOpen=$isOpen, restaurant.isOpen=${restaurant.isOpen}');

    Future<void> toggleFavorite() async {
      await ref
          .read(profileControllerProvider.notifier)
          .addToFavorites(shopId: restaurant.id ?? '');
      await ref
          .read(profileControllerProvider.notifier)
          .fetchFavouritesList();
      await ref.read(shopControllerProvider.notifier).revalidateShops();
    }

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
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Builder(
                  builder: (context) {
                    final imageUrl = restaurant.store?.storeDisplayImage;
                    Widget fallback() => Container(
                          height: 160,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.storefront,
                            color: Colors.grey[500],
                            size: 48,
                          ),
                        );
                    if (imageUrl == null || imageUrl.isEmpty) {
                      return fallback();
                    }
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => fallback(),
                      errorWidget: (context, url, error) => fallback(),
                    );
                  },
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _PromoBadges(
                    promotion: restaurant.store?.promotionDisplay,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        restaurant.isLiked == true
                            ? Iconsax.heart5
                            : Iconsax.heart,
                        color: restaurant.isLiked == true
                            ? AppColors.green800
                            : kcPrimaryNeutral400,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.store?.storeName ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 0.1,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Iconsax.location,
                          size: 13, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.shopName ?? '',
                          style: TextStyle(
                              fontSize: 12.5, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(IconsaxPlusLinear.activity,
                          size: 14, color: kcPrimaryNeutral400),
                      const SizedBox(width: 4),
                      const Text(
                        "Instant Delivery",
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: kcPrimaryNeutral400),
                      ),
                      const Spacer(),
                      RestaurantStatusPill(isOpen: isOpen),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantStatusPill extends StatelessWidget {
  const RestaurantStatusPill({super.key, required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.green800 : AppColors.red800;
    final label = isOpen ? 'OPEN' : 'CLOSED';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBadges extends StatelessWidget {
  const _PromoBadges({required this.promotion});

  final PromotionDisplay? promotion;

  @override
  Widget build(BuildContext context) {
    if (promotion?.hasActivePromotion != true) return const SizedBox.shrink();

    final freeDelivery = promotion?.freeDelivery == true;
    final percent = promotion?.discountPercent ?? 0;
    final showDiscount = percent > 0;

    if (!freeDelivery && !showDiscount) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDiscount)
          _PromoChip(
            icon: Iconsax.discount_shape,
            label: '${percent.toStringAsFixed(0)}% OFF',
            color: kcPrimaryOrange500,
          ),
        if (showDiscount && freeDelivery) const SizedBox(height: 6),
        if (freeDelivery)
          const _PromoChip(
            icon: Iconsax.truck_fast,
            label: 'Free Delivery',
            color: AppColors.green800,
          ),
      ],
    );
  }
}

class _PromoChip extends StatelessWidget {
  const _PromoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
