import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/clinician_support/presentation/controllers/clinician_prep_controller.dart';
import '../../features/daily_log/presentation/controllers/daily_log_controller.dart';
import '../../features/education/presentation/controllers/library_controller.dart';
import '../../features/experiment/presentation/controllers/experiment_controller.dart';
import '../../features/habits/presentation/controllers/habit_controllers.dart';
import '../../features/reflections/presentation/controllers/reflection_controllers.dart';
import '../../features/reminders/data/reminder_scheduler.dart';
import '../../features/reminders/presentation/controllers/reminder_controller.dart';
import '../../features/settings/presentation/controllers/preferences_controller.dart';
import '../logging/app_logger.dart';
import '../storage/storage_providers.dart';

/// Removes every piece of locally stored personal data and cancels all
/// scheduled notifications. Bundled educational content is unaffected.
class DataDeletionService {
  DataDeletionService(this._ref);
  final Ref _ref;

  Future<void> deleteEverything() async {
    try {
      await _ref.read(reminderSchedulerProvider).cancelAll();
    } catch (e, s) {
      // Continue: data deletion must not be blocked by notification APIs.
      AppLogger.error('deletion.cancel_notifications_failed', e, s);
    }
    await _ref.read(appStorageProvider).clearAll();
    for (final p in [
      preferencesProvider,
      libraryProvider,
      reflectionHistoryProvider,
      habitsProvider,
      habitCompletionsProvider,
      dailyLogProvider,
      clinicianPrepProvider,
      experimentProvider,
      wellnessReminderProvider,
    ]) {
      _ref.invalidate(p);
    }
    AppLogger.info('deletion.completed');
  }
}

final dataDeletionServiceProvider = Provider((ref) => DataDeletionService(ref));
