import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/daily_log.dart';

class DailyLogRepository {
  DailyLogRepository(this._store);
  final KeyValueStore _store;

  Map<String, DailyLog> all() => {
    for (final log in [for (final json in _store.readAll().values) ?DailyLog.fromJson(json)]) log.key: log,
  };

  Future<void> save(DailyLog log) => log.isEmpty ? _store.delete(log.key) : _store.write(log.key, log.toJson());
  Future<void> delete(String key) => _store.delete(key);
  Future<void> deleteAll() => _store.clear();
}

final dailyLogRepositoryProvider = Provider<DailyLogRepository>(
  (ref) => DailyLogRepository(ref.watch(appStorageProvider).store(StoreName.checkIns)),
);
