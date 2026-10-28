import '../../../core/utils/dates.dart';
import 'habit.dart';

/// Completion key for a habit on a calendar day.
String completionKey(String habitId, DateTime day) => '$habitId|${Dates.key(day)}';

/// Neutral progress figures. Missed days are simply not counted; there are
/// no streaks to lose.
class HabitStats {
  const HabitStats(this.habits, this.completions);
  final List<Habit> habits;
  final Set<String> completions;

  bool isDone(Habit h, DateTime day) => completions.contains(completionKey(h.id, day));

  List<Habit> scheduledOn(DateTime day) => habits.where((h) => h.isScheduledOn(day)).toList();

  /// (completed, scheduled) for the Monday-based week containing [today],
  /// counting only days up to and including today.
  (int, int) weekProgress(DateTime today) {
    var done = 0;
    var scheduled = 0;
    final start = Dates.startOfWeek(today);
    for (var i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      if (day.isAfter(Dates.dayOf(today))) break;
      for (final h in scheduledOn(day)) {
        scheduled++;
        if (isDone(h, day)) done++;
      }
    }
    return (done, scheduled);
  }

  /// Completions per day for the last [days] days (oldest first).
  List<(DateTime, int)> dailyCompletions(DateTime today, int days) => [
    for (final day in Dates.lastNDays(today, days)) (day, habits.where((h) => isDone(h, day)).length),
  ];

  int completedIn(DateTime from, DateTime to) {
    var n = 0;
    for (final key in completions) {
      final parts = key.split('|');
      if (parts.length != 2) continue;
      final day = Dates.parseKey(parts[1]);
      if (!day.isBefore(Dates.dayOf(from)) && !day.isAfter(Dates.dayOf(to))) n++;
    }
    return n;
  }
}
