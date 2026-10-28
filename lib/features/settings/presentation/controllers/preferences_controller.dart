import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/enums.dart';
import '../../data/preferences_repository.dart';
import '../../domain/user_preferences.dart';

/// Source of truth for preferences. Reads are synchronous (stores are open
/// before the UI starts); writes persist first, then update state, so the
/// UI never shows a value that failed to save.
class PreferencesController extends Notifier<UserPreferences> {
  @override
  UserPreferences build() => ref.watch(preferencesRepositoryProvider).load();

  Future<void> update(UserPreferences Function(UserPreferences) change) async {
    final next = change(state);
    await ref.read(preferencesRepositoryProvider).save(next);
    state = next;
  }

  Future<void> setThemeMode(AppThemeMode mode) => update((p) => p.copyWith(themeMode: mode));

  Future<void> toggleGoal(WellnessGoal goal) => update((p) {
    final goals = {...p.goals};
    goals.contains(goal) ? goals.remove(goal) : goals.add(goal);
    return p.copyWith(goals: goals);
  });

  Future<void> toggleMetric(TrackedMetric metric) => update((p) {
    final metrics = {...p.trackedMetrics};
    metrics.contains(metric) ? metrics.remove(metric) : metrics.add(metric);
    return p.copyWith(trackedMetrics: metrics);
  });

  /// Re-reads from storage, e.g. after all data has been deleted.
  void reload() => state = ref.read(preferencesRepositoryProvider).load();
}

final preferencesProvider = NotifierProvider<PreferencesController, UserPreferences>(PreferencesController.new);
