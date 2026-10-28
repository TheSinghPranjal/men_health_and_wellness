import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/key_value_store.dart';
import '../../../core/storage/storage_providers.dart';
import '../domain/reflection.dart';

/// Stores reflection sessions the user explicitly chose to save.
class ReflectionRepository {
  ReflectionRepository(this._store);
  final KeyValueStore _store;

  List<ReflectionSession> all() {
    final sessions = [for (final json in _store.readAll().values) ?ReflectionSession.fromJson(json)]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sessions;
  }

  Future<void> save(ReflectionSession session) => _store.write(session.id, session.toJson());
  Future<void> delete(String id) => _store.delete(id);
  Future<void> deleteAll() => _store.clear();
}

final reflectionRepositoryProvider = Provider<ReflectionRepository>(
  (ref) => ReflectionRepository(ref.watch(appStorageProvider).store(StoreName.reflections)),
);
