import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:men_health_and_wellness/core/errors/app_exception.dart';
import 'package:men_health_and_wellness/core/storage/key_value_store.dart';
import 'package:men_health_and_wellness/features/habits/domain/habit.dart';
import 'package:men_health_and_wellness/features/habits/domain/habit_stats.dart';
import 'package:men_health_and_wellness/features/habits/presentation/controllers/habit_controllers.dart';
import 'package:men_health_and_wellness/features/settings/domain/user_preferences.dart';

import '../helpers/fakes.dart';

void main() {
  final monday = DateTime(2026, 10, 26);
  final wednesday = DateTime(2026, 10, 28);

  Habit habit({Set<int> days = Habit.allDays, bool active = true, DateTime? start}) =>
      Habit(id: 'h1', title: 'Walk', weekdays: days, startDate: start ?? monday, active: active);

  group('Habit', () {
    test('schedule respects weekdays, start date and paused state', () {
      final h = habit(days: {1, 3});
      expect(h.isScheduledOn(monday), isTrue);
      expect(h.isScheduledOn(monday.add(const Duration(days: 1))), isFalse);
      expect(h.isScheduledOn(monday.subtract(const Duration(days: 7))), isFalse);
      expect(habit(active: false).isScheduledOn(monday), isFalse);
      expect(h.scheduleLabel, 'Mon, Wed');
    });

    test('json round trip, tolerant parse', () {
      final h = habit().copyWith(reminder: () => const TimeOfDay(hour: 7, minute: 15));
      final back = Habit.fromJson(h.toJson())!;
      expect(back.reminder, const TimeOfDay(hour: 7, minute: 15));
      expect(back.weekdays, Habit.allDays);
      expect(Habit.fromJson({'id': 'x'}), isNull);
    });

    test('validation', () {
      expect(HabitValidator.title(''), isNotNull);
      expect(HabitValidator.title('a' * 61), isNotNull);
      expect(HabitValidator.title('Walk'), isNull);
      expect(HabitValidator.weekdays({}), isNotNull);
    });
  });

  group('HabitStats', () {
    test('week progress counts only scheduled days up to today', () {
      final h = habit();
      final stats = HabitStats([h], {completionKey('h1', monday), completionKey('h1', wednesday)});
      expect(stats.weekProgress(wednesday), (2, 3));
    });

    test('daily completions oldest first', () {
      final stats = HabitStats([habit()], {completionKey('h1', wednesday)});
      final days = stats.dailyCompletions(wednesday, 3);
      expect(days.map((d) => d.$2), [0, 0, 1]);
    });
  });

  group('HabitsController', () {
    test('save schedules discreet reminder, delete removes completions and reminder', () async {
      final env = TestEnv(prefs: const UserPreferences(onboardingComplete: true));
      final c = env.container();
      final h = habit().copyWith(reminder: () => const TimeOfDay(hour: 8, minute: 0));
      await c.read(habitsProvider.notifier).save(h);
      expect(env.scheduler.scheduled['habit:h1']!.body, 'Your wellness reminder is ready.');
      expect(env.scheduler.scheduled['habit:h1']!.body.contains('Walk'), isFalse);

      await c.read(habitCompletionsProvider.notifier).toggle(h, wednesday);
      expect(c.read(habitStatsProvider).isDone(h, wednesday), isTrue);

      await c.read(habitsProvider.notifier).delete('h1');
      expect(env.storage.store(StoreName.habitCompletions).data, isEmpty);
      expect(env.scheduler.scheduled, isEmpty);
    });

    test('pausing cancels reminder', () async {
      final env = TestEnv();
      final c = env.container();
      final h = habit().copyWith(reminder: () => const TimeOfDay(hour: 8, minute: 0));
      await c.read(habitsProvider.notifier).save(h);
      await c.read(habitsProvider.notifier).setActive(h, false);
      expect(env.scheduler.scheduled, isEmpty);
    });

    test('invalid habit is rejected', () async {
      final c = TestEnv().container();
      expect(
        () => c.read(habitsProvider.notifier).save(habit().copyWith(title: ' ')),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
