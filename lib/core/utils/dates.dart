/// Date helpers that operate on calendar days in local time.
abstract final class Dates {
  static DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Stable key like `2026-10-28`, used for per-day records.
  static String key(DateTime d) {
    final day = dayOf(d);
    return '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  static DateTime parseKey(String key) {
    final parts = key.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  /// Monday-based start of the week containing [d].
  static DateTime startOfWeek(DateTime d) {
    final day = dayOf(d);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  static List<DateTime> lastNDays(DateTime today, int n) => [
    for (var i = n - 1; i >= 0; i--) dayOf(today).subtract(Duration(days: i)),
  ];

  static bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
