import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/habit.dart';

class HabitRepository {
  HabitRepository(this._habits, this._completions);
  final KeyValueStore _habits;
  final KeyValueStore _completions;

  List<Habit> habits() =>
      [for (final json in _habits.readAll().values) ?Habit.fromJson(json)]
        ..sort((a, b) => a.startDate.compareTo(b.startDate));

  Set<String> completions() => _completions.readAll().keys.toSet();

  Future<void> saveHabit(Habit h) => _habits.write(h.id, h.toJson());

  Future<void> deleteHabit(String id) async {
    await _habits.delete(id);
    await _completions.deleteAll(completions().where((k) => k.startsWith('$id|')));
  }

  Future<void> setCompleted(String key, bool done) =>
      done ? _completions.write(key, {'_v': 1}) : _completions.delete(key);

  Future<void> deleteAll() async {
    await _habits.clear();
    await _completions.clear();
  }
}

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final storage = ref.watch(appStorageProvider);
  return HabitRepository(storage.store(StoreName.habits), storage.store(StoreName.habitCompletions));
});
