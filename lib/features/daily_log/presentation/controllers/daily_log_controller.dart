import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../../../core/utils/dates.dart';
import '../../data/daily_log_repository.dart';
import '../../domain/daily_log.dart';

/// All daily logs keyed by day key.
class DailyLogController extends Notifier<Map<String, DailyLog>> {
  @override
  Map<String, DailyLog> build() => ref.watch(dailyLogRepositoryProvider).all();

  DailyLog forDay(DateTime day) => state[Dates.key(day)] ?? DailyLog(day: Dates.dayOf(day));

  Future<void> save(DailyLog log) async {
    await ref.read(dailyLogRepositoryProvider).save(log);
    final next = {...state};
    log.isEmpty ? next.remove(log.key) : next[log.key] = log;
    state = next;
  }

  Future<void> addRelaxationSession() {
    final today = forDay(ref.read(clockProvider)());
    return save(today.copyWith(relaxationSessions: today.relaxationSessions + 1));
  }

  Future<void> delete(String key) async {
    await ref.read(dailyLogRepositoryProvider).delete(key);
    state = {...state}..remove(key);
  }

  Future<void> deleteAll() async {
    await ref.read(dailyLogRepositoryProvider).deleteAll();
    state = const {};
  }
}

final dailyLogProvider = NotifierProvider<DailyLogController, Map<String, DailyLog>>(DailyLogController.new);

/// Logs sorted newest first, for history lists.
final sortedDailyLogsProvider = Provider<List<DailyLog>>((ref) {
  final logs = ref.watch(dailyLogProvider).values.toList()..sort((a, b) => b.day.compareTo(a.day));
  return logs;
});
