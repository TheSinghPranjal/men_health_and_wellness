import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/reminder.dart';

class ReminderRepository {
  ReminderRepository(this._store);
  final KeyValueStore _store;
  static const _key = 'wellness';

  WellnessReminder load() {
    final json = _store.read(_key);
    return json == null ? const WellnessReminder() : WellnessReminder.fromJson(json);
  }

  Future<void> save(WellnessReminder r) => _store.write(_key, r.toJson());
  Future<void> clear() => _store.clear();
}

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepository(ref.watch(appStorageProvider).store(StoreName.reminders)),
);
