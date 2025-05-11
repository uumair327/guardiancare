import 'package:intl/intl.dart';

class AppDateUtils {
  // Common date formats
  static const String dateFormatYMD = 'yyyy-MM-dd';
  static const String dateFormatDMY = 'dd/MM/yyyy';
  static const String dateFormatMDY = 'MM/dd/yyyy';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String timeFormat12 = 'h:mm a';
  static const String timeFormat24 = 'HH:mm';
  static const String dayMonth = 'dd MMM';
  static const String dayMonthYear = 'dd MMM yyyy';
  static const String monthYear = 'MMM yyyy';
  static const String dayName = 'EEEE';
  static const String dayNameShort = 'EEE';

  // Format DateTime to string
  static String formatDate(DateTime date, {String format = dateFormatYMD}) {
    return DateFormat(format).format(date);
  }

  // Parse string to DateTime
  static DateTime? parseDate(String dateString, {String format = dateFormatYMD}) {
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Format timestamp (milliseconds since epoch) to string
  static String formatTimestamp(int timestamp, {String format = dateFormatYMD}) {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(timestamp), format: format);
  }

  // Get current date as string
  static String getCurrentDate({String format = dateFormatYMD}) {
    return formatDate(DateTime.now(), format: format);
  }

  // Get current timestamp in milliseconds
  static int get currentTimestamp => DateTime.now().millisecondsSinceEpoch;

  // Get time ago string (e.g., "2 hours ago")
  static String timeAgo(DateTime date, {bool numericDates = true}) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  // Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }

  // Check if a date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Check if a date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  // Add days to a date
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  // Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day (23:59:59.999)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get first day of the week (Monday)
  static DateTime firstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Get last day of the week (Sunday)
  static DateTime lastDayOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
  }

  // Get first day of the month
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get last day of the month
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Get days in month
  static int daysInMonth(DateTime date) {
    return lastDayOfMonth(date).day;
  }

  // Format duration (e.g., "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Get age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    // Adjust age if birthday hasn't occurred yet this year
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  // Check if a year is a leap year
  static bool isLeapYear(int year) {
    return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
  }

  // Get list of days in a month
  static List<DateTime> getDaysInMonth(DateTime month) {
    final first = firstDayOfMonth(month);
    final last = lastDayOfMonth(month);
    final days = last.difference(first).inDays + 1;
    
    return List.generate(
      days,
      (index) => DateTime(first.year, first.month, first.day + index),
    );
  }

  // Get list of months between two dates
  static List<DateTime> getMonthsInRange(DateTime startDate, DateTime endDate) {
    final months = <DateTime>[];
    var current = DateTime(startDate.year, startDate.month, 1);
    
    while (!current.isAfter(DateTime(endDate.year, endDate.month, 1))) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }
    
    return months;
  }

  // Format date range (e.g., "Jan 1 - 15, 2023")
  static String formatDateRange(DateTime start, DateTime end, {bool showYear = true}) {
    final startFormat = [
      DateFormat.MMMd(),
      if (showYear) ' yyyy',
    ].join();
    
    final endFormat = [
      if (start.month != end.month) DateFormat.MMMd(),
      if (start.year != end.year) ' yyyy' else if (start.month != end.month) 'd',
      if (start.month == end.month) 'd',
    ].join();
    
    final formattedStart = DateFormat(startFormat).format(start);
    final formattedEnd = DateFormat(endFormat).format(end);
    
    return '$formattedStart - $formattedEnd';
  }
}
