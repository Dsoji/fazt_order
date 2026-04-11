import 'package:logger/logger.dart';
import 'package:fazt_order/src/features/home/data/model/response/shops_model/result.dart';
import 'package:fazt_order/src/features/home/data/model/response/shops_model/day_schedule.dart';

final _logger = Logger();

extension ShopStatusExtension on ShopResult {
  /// Gets the schedule for the current weekday
  DaySchedule? get currentDaySchedule {
    final schedule = store?.salesOperation?.schedule;
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

  /// Checks if the restaurant is currently open based on schedule and emergency flags
  bool get isOpenNow {
    // Check if schedule exists at all - schedule takes precedence
    final schedule = store?.salesOperation?.schedule;
    final now = DateTime.now();

    // If schedule exists, use it (schedule overrides restaurant.isOpen flag)
    if (schedule != null) {
      final currentSched = currentDaySchedule;
      _logger.d(
          '[ShopResult Extension] shop=$id weekday=${now.weekday} dayOpen=${currentSched?.open}');

      // If no schedule exists for current day, check emergency override
      if (currentSched == null) {
        _logger.d(
            '[ShopResult Extension] shop=$id no day schedule, checking emergency override');
        // Emergency override: explicit false always closes
        if (isOpen == false) {
          return false;
        }
        // If restaurant.isOpen is explicitly true, return true
        // If restaurant.isOpen is null, default to true (open by default)
        return isOpen ?? true;
      }

      // If schedule exists but day is marked closed
      if (currentSched.open != true) {
        _logger.d(
            '[ShopResult Extension] shop=$id day marked closed, open=${currentSched.open}');
        return false;
      }

      final timeSlots = currentSched.time;
      _logger.d(
          '[ShopResult Extension] shop=$id dayOpen=true, timeSlots=${timeSlots?.length ?? 0}');

      // Day open with no time slots: open all day
      final hasTimeSlots = timeSlots != null && timeSlots.isNotEmpty;
      if (!hasTimeSlots) {
        _logger.d(
            '[ShopResult Extension] shop=$id open all day (no time slots), returning true');
        return true;
      }

      Duration? clockFromIso(String iso) {
        try {
          final timePart =
              iso.split('T').last.replaceAll('Z', '').split('.').first;
          final segments = timePart.split(':');
          if (segments.length < 2) return null;
          final h = int.parse(segments[0]);
          final m = int.parse(segments[1]);
          final s = segments.length > 2 ? int.parse(segments[2]) : 0;
          return Duration(hours: h, minutes: m, seconds: s);
        } catch (e) {
          _logger.e('[ShopResult Extension] Error parsing time "$iso": $e');
          return null;
        }
      }

      // Use local clock to compare against clock-only slot times
      final nowClock =
          Duration(hours: now.hour, minutes: now.minute, seconds: now.second);

      var hasValidSlot = false;

      for (final timeSlot in timeSlots) {
        if (timeSlot.startTime == null || timeSlot.endTime == null) continue;

        final start = clockFromIso(timeSlot.startTime!);
        final end = clockFromIso(timeSlot.endTime!);
        if (start == null || end == null) continue;

        hasValidSlot = true;
        final crossesMidnight = end <= start;

        // For same-day ranges: current time must be >= start AND < end (exclusive end)
        // For overnight ranges: current time must be >= start OR < end
        final inSameDayRange =
            !crossesMidnight && nowClock >= start && nowClock < end;
        final inOvernightRange =
            crossesMidnight && (nowClock >= start || nowClock < end);

        if (inSameDayRange || inOvernightRange) {
          return true;
        }
      }

      if (hasValidSlot) return false;
      return false; // Slots list existed but all invalid
    }

    // No schedule exists - fall back to restaurant.isOpen flag
    _logger.d(
        '[ShopResult Extension] shop=$id no schedule, isOpen=$isOpen');
    if (isOpen == false) return false;
    return isOpen ?? true;
  }

  /// Formats time from ISO string to readable format (e.g., "2PM")
  String _formatTime(String? isoTime) {
    if (isoTime == null) return '';
    try {
      final dateTime = DateTime.parse(isoTime).toUtc();
      final hour = dateTime.hour;
      final minute = dateTime.minute;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      if (minute == 0) {
        return '$displayHour$period';
      } else {
        return '$displayHour:${minute.toString().padLeft(2, '0')}$period';
      }
    } catch (e) {
      _logger.e('Error formatting time: $e');
      return '';
    }
  }

  /// Gets opening hours display text like "OPENING FROM 9AM TO 10PM" or "CLOSED" or "ALL DAY"
  String get openingHoursDisplayText {
    final sched = currentDaySchedule;

    if (sched?.open != true) {
      return 'CLOSED';
    }

    final startTime = sched?.time?.isNotEmpty == true
        ? sched!.time!.first.startTime
        : null;
    final endTime = sched?.time?.isNotEmpty == true
        ? sched!.time!.first.endTime
        : null;

    if (startTime != null && endTime != null) {
      final formattedStartTime = _formatTime(startTime);
      final formattedEndTime = _formatTime(endTime);
      if (formattedStartTime.isNotEmpty && formattedEndTime.isNotEmpty) {
        return 'OPENING FROM\n$formattedStartTime TO $formattedEndTime';
      }
    }

    return 'ALL DAY';
  }
}
