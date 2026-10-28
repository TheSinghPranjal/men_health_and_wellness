import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/storage/storage_providers.dart';
import '../../../reminders/data/reminder_scheduler.dart';
import '../../../reminders/domain/reminder.dart';
import '../../../settings/presentation/controllers/preferences_controller.dart';
import '../../data/habit_repository.dart';
import '../../domain/habit.dart';
import '../../domain/habit_stats.dart';

class HabitsController extends Notifier<List<Habit>> {
  @override
  List<Habit> build() => ref.watch(habitRepositoryProvider).habits();

  Future<void> save(Habit habit) async {
    final error =
        HabitValidator.title(habit.title) ??
        HabitValidator.description(habit.description) ??
        HabitValidator.weekdays(habit.weekdays);
    if (error != null) throw ValidationException(error);
    await ref.read(habitRepositoryProvider).saveHabit(habit);
    final exists = state.any((h) => h.id == habit.id);
    state = exists ? [for (final h in state) h.id == habit.id ? habit : h] : [...state, habit];
    await _syncReminder(habit);
  }

  Future<void> setActive(Habit habit, bool active) => save(habit.copyWith(active: active));

  Future<void> delete(String id) async {
    await ref.read(habitRepositoryProvider).deleteHabit(id);
    state = state.where((h) => h.id != id).toList();
    ref.read(habitCompletionsProvider.notifier).forgetHabit(id);
    await _cancelReminder(id);
  }

  Future<void> deleteAll() async {
    for (final h in state) {
      await _cancelReminder(h.id);
    }
    await ref.read(habitRepositoryProvider).deleteAll();
    state = const [];
    ref.read(habitCompletionsProvider.notifier).forgetAll();
  }

  /// Re-schedules every habit reminder, e.g. after a wording change.
  Future<void> resyncReminders() async {
    for (final h in state) {
      await _syncReminder(h);
    }
  }

  Future<void> _syncReminder(Habit h) async {
    final scheduler = ref.read(reminderSchedulerProvider);
    try {
      if (!h.active || h.reminder == null) {
        await scheduler.cancel('habit:${h.id}');
        return;
      }
      final (title, body) = ReminderWording.habit(
        h.title,
        discreet: ref.read(preferencesProvider).discreetNotifications,
      );
      await scheduler.schedule(
        ReminderSpec(id: 'habit:${h.id}', title: title, body: body, time: h.reminder!, weekdays: h.weekdays),
      );
    } catch (e, s) {
      // The habit itself is saved; surface the reminder problem separately.
      AppLogger.error('habit.reminder_failed', e, s);
      throw const PlatformFeatureException('Your habit was saved, but its reminder could not be scheduled.');
    }
  }

  Future<void> _cancelReminder(String id) async {
    try {
      await ref.read(reminderSchedulerProvider).cancel('habit:$id');
    } catch (e, s) {
      AppLogger.error('habit.reminder_cancel_failed', e, s);
    }
  }
}

final habitsProvider = NotifierProvider<HabitsController, List<Habit>>(HabitsController.new);

class HabitCompletionsController extends Notifier<Set<String>> {
  @override
  Set<String> build() => ref.watch(habitRepositoryProvider).completions();

  Future<void> toggle(Habit habit, DateTime day) async {
    final key = completionKey(habit.id, day);
    final done = !state.contains(key);
    await ref.read(habitRepositoryProvider).setCompleted(key, done);
    state = done ? {...state, key} : ({...state}..remove(key));
  }

  // State is updated in place rather than invalidated: invalidating while a
  // covered tab's consumers are paused triggers a Riverpod 3.3 rebuild-
  // during-build bug on resume (fixed upstream in 3.4, which needs Dart 3.12).
  void forgetHabit(String habitId) => state = state.where((k) => !k.startsWith('$habitId|')).toSet();
  void forgetAll() => state = const {};
}

final habitCompletionsProvider = NotifierProvider<HabitCompletionsController, Set<String>>(
  HabitCompletionsController.new,
);

final habitStatsProvider = Provider<HabitStats>(
  (ref) => HabitStats(ref.watch(habitsProvider), ref.watch(habitCompletionsProvider)),
);

/// Habits scheduled for today. Depends on [habitsProvider] directly (not on
/// [habitStatsProvider]) to avoid a provider-to-provider chain.
final todaysHabitsProvider = Provider<List<Habit>>((ref) {
  final today = ref.watch(clockProvider)();
  return ref.watch(habitsProvider).where((h) => h.isScheduledOn(today)).toList();
});
