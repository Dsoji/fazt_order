import 'dart:math';

import 'package:intl/intl.dart';

extension DateUtil on DateTime {
  String getDate() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  String formatToReadableDateTime() {
    // List of months to match the format 'Mar' for example
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    // Extract parts of the date
    String day = this.day.toString().padLeft(2, '0');
    String month = months[this.month - 1];
    String year = this.year.toString();

    // Extract parts of the time
    String hour = this.hour.toString().padLeft(2, '0');
    String minute = this.minute.toString().padLeft(2, '0');
    String second = this.second.toString().padLeft(2, '0');

    // Return formatted string
    return '$day $month, $year $hour:$minute:$second';
  }

  String getDateAsWords() {
    return DateFormat('dd MMMM yyyy').format(this);
  }

  // Write an extension method on DateTime to format it as January 1, 2023
  String getFormattedDate() {
    return DateFormat('MMMM dd, yyyy').format(this);
  }

  String getTime() {
    return DateFormat('h:mm a').format(this);
  }

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }

  String timeAgo() {
    final now = DateTime.now();
    final difference =
        now.difference(this).abs(); // Use abs() to handle future dates

    if (difference.inSeconds < 60) {
      return difference.inSeconds == 1
          ? 'a second ago'
          : '${difference.inSeconds} seconds ago';
    }

    if (difference.inMinutes < 60) {
      return difference.inMinutes == 1
          ? 'a minute ago'
          : '${difference.inMinutes} minutes ago';
    }

    if (difference.inHours < 24) {
      return difference.inHours == 1
          ? 'an hour ago'
          : '${difference.inHours} hours ago';
    }

    if (difference.inDays < 7) {
      return difference.inDays == 1
          ? 'a day ago'
          : '${difference.inDays} days ago';
    }

    return getDateAsWords(); // Assuming this method returns the date in a different format
  }

  String timeAgoShort() {
    final now = DateTime.now();
    final difference =
        now.difference(this).abs(); // Use abs() to handle future dates

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s'; // Seconds
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m'; // Minutes
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h'; // Hours
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d'; // Days
    }

    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w'; // Weeks
    }

    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo'; // Months
    }

    return '${(difference.inDays / 365).floor()}y'; // Years
  }

  static DateTime randomPastDate() {
    return DateTime.now().subtract(Duration(days: Random().nextInt(365)));
  }

  static DateTime covertStringToDate(String date) {
    return DateTime.parse(date);
  }
}
