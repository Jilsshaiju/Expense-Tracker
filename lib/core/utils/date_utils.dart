import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _displayFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dayFormat = DateFormat('EEE, dd MMM');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _shortDate = DateFormat('dd/MM/yy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  static String toDisplay(DateTime dt) => _displayFormat.format(dt);
  static String toDayFormat(DateTime dt) => _dayFormat.format(dt);
  static String toMonthYear(DateTime dt) => _monthYear.format(dt);
  static String toShort(DateTime dt) => _shortDate.format(dt);
  static String toTime(DateTime dt) => _timeFormat.format(dt);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameWeek(DateTime a, DateTime b) {
    final startOfWeekA = a.subtract(Duration(days: a.weekday - 1));
    final startOfWeekB = b.subtract(Duration(days: b.weekday - 1));
    return isSameDay(startOfWeekA, startOfWeekB);
  }

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static DateTime startOfWeek(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day - (dt.weekday - 1));

  static DateTime startOfMonth(DateTime dt) => DateTime(dt.year, dt.month, 1);

  static String relativeLabel(DateTime dt) {
    final now = DateTime.now();
    if (isSameDay(dt, now)) return 'Today';
    if (isSameDay(dt, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return toDisplay(dt);
  }
}
